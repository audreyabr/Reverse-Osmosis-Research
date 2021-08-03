#Libraries
import RPi.GPIO as GPIO
import statistics
import time
import csv 
import serial
from datetime import datetime 
import os
import pathlib

############ READ ME: IMPORTANT INFO #####################

# To stop data collection, you must do Ctrl + c  (KeyboardInterrupt)
# to actually record the data. Don't click the stop button or nothing will be writted in csv.

# Data will be written in the folder CSV_data and a new file would be added every time

# The scale should be plugged into the bottom left USB port of the Pi if you look at it from the front

# Make sure that the conductivity transmitter and digital flowmeter are plugged into power and turned on 

# For some reason this code doesn't work if you run it in terminal so just run it in Thonny 
#################################################

#set GPIO Pins for Ultrasonic Sensor
GPIO_TRIGGER = 21 
GPIO_ECHO = 20

#setup Voltmeter Pins for Conductivity Sensor
AO_pin = 0 #flame sensor AO connected to ADC channel 0
# change these as desired - they're the pins connected from the
# SPI port on the ADC to the Cobbler
SPICLK = 11
SPIMISO = 9
SPIMOSI = 10
SPICS = 8

#setup Voltmeter 2 Pins for Digital Flowmeter
AO_pin_2 = 0  # what is this?
SPICLK_2 = 22
SPIMISO_2 = 27
SPIMOSI_2 = 17
SPICS_2 = 24

def init_serial():
    global ser

    #writing C, P, LF (\n)
    #1 == 1
    #C = 67, P = 80, \n = 10
    init_message = [49, 80, 10]

    ser = serial.Serial(port='/dev/ttyUSB0', baudrate=9600,
                         parity=serial.PARITY_NONE,
                          stopbits=serial.STOPBITS_TWO,
                           bytesize=serial.EIGHTBITS,
                            timeout=0)

    ser.write(init_message)
    
def init():
    GPIO.setwarnings(False)
    GPIO.setmode(GPIO.BCM)
    # set up the SPI interface pins for Voltmeter
    GPIO.setup(SPIMOSI, GPIO.OUT)
    GPIO.setup(SPIMISO, GPIO.IN)
    GPIO.setup(SPICLK, GPIO.OUT)
    GPIO.setup(SPICS, GPIO.OUT)
    
    # set up the SPI interface pins for Voltmeter 2
    GPIO.setup(SPIMOSI_2, GPIO.OUT)
    GPIO.setup(SPIMISO_2, GPIO.IN)
    GPIO.setup(SPICLK_2, GPIO.OUT)
    GPIO.setup(SPICS_2, GPIO.OUT)
          
    #set GPIO ultrasonic direction (IN / OUT)
    GPIO.setup(GPIO_TRIGGER, GPIO.OUT)
    GPIO.setup(GPIO_ECHO, GPIO.IN)
          
    #setup Relay Pins for Feed Valve
    GPIO.setup(12,GPIO.OUT)
    GPIO.output(12,GPIO.HIGH) # relay is OFF initially

    #setup Relay Pins for Brine Valve
    GPIO.setup(16,GPIO.OUT)
    GPIO.output(16,GPIO.HIGH) # relay is OFF initially

    #setup Relay Pins for Batch Valve
    GPIO.setup(13,GPIO.OUT)
    GPIO.output(13,GPIO.HIGH) # relay is OFF initially
    pass


# CONSTANTS --------------------------------

empty_tank_dist = 26  # cm, top of the tank to the top of the drainage square with some extra room 
full_tank_dist = 22  # cm  (CHANGE LATER?)

time_step = 0.50 # seconds (this is not actually the real time step between data points)
num_average_elements = 1  # average last 1 distance values
took_scale_data = 0 # this helps with the scale data collecting

# LIST SETUP ----------------------------------------
rows = []
time_list = []
permeate_mass_list = []
distance_list = []
current_distance_list = []
conductivity_list = []
flowrate_list = []
raw_distance_list = [10,10,10,10] # arbitrary values to get the standard dev. thing to work

# feed_conductivity = 10 # mS/cm

# FUNCTIONS -----------------------------------------

def scale_reading():
    '''
    Reads scale data and adds it to permeate_mass_list
    '''
    init_serial()
    data = ''
    units = ''
    took_scale_data = 0
    
    while took_scale_data == 0:
        c = ser.read()
        if c:
            char = str(c)
            char = char[-2]
            if char == 'r' or char == 'n': # if the scale data is readable
     
                if data == '': 
                    continue
                else:
                    
                    data = data.replace(" ","")
                    for i in data:
                        if i.isalpha():
                            units += i
                            data = data.replace(i,"") # replaces any letters in data (like g)
                        elif i == '?':
                            data = data.replace(i,"")
                     
                    print(" Permeate mass =" ,data,"g")
                    if(data == ''):
                        continue
                    else:
                        permeate_mass_list.append(data) 
                        took_scale_data = 1
                
                    data = ''
                    stable = 1
                    units = ''

            else:
                data += char
    ser.close()


