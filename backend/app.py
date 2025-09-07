from fastapi import FastAPI, HTTPException
from typing import List
import uvicorn

try:
    from hk_bus_eta import HKEta
except Exception:
    HKEta = None

app = FastAPI(title="HK Bus ETA Proxy")
eta = None

@app.on_event("startup")
def startup():
    global eta
    if HKEta is None:
        raise RuntimeError("hk-bus-eta is not installed. See requirements.txt")
    eta = HKEta()

@app.get("/routes", response_model=List[str])
def get_routes():
    """Return available route ids from hk-bus-eta"""
    return list(eta.route_list.keys())

@app.get("/etas")
def get_etas(route_id: str, seq: int = 0, language: str = "en"):
    """Fetch ETAs for a given route_id. Example route_id format: 'TCL+1+Hong Kong+Tung Chung'"""
    try:
        res = eta.getEtas(route_id=route_id, seq=seq, language=language)
        return res
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run("app:app", host="0.0.0.0", port=8000, reload=True)
