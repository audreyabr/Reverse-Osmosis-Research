#Libraries
import RPi.GPIO as GPIO
import time
 
#GPIO Mode (BOARD / BCM)
GPIO.setmode(GPIO.BCM)
 
#set GPIO Pins for Ultrasonic Sensor
GPIO_TRIGGER = 21 
GPIO_ECHO = 20

#setup Relay Pins for Feed Valve
GPIO.setup(12,GPIO.OUT)
GPIO.output(12,GPIO.HIGH) # relay is OFF initially

#setup Relay Pins for Brine Valve
GPIO.setup(16,GPIO.OUT)
GPIO.output(16,GPIO.HIGH) # relay is OFF initially

#set GPIO direction (IN / OUT)
GPIO.setup(GPIO_TRIGGER, GPIO.OUT)
GPIO.setup(GPIO_ECHO, GPIO.IN)
 
distance_list = [] 
 
def distance():
    
    '''
    Ultrasonic Sensor Code to calculate distances and store
    them into a list
    
    Returns:
        A list of measured distances from the ultrasonic sensor
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
 
    distance_list.append(current_distance)
    
    return distance_list
 

empty_tank_dist = 28 #(centimeters) this is from the top of the tank to the top of the
                     # drainage square 

def feed_valve(distance_list):
    '''
    If distance is greater than empty tank distance, open the feed valve.
    To make it less finicky, it averages a certain number of last distance
    measurements taken before making the decision to open the feed valve.
    
    Args:
        distance_list: A list of measured batch tank distances from the ultrasonic sensor
        
    Returns:
        last_num_average: An integer representing the averaged batch tank distance
                            with number of elements specified by num_average_elements
    '''
    
    num_average_elements = 10 # average last 10 distance values
    
    last_num_average = sum(distance_list[-num_average_elements:])/len(distance_list[-num_average_elements:])
    
    if last_num_average >= empty_tank_dist:
        
        GPIO.output(12,GPIO.LOW) # relay is ON, so valve is open
        print("Feed valve is open")
        time.sleep(0.1)
        return last_num_average
    
    else:
        GPIO.output(12,GPIO.HIGH) # relay is OFF, so valve is closed

        print("Feed valve is closed")
        return last_num_average
    
    
def brine_flushing(conductivity_list, last_num_average):
    '''
    If conductivity is greater than 20 micro Siemens, open the brine valve
    and flush the water out.
    
    Args:
        conductivity_list: A list of measured conductivities
        last_num_average: An integer representing the averaged
                            distance value of the batch tank
    
    Returns:
        nothing? 
    '''
    max_conductivity = 20
    
    conductivity_check = 0 # can either be 1 or 0 depending if the conductivity was checked
    
    GPIO.output(12,GPIO.HIGH) # Feed valve is closed initially
    print("Feed valve is closed")
    GPIO.output(16,GPIO.HIGH) # Brine valve is closed initially 
    print("Brine valve is closed")
    GPIO.output(13,GPIO.HIGH) # Batch Tank valve is open initially 
    print("Batch tank valve is open")
    
    #while last_num_average <= empty_tank_dist: # while batch tank isn't empty 
        
    if conductivity_list[-1] >= max_conductivity and conductivity_check == 0:
        # if conductivity is too high and we haven't checked conductivity yet
           
        print("Salinity is too high. Flushing time!")
        conductivity_check += 1
            
        GPIO.output(16,GPIO.LOW) # Open Brine Valve
        print("Brine valve is open")
        
        GPIO.output(13,GPIO.LOW) # Close Batch Tank valve
        print("Batch tank valve is closed")
        time.sleep(30) # SPECIFY HOW LONG TO FLUSH BRINE OUT
            
        
        
    elif last_num_average >= empty_tank_dist: # if batch tank is empty
        
        GPIO.output(12,GPIO.LOW) # Open Feed valve 
        print("Feed valve is open")
        GPIO.output(16,GPIO.LOW) # Open Brine valve
        print("Brine valve is open")
        GPIO.output(13,GPIO.LOW) # Close Batch Tank valve
        print("Batch tank valve is closed")
        
        time.sleep(30) # SPECIFY HOW LONG TO FLUSH WITH NEW FEEDWATER
        
        GPIO.output(12,GPIO.HIGH) # Close Feed valve
        print("Feed valve is closed")
        GPIO.output(16,GPIO.HIGH) # Close Brine valve
        print("Brine valve is closed")
        GPIO.output(13,GPIO.HIGH) # Open Batch Tank valve
        print("Batch tank valve is open")
 
if __name__ == '__main__':
    try:
        while True:
            dist = distance()
            feed_valve(dist)
            print ("Measured Distance = %.1f cm" % dist[-1])
            time.sleep(0.1)
            brine_flushing #TBDDDDD REPLACE LATER
                
        # Reset by pressing CTRL + C
    except KeyboardInterrupt:
        print("Measurement stopped by User")
        
    finally:     
        GPIO.cleanup()

