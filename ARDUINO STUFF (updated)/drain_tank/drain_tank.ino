const int batch_valve_pin = 4;     // the number of the pushbutton pin
const int brine_valve_pin = 3;     // the number of the pushbutton pin
const int feed_valve_pin = 5;

const int trigger_pin= 8;
const int echo_pin = 9;

long duration; // variable for the duration of sound wave travel
int distance; // variable for the distance measurement  


// ultrasonicObj = ultrasonic(a,trigger_pin, echo_pin, 'OutputFormat','double');


void setup() {
  // put your setup code here, to run once:
  pinMode(batch_valve_pin, OUTPUT);
  pinMode(brine_valve_pin, OUTPUT);
  pinMode(feed_valve_pin, OUTPUT);


  pinMode(trigger_pin, OUTPUT); // Sets the trigPin as an OUTPUT
  pinMode(echo_pin, INPUT); // Sets the echoPin as an INPUT
  
  Serial.begin(9600);
  Serial.println("setup");
}



void loop() {
  Serial.println("loop start");

// we've found that 25 is the best distance to use for the arduino code, takes it right down to the square nub of the tank
  while (distance <27.5) {
    // put your main code here, to run repeatedly:

    digitalWrite(feed_valve_pin, HIGH);
    delay(1000);
    
    digitalWrite(brine_valve_pin, LOW);
    delay(1000);

    digitalWrite(batch_valve_pin, LOW);
    delay(1000);


        Serial.println("brine and batch high");

    
    digitalWrite(trigger_pin, LOW);
    delayMicroseconds(2);
    // Sets the trigPin HIGH (ACTIVE) for 10 microseconds
    digitalWrite(trigger_pin, HIGH);
    delayMicroseconds(10);
    digitalWrite(trigger_pin, LOW);
    // Reads the echoPin, returns the sound wave travel time in microseconds
    duration = pulseIn(echo_pin, HIGH);
    // Calculating the distance
    distance = duration * 0.034 / 2; 
    
          Serial.println("take dist measurement");
          Serial.println(     distance);


//    if (distance >14.9) { 
//      break;
//    }

  }    
    digitalWrite(batch_valve_pin, HIGH);
    delay(1000);
    
    digitalWrite(brine_valve_pin, HIGH);
    delay(1000);


    Serial.println("batch and brine off");


//break;
  
}
