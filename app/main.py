from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, EmailStr, field_validator
from typing import Optional, List
import re

# Importamos las funciones que consultan/insertan/eliminan en MySQL
from app.database import (
    fetch_all_clientes, 
    insert_cliente, 
    delete_cliente,
    fetch_cliente_by_id,
    update_cliente
)


# Modelo base con validaciones comunes
class ClienteBase(BaseModel):
    nombre: str
    apellido: str
    email: EmailStr
    telefono: Optional[str] = None
    direccion: Optional[str] = None
    
    @field_validator('nombre', 'apellido')
    @classmethod
    def validar_nombre_apellido(cls, v: str) -> str:
        """Valida que nombre y apellido tengan formato correcto."""
        if not v or not v.strip():
            raise ValueError('El campo no puede estar vacío')
        
        v = v.strip()
        
        if len(v) < 2:
            raise ValueError('Debe tener al menos 2 caracteres')
        
        if len(v) > 50:
            raise ValueError('No puede exceder 50 caracteres')
        
        # Solo letras, espacios, tildes y caracteres especiales del español
        if not re.match(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$', v):
            raise ValueError('Solo se permiten letras y espacios')
        
        return v.title()  # Capitaliza cada palabra
    
    @field_validator('telefono')
    @classmethod
    def validar_telefono(cls, v: Optional[str]) -> Optional[str]:
        """Valida el formato del teléfono."""
        if v is None or v.strip() == '':
            return None
        
        v = v.strip()
        
        # Elimina espacios, guiones y paréntesis para validar
        telefono_limpio = re.sub(r'[\s\-\(\)]', '', v)
        
        # Debe contener solo dígitos y opcionalmente + al inicio
        if not re.match(r'^\+?\d{7,15}$', telefono_limpio):
            raise ValueError('Formato de teléfono inválido. Debe contener entre 7 y 15 dígitos')
        
        return v
    
    @field_validator('direccion')
    @classmethod
    def validar_direccion(cls, v: Optional[str]) -> Optional[str]:
        """Valida la dirección."""
        if v is None or v.strip() == '':
            return None
        
        v = v.strip()
        
        if len(v) > 200:
            raise ValueError('La dirección no puede exceder 200 caracteres')
        
        return v


# Modelo para lectura de BD (sin validaciones estrictas, acepta datos históricos)
class ClienteDB(BaseModel):
    id: int
    nombre: str
    apellido: str
    email: str
    telefono: Optional[str] = None
    direccion: Optional[str] = None


# Modelo para crear cliente (sin ID)
class ClienteCreate(ClienteBase):
    pass


# Modelo para actualizar cliente (sin ID)
class ClienteUpdate(ClienteBase):
    pass


# Modelo completo de Cliente (con ID y validaciones)
class Cliente(ClienteBase):
    id: int


app = FastAPI(
    title="Clientes API REST",
    description="API REST para gestión de clientes con MySQL",
    version="1.0.0"
)


# --- Endpoint de health check ---
@app.get("/ping")
def ping():
    """
    Endpoint de health check para verificar que la API está funcionando.
    """
    return {"message": "pong"}


# --- Endpoint para listar todos los clientes ---
@app.get("/clientes", response_model=List[ClienteDB])
def listar_clientes():
    """
    Obtiene la lista completa de clientes desde la base de datos.
    """
    rows = fetch_all_clientes()
    return [ClienteDB(**row) for row in rows]


# --- Endpoint para crear un nuevo cliente ---
@app.post("/clientes", response_model=ClienteDB, status_code=201)
def crear_cliente(cliente: ClienteCreate):
    """
    Crea un nuevo cliente en la base de datos.
    Los datos son validados automáticamente por Pydantic.
    """
    cliente_id = insert_cliente(
        cliente.nombre,
        cliente.apellido,
        cliente.email,
        cliente.telefono,
        cliente.direccion
    )
    
    return ClienteDB(
        id=cliente_id,
        nombre=cliente.nombre,
        apellido=cliente.apellido,
        email=cliente.email,
        telefono=cliente.telefono,
        direccion=cliente.direccion
    )


# --- Endpoint para actualizar un cliente ---
@app.put("/clientes/{cliente_id}", response_model=ClienteDB)
def actualizar_cliente(cliente_id: int, cliente: ClienteUpdate):
    """
    Actualiza los datos de un cliente existente.
    Los datos son validados automáticamente por Pydantic.
    """
    actualizado = update_cliente(
        cliente_id,
        cliente.nombre,
        cliente.apellido,
        cliente.email,
        cliente.telefono,
        cliente.direccion
    )
    
    if not actualizado:
        raise HTTPException(status_code=404, detail="Cliente no encontrado")
    
    return ClienteDB(
        id=cliente_id,
        nombre=cliente.nombre,
        apellido=cliente.apellido,
        email=cliente.email,
        telefono=cliente.telefono,
        direccion=cliente.direccion
    )


# --- Endpoint para eliminar un cliente ---
@app.delete("/clientes/{cliente_id}", status_code=204)
def eliminar_cliente(cliente_id: int):
    """
    Elimina un cliente de la base de datos por su ID.
    """
    eliminado = delete_cliente(cliente_id)
    
    if not eliminado:
        raise HTTPException(status_code=404, detail="Cliente no encontrado")
    
    return None
