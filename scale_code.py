import os
import numpy as np
import string
from pathlib import Path
import csv
import time
from datetime import datetime
import serial


# THE GREAT PUMPKIN PLOTTER

def writeCSV(file, time, data, units, stable):
    with open(file,'a',newline='') as csvfile:
      writer = csv.writer(csvfile, delimiter=',')
      writer.writerow([time, data, units, stable])

def init_serial():
    global ser

    #writing C, P, LF (\n)
    #1 == 1
    #C = 67, P = 80, \n = 10
    init_message = [49, 80, 10]

    ser = serial.Serial(port='COM2', baudrate=9600,
                         parity=serial.PARITY_NONE,
                          stopbits=serial.STOPBITS_ONE,
                           bytesize=serial.EIGHTBITS,
                            timeout=0)

    ser.write(init_message)
    #time.sleep(1)
    # for i in init_message:
    #     print(chr(i))
    #     ser.write(i)

def init():
    global filePath, csvFile, time_start

    # home = str(Path.home())
    # print(home)

    # filePath = home + '/data_fall2019'
    filePath = d'ata_fall2019'

    date = datetime.today().strftime('%Y-%m-%d')
    time_start = time.time()

    if not os.path.exists(filePath):
        os.mkdir(filePath)

    index = len(os.listdir(filePath))

    csvFile = filePath + date + '_' + str(index) + '.csv'

    if not os.path.exists(csvFile):
        open(csvFile,'w',newline='')

    writeCSV(csvFile, 'time', 'mass', 'unit', 'stable?')


init()
init_serial()


data = ''
stable = 1
units = ''
while True:

    c = ser.read()

    if c:
        char = str(c)
        char = char[-2]

        if char == 'r' or char == 'n':
            if data == '':
                continue
            else:
                time_now = time.time() - time_start

                data = data.replace(" ","")

                for i in data:
                    if i.isalpha():
                        units += i
                        data = data.replace(i,"")
                    elif i == '?':
                        stable = 0
                        data = data.replace(i,"")

                print(data)
                if(data == ''):
                    continue
                else:
                    writeCSV(csvFile, time_now, float(data), units, stable)
                data = ''
                stable = 1
                units = ''

        else:
            data += char

        # time_now = time.time() - time_start
        # for c in data:
        #     char = chr(c)
        #     print(char)
        # writeCSV(csvFile, time_now, char)


ser.close()

"""    if userInput == 'y':
        ser.write(str(time_tot), 'utf-8')*)"""