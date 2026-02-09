# 🚀 Guía de Desarrollo - Clientes Monolítico Python

## 📋 Requisitos Previos

- Docker y Docker Compose instalados
- Git configurado
- Puerto 8000 (app) y 3307 (DB) disponibles

---

## 🌅 AL COMENZAR EL DÍA (Primera vez)

### 1. Clonar el repositorio (solo primera vez)
```bash
git clone <URL_DEL_REPOSITORIO>
cd clientes-monolitico-python
```

### 2. Seleccionar la rama de desarrollo
```bash
git checkout mysql
```

### 3. Levantar el entorno de desarrollo
```bash
docker compose up -d
```

**¿Qué hace este comando?**
- `-d`: Ejecuta los contenedores en segundo plano (detached mode)
- Levanta 2 contenedores:
  - `clientes-monolitico`: Aplicación FastAPI
  - `clientes-db`: Base de datos MariaDB

### 4. Verificar que los contenedores estén corriendo
```bash
docker compose ps
```

**Salida esperada:**
```
NAME                  STATUS         PORTS
clientes-monolitico   Up X seconds   0.0.0.0:8000->8000/tcp
clientes-db           Up X seconds   0.0.0.0:3307->3306/tcp
```

### 5. Ver los logs de la aplicación
```bash
docker compose logs app -f
```
- Presiona `Ctrl+C` para salir de los logs
- Deberías ver: `INFO: Application startup complete.`

### 6. Acceder a la aplicación
- **Interfaz web**: http://localhost:8000
- **API Docs**: http://localhost:8000/docs
- **Health check**: http://localhost:8000/ping

---

## 🌅 AL COMENZAR EL DÍA (días siguientes)

### 1. Actualizar código
```bash
git pull origin mysql
```

### 2. Levantar los contenedores
```bash
docker compose up -d
```

### 3. Verificar estado
```bash
docker compose ps
docker compose logs app --tail=50
```

---

## 💻 DURANTE EL DESARROLLO

### Editar código
- Edita los archivos en `app/` usando tu editor favorito
- Los cambios se reflejan **automáticamente** (hot reload activado)
- No necesitas reiniciar el contenedor

### Ver logs en tiempo real
```bash
docker compose logs app -f
```

### Reiniciar solo la aplicación (si es necesario)
```bash
docker compose restart app
```

### Acceder al contenedor (shell)
```bash
docker compose exec app bash
```

### Ejecutar comandos Python en el contenedor
```bash
docker compose exec app python -m pip list
```

### Ver logs de la base de datos
```bash
docker compose logs db -f
```

### Conectarse a la base de datos (desde tu máquina)
```bash
mysql -h 127.0.0.1 -P 3307 -u clientes -p
# Password: clientes123
```

---

## 🔄 COMANDOS ÚTILES

### Ver estado de contenedores
```bash
docker compose ps
```

### Ver uso de recursos
```bash
docker stats
```

### Limpiar logs antiguos
```bash
docker compose logs --tail=0 -f
```

### Reconstruir imagen (después de cambiar requirements.txt)
```bash
docker compose down
docker compose build --no-cache
docker compose up -d
```

### Resetear la base de datos
```bash
docker compose down -v  # Elimina volúmenes
docker compose up -d    # Recrea todo con datos frescos
```

---

## 🌙 AL TERMINAR EL DÍA

### Opción 1: Dejar contenedores corriendo (recomendado)
```bash
# No hacer nada - los contenedores siguen corriendo
# Ventaja: al día siguiente solo editas código y trabajas
```

### Opción 2: Detener contenedores (libera recursos)
```bash
docker compose stop
```
**Al día siguiente:**
```bash
docker compose start
```

### Opción 3: Apagar y eliminar contenedores (limpieza completa)
```bash
docker compose down
```
> ⚠️ **Nota**: Los datos de la BD se mantienen en el volumen `db_data`

**Al día siguiente:**
```bash
docker compose up -d
```

---

