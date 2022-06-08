const int batch_valve_pin = 3;     // the number of the pushbutton pin
const int brine_valve_pin = 3;     // the number of the pushbutton pin


void setup() {
  // put your setup code here, to run once:
    pinMode(batch_valve_pin, OUTPUT);
//    pinMode(brine_valve_pin, OUTPUT);
    Serial.begin(9600);

}


void loop() {

  Serial.println("hello");

  while(1) {
    // put your main code here, to run repeatedly:
    digitalWrite(batch_valve_pin, HIGH);
    Serial.println("1");
    delay(5000);
  
  
  //  digitalWrite(brine_valve_pin, HIGH);
  
  //  delay(5000);
  
     digitalWrite(batch_valve_pin, LOW);
     Serial.println("2");
    delay(5000);
  
  
    Serial.println("3");
  }
}
