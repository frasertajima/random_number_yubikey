# random_number_generator_yubikey
Generate high quality random numbers using Yubikey "SCD Random" command.

https://forum.yubico.com/viewtopic07a2.html?p-7040 has the formatting commands to convert bytes to numbers. Modification from the original "tr -dc 0-z" to "tr -dc 0-9" to generate numbers only.

This program generates a list of numbers in the "random_numbers_yubikey_generated.csv" file. Use GOOGLE sheets or Libreoffice for handling long numbers (excel truncates them).

You can also modify the output to create a high quality password generator (see random_password_generator_yubikey.py).

At the command line gpg-connect-agent "scd random 128" /bye generates random bytes of length 128.
This program takes that output and formats it into numbers only with '| tr -dc 0-9 | xargs' command in Debian.

Make sure your yubikey is linked with your Linux OS when running in a new VM: https://blog.programster.org/yubikey-link-with-gpg.

# random_number_generator_yubikey_windows
Modified the linux version to run in Windows. This requires WSL2 to be installed as the Windows version calls "wsl tr" given the lack of Windows version of "tr" command. File writing is slightly different in Windows and required newline="" in line 49.

The Windows version runs more slowly than the Linux version.
https://felixquinihildebet.wordpress.com/2023/01/03/generate-random-numbers-and-passwords-using-your-yubikey/

# refactored into Fortran!
See https://felixquinihildebet.wordpress.com/2024/06/28/random-number-and-password-generator-using-yubikey-in-fortran/ for a discussion.
