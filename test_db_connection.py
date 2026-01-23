#!/usr/bin/env python3
"""
Script para verificar la conexión a la base de datos
"""
import mysql.connector
from dotenv import load_dotenv, find_dotenv
import os
import sys

# Carga variables de entorno
load_dotenv(find_dotenv())

print("=" * 60)
print("VERIFICACIÓN DE CONEXIÓN A BASE DE DATOS")
print("=" * 60)

# Obtener variables de entorno
db_host = os.getenv("DB_HOST", "localhost")
db_user = os.getenv("DB_USER", "root")
db_password = os.getenv("DB_PASSWORD", "")
db_name = os.getenv("DB_NAME", "clientes_db")
db_port = int(os.getenv("DB_PORT", "3306"))

print(f"\n📋 Parámetros de conexión:")
print(f"  Host: {db_host}")
print(f"  Usuario: {db_user}")
print(f"  Base de datos: {db_name}")
print(f"  Puerto: {db_port}")
print(f"  Contraseña: {'*' * len(db_password) if db_password else '(vacía)'}")

try:
    print(f"\n⏳ Intentando conectar...")
    conn = mysql.connector.connect(
        host=db_host,
        user=db_user,
        password=db_password,
        database=db_name,
        port=db_port,
        charset="utf8mb4"
    )
    print("✅ ¡Conexión exitosa!")
    
    # Verificar las tablas
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SHOW TABLES;")
    tables = cursor.fetchall()
    
    print(f"\n📊 Tablas en la BD:")
    if tables:
        for table in tables:
            print(f"  - {table[list(table.keys())[0]]}")
    else:
        print("  ⚠️  No hay tablas en la BD")
    
    # Verificar estructura de la tabla 'clientes'
    try:
        cursor.execute("DESCRIBE clientes;")
        columns = cursor.fetchall()
        print(f"\n🔍 Estructura de tabla 'clientes':")
        for col in columns:
            print(f"  - {col['Field']}: {col['Type']}")
    except:
        print("  ⚠️  La tabla 'clientes' no existe")
    
    # Contar registros
    try:
        cursor.execute("SELECT COUNT(*) as count FROM clientes;")
        result = cursor.fetchone()
        count = result['count'] if result else 0
        print(f"\n📈 Registros en 'clientes': {count}")
    except:
        print("  ⚠️  No se pudo contar registros")
    
    cursor.close()
    conn.close()
    
except mysql.connector.Error as err:
    print(f"\n❌ Error de conexión: {err}")
    sys.exit(1)
except Exception as e:
    print(f"\n❌ Error inesperado: {e}")
    sys.exit(1)

print("\n" + "=" * 60)