def readadc(adcnum, clockpin, mosipin, misopin, cspin):
    '''
    Setting up the voltmeter with the ADC 
    '''
    if ((adcnum > 7) or (adcnum < 0)):
        return -1
    GPIO.output(cspin, True)  

    GPIO.output(clockpin, False)  # start clock low
    GPIO.output(cspin, False)     # bring CS low

    commandout = adcnum
    commandout |= 0x18  # start bit + single-ended bit
    commandout <<= 3    # we only need to send 5 bits here
    for i in range(5):
        if (commandout & 0x80):
            GPIO.output(mosipin, True)
        else:
            GPIO.output(mosipin, False)
        commandout <<= 1
        GPIO.output(clockpin, True)
        GPIO.output(clockpin, False)

    adcout = 0
    for i in range(12):
        GPIO.output(clockpin, True)
        GPIO.output(clockpin, False)
        adcout <<= 1
        if (GPIO.input(misopin)):
            adcout |= 0x1

    GPIO.output(cspin, True)
        
    adcout >>= 1   
    return adcout
    
def distance():
    '''
    Ultrasonic Sensor Code to calculate distances and smooths out the readings from weird outliers.
    
    It filters out distances that are not within the standard deviation of the last 5 distances
    from the mean. It replaces it with value of the mean of the last 3 previous accepted distances. 
    
    Returns:
        new_distance: An integer representing the current distance 
   
    '''
    # set Trigger to HIGH
    GPIO.output(GPIO_TRIGGER, True)
 
    # set Trigger after 0.01ms to LOW
    time.sleep(0.00001)
    GPIO.output(GPIO_TRIGGER, False)
 
    StartTime = time.time()
    StopTime = time.time()
 
    # save StartTime
    while GPIO.input(GPIO_ECHO) == 0:
        StartTime = time.time()
 
    # save time of arrival
    while GPIO.input(GPIO_ECHO) == 1:
        StopTime = time.time()
 
    # time difference between start and arrival
    TimeElapsed = StopTime - StartTime
    # multiply with the sonic speed (34300 cm/s)
    # and divide by 2, because there and back
    current_distance = (TimeElapsed * 34300) / 2
  #  print("current distance is ",current_distance)
 
    raw_distance_list.append(int(current_distance))
    current_distance_list.append(int(current_distance))
    
    
    if len(raw_distance_list) >= 5:
    
        distance_sample = raw_distance_list[-5:] # sample includes last 5 measurements taken
        std_dev_sample = statistics.stdev(distance_sample) # standard deviation of the last 5 digits 
        mean_sample = statistics.mean(distance_sample)
        if abs(raw_distance_list[-1] - mean_sample) <= std_dev_sample:
            # if the distance is within the standard deviation of the sample from the mean
            new_distance = raw_distance_list[-1]
            return new_distance
        
        else:
            # remove element from the sample return the mean of the remaining 3 
            distance_sample.remove(raw_distance_list[-1])
            new_distance = (statistics.mean(raw_distance_list[-5:-2])) 
            return new_distance


def check_tank_empty(last_distance):
    '''
    Checks whether the batch tank is empty.
    
    Args:
        last_distance: A integer representing the average measured distance
        from the ultrasonic sensor
        
    Returns:
        tank_is_empty: Either True or False if the batch tank is empty 
        
    '''
    tank_is_empty = False
    if last_distance >= empty_tank_dist: # if tank is empty 
        
        tank_is_empty = True
        print("TANK IS EMPTY")

    return tank_is_empty
    
def check_tank_full(last_distance):
    '''
    Checks if the batch tank is full. 
    
    Args:
        last_num_average: An integer representing the averaged batch tank distance
                            with number of elements specified by num_average_elements
                            
    Returns:
        tank_is_full: Either True or False if the batch tank is full 

    '''
    tank_is_full = False

    if last_distance <= full_tank_dist: # if tank is full
    
        print("TANK IS FULL")
        tank_is_full = True

    return tank_is_full


def conductivity_reading():
    '''
    Measures the voltage from the conductivity transmitter
    and converts it to a conductivity reading (mS). Also adds these readings
    to a list.
    
    Returns:
        conductivity: an integer representing the current conductivity in mS
        conductivity_list: a list of conductivity measurements 
    '''
    
    # Voltmeter
    ad_value = readadc(AO_pin, SPICLK, SPIMOSI, SPIMISO, SPICS)
    voltage = ad_value*(3.3/1024)*5
    print (" Voltage 1 is: " + str("%.2f"%voltage)+"V")
    
    R = 604 # ohms
    K = 100 # constant set by the manufacturer
    
    conductivity = ((2000 * voltage)/(16*0.001*R*K)) - ((4*2000)/(K*16))
    print(" Conductivity: " + str("%.2f"%conductivity)+"mS")
    
    conductivity_list.append(conductivity)
    
    return conductivity_list, conductivity 

