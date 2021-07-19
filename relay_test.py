import RPi.GPIO as GPIO
import time
GPIO.setmode(GPIO.BOARD)

GPIO.setup(32,GPIO.OUT)
GPIO.output(32,GPIO.HIGH) # relay is OFF initially
# GPIO.setup(36,GPIO.OUT)
# GPIO.output(36,GPIO.HIGH) # relay is OFF initially
# GPIO.setup(38,GPIO.OUT)
# GPIO.output(38,GPIO.HIGH) # relay is OFF initially

try:
        GPIO.output(32,GPIO.LOW) # relay is ON
        print("First Relay On")
        time.sleep(3)
#         GPIO.output(36,GPIO.LOW) # relay is ON
#         print("Second Relay On")
#         time.sleep(2)
#         GPIO.output(38,GPIO.LOW) # relay is ON
#         print("Third Relay On")
#         time.sleep(2)

except KeyboardInterrupt:
        print ("quit")
        
        
finally:
    
    GPIO.cleanup()
    print ("everything off")
        

