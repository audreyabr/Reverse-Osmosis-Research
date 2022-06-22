const int batch_valve_pin = 4;     // the number of the pushbutton pin
const int brine_valve_pin = 3;     // the number of the pushbutton pin
const int feed_valve_pin = 5;



void setup() {
  // put your setup code here, to run once:
  pinMode(batch_valve_pin, OUTPUT);
  pinMode(brine_valve_pin, OUTPUT);
  pinMode(feed_valve_pin, OUTPUT);

  Serial.begin(9600);
  Serial.println("setup");

}

void loop() {

  Serial.println("loop start");

  while (1) {
    // put your main code here, to run repeatedly:
    digitalWrite(brine_valve_pin, HIGH);
    Serial.println("1 high ");
    delay(1000);

    digitalWrite(batch_valve_pin, HIGH);
    Serial.println("2 high");
    delay(1000);
    
    digitalWrite(feed_valve_pin, HIGH);
    Serial.println("3 high");
    delay(1000);
    
// break in between highs and lows

    digitalWrite(brine_valve_pin, LOW);
    Serial.println("1 low ");
    delay(1000);

    digitalWrite(batch_valve_pin, LOW);
    Serial.println("2 low");
    delay(1000);
    
    digitalWrite(feed_valve_pin, LOW);
    Serial.println("3 low");
    delay(1000);


    Serial.println("loop completed");
    delay(1000);
  }
}
