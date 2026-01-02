from fastapi import FastAPI, Request, Form
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from pydantic import BaseModel, EmailStr
from typing import Optional, List

# Importamos las funciones que consultan/insertan en MySQL
from app.database import fetch_all_clientes, insert_cliente


# Modelo Pydantic para Cliente
class Cliente(BaseModel):
    id: int
    nombre: str
    apellido: str
    email: EmailStr
    telefono: Optional[str] = None
    direccion: Optional[str] = None


app = FastAPI(title="SumaAPI")

# Servir archivos estáticos
app.mount("/static", StaticFiles(directory="app/static"), name="static")

# Motor de plantillas
templates = Jinja2Templates(directory="app/templates")


def map_rows_to_clientes(rows: List[dict]) -> List[Cliente]:
    """
    Convierte las filas del SELECT * FROM clientes (dict) 
    en objetos Cliente validados con Pydantic.
    """
    return [
        Cliente(
            id=row["id"],
            nombre=row["nombre"],
            apellido=row["apellido"],
            email=row["email"],
            telefono=row.get("telefono"),
            direccion=row.get("direccion"),
        )
        for row in rows
    ]


# --- GET principal ---
@app.get("/", response_class=HTMLResponse)
def get_index(request: Request):
    # 1️⃣ Obtenemos los datos desde MySQL
    rows = fetch_all_clientes()

    # 2️⃣ Convertimos cada fila a Cliente (valida estructura)
    clientes = map_rows_to_clientes(rows)

    # 3️⃣ Enviamos a la plantilla
    return templates.TemplateResponse(
        "pages/index.html",
        {
            "request": request,
            "clientes": clientes
        }
    )


# --- GET formulario nuevo cliente ---
@app.get("/clientes/nuevo", response_class=HTMLResponse)
def get_nuevo_cliente(request: Request):
    return templates.TemplateResponse(
        "pages/nuevo_cliente.html",
        {
            "request": request,
            "mensaje": None
        }
    )


# --- POST guardar nuevo cliente ---
@app.post("/clientes/nuevo")
def post_nuevo_cliente(
    nombre: str = Form(...),
    apellido: str = Form(...),
    email: str = Form(...),
    telefono: Optional[str] = Form(None),
    direccion: Optional[str] = Form(None)
):
    # Insertamos el cliente en la base de datos
    insert_cliente(nombre, apellido, email, telefono, direccion)
    
    # Redirigimos al inicio para ver el listado actualizado
    return RedirectResponse(url="/", status_code=303)
