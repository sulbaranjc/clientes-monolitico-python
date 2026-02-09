# 🎯 Clientes Monolítico Python - FastAPI + MySQL

> **Aplicación web monolítica para gestión de clientes con FastAPI, Jinja2 Templates y MySQL/MariaDB**

[![FastAPI](https://img.shields.io/badge/FastAPI-0.109.0-009688.svg?style=flat&logo=FastAPI)](https://fastapi.tiangolo.com)
[![Python](https://img.shields.io/badge/Python-3.11-blue.svg?style=flat&logo=python)](https://www.python.org)
[![Docker](https://img.shields.io/badge/Docker-Enabled-2496ED.svg?style=flat&logo=docker)](https://www.docker.com)
[![MySQL](https://img.shields.io/badge/MySQL-MariaDB-4479A1.svg?style=flat&logo=mariadb)](https://mariadb.org)

---

## 📌 IMPORTANTE: Rama Principal

### ✅ **Rama `mysql` - VERSIÓN ESTABLE Y ACTUAL**

Esta es la rama principal del proyecto que contiene:
- ✅ Implementación completa con MySQL/MariaDB
- ✅ Interfaz web con templates Jinja2
- ✅ CRUD completo de clientes
- ✅ Configuración Docker optimizada
- ✅ Documentación actualizada
- ✅ **Código de producción**

```bash
# Para trabajar, SIEMPRE usa la rama mysql:
git checkout mysql
git pull origin mysql
```

### 📋 Otras ramas

- **`main`**: Contiene versión antigua (API REST) - no usar para desarrollo
- **`deploy`**: Rama preparada para despliegue a producción
- **`api-rest`**: Versión experimental anterior - descontinuada

---

## 🚀 Inicio Rápido

### 1️⃣ Clonar y configurar
```bash
git clone <URL_DEL_REPOSITORIO>
cd clientes-monolitico-python
git checkout mysql  # ⚠️ IMPORTANTE: Usar rama mysql
```

### 2️⃣ Levantar el entorno
```bash
docker compose up -d
```

### 3️⃣ Acceder a la aplicación
- **Aplicación web**: http://localhost:8000
- **API Docs**: http://localhost:8000/docs
- **Health check**: http://localhost:8000/ping

---

## 📚 Documentación Completa

📖 **[Ver Guía de Desarrollo Completa](GUIA_DESARROLLO.md)** - Workflows, comandos y solución de problemas

📝 **[Comandos Rápidos](COMANDOS_RAPIDOS.md)** - Referencia rápida de comandos Docker

---

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────┐
│  FastAPI Application (Port 8000)        │
│  ┌─────────────────────────────────┐   │
│  │  Jinja2 Templates (HTML)        │   │
│  │  Static Files (CSS/JS)          │   │
│  │  FastAPI Routes (CRUD)          │   │
│  └─────────────────────────────────┘   │
└──────────────┬──────────────────────────┘
               │
               ▼
┌──────────────────────────────────────────┐
│  MariaDB Database (Port 3307)            │
│  ┌────────────────────────────────┐     │
│  │  Table: clientes               │     │
│  │  - id (PK)                     │     │
│  │  - nombre                      │     │
│  │  - email                       │     │
│  │  - telefono                    │     │
│  └────────────────────────────────┘     │
└──────────────────────────────────────────┘
```

---

## 🛠️ Stack Tecnológico

| Capa | Tecnología | Versión |
|------|-----------|----------|
| **Backend** | FastAPI | 0.109.0+ |
| **Template Engine** | Jinja2 | 3.1.3+ |
| **Database** | MariaDB | 11.2+ |
| **ORM** | MySQL Connector | 8.3.0+ |
| **Contenedores** | Docker + Compose | - |
| **Python** | Python | 3.11+ |

---

## 📂 Estructura del Proyecto

```
clientes-monolitico-python/
├── app/
│   ├── main.py              # Aplicación FastAPI principal
│   ├── database.py          # Conexión y operaciones MySQL
│   ├── static/              # Archivos estáticos
│   │   ├── css/style.css    # Estilos personalizados
│   │   ├── js/main.js       # JavaScript del cliente
│   │   └── img/             # Imágenes
│   └── templates/           # Plantillas Jinja2
│       └── pages/
│           ├── index.html           # Listado de clientes
│           ├── nuevo_cliente.html   # Formulario crear
│           ├── editar_cliente.html  # Formulario editar
│           ├── error_404.html       # Página 404
│           └── error_500.html       # Página 500
├── docker-compose.yml              # Configuración producción
├── docker-compose.override.yml     # Configuración desarrollo
├── Dockerfile                      # Imagen de la aplicación
├── requirements.txt                # Dependencias Python
├── init_db.sql                     # Script inicial BD
├── .env                            # Variables de entorno
├── GUIA_DESARROLLO.md             # Guía completa desarrollo
├── COMANDOS_RAPIDOS.md            # Referencia rápida
└── README.md                       # Este archivo
```

---

## 🔧 Configuración

### Variables de Entorno

El archivo `.env` contiene:

```env
DB_HOST=clientes-db
DB_USER=clientes
DB_PASSWORD=clientes123
DB_NAME=clientes_db
DB_PORT=3306
```

### Puertos

- **8000**: Aplicación web (http://localhost:8000)
- **3307**: Base de datos (acceso externo desde host)
- **3306**: Base de datos (interno en red Docker)

---

## 💻 Desarrollo

### Comandos Esenciales

```bash
# Levantar entorno
docker compose up -d

# Ver logs
docker compose logs app -f

# Estado de contenedores
docker compose ps

# Detener
docker compose stop

# Reiniciar
docker compose restart app

# Limpiar todo
docker compose down -v
```

### Hot Reload Activado ♻️

Los cambios en archivos Python se reflejan automáticamente. No es necesario reiniciar el contenedor.

---

## 🧪 Funcionalidades

### Operaciones CRUD

- ✅ **Listar** todos los clientes (GET `/`)
- ✅ **Crear** nuevo cliente (POST `/guardar-cliente`)
- ✅ **Editar** cliente existente (GET/POST `/editar-cliente/{id}`)
- ✅ **Eliminar** cliente (POST `/eliminar-cliente/{id}`)

### Características Adicionales

- 🎨 Interfaz web responsive con Bootstrap
- 📊 Validación de datos en frontend y backend
- 🔄 Manejo de errores personalizado (404, 500)
- 🏥 Health check endpoint (`/ping`)
- 📝 Documentación automática de API (`/docs`)

---

## 🐛 Solución de Problemas

### Contenedores no inician
```bash
docker compose logs
docker compose down -v
docker compose up -d
```

### Puerto en uso
```bash
# Ver qué usa el puerto
sudo lsof -i :8000

# O cambiar puerto en docker-compose.override.yml
ports:
  - "8001:8000"
```

### Error de base de datos
```bash
# Reiniciar BD
docker compose restart db

# Recrear volumen (⚠️ pierde datos)
docker compose down -v
docker compose up -d
```

---

## 📊 Estado del Proyecto

### ✅ Completado

- [x] Aplicación FastAPI con templates Jinja2
- [x] Conexión a MySQL/MariaDB
- [x] CRUD completo de clientes
- [x] Interfaz web responsive
- [x] Dockerización completa
- [x] Hot reload en desarrollo
- [x] Documentación completa
- [x] Manejo de errores

### 🔄 En Progreso / Futuras Mejoras

- [ ] Tests unitarios y de integración
- [ ] CI/CD pipeline
- [ ] Validaciones avanzadas
- [ ] Paginación de resultados
- [ ] Búsqueda y filtros
- [ ] Autenticación de usuarios

---

## 👥 Contribuir

1. Hacer checkout de la rama `mysql`
2. Crear una rama feature: `git checkout -b feature/nueva-funcionalidad`
3. Commit de cambios: `git commit -m 'Agregar nueva funcionalidad'`
4. Push a la rama: `git push origin feature/nueva-funcionalidad`
5. Abrir un Pull Request hacia `mysql`

---

## 📄 Licencia

[Especificar licencia del proyecto]

---

## 📞 Contacto

Para preguntas o soporte, contacta al equipo de desarrollo.

---

**✨ Desarrollado con FastAPI, MySQL y Docker**