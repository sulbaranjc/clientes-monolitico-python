from dotenv import load_dotenv, find_dotenv
import os
import mysql.connector
from typing import List, Dict, Any, cast
from mysql.connector.cursor import MySQLCursorDict  # opción C si la prefieres

# Carga .env desde la raíz
load_dotenv(find_dotenv())

def get_connection():
    return mysql.connector.connect(
        host=os.getenv("DB_HOST", "localhost"),        # <— corregidos nombres
        user=os.getenv("DB_USER", "root"),
        password=os.getenv("DB_PASSWORD", ""),
        database=os.getenv("DB_NAME", "clientes_db"),
        charset="utf8mb4"
    )

def fetch_all_clientes() -> List[Dict[str, Any]]:
    """
    Ejecuta SELECT * FROM clientes y devuelve una lista de dicts.
    """
    conn = None
    try:
        conn = get_connection()
        # Opción C (anotación explícita del cursor):
        cur: MySQLCursorDict
        cur = conn.cursor(dictionary=True)  # type: ignore[assignment]
        try:
            cur.execute(
                "SELECT id, nombre, apellido, email, telefono, direccion FROM clientes;"
            )
            # Opción A: cast para contentar al type checker
            rows = cast(List[Dict[str, Any]], cur.fetchall())
            return rows

            # Opción B alternativa (sin cast):
            # return [dict(row) for row in cur.fetchall()]
        finally:
            cur.close()
    finally:
        if conn:
            conn.close()


def insert_cliente(
    nombre: str, 
    apellido: str, 
    email: str, 
    telefono: str | None = None, 
    direccion: str | None = None
) -> int:
    """
    Inserta un nuevo cliente en la base de datos.
    Retorna el ID del cliente insertado.
    """
    conn = None
    try:
        conn = get_connection()
        cur = conn.cursor()
        try:
            cur.execute(
                """
                INSERT INTO clientes (nombre, apellido, email, telefono, direccion)
                VALUES (%s, %s, %s, %s, %s)
                """,
                (nombre, apellido, email, telefono, direccion)
            )
            conn.commit()
            return cur.lastrowid
        finally:
            cur.close()
    finally:
        if conn:
            conn.close()
