from __future__ import print_function
import xlsxwriter
import xml.dom
import sys

if len(sys.argv) < 2:
    print("No files were specified on the command line. Quitting...")
    exit()

input_file = sys.argv[1]
output_file = sys.argv[2]
print ("The arguments are: " + str(sys.argv))
workbook = xlsxwriter.Workbook('hello.xlsx')
worksheet = workbook.add_worksheet()


#worksheet.write('A1', 'Hello world')
workbook.close()