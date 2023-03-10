# high quality random number generator using Yubikey hardware
# works in Debian using formatting command line "| tr -dc 0-9 | xargs"
# if you want letters, change '0-9' to '0-z' and dont use int()

# https://forum.yubico.com/viewtopic07a2.html?p-7040 has the formatting commands to convert bytes to numbers
# my modification as the original had "tr -dc 0-z" while I changed it to "tr -dc 0-9" because I only wanted numbers

# you can specify the largest random number (otherwise the variation can be large)
# this generates a list of numbers in the random_numbers_yubikey_generated.csv file
# use GOOGLE sheets or Libreoffice for handling long numbers (excel truncates them!!)

# you can also modify the output to create a high quality password generator (see random_password_generator_yubikey.py)
# at the command line gpg-connect-agent "scd random 128" /bye generates random bytes of length 128
# this program takes that output and formats it into numbers only with '| tr -dc 0-9 | xargs' command in Debian

# make sure yubikey is linked with your Linux OS when running in a new VM: https://blog.programster.org/yubikey-link-with-gpg

import subprocess
import csv 
rand_list = []
total_random_numbers = 100
num = 0
maxnum = 0

print("Input number of random numbers wanted:")
total_random_numbers = input()
print("Input biggest random number wanted:")
maxnum = input()
total_random_numbers = int(total_random_numbers)
maxnum = int(maxnum)

while num < total_random_numbers:
    output = subprocess.check_output('echo "scd random 128" | gpg-connect-agent | tr -dc 0-9 | xargs', shell=True)
    if output == b'\n':
        output = b'0\n'                                 # when scd random is 10 or another low number, blank numbers come up!
    if int(output) <= maxnum:
        rand_list.append(int(output))
        num += 1
    #print ('random number:', int(output))

with open('random_numbers_yubikey_generated.csv', 'w') as f:
    write = csv.writer(f)
    write.writerows(map(lambda x: [x], rand_list))

print("saved list of random numbers to random_numbers_yubikey_generated.csv")
