#include <DHT.h>

// 핀 설정
#define DHTPIN 2          // DHT11 센서 핀
#define SOIL_MOISTURE_PIN A0  // 토양습도 센서 핀
#define LDR_PIN A1        // 조도센서 핀
#define PUMP_PIN 3        // 워터펌프 제어 핀
#define LED_PIN 4         // LED 제어 핀
#define FAN_PIN 5         // 팬 제어 핀

// DHT 센서 설정
#define DHTTYPE DHT11
DHT dht(DHTPIN, DHTTYPE);

// 전역 변수
float temperature;
float humidity;
int soilMoisture;
int lightLevel;
bool pumpStatus = false;
bool ledStatus = false;
bool fanStatus = false;

void setup() {
  Serial.begin(9600);
  dht.begin();
  
  // 출력 핀 설정
  pinMode(PUMP_PIN, OUTPUT);
  pinMode(LED_PIN, OUTPUT);
  pinMode(FAN_PIN, OUTPUT);
  
  // 초기 상태 설정
  digitalWrite(PUMP_PIN, LOW);
  digitalWrite(LED_PIN, LOW);
  digitalWrite(FAN_PIN, LOW);
}

void loop() {
  // 센서 데이터 읽기
  readSensors();
  
  // 데이터 전송
  sendData();
  
  // 시리얼 명령 체크
  checkCommands();
  
  delay(2000);  // 2초 대기
}

void readSensors() {
  // DHT11 센서 읽기
  temperature = dht.readTemperature();
  humidity = dht.readHumidity();
  
  // 토양습도 센서 읽기 (0-1023를 0-100%로 변환)
  soilMoisture = map(analogRead(SOIL_MOISTURE_PIN), 0, 1023, 100, 0);
  
  // 조도센서 읽기 (0-1023를 0-100%로 변환)
  lightLevel = map(analogRead(LDR_PIN), 0, 1023, 0, 100);
}

void sendData() {
  // JSON 형식으로 데이터 전송
  Serial.print("{");
  Serial.print("\"temperature\":");
  Serial.print(temperature);
  Serial.print(",\"humidity\":");
  Serial.print(humidity);
  Serial.print(",\"soilMoisture\":");
  Serial.print(soilMoisture);
  Serial.print(",\"lightLevel\":");
  Serial.print(lightLevel);
  Serial.print(",\"pumpStatus\":");
  Serial.print(pumpStatus ? "true" : "false");
  Serial.print(",\"ledStatus\":");
  Serial.print(ledStatus ? "true" : "false");
  Serial.print(",\"fanStatus\":");
  Serial.print(fanStatus ? "true" : "false");
  Serial.println("}");
}

void checkCommands() {
  if (Serial.available() > 0) {
    String command = Serial.readStringUntil('\n');
    
    // 명령어 처리
    if (command == "PUMP_ON") {
      digitalWrite(PUMP_PIN, HIGH);
      pumpStatus = true;
    }
    else if (command == "PUMP_OFF") {
      digitalWrite(PUMP_PIN, LOW);
      pumpStatus = false;
    }
    else if (command == "LED_ON") {
      digitalWrite(LED_PIN, HIGH);
      ledStatus = true;
    }
    else if (command == "LED_OFF") {
      digitalWrite(LED_PIN, LOW);
      ledStatus = false;
    }
    else if (command == "FAN_ON") {
      digitalWrite(FAN_PIN, HIGH);
      fanStatus = true;
    }
    else if (command == "FAN_OFF") {
      digitalWrite(FAN_PIN, LOW);
      fanStatus = false;
    }
  }
}
