# SmartGarden

스마트 가든 모니터링 시스템 - Arduino, Python, Flutter를 활용한 IoT 프로젝트

## 프로젝트 구조
```
smart_garden/
├── arduino/           # 아두이노 코드
├── backend/          # Python FastAPI 백엔드
└── flutter_app/      # Flutter 모바일 앱
```

## 필요한 하드웨어
- 아두이노 UNO 또는 ESP32
- DHT11 온습도 센서
- 토양습도 센서
- 조도센서(LDR)
- 릴레이 모듈
- 워터펌프
- LED
- DC 팬
- 점퍼 와이어
- 브레드보드

## 주요 기능
1. 실시간 식물 상태 모니터링
   - 토양 습도
   - 주변 온도
   - 조도
   - 물 공급 상태

2. 자동화 기능
   - 자동 급수 시스템
   - 조명 제어
   - 환기 팬 제어

3. 모바일 앱 기능
   - 실시간 센서 데이터 확인
   - 원격 제어
   - 식물 관리 일정 설정
   - 식물 성장 기록 및 통계
   - 알림 설정

## 설치 방법
1. 아두이노 설정
   - Arduino IDE 설치
   - 필요한 라이브러리 설치
   - 하드웨어 연결

2. 백엔드 설정
   ```bash
   cd backend
   pip install -r requirements.txt
   python main.py
   ```

3. 플러터 앱 설정
   ```bash
   cd flutter_app
   flutter pub get
   flutter run
   ```