def time_readings(time_now):
    '''
    Takes the current time and adds it to a list. 
    
    Args:
        current_time: An integer representing the current time in seconds
    Returns:
        time_list: A list of recorded times
    '''
    time_list.append(time_now)
    return time_list

def flowrate_reading():
    
    '''
    Measures the voltage from the Digital Flowmeter
    and converts it to a flow rate reading. Also adds these readings
    to a list.
    
    Returns:
        flowrate: an integer representing the current flowrate 
        flowrate_list : a list of flowrate measurements
    '''
    # Voltmeter 2
    ad_value = readadc(AO_pin_2, SPICLK_2, SPIMOSI_2, SPIMISO_2, SPICS_2)
    voltage = ad_value*(3.3/1024)*5
    print (" Voltage 2 is: " + str("%.2f"%voltage)+"V")
    
    flowrate = voltage*200
    
    flowrate_list.append(flowrate)
    
    return flowrate, flowrate_list
    
def volume_step_approximation(time_step, last_flowrate, current_flowrate):
    
    '''
    Calculates the step volume of water (mL) that flowed through the pipe
    system by approximating the integral of flowrate data using the Midpoint Rule. 
    This function helps calculate whether the brine has been flushed from the system
    
    Args:
        time_step: an integer representing the time step from the last volume measurement taken
        last_flowrate: an integer representing the last flowrate measurement taken in mL/min 
        current_flowrate: an integer representing the current flowrate in mL/min
        
    Returns:
        volume_step: an integer representing the volume that flowed through
        the meter within the timestep (mL)
    '''
    
    volume_step = ((last_flowrate + current_flowrate)/2) * time_step
    
    return volume_step
    
    
# def check_salinity(conductivity_list):
#     '''
#     If conductivity of the feed water is equal to conductivity in the system
#     (flushing is done), close the brine valve and open the batch valve.
#     
#     Args:
#         conductivity_list: A list of measured conductivities
#     
#     Returns:
#         average_conductivity: An integer representing the averaged conductivity readings
#           with number of elements specified by num_average_elements
#     '''
#     average_conductivity = (sum(conductivity_list[-num_average_elements:])/
#                 len(conductivity_list[-num_average_elements:]))
#             # average conductivity value
#                 
#     if average_conductivity == feed_conductivity:
#         
#         GPIO.output(16,GPIO.HIGH) # relay is OFF, so valve is closed
#         print("Brine valve is closed")
#         GPIO.output(13,GPIO.HIGH) # relay is OFF, so valve is open
#         print("Batch tank valve is open")
#         return average_conductivity


def data_formatting(time_list, conductivity_list, current_distance_list,
                    current_flowrate_list, permeate_mass_list, time_end):
   
    '''
    Formats the raw data and compiles it into a csv file called DATA.csv.
    DATA.csv contains time, distance, conductivity, and flowrate measurments. 
    
    Args:
        conductivity list: a list of measured conductivites taken every time step
        current_distance_list: a list of ultrasonic sensor distances taken every time step
        current_flowrate_list: a list of measured flowrates taken every time step
    '''
    
    # Makes sure that the lists are equal size
    
    if ((len(time_list) + len(conductivity_list) + len(current_distance_list)
        + len(flowrate_list)+ len(permeate_mass_list))/5) != 1:
                    
        if (len(time_list) < len(conductivity_list) and
            len(time_list) < len(current_distance_list)):
            time_list.append(time_end)
                
        if (len(permeate_mass_list) < len(conductivity_list) and
            len(permeate_mass_list) < len(current_distance_list)): 
            scale_reading()
            
        if (len(conductivity_list) > len(current_distance_list) and
            len(conductivity_list) > len(flowrate_list) and
            len(conductivity_list) > len(permeate_mass_list)):
            conductivity_list.pop(-1)       
        
        print(len(time_list), len(conductivity_list), len(current_distance_list),
              len(flowrate_list), len(permeate_mass_list))
    
    headers = (['Time (seconds)',  'Conductivity (mS)', 'Measured distance (cm)',
                'Flowrate (mL/min)', 'Permeate mass (g)'])
    
    for entry in range(len(conductivity_list)):
        rows.append([time_list[entry], conductivity_list[entry], current_distance_list[entry],
                     current_flowrate_list[entry], permeate_mass_list[entry]])
    
    # WRITING TO A CSV FILE IN THE FOLDER "CSV_dara"

    date = datetime.today().strftime('%Y-%m-%d')    
