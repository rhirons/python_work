Collection of scripts to help me learn (mainly) python. I decided to learn by solving problems I have on a day to day basis rather than going page by page through various books.

Please note: These scripts are in no way polished. They're very much a WIP. Use at your own risk ;)

# Python scripting

-py_encode.py-

Simple script to batch convert video files in ffmpeg using the Nvidia hardware decoding & encoding libraries. The script will process all video files in a folder called batch and convert to h264 mkv files. The audio stream of the file will not be touched and simply copied.

-py_excel_writer.py-

A python script to take in an XML based .nessus file and convert it to an .xlsx spreadsheet for easier viewing/filtering. WIP. Based off a similar script a colleague made in Perl. I use this script every day and thought it would be a good as part of my Python learning.

# Bash scripting

-vlan config script-

My day to day job requires me to setup various virtual network interfaces which are tied to different VLANs. The setup changes too often for it to be worth statically configuring these interfaces in /etc/sysconfig/network-scripts/. Problem: The configs are not persistent. If the server crashes or has to be rebooted (usually for a kernel update), all the interfaces are wiped. 

The bash script simply takes a dump of all existing VLAN interfaces (including any static) and places them in a backup file. Once the server has been rebooted, this file is then fed back into the script where it's used to construct a set of "ip" commands which will restore all of the interfaces and static routes. "ip" has a handy batch option (-b) which lets you feed it in a file with pre-constructed commands. 
