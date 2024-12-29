from fastapi import FastAPI, HTTPException, WebSocket
from fastapi.middleware.cors import CORSMiddleware
import serial
import json
import asyncio
from typing import List, Optional
from datetime import datetime
import logging

app = FastAPI(title="SmartGarden API")

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 시리얼 통신 설정
try:
    arduino = serial.Serial('COM3', 9600, timeout=1)  # COM 포트는 환경에 따라 변경 필요
except:
    arduino = None
    logging.warning("아두이노 연결 실패. 시뮬레이션 모드로 실행됩니다.")

# 웹소켓 클라이언트 저장
websocket_clients: List[WebSocket] = []

# 최신 센서 데이터 저장
current_data = {
    "temperature": 0,
    "humidity": 0,
    "soilMoisture": 0,
    "lightLevel": 0,
    "pumpStatus": False,
    "ledStatus": False,
    "fanStatus": False,
    "timestamp": datetime.now().isoformat()
}

@app.get("/")
async def read_root():
    return {"status": "running", "message": "SmartGarden API is running"}

@app.get("/status")
async def get_status():
    return current_data

@app.post("/control/{device}/{action}")
async def control_device(device: str, action: str):
    if arduino is None:
        raise HTTPException(status_code=503, detail="Arduino not connected")
    
    command = f"{device.upper()}_{action.upper()}\n"
    arduino.write(command.encode())
    return {"status": "success", "command": command.strip()}

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    websocket_clients.append(websocket)
    try:
        while True:
            # 클라이언트로부터의 메시지 대기
            data = await websocket.receive_text()
            # 필요한 경우 메시지 처리
    except:
        websocket_clients.remove(websocket)

async def read_arduino():
    while True:
        if arduino and arduino.in_waiting:
            try:
                line = arduino.readline().decode('utf-8').strip()
                data = json.loads(line)
                current_data.update(data)
                current_data["timestamp"] = datetime.now().isoformat()
                
                # 연결된 모든 웹소켓 클라이언트에게 데이터 전송
                for client in websocket_clients:
                    await client.send_json(current_data)
            except:
                logging.error("Error reading from Arduino", exc_info=True)
        await asyncio.sleep(1)

@app.on_event("startup")
async def startup_event():
    asyncio.create_task(read_arduino())

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)