# 

    try:
        os.mkdir("./CSV_data")
    except OSError as e:
        print("Directory exists")
    
    index = len(os.listdir("CSV_data"))
    filename = str(index) + '_' + date + '.csv'  

    if not os.path.exists(filename):
        with open("./CSV_data/" + filename,'w',newline='') as csvfile:
            csvwriter = csv.writer(csvfile) 
            csvwriter.writerow(headers) 
            csvwriter.writerows(rows)   


def main():
    init()
    init_serial()
    #time.sleep(2)
    while True:
       
        # Regular sensor data collecting when tank is draining
        conductivity_reading()        
        average_distance = distance()
        current_flowrate, current_flowrate_list = flowrate_reading()
        time_now = time.time() - beginning_time
        time_readings(time_now)
        scale_reading()

        tank_is_empty = check_tank_empty(average_distance)
        tank_is_full = check_tank_full(average_distance)
        print ("-----REGULAR OPERATION... DRAINING BATCH TANK-----")
        print ("Measured Distance = %.1f cm" % average_distance)
        time.sleep(time_step)
                        
        elapsed_time = 0
        brine_valve_open = 0 
      
        if tank_is_empty == True:
                   
            volume_flushed = 0
            last_flowrate = 0
            time_step_flushing = 1 # this is 1 sec on average
            print("-----TANK IS EMPTY-----")
            
            while volume_flushed < 72 and tank_is_full == False:
               #   Fill the tank and drain the brine until 72 ml has been flushed 

                
                time_then = time.time()    
                conductivity_reading()
                average_distance = distance()
                current_flowrate, current_flowrate_list = flowrate_reading()
                scale_reading()
                time_now = time.time() - beginning_time
                time_readings(time_now)
                
                added_volume = volume_step_approximation(time_step_flushing,
                                                         last_flowrate, current_flowrate)
                volume_flushed += added_volume
                print(" Volume flushed is = %.1f ml" % volume_flushed)
                last_flowrate = current_flowrate
                
                time.sleep(time_step)                    
                print("-----FLUSHING... WAITING 9 SECONDS-----")
                GPIO.output(16,GPIO.LOW) # relay is ON, so Brine valve is open
                Brine_valve_open = 1
                GPIO.output(13,GPIO.LOW) # relay is ON, so Batch valve is closed
                GPIO.output(12,GPIO.LOW) # relay is ON, so Feed valve is open
                time_step_flushing = time.time() - time_then
                
            else:
                while volume_flushed >= 72:
                # After 9 seconds of draining, close Brine valve,
                # open Batch valve and resume regular filling

                    time.sleep(time_step)
                            
                    print("-----FILLING BATCH TANK-----")
                    conductivity_reading()
                    average_distance = distance()
                    current_flowrate, current_flowrate_list = flowrate_reading()
                    time_now = time.time() - beginning_time
                    time_readings(time_now)
                    scale_reading()
 
                    tank_is_full = check_tank_full(average_distance)
                          
                    print ("Measured Distance = %.1f cm" % average_distance)
                            
                    GPIO.output(16,GPIO.HIGH) # relay is OFF, so Brine valve is closed
                    Brine_valve_open = 0

                    GPIO.output(13,GPIO.HIGH) # relay is OFF, so Batch valve is open

                    if tank_is_full == True:
                        break 
                    
            if tank_is_full == True:
                        
                # Turn the feed valve off if the tank is full
                
                GPIO.output(12,GPIO.HIGH) # relay is OFF, so Feed valve is closed
                print("-----TANK IS FULL-----") 
                conductivity_reading()
                average_distance = distance()
                current_flowrate, current_flowrate_list = flowrate_reading()
                time_now = time.time() - beginning_time
                time_readings(time_now)
                scale_reading()
   
                if Brine_valve_open == 1: # if the Brine valve is currently open 
                            
                    print("-----FLUSHING... WAITING 9 SECONDS-----")
                    time.sleep(9)
                    conductivity_reading()
                    average_distance = distance()                       
                    current_flowrate, current_flowrate_list = flowrate_reading()
                    time_now = time.time() - beginning_time
                    time_readings(time_now)
                    scale_reading()
                
                    GPIO.output(16,GPIO.HIGH) # relay is OFF, so Brine valve is closed
                    Brine_valve_open = 0
                            
                    GPIO.output(13,GPIO.HIGH) # relay is OFF, so Batch valve is open
                    Brine_valve_open = 0            


if __name__ == '__main__':
    try:
        beginning_time = time.time()
        main()         
    except KeyboardInterrupt: # Stop measurements by pressing CTRL + C and also write data to csv
        time_end = time.time() - beginning_time 
        
        print("-----Measurement stopped!-----")
        
        data_formatting(time_list, conductivity_list,current_distance_list,
                        flowrate_list, permeate_mass_list, time_end)

    finally:     
        GPIO.cleanup()
 