## 🆘 SOLUCIÓN DE PROBLEMAS

### Los contenedores no inician
```bash
# Ver qué pasó
docker compose logs

# Eliminar todo y empezar de cero
docker compose down -v
docker compose up -d
```

### Error de puerto en uso
```bash
# Ver qué proceso usa el puerto 8000
sudo lsof -i :8000

# O cambiar el puerto en docker-compose.override.yml
ports:
  - "8001:8000"  # Cambia 8000 a 8001
```

### La aplicación no recarga automáticamente
```bash
# Reiniciar el contenedor
docker compose restart app

# Ver logs para detectar errores
docker compose logs app --tail=100
```

### Error de conexión a la base de datos
```bash
# Verificar que la BD esté corriendo
docker compose ps db

# Ver logs de la BD
docker compose logs db

# Reiniciar la BD
docker compose restart db
```

### Limpiar todo (último recurso)
```bash
# Detener y eliminar todo
docker compose down -v

# Eliminar imágenes viejas
docker rmi clientes-monolitico-python-app

# Reconstruir desde cero
docker compose build --no-cache
docker compose up -d
```

---

## 📝 WORKFLOW RECOMENDADO

### Mañana
```bash
# 1. Actualizar código
git pull origin mysql

# 2. Si los contenedores están detenidos:
docker compose up -d

# 3. Verificar
docker compose ps
docker compose logs app --tail=20

# 4. Abrir navegador en http://localhost:8000
# 5. Empezar a codear
```

### Durante el día
```bash
# Editar archivos en app/
# Los cambios se reflejan automáticamente
# Ver logs si hay errores: docker compose logs app -f
```

### Noche
```bash
# Opción A: Dejar corriendo (recomendado)
# No hacer nada

# Opción B: Liberar recursos
docker compose stop

# Opción C: Limpieza completa (solo si es necesario)
docker compose down
```

---

## 🔧 VARIABLES DE ENTORNO

Las credenciales están en `.env`:
```env
DB_HOST=clientes-db
DB_USER=clientes
DB_PASSWORD=clientes123
DB_NAME=clientes_db
DB_PORT=3306
```

**No commitear** cambios en `.env` con credenciales de producción.

---

## 📦 ESTRUCTURA DEL PROYECTO

```
.
├── app/
│   ├── main.py              # Aplicación FastAPI
│   ├── database.py          # Conexión a MySQL
│   ├── static/              # CSS, JS, imágenes
│   └── templates/           # Plantillas HTML
├── docker-compose.yml       # Configuración de producción
├── docker-compose.override.yml  # Configuración de desarrollo
├── Dockerfile               # Imagen de la app
├── requirements.txt         # Dependencias Python
├── init_db.sql             # Script inicial de BD
└── .env                    # Variables de entorno
```

---

## 🚢 PUERTOS

- **8000**: Aplicación web (http://localhost:8000)
- **3307**: Base de datos MySQL (desde tu máquina)
- **3306**: Base de datos MySQL (dentro de Docker)

---

## ✅ CHECKLIST DIARIO

**Al comenzar:**
- [ ] `git pull origin mysql`
- [ ] `docker compose up -d`
- [ ] `docker compose ps` (verificar estado)
- [ ] Abrir http://localhost:8000

**Durante el desarrollo:**
- [ ] Editar código en `app/`
- [ ] Ver cambios automáticamente en el navegador
- [ ] Revisar logs si hay errores

**Al terminar:**
- [ ] `git add .`
- [ ] `git commit -m "Descripción de cambios"`
- [ ] `git push origin mysql`
- [ ] `docker compose stop` (opcional)

---

## 📚 RECURSOS ADICIONALES

- **Documentación FastAPI**: https://fastapi.tiangolo.com
- **Docker Compose**: https://docs.docker.com/compose/
- **MariaDB**: https://mariadb.org/documentation/

---

**¿Necesitas ayuda?** Contacta al equipo de DevOps o revisa la sección de "Solución de Problemas".
