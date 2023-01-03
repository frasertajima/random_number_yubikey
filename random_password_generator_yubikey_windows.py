# high quality random password generator using Yubikey hardware
# https://forum.yubico.com/viewtopic07a2.html?p-7040 has the formatting commands to convert bytes to numbers
# you can change the length of the random numbers from 100 to bigger or smaller numbers
# I modified the number generator to create a high quality password generator with letters and symbols
# tested strength by copying some passwords to enpass and the program seems to think they are strong passwords
# this program uses the command line 'gpg-connect-agent "scd random 100"' command to generate random bytes using the yubikey
# it then formats these bytes into characters from 0-z using the redirect "| tr -dc 0-z | xargs" 

import subprocess
import csv 
rand_list = []
total_random_numbers = 100
num = 0

print ("Below please find {} random passwords generated. Select one to use and copy to your password manager.".format(total_random_numbers))
print ("------------------------------------------------------------------------------")
print (" ")
while num < total_random_numbers:
    output = subprocess.check_output('gpg-connect-agent "scd random 128" /bye | wsl tr -dc 0-z | wsl xargs', shell=True)
    if output == b'\n':
        output = b'0\n'                                 # when scd random is 10 or another low number, blank numbers come up!
    output = str(output)
    output = output.replace("b'D",'',1)                 # clean up formating to remove binary
    output = output.replace("\\n'", '')                 # clean up formatting to remove /n newline 
    rand_list.append(output)
    num += 1
    print (output)

# for security, maybe it is better NOT to save any random passwords in open text on a filesystem
# instead, generate say 100 random passwords, pick one of them at random, copy and paste into your password manager
# and where you want to use the password!

#with open('random_passwords_yubikey_generated.csv', 'w') as f:
#    write = csv.writer(f)
#    write.writerows(map(lambda x: [x], rand_list))

#print("saved file to random_passwords_yubikey_generated.csv")
