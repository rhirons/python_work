"""
Simple script to batch convert video files in ffmpeg using Nvidia hardware decoding & encoding.
Script will search and process video files found in a folder called batch in the directory
of the python script.
"""
# Video will be converted to h265 mkv file. Change to suit your needs.
# The audio stream of the file will not be touched and simply copied.
# Ross H - 2018
from __future__ import print_function
import subprocess
import platform
from os import getcwd, listdir, rename
from os.path import isfile, join, split

# Can use raw string to hold the dir path or use os.path.join to normalise input.
# Forward slashes work in windows and works across Osx/linux.
# Decided to user getcwd so you don't need to replace the path for every system..
# Ensure files to convert are in a folder called batch in the same dir of the python script.
which_os = platform.system()
filename = []
fullpath = []
if which_os == "Windows":
    userpath = getcwd() + "\\batch\\"
else:
    userpath = getcwd() + "/batch/"

# Loops through "userpath" using os.listdir and if any files are found (isfile),
# the name is placed into list "filename"
filename = [x for x in listdir(userpath) if isfile(join(userpath, x))]
# Combine path (userpath) to file name (filename) into a newlist (fullpath)
for f in filename:
    fullpath.append(userpath + f)
#Renames the files in the batch folder to remove any spaces in the filename
for f in fullpath:
    rename(f, f.replace(' ', '.').lower())

#Re-runs the original command to get an updated list of files that may have been renamed
filename = [x for x in listdir(userpath) if isfile(join(userpath, x))]
fullpath = []
for f in filename:
    fullpath.append(userpath + f)

#Prints which OS user is running using platform.system()
if which_os == "Windows":
    print("\nOS Type is: " + which_os + " - Nvidia GPU encoding & decoding will be used\n")
else:
    print("\nOS Type is: " + which_os + " - CPU encoding & decoding will be used\n")

if len(fullpath) <= 0:
    print ("There are no files in the batch folder. Nothing to do. Quitting....")
    exit()

print ("\n" + "=====================")
print ("Files to convert are:")
print ("=====================")

# This shows the user the list of files that will be converted.
print("Number of files: " + str(len(fullpath)))
for f in filename:
    print (f)
print ("\n")

raw_input('Press ENTER to continue')

# This constructs the ffmpeg command that will be passed to the windows shell.
# Using os.path.split to seperate the path and filename, Subprocess to execute the command
# String.split used to remove the file extension as we want to append all output file as mkv
for x in fullpath:
    #Uses os.path.split to chop full path/filname into just a filename
    remove_extension = split(x)[1]
    #Uses string split to take off .mkv extension. Could also use "re" lib to use regex to take of
    #mutiple type of extensions.
    remove_extension = remove_extension.split('.mkv')[0]

    cmd = "ffmpeg.exe -hide_banner -hwaccel nvdec -i " + x + " -c:v hevc_nvenc -profile:v main -preset slow -rc vbr_hq -b:v 6M -maxrate:v 15M -c:a copy " + split(x)[0]

    if which_os == "Windows":
        cmd = cmd + "\\converted." + remove_extension + ".mkv"
    else:
        cmd = cmd + "/converted." + remove_extension + ".mkv"

    print("\n" + cmd + "\n")
    raw_input('Press ENTER to continue')
    #Use subprocess.call if you want to convert one by one.
    #Use subprocess.Popen if you want to convert everything at once.
    #subprocess.call(cmd, shell=True)
