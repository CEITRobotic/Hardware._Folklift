void setup() {
  Serial.begin(9600);  // Set baud rate to 9600 (default for HM-05)
  Serial.println("Bluetooth module is ready...");
}

void loop() {
  if (Serial.available()) {
    char data = Serial.read();
    Serial.write(data);  // Echo the received data back
  }
}