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

#setup Relay Pins for Batch Valve
GPIO.setup(13,GPIO.OUT)
GPIO.output(13,GPIO.HIGH) # relay is OFF initially

#set GPIO direction (IN / OUT)
GPIO.setup(GPIO_TRIGGER, GPIO.OUT)
GPIO.setup(GPIO_ECHO, GPIO.IN)
 
distance_list = []
empty_tank_dist = 22 # cm, this is from the top of the tank to the top of the
                     # drainage square
full_tank_dist = 5 # cm, CHANGE LATER
num_average_elements = 5 # average last 10 distance values

# test conductivity values, CHANGE LATER
conductivity_list = [10, 12, 10, 12, 15, 13, 14, 10, 11, 12, 10, 15, 12, 13, 15, 10] # mS/cm
#conductivity_list = [10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10] # mS/cm
feed_conductivity = 10 # mS/cm
 
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


def check_tank_empty(distance_list):
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
    last_num_average = sum(distance_list[-num_average_elements:])/len(distance_list[-num_average_elements:])
            # average distance value
    
    if last_num_average >= empty_tank_dist: # if tank is empty 
        
        GPIO.output(12,GPIO.LOW) # relay is ON, so valve is open
        print("Feed valve is open")
        GPIO.output(16,GPIO.LOW) # relay is ON, so valve is open
        print("Brine valve is open")
        GPIO.output(13,GPIO.LOW) # relay is ON, so valve is closed
        print("Batch valve is closed")
        time.sleep(0.1)
        
    return last_num_average
    
    
def check_tank_full(last_num_average):
    '''
    If distance is less than full tank distance, close the feed valve.
    Uses the average of the last ten distance readings.
    
    Args:
        last_num_average: An integer representing the averaged batch tank distance
                            with number of elements specified by num_average_elements
                            
    Returns:
    
    '''
    if last_num_average <= full_tank_dist: # if tank is empty 
        
        GPIO.output(12,GPIO.HIGH) # relay is OFF, so valve is closed
        print("Feed valve is closed") # only feed valve turns off until we get conductivity sensor
        time.sleep(0.1)
    
    

    
def check_salinity(conductivity_list):
    '''
    If conductivity of the feed water is equal to conductivity in the system
    (flushing is done), close the brine valve and open the batch valve.
    
    Args:
        conductivity_list: A list of measured conductivities
    
    Returns:
        average_conductivity: An integer representing the averaged conductivity readings
          with number of elements specified by num_average_elements
    '''
    average_conductivity = sum(conductivity_list[-num_average_elements:])/len(conductivity_list[-num_average_elements:])
            # average conductivity value
   
            
    if average_conductivity == feed_conductivity:
        
        GPIO.output(16,GPIO.HIGH) # relay is OFF, so valve is closed
        print("Brine valve is closed")
        GPIO.output(13,GPIOHIGH) # relay is OFF, so valve is open
        print("Batch tank valve is open")
        return average_conductivity
    
    # else:
        # GPIO.output(16,GPIO.LOW) # relay is ON, so valve is open
        # print("Brine valve is open")
        # GPIO.output(13,GPIO.LOW) # relay is ON, so valve is closed
        # print("Batch tank valve is closed")
        


if __name__ == '__main__':
    try:
        while True:
            dist = distance()
            check_tank_empty(dist)
            print ("Measured Distance = %.1f cm" % dist[-1])
            check_tank_full(check_tank_empty(dist))
            check_salinity(conductivity_list) # won't work until conductivity sensor is connected
            print ("Measured Distance = %.1f cm" % dist[-1])
            time.sleep(0.1)
                
        # Reset by pressing CTRL + C
    except KeyboardInterrupt:
        print("Measurement stopped by User")
        
    finally:     
        GPIO.cleanup()
 
