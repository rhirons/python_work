# Simple script to batch convert video files in ffmpeg using Nvidia hardware decoding & encoding.
# Script will process all video files found in a folder called batch in the current directory
# of the python script.

# Video will be converted to h264 mkv file. Change to suit your needs.
# The audio stream of the file will not be touched and simply copied.
# Ross H - 2018
from __future__ import print_function
import subprocess
import platform
from os import getcwd, listdir
from os.path import isfile, join, split

# Can use raw string to hold the dir path or use os.path.join to normalise input. 
# Forward slashes work in windows and works across Osx/linux.
# Decided to user getcwd so you don't need to replace the path for every system..
# just need to ensure files to convert are in a folder called batch in the dir of the python file.
#userpath = r"E:/iCloudDrive/python_work/batch/"
#userpath = join("E:/iCloudDrive/python_work/batch/")
which_os = platform.system()
filename = []
if which_os == "Windows":
    userpath = getcwd() + "\\batch\\"
else:
    userpath = getcwd() + "/batch/"


# Loops through "userpath" using os.listdir and if any files are found (isfile), the name is placed into list variable "filename". 
filename = [x for x in listdir(userpath) if isfile(join(userpath, x))]

# Combine path (userpath) to file name (filename) into a list (fullpath)
fullpath = []
for f in filename:
    fullpath.append(userpath + f)

#Prints which OS user is running using platform.system()
if which_os == "Windows":
    print("\nOS Type is: " + which_os + " - Nvidia GPU encoding & decoding will be used\n")
else:
    print("\nOS Type is: " + which_os + " - CPU encoding & decoding will be used\n")


if len(fullpath) == 0:
    print ("There are no files in the batch folder. Nothing to do. Quitting....")
    exit()

# Asks user if they want to convert sequentially or in parallel. 
# Will determine the subprocess command further down
print ("Encoding multiple files is ONLY recomendeded when using the GPU") 
user_choice = raw_input("Do you want to convert one video at a time? Y/N: ")
user_choice = user_choice.upper()

if user_choice != "Y" and user_choice != "N":
    print("Choice is Y or N! Quitting...\n")
    exit()

print ("\n" + "=====================")
print ("Files to convert are:")
print ("=====================")

# This shows the user the list of files that will be converted. 
print(len(fullpath))
for f in filename:
    print (f)
print ("\n")

# This constructs the ffmpeg command that will be passed to the windows shell. 
# Using os.path.split to seperate the path and filename, Subprocess to execute the command
# String.split used to remove the file extension as we want to append all output file as mkv
for x in fullpath:
    remove_extension = split(x)[1]
    remove_extension = remove_extension.split('.')[0]
    cmd = "ffmpeg.exe -hide_banner -hwaccel nvdec -i " + x + " -c:v h264_nvenc -preset:v slow -profile:v high -level:v 5.1 -tier:v main -cbr 0 -b:v 3.5M -maxrate:v 5M -minrate:v 3K -c:a copy " + split(x)[0]
    if which_os == "Windows":
        cmd = cmd + "\\converted_" + remove_extension + ".mkv"
    else:
        cmd = cmd + "/converted_" + remove_extension + ".mkv"

    print(cmd + "\n")
    
    #Un-comment the below line when you're ready to convert. I've commented it out for now as I'm still making changes.
    #Use subprocess.call if you want to convert one by one.
    #Use subprocess.Popen if you want to convert everything at once.
    #subprocess.call(cmd, shell=True)
    #subprocess.Popen(cmd, shell=True,stdin=None, stdout=None, stderr=Noyne, close_fds=True)
