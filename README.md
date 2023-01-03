# random_number_yubikey
Generate random numbers using Yubikey "SCD Random" command.

High quality random number generator using Yubikey hardware. Only works in Debian at the moment due to formatting command line commands "| tr -dc 0-9 | xargs".
If you want letters change '0-9' to '0-z' and dont use int().

https://forum.yubico.com/viewtopic07a2.html?p-7040 has the formatting commands to convert bytes to numbers.
Modification from the original "tr -dc 0-z" to "tr -dc 0-9" to generate numbers only.

This program generates a list of numbers in the "random_numbers_yubikey_generated.csv" file. Use GOOGLE sheets or Libreoffice for handling long numbers (excel truncates them).

You can also modify the output to create a high quality password generator! (see random_password_generator_yubikey.py).
At the command line gpg-connect-agent "scd random 100" /bye generates random bytes of length 100.
This program takes that output and formats it into numbers only with '| tr -dc 0-9 | xargs' command in Debian.

Make sure your yubikey is linked with your Linux OS when running in a new VM: https://blog.programster.org/yubikey-link-with-gpg.

To do:
1. looking for the Windows equivalent formatting commands 
2. getting yubikey to work with WSL elegantly (there are some hacks but...)
