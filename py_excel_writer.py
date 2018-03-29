from __future__ import print_function
import xlsxwriter
import xml.dom
import sys

if len(sys.argv) < 2:
    print("\nNo files were specified on the command line.\n"
    + "Usage: python_excel_writer.py infile.nessus outfile.xlsx\n"
    + "Quitting....\n")
    exit()
elif ".nessus" not in sys.argv[1]:
    print("\nYour input filename did not contain a valid .nessus extension\n"
    + "Usage: python_excel_writer.py infile.nessus outfile.xlsx\n"
    + "Quitting....\n")
    exit()
elif ".xlsx" not in sys.argv[2]:
    print("\nYour output filename did not contain a valid .xlsx extension\n"
    + "Usage: python_excel_writer.py infile.nessus outfile.xlsx\n"
    + "Quitting....\n")
    exit()

#friendly naming for sys args
input_file = sys.argv[1]
output_file = sys.argv[2]
#print ("The arguments are: " + str(sys.argv))

workbook = xlsxwriter.Workbook('hello.xlsx')
worksheet = workbook.add_worksheet()


#worksheet.write('A1', 'Hello world')
#workbook.close()