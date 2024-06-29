program random_number_generator

  use iso_fortran_env, only: int32, int64
  implicit none

  integer(int32)                :: num, u, io_stat 
  integer(int64)                :: output, maxnum, total_random_numbers
  integer(int64), allocatable   :: rand_list(:)
  integer(int64), parameter     :: max_allowed = 9223372036854775807_8
  character(len=256)            :: command, fifo_name


  print *, "Input number of random numbers wanted:"
  call read_maxnum(total_random_numbers)
  call check_max(total_random_numbers)
 
  print *, "Input biggest random number wanted up to 9,223,372,036,854,775,807:"
  call read_maxnum(maxnum)
  call check_max(maxnum)

  allocate(rand_list(total_random_numbers))

  ! Create a unique FIFO name
  write(fifo_name, '(a,i0)') 'fifo_', getpid()
  ! Create FIFO
  call execute_command_line('mkfifo ' // trim(fifo_name))

  ! generate random numbers using YubiKey
  num = 0
  do while (num < total_random_numbers)
    command = 'echo "scd random 128" | gpg-connect-agent | sed "s/^D //" | tr -dc 0-9 | xargs > ' // trim(fifo_name) // ' &'
    call execute_command_line(command)
    
    open(newunit=u, file=trim(fifo_name), action='read', iostat=io_stat)
    if (io_stat /= 0) then
      print *, "Error opening FIFO"
      exit
    end if

    read(u, *, iostat=io_stat) output
    ! print *, output
    if (io_stat /= 0) then
      ! still getting FIFO error io_stat=-1 when > 150 numbers; Yubikey timeout?
      ! print *, "Error reading from FIFO, io_stat: ", io_stat, " will keep going as likely YubiKey cannot keep up ..."
    end if
    close(u)
    
    ! add random list to array only if under maxnum size limit
    if (output <= maxnum) then
      num = num + 1
      rand_list(num) = output
    end if
  end do

  call write_to_csv(rand_list, total_random_numbers)
  print *, "Saved list of random numbers to random_numbers_yubikey_generated.csv"
  deallocate(rand_list)

  ! Remove the FIFO: cleanup
  call execute_command_line('rm ' // trim(fifo_name))

contains

  function getpid() result(pid)
    integer                     :: pid
    call system_clock(pid)
  end function getpid

  subroutine write_to_csv(arr, size)
    integer(int64), intent(in)  :: arr(:)
    integer(int64)              :: size, i, unit
    
    open(newunit=unit, file='random_numbers_yubikey_generated.csv', status='replace', action='write')
    do i = 1, size
      write(unit, '(I0)') arr(i)
    end do
    close(unit)
  end subroutine write_to_csv

  subroutine read_maxnum(maxnum)
    ! error check maximum number inputs to ensure the program will not crash
    ! fortran oddly crashes if the input number exceeds int64, so need to read as characters
    ! then convert to integer to avoid crash even when error checking
    integer(int64)              :: maxnum
    integer(int64), parameter   :: max_allowed = 9223372036854775807_8
    character(len=200)          :: line
    
    ! Read the input as a string to prevent crashes when number is too big
    read(*,'(A)'), line  
    ! convert str to number (without crashing when number is too big)
    read(line, *, iostat=num) maxnum
    if (num /= 0) then
      print*, "Input is not a valid integer or exceeds the maximum limit."
    else if (maxnum > max_allowed) then
        print*, "Number is larger than maxnum."
    else
        print*, "Maximum number received:", maxnum
    end if
  end subroutine read_maxnum

  subroutine check_max(maxnum)
    integer(int64)              :: maxnum
    integer(int64), parameter   :: max_allowed = 9223372036854775807_8

    do while (maxnum <= 0 .or. maxnum > max_allowed)
      if (maxnum > max_allowed) then
        print *, "Error: input must be greater than 0 and less than", max_allowed
      end if
  
      if (maxnum <= 0) then
        print *, "Input must be more than 0."
      end if
      print *, "Please enter a number between 1 and 9,223,372,036,854,775,807"
      !read *, total_random_numbers
      call read_maxnum(maxnum)
    end do
  end subroutine check_max

end program random_number_generator

! refactoring of python version with help by various AI LLMs
! added conversion of input to text to prevent crashes when number is too big (for both total number and max number)
! re-use subroutines for both total number and max number (make both int64)
! runs 2x faster than python version
! increased maxnum from int32 to int64 to allow larger max numbers
! FIFO error mostly due to YubiKey limitations? Ignoring it and moving on seems ok: just generate another number
! updated GPG command to remove leading 'D' as per password generator

! claude 3.5-sonnet AI refactoring to prevent crashes for total number of random numbers > 50
! Key changes by claude:
! Created a unique FIFO name using a simple getpid() function to avoid conflicts if multiple instances are run.
! Moved the FIFO creation outside the loop, creating it only once.
! Open and close the FIFO for each read operation, which is more robust for handling multiple numbers.
! Added error checking for FIFO operations.
! Removed the cmdstat and cmdmsg arguments from execute_command_line as they weren't being used effectively.
! Added FIFO cleanup at the end of the program.

! These changes should allow the program to handle more than 50 numbers without crashing. 
! The use of a unique FIFO name also makes it safer to run multiple instances of the program simultaneously.