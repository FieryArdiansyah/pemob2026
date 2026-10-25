from datetime import datetime

from fastapi import FastAPI
from fastapi.responses import JSONResponse
from sqlalchemy import text

from .database import engine

app = FastAPI(
    title="TabungKu API",
    version="0.1.0",
)


@app.get("/")
def beranda():
    return {
        "pesan": "Selamat datang di TabungKu API. Dokumentasi: /docs"
    }


@app.get("/health")
def health():
    waktu = datetime.now().isoformat(timespec="seconds")

    try:
        with engine.connect() as connection:
            mysql_version = connection.execute(
                text("SELECT VERSION()")
            ).scalar_one()

        return {
            "status": "ok",
            "waktu_server": waktu,
            "database": "ok",
            "mysql_version": mysql_version,
        }

    except Exception as error:
        return JSONResponse(
            status_code=503,
            content={
                "status": "error",
                "waktu_server": waktu,
                "database": "error",
                "mysql_version": None,
                "pesan": str(error),
            },
        )
