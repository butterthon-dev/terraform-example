from fastapi import FastAPI

app = FastAPI()

@app.get("/healthz")
async def healthz():
    return {"message": "Healthy"}


@app.post("/call-back")
async def call_back(payload: dict):
    print('■■■■■■■■■■■ call_back ■■■■■■■■■■■')
    print(payload)
    return {"message": "successfully"}
