from fastapi import FastAPI, Request, Form
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from pydantic import BaseModel, EmailStr
from typing import Optional

# Modelo Pydantic para Cliente
class Cliente(BaseModel):
    id: int
    nombre: str
    apellido: str
    email: EmailStr
    telefono: Optional[str] = None
    direccion: Optional[str] = None

# Lista de clientes en memoria
clientes_db = [
    Cliente(
        id=1,
        nombre="Juan Carlos",
        apellido="Pérez",
        email="juan.perez@example.com",
        telefono="555-0101",
        direccion="Calle 123, Ciudad"
    ),
    Cliente(
        id=2,
        nombre="María",
        apellido="García",
        email="maria.garcia@example.com",
        telefono="555-0102",
        direccion="Avenida 456, Ciudad"
    ),
    Cliente(
        id=3,
        nombre="Carlos",
        apellido="Rodríguez",
        email="carlos.rodriguez@example.com",
        telefono="555-0103",
        direccion="Plaza 789, Ciudad"
    ),
    Cliente(
        id=4,
        nombre="Ana",
        apellido="Martínez",
        email="ana.martinez@example.com",
        telefono="555-0104",
        direccion="Paseo 321, Ciudad"
    ),
    Cliente(
        id=5,
        nombre="Luis",
        apellido="López",
        email="luis.lopez@example.com",
        telefono="555-0105",
        direccion="Boulevard 654, Ciudad"
    )
]

app = FastAPI(title="SumaAPI")

# Servir archivos estáticos
app.mount("/static", StaticFiles(directory="app/static"), name="static")

# Motor de plantillas
templates = Jinja2Templates(directory="app/templates")

# --- GET: muestra el formulario ---
@app.get("/", response_class=HTMLResponse)
def get_index(request: Request):
    return templates.TemplateResponse("pages/index.html", {
        "request": request,
        "clientes": clientes_db
    })

