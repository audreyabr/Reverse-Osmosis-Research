#Libraries
import RPi.GPIO as GPIO
import time
 
#GPIO Mode (BOARD / BCM)
GPIO.setmode(GPIO.BCM)
 
#set GPIO Pins
GPIO_TRIGGER = 21
GPIO_ECHO = 20

#setup Relay Pins for Feed Valve
GPIO.setup(12,GPIO.OUT)
GPIO.output(12,GPIO.HIGH) # relay is OFF initially

#setup Relay Pins for Brine Valve
GPIO.setup(16,GPIO.OUT)
GPIO.output(16,GPIO.LOW) # relay is ON initially

#setup Relay Pins for Batch Valve
GPIO.setup(13,GPIO.OUT)
GPIO.output(13,GPIO.LOW) # relay is ON initially

#set GPIO direction (IN / OUT)
GPIO.setup(GPIO_TRIGGER, GPIO.OUT)
GPIO.setup(GPIO_ECHO, GPIO.IN)
 
distance_list = [] 
 
def distance():
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
 

def feed_valve(distance_list):
    '''
    If distance is greater than 20 cm, open the feed valve
    '''
    empty_tank_dist = 26
    
    num_average_elements = 10 # average last 10 distance values
    
    last_num_average = sum(distance_list[-num_average_elements:])/len(distance_list[-num_average_elements:])
    
    if last_num_average >= empty_tank_dist:
        
        GPIO.output(12,GPIO.LOW) # relay is ON, so valve is open
        GPIO.output(13,GPIO.HIGH) # relay is OFF, so valve is closed
        GPIO.output(16,GPIO.HIGH) # relay is OFF, so valve is open
        print("Feed valve is open")
        print("Brine valve is closed")
        print("Batch valve is open")
        time.sleep(0.1)
        return last_num_average
    
    else:
        GPIO.output(12,GPIO.HIGH) # relay is OFF, so valve is closed
        GPIO.output(13,GPIO.LOW) # relay is ON, so valve is open
        GPIO.output(16,GPIO.LOW) # relay is ON, so valve is closed

        print("Feed valve is closed")
        print("Brine valve is open")
        print("Batch valve is closed")
        return last_num_average
 
if __name__ == '__main__':
    try:
        while True:
            dist = distance()
            feed_valve(dist)
            print ("Measured Distance = %.1f cm" % dist[-1])
            time.sleep(0.1)
            #print(last_10_average)
            #feed_valve(dist)
            
        # Reset by pressing CTRL + C
    except KeyboardInterrupt:
        print("Measurement stopped by User")
        
    finally:     
        GPIO.cleanup()
