program random_passwords

    use iso_fortran_env, only: int32, real64
    implicit none
    
    integer(int32), parameter                               :: total_random_numbers = 10
    integer(int32)                                          :: num, ios, i
    character(len=100)                                      :: output
    character(len=200)                                      :: command

    print '(A)', "Select one of the YubiKey generated random passwords by manually copying it to your password manager."
    print '(A)', "----------------------------------------------------------------------------------------------------------"
    print '(A)', " "
    num = 0

    do while (num < total_random_numbers)
        ! sed "s/^D //" removes the leading D created by gpg using the YubiKey
        command = 'echo "scd random 100" | gpg-connect-agent | sed "s/^D //" | tr -dc 0-z | xargs'
        call execute_command_line(command, cmdstat=ios, cmdmsg=output)
        
        if (ios /= 0) then
            print '(A,A)', "Error executing command: ", trim(output)
            stop
        end if
        
        num = num + 1
        print '(A)', trim(output)
    end do

end program random_passwords
! refactored from python to fortran with claude AI
! removed leading D from python code by refining scd command
! for security, nothing is saved to disk, just randomly select a password and copy it to your passward manager