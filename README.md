# 📚 API REST de Gestión de Clientes - Guía Educativa

## 📖 Índice
1. [Descripción General](#descripción-general)
2. [Conceptos de Arquitectura de Software](#conceptos-de-arquitectura-de-software)
3. [Librerías Python y su Función](#librerías-python-y-su-función)
4. [Estructura del Proyecto](#estructura-del-proyecto)
5. [Instalación y Ejecución](#instalación-y-ejecución)
6. [Endpoints de la API](#endpoints-de-la-api)
7. [Validaciones Implementadas](#validaciones-implementadas)
8. [Ejercicios Prácticos](#ejercicios-prácticos)

---

## 🎯 Descripción General

Esta API REST permite gestionar un catálogo de clientes con operaciones CRUD (Create, Read, Update, Delete) completas. Es un proyecto educativo que implementa buenas prácticas de desarrollo de software y patrones de diseño modernos.

**Tecnologías principales:**
- **Backend:** FastAPI (Python)
- **Base de datos:** MariaDB/MySQL
- **Contenedorización:** Docker & Docker Compose
- **Servidor ASGI:** Uvicorn

---

## 🏗️ Conceptos de Arquitectura de Software

### 1. **Arquitectura en Capas (Layered Architecture)**

El proyecto separa responsabilidades en distintas capas:

```
┌─────────────────────────────────┐
│   Capa de Presentación (API)    │  ← main.py (Endpoints FastAPI)
├─────────────────────────────────┤
│   Capa de Lógica de Negocio     │  ← Modelos Pydantic (Validaciones)
├─────────────────────────────────┤
│   Capa de Acceso a Datos (DAL)  │  ← database.py (Funciones CRUD)
├─────────────────────────────────┤
│   Capa de Persistencia          │  ← MariaDB (Base de datos)
└─────────────────────────────────┘
```

**Ventajas:**
- ✅ Separación de responsabilidades (Separation of Concerns)
- ✅ Fácil mantenimiento y testing
- ✅ Cambios en una capa no afectan a las otras

### 2. **Patrón Repository**

El archivo `database.py` implementa el patrón Repository, encapsulando toda la lógica de acceso a datos:

```python
# Funciones que abstraen las operaciones de BD
fetch_all_clientes()      # SELECT
fetch_cliente_by_id()     # SELECT WHERE id
insert_cliente()          # INSERT
update_cliente()          # UPDATE
delete_cliente()          # DELETE
```

**Beneficios:**
- ✅ Centraliza el acceso a datos
- ✅ Facilita el cambio de BD sin modificar la lógica de negocio
- ✅ Mejora la testabilidad (se puede mockear fácilmente)

### 3. **RESTful API Design**

Sigue los principios REST:

| Método HTTP | Endpoint                | Acción                    | Idempotente |
|-------------|-------------------------|---------------------------|-------------|
| GET         | `/clientes`             | Listar todos              | ✓           |
| GET         | `/clientes/{id}`        | Obtener uno específico    | ✓           |
| POST        | `/clientes`             | Crear nuevo               | ✗           |
| PUT         | `/clientes/{id}`        | Actualizar completo       | ✓           |
| DELETE      | `/clientes/{id}`        | Eliminar                  | ✓           |

**Características REST:**
- ✅ Recursos identificados por URIs
- ✅ Uso semántico de métodos HTTP
- ✅ Respuestas con códigos de estado apropiados (200, 201, 204, 404)
- ✅ Stateless (sin estado en el servidor)

### 4. **Validación de Datos (Data Validation)**

Usa **Pydantic** para validación automática en dos niveles:

**Nivel 1: Validaciones declarativas con `Field()`**
```python
nombre: str = Field(
    min_length=2,
    max_length=50,
    description="..."
)
```

**Nivel 2: Validaciones personalizadas con `@field_validator`**
```python
@field_validator('telefono')
def validar_telefono(cls, v):
    # Lógica personalizada
    return v
```

### 5. **Separación de Modelos (Model Segregation)**

```python
ClienteBase       # Modelo base con validaciones comunes
ClienteCreate     # Para crear (sin ID)
ClienteUpdate     # Para actualizar (sin ID)
Cliente           # Completo (con ID)
```

**Principio:** Interface Segregation Principle (ISP) del SOLID
- Cada endpoint usa solo los campos que necesita
- Evita exposición accidental de datos

### 6. **Dependency Injection (Inyección de Dependencias)**

FastAPI inyecta automáticamente dependencias:
```python
def crear_cliente(cliente: ClienteCreate):  # ← FastAPI inyecta y valida
```

### 7. **Documentación Automática (API Documentation)**

FastAPI genera automáticamente:
- **Swagger UI:** `/docs` - Interfaz interactiva
- **ReDoc:** `/redoc` - Documentación alternativa
- **OpenAPI Schema:** `/openapi.json` - Especificación estándar

### 8. **Contenedorización (Containerization)**

Uso de Docker para:
- ✅ Consistencia entre entornos (desarrollo, producción)
- ✅ Aislamiento de dependencias
- ✅ Orquestación con Docker Compose (app + base de datos)

### 9. **Configuración Externa (Externalized Configuration)**

Uso de `.env` para configuración:
```python
DB_HOST=localhost
DB_USER=profesor
DB_PASSWORD=4688
```

**Principio:** 12-Factor App - Configuration
- ✅ No hardcodear credenciales
- ✅ Fácil cambio entre entornos

### 10. **Manejo de Errores HTTP (Error Handling)**

```python
if not cliente:
    raise HTTPException(status_code=404, detail="Cliente no encontrado")
```

Respuestas estándar y descriptivas para el cliente.

---

## 📦 Librerías Python y su Función

### **Librerías Core de la API**

#### 1. **FastAPI** (`fastapi==0.121.0`)
**¿Qué es?** Framework web moderno y de alto rendimiento para crear APIs.

**¿Para qué sirve en la API?**
- Define los endpoints (rutas)
- Maneja requests/responses HTTP
- Genera documentación automática
- Inyección de dependencias
- Manejo de errores HTTP

```python
app = FastAPI()  # Crea la aplicación

@app.get("/clientes")  # Define un endpoint
def listar_clientes():
    pass
```

#### 2. **Pydantic** (`pydantic==2.12.4`)
**¿Qué es?** Librería para validación de datos usando type hints de Python.

**¿Para qué sirve en la API?**
- Validación automática de datos de entrada
- Serialización JSON ↔ Python objects
- Generación de schema OpenAPI
- Type safety (seguridad de tipos)

```python
class Cliente(BaseModel):  # Modelo con validación automática
    nombre: str
    email: EmailStr  # Valida formato de email
```

#### 3. **Uvicorn** (`uvicorn==0.38.0`)
**¿Qué es?** Servidor ASGI ultrarrápido para aplicaciones asíncronas.

**¿Para qué sirve en la API?**
- Ejecuta la aplicación FastAPI
- Maneja conexiones HTTP
- Soporte para async/await
- Hot reload en desarrollo

```bash
uvicorn app.main:app --reload
```

#### 4. **mysql-connector-python** (`mysql-connector-python==9.5.0`)
**¿Qué es?** Driver oficial de Oracle para conectarse a MySQL/MariaDB.

**¿Para qué sirve en la API?**
- Conexión a la base de datos
- Ejecución de queries SQL
- Manejo de transacciones
- Cursor para resultados

```python
conn = mysql.connector.connect(
    host="localhost",
    user="profesor",
    password="4688"
)
```

#### 5. **python-dotenv** (`python-dotenv==1.2.1`)
**¿Qué es?** Carga variables de entorno desde archivos `.env`.

**¿Para qué sirve en la API?**
- Gestión de configuración
- Separar secrets del código
- Diferentes configs por entorno

```python
from dotenv import load_dotenv
load_dotenv()  # Carga .env

DB_HOST = os.getenv("DB_HOST")
```

### **Librerías de Validación**

#### 6. **email-validator** (`email-validator==2.1.0`)
**¿Qué es?** Validador robusto de direcciones de email.

**¿Para qué sirve en la API?**
- Valida formato de emails
- Verifica sintaxis RFC 5322
- Detecta emails inválidos

```python
email: EmailStr  # Usa email-validator internamente
```

#### 7. **dnspython** (`dnspython==2.8.0`)
**¿Qué es?** Toolkit para consultas DNS.

**¿Para qué sirve en la API?**
- Dependencia de email-validator
- Verifica existencia de dominios de email
- Validación avanzada de emails

### **Librerías de Desarrollo**

#### 8. **Black** (`black==25.9.0`)
**¿Qué es?** Formateador de código Python automático.

**¿Para qué sirve?**
- Mantiene estilo de código consistente
- Formatea automáticamente
- Evita discusiones sobre estilo

```bash
black app/main.py  # Formatea el archivo
```

#### 9. **python-multipart** (`python-multipart==0.0.20`)
**¿Qué es?** Parser para datos multipart/form-data.

**¿Para qué sirve en la API?**
- Manejo de formularios HTML
- Upload de archivos
- Datos form-encoded

### **Librerías de Soporte**

#### 10. **Starlette** (`starlette==0.49.3`)
**¿Qué es?** Framework ASGI ligero (FastAPI está construido sobre Starlette).

**¿Para qué sirve?**
- Base de FastAPI
- Routing
- Middleware
- WebSockets

#### 11. **anyio** (`anyio==4.11.0`)
**¿Qué es?** Capa de abstracción para async I/O.

**¿Para qué sirve?**
- Compatibilidad asyncio/trio
- Operaciones asíncronas
- Concurrencia

#### 12. **typing_extensions** (`typing-extensions==4.15.0`)
**¿Qué es?** Backport de nuevas características de typing.

**¿Para qué sirve?**
- Type hints modernos
- Compatibilidad entre versiones de Python
- Tipos avanzados

---

## 📁 Estructura del Proyecto

```
clientes/
├── app/
│   ├── main.py              # 🎯 Endpoints de la API (FastAPI)
│   ├── database.py          # 🗄️ Funciones CRUD (Repository Pattern)
│   └── __pycache__/         # Cache de Python (auto-generado)
│
├── docs/
│   ├── init_db.sql          # 📜 Script de inicialización de BD
│   └── Diagrama de secuencia basico.drawio
│
├── docker-compose.yml       # 🐳 Orquestación de contenedores
├── Dockerfile              # 🐳 Imagen de la aplicación
├── requirements.txt        # 📦 Dependencias Python
├── .env                    # 🔐 Variables de entorno (NO subir a Git)
└── README.md              # 📖 Esta documentación
```

### Descripción de archivos clave:

**`app/main.py`**
- Define todos los endpoints de la API
- Modelos Pydantic (ClienteBase, Cliente, etc.)
- Lógica de validación personalizada
- Configuración de FastAPI

**`app/database.py`**
- Funciones para conectarse a MySQL
- Operaciones CRUD encapsuladas
- Manejo de conexiones y cursores
- Type hints para seguridad

**`docker-compose.yml`**
- Servicio `db`: MariaDB con datos iniciales
- Servicio `app`: API FastAPI
- Redes y volúmenes persistentes

**`requirements.txt`**
- Lista todas las dependencias Python
- Versionado explícito para reproducibilidad

---

## 🚀 Instalación y Ejecución

### **Opción 1: Con Docker (Recomendado)**

```bash
# 1. Clonar el repositorio
git clone <url-repositorio>
cd clientes

# 2. Crear archivo .env (si no existe)
cat > .env << EOF
DB_HOST=db
DB_USER=profesor
DB_PASSWORD=4688
DB_NAME=clientes_db
DB_PORT=3306
EOF

# 3. Levantar los servicios
docker-compose up -d

# 4. Verificar que esté funcionando
curl http://localhost:8000/ping
# Respuesta esperada: {"message":"pong"}

# 5. Ver logs
docker-compose logs -f app

# 6. Detener los servicios
docker-compose down
```

### **Opción 2: Sin Docker (Local)**

```bash
# 1. Crear entorno virtual
python3 -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate   # Windows

# 2. Instalar dependencias
pip install -r requirements.txt

# 3. Configurar .env para BD local
cat > .env << EOF
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=tu_password
DB_NAME=clientes_db
DB_PORT=3306
EOF

# 4. Crear la base de datos
mysql -u root -p < docs/init_db.sql

# 5. Ejecutar la aplicación
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# 6. Acceder a la documentación
# http://localhost:8000/docs
```

---

## 🔌 Endpoints de la API

### **Base URL:** `http://localhost:8000`

### 1. Health Check
```http
GET /ping
```
**Respuesta:**
```json
{"message": "pong"}
```

### 2. Listar todos los clientes
```http
GET /clientes
```
**Respuesta:** `200 OK`
```json
[
  {
    "id": 1,
    "nombre": "Juan",
    "apellido": "Pérez",
    "email": "juan.perez@example.com",
    "telefono": "+34612345678",
    "direccion": "Calle Mayor 123, Madrid"
  }
]
```

### 3. Obtener un cliente por ID
```http
GET /clientes/{id}
```
**Ejemplo:** `GET /clientes/1`

**Respuesta exitosa:** `200 OK`
```json
{
  "id": 1,
  "nombre": "Juan",
  "apellido": "Pérez",
  "email": "juan.perez@example.com",
  "telefono": "+34612345678",
  "direccion": "Calle Mayor 123, Madrid"
}
```

**Respuesta error:** `404 Not Found`
```json
{
  "detail": "Cliente no encontrado"
}
```

### 4. Crear un nuevo cliente
```http
POST /clientes
Content-Type: application/json
```
**Body:**
```json
{
  "nombre": "María",
  "apellido": "García",
  "email": "maria.garcia@example.com",
  "telefono": "612345678",
  "direccion": "Av. Principal 45, Barcelona"
}
```

**Respuesta:** `201 Created`
```json
{
  "id": 2,
  "nombre": "María",
  "apellido": "García",
  "email": "maria.garcia@example.com",
  "telefono": "612345678",
  "direccion": "Av. Principal 45, Barcelona"
}
```

### 5. Actualizar un cliente
```http
PUT /clientes/{id}
Content-Type: application/json
```
**Body:**
```json
{
  "nombre": "María José",
  "apellido": "García López",
  "email": "mariajose.garcia@example.com",
  "telefono": "+34612345678",
  "direccion": "Av. Principal 45, 2º A, Barcelona"
}
```

**Respuesta:** `200 OK`

### 6. Eliminar un cliente
```http
DELETE /clientes/{id}
```

**Respuesta exitosa:** `204 No Content` (sin cuerpo)

**Respuesta error:** `404 Not Found`

---

## ✅ Validaciones Implementadas

### **Campo: nombre y apellido**

| Validación              | Descripción                                    |
|-------------------------|------------------------------------------------|
| Requerido               | No puede ser vacío                             |
| Longitud mínima         | 2 caracteres                                   |
| Longitud máxima         | 50 caracteres                                  |
| Caracteres permitidos   | Solo letras, espacios, tildes (á, é, í, ó, ú), ñ |
| Transformación          | Capitaliza cada palabra (Title Case)           |

**Ejemplos válidos:** `"Juan"`, `"María José"`, `"García López"`
**Ejemplos inválidos:** `"J"` (muy corto), `"Juan123"` (números), `""` (vacío)

### **Campo: email**

| Validación              | Descripción                                    |
|-------------------------|------------------------------------------------|
| Requerido               | Sí                                             |
| Formato                 | Debe ser un email válido (RFC 5322)            |
| Validación DNS          | Verifica existencia del dominio                |

**Ejemplos válidos:** `"juan@example.com"`, `"maria.garcia@empresa.es"`
**Ejemplos inválidos:** `"noesuncorreo"`, `"@example.com"`, `"usuario@"`

### **Campo: telefono** (opcional)

| Validación              | Descripción                                    |
|-------------------------|------------------------------------------------|
| Requerido               | No (opcional)                                  |
| Longitud                | 7-15 dígitos                                   |
| Formato                 | Puede incluir `+` al inicio                    |
| Caracteres ignorados    | Espacios, guiones, paréntesis (se eliminan para validar) |

**Ejemplos válidos:** `"+34612345678"`, `"612345678"`, `"91 234 56 78"`, `"(91) 234-5678"`
**Ejemplos inválidos:** `"123"` (muy corto), `"abc123"` (letras), `"123456789012345678"` (muy largo)

### **Campo: direccion** (opcional)

| Validación              | Descripción                                    |
|-------------------------|------------------------------------------------|
| Requerido               | No (opcional)                                  |
| Longitud máxima         | 200 caracteres                                 |

**Ejemplo válido:** `"Calle Mayor 123, 28013 Madrid, España"`

---

## 🧪 Ejercicios Prácticos

### **Ejercicio 1: Testing con Swagger UI**
1. Accede a `http://localhost:8000/docs`
2. Crea 3 clientes con datos válidos
3. Intenta crear un cliente con email inválido
4. Intenta crear un cliente con nombre de 1 letra
5. Lista todos los clientes
6. Actualiza un cliente
7. Elimina un cliente

### **Ejercicio 2: Testing con curl**
```bash
# Crear cliente
curl -X POST http://localhost:8000/clientes \
  -H "Content-Type: application/json" \
  -d '{
    "nombre": "Pedro",
    "apellido": "Martínez",
    "email": "pedro@example.com",
    "telefono": "666777888"
  }'

# Listar clientes
curl http://localhost:8000/clientes

# Obtener cliente por ID
curl http://localhost:8000/clientes/1

# Actualizar cliente
curl -X PUT http://localhost:8000/clientes/1 \
  -H "Content-Type: application/json" \
  -d '{
    "nombre": "Pedro José",
    "apellido": "Martínez Ruiz",
    "email": "pedro.martinez@example.com",
    "telefono": "+34666777888",
    "direccion": "Nueva dirección"
  }'

# Eliminar cliente
curl -X DELETE http://localhost:8000/clientes/1
```

### **Ejercicio 3: Modificar el Proyecto**

**A) Agregar nuevo campo:**
1. Agrega el campo `edad: int` al modelo
2. Valida que sea entre 18 y 120 años
3. Actualiza la tabla en `init_db.sql`
4. Prueba los endpoints

**B) Agregar nuevo endpoint:**
1. Crea `GET /clientes/buscar?email=xxx@example.com`
2. Implementa la función en `database.py`
3. Documenta el endpoint

**C) Paginación:**
1. Modifica `GET /clientes` para aceptar `?skip=0&limit=10`
2. Implementa la lógica de paginación
3. Prueba con muchos registros

### **Ejercicio 4: Análisis de Código**

**Preguntas:**
1. ¿Qué pasa si la base de datos no está disponible?
2. ¿Cómo podrías agregar autenticación JWT?
3. ¿Qué patrón de diseño usarías para logging?
4. ¿Cómo implementarías un caché de clientes?
5. ¿Qué ventajas tiene usar `async def` en los endpoints?

### **Ejercicio 5: Testing Unitario**

Crea un archivo `test_main.py`:

```python
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_ping():
    response = client.get("/ping")
    assert response.status_code == 200
    assert response.json() == {"message": "pong"}

def test_crear_cliente_valido():
    response = client.post("/clientes", json={
        "nombre": "Test",
        "apellido": "Usuario",
        "email": "test@example.com"
    })
    assert response.status_code == 201
    assert response.json()["nombre"] == "Test"

def test_crear_cliente_email_invalido():
    response = client.post("/clientes", json={
        "nombre": "Test",
        "apellido": "Usuario",
        "email": "email-invalido"
    })
    assert response.status_code == 422  # Unprocessable Entity
```

Ejecuta: `pytest test_main.py -v`

---

## 📚 Recursos Adicionales

### **Documentación Oficial:**
- [FastAPI](https://fastapi.tiangolo.com/)
- [Pydantic](https://docs.pydantic.dev/)
- [MySQL Connector](https://dev.mysql.com/doc/connector-python/en/)
- [Docker](https://docs.docker.com/)

### **Conceptos de Arquitectura:**
- [REST API Best Practices](https://restfulapi.net/)
- [SOLID Principles](https://en.wikipedia.org/wiki/SOLID)
- [Repository Pattern](https://martinfowler.com/eaaCatalog/repository.html)
- [12-Factor App](https://12factor.net/)

### **Herramientas Útiles:**
- **Postman:** Cliente para probar APIs
- **HTTPie:** Cliente CLI moderno (`pip install httpie`)
- **DBeaver:** Cliente visual para bases de datos

---

## 🤝 Contribuciones

Este es un proyecto educativo. Se anima a los estudiantes a:
1. Hacer fork del proyecto
2. Experimentar con nuevas features
3. Compartir mejoras con la clase
4. Documentar los cambios realizados

---

## 📝 Licencia

Proyecto educativo para uso académico.

---

## ✉️ Contacto

**Profesor:** [Tu nombre]
**Email:** [tu-email@universidad.edu]
**Curso:** Desarrollo de APIs REST con Python

---

**¡Happy Coding! 🚀**
