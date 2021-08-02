#Libraries
import RPi.GPIO as GPIO
import statistics
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
empty_tank_dist = 26  # cm, this is from the top of the tank to the top of the
                     # drainage square
full_tank_dist = 22  # cm, CHANGE LATER
num_average_elements = 1  # average last 5 distance values


# test conductivity values, CHANGE LATER
conductivity_list = [10, 12, 10, 12, 15, 13, 14, 10, 11, 12, 10, 15, 12, 13, 15, 10] # mS/cm
#conductivity_list = [10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10] # mS/cm
feed_conductivity = 10 # mS/cm
raw_distance_list = [10,10,10,10]
def distance():
    '''
    Ultrasonic Sensor Code to calculate distances and store
    them into a list
    
    Returns:
        last_num_average: A integer representing the average measured distance from the ultrasonic sensor
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
 
    raw_distance_list.append(current_distance)
    
   #last_num_average = sum(distance_list[-num_average_elements:])/len(distance_list[-num_average_elements:])
    # average distance value
    
    
    
    if len(raw_distance_list) >= 5:
    
        distance_sample = raw_distance_list[-5:] # sample includes last 4 measurements taken
      #  print(f"distance sample is {distance_sample}")
        std_dev_sample = statistics.stdev(distance_sample) # standard deviation of the last 4 digits 
      #  print(f"std is {std_dev_sample}")  
        mean_sample = statistics.mean(distance_sample)
        if abs(raw_distance_list[-1] - mean_sample) <= std_dev_sample: # if the distance is within the standard deviation of the sample from the mean
           # print("PASS: diff = ",(raw_distance_list[-1] - mean_sample)) 
            return raw_distance_list[-1]
        

        else:
            # remove element from the sample return the mean of the remaining 3 
            distance_sample.remove(raw_distance_list[-1])
            new_distance = (statistics.mean(raw_distance_list[-5:-2])) 
          #  print("FAIL : new distance is ", new_distance)
            return new_distance


def check_tank_empty(last_num_average):
    '''
    Checks whether the batch tank is empty.
    
    Args:
        last_num_average: A integer representing the average measured distance from the ultrasonic sensor
        
    Returns:
        tank_is_empty: Either True or False if the batch tank is empty 
        
    '''
    
    tank_is_empty = False
   # print(f"last_num_average is {last_num_average}")
    if last_num_average >= empty_tank_dist: # if tank is empty 
        
        tank_is_empty = True
        print("tank is empty")

    return tank_is_empty

    
    
def check_tank_full(last_num_average):
    '''
    Checks if the batch tank is full. 
    
    Args:
        last_num_average: An integer representing the averaged batch tank distance
                            with number of elements specified by num_average_elements
                            
    Returns:
        tank_is_full: Either True or False if the batch tank is full 

    '''
    tank_is_full = False

    if last_num_average <= full_tank_dist: # if tank is full
    
        print("tank is full")
        tank_is_full = True

    return tank_is_full


    
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
        GPIO.output(13,GPIO.HIGH) # relay is OFF, so valve is open
        print("Batch tank valve is open")
        return average_conductivity
    

      

if __name__ == '__main__':
    try:
        while True:
            average_distance = distance()
            tank_is_empty = check_tank_empty(average_distance)
 
            tank_is_full = check_tank_full(average_distance)
            check_salinity(conductivity_list) # won't work until conductivity sensor is connected
            print ("Measured Distance 0 = %.1f cm" % average_distance)
            time.sleep(0.7)
                    
            elapsed_time = 0
            brine_valve_open = 0 
  
            if tank_is_empty == True:
                
                start_time = time.time()
                print("tank is empty")
                
                while elapsed_time < 9 and tank_is_full == False: 
                
                #   Fill the tank and drain the brine for 9 seconds if the tank is empty 
                
                    current_time = time.time()
                    elapsed_time = current_time - start_time
                    print(elapsed_time)
                    time.sleep(0.7)                     
                  #  average_distance = distance()
                  #  tank_is_empty = check_tank_empty(average_distance)
 
                 #   tank_is_full = check_tank_full(average_distance)
                  #  check_salinity(conductivity_list) # won't work until conductivity sensor is connected
                   # print ("Measured Distance 1 = %.1f cm" % average_distance)
            
            
                    GPIO.output(16,GPIO.LOW) # relay is ON, so valve is open
                    print("Brine valve is open")
                    Brine_valve_open = 1
                    
                    GPIO.output(13,GPIO.LOW) # relay is ON, so valve is closed
                    print("Batch valve is closed")
                    GPIO.output(12,GPIO.LOW) # relay is ON, so valve is open
                    print("Feed valve is open")
                         
                else:
                    while elapsed_time >= 9:

                        time.sleep(0.7)
                       # After 9 seconds of draining, close brine valve and resume regular filling
                        
                        
                        average_distance = distance()
                       # tank_is_empty = check_tank_empty(average_distance)
                       
                        tank_is_full = check_tank_full(average_distance)
                       # check_salinity(conductivity_list) # won't work until conductivity sensor is connected
                      
                        print ("Measured Distance 2  = %.1f cm" % average_distance)
                        
                        GPIO.output(16,GPIO.HIGH) # relay is OFF, so valve is closed
                        print("Brine valve is closed")
                        Brine_valve_open = 0

                        GPIO.output(13,GPIO.HIGH) # relay is OFF, so valve is open
                        print("Batch tank valve is open")
                        
                        if tank_is_full == True:
                            break 
                
                if tank_is_full == True:
                    
   
                    GPIO.output(12,GPIO.HIGH) # relay is OFF, so valve is closed
                    print("Feed valve is closed") # only feed valve turns off until we get conductivity sensor
                    
                    if Brine_valve_open == 1:
                        
                        print("waiting 9 seconds...")
                        time.sleep(9)
                        
                        GPIO.output(16,GPIO.HIGH) # relay is OFF, so valve is closed
                        print("Brine valve is closed")
                        Brine_valve_open = 0
                        
                        GPIO.output(13,GPIO.HIGH) # relay is OFF, so valve is open
                        print("Batch tank valve is open")
                        
                        Brine_valve_open = 0
                         
        # Reset by pressing CTRL + C
    except KeyboardInterrupt:
        print("Measurement stopped by User")
        
    finally:     
        GPIO.cleanup()
 

