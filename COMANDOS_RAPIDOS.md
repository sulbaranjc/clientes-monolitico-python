# ⚡ Comandos Rápidos - Docker Development

## 🌅 INICIO DEL DÍA

```bash
git pull origin mysql
docker compose up -d
docker compose ps
```

**URL**: http://localhost:8000

---

## 🔄 COMANDOS ESENCIALES

| Acción | Comando |
|--------|---------|
| **Levantar contenedores** | `docker compose up -d` |
| **Ver estado** | `docker compose ps` |
| **Ver logs** | `docker compose logs app -f` |
| **Detener contenedores** | `docker compose stop` |
| **Iniciar contenedores** | `docker compose start` |
| **Reiniciar app** | `docker compose restart app` |
| **Apagar todo** | `docker compose down` |
| **Apagar + borrar datos** | `docker compose down -v` |

---

## 🛠️ DESARROLLO

| Acción | Comando |
|--------|---------|
| **Ver logs en vivo** | `docker compose logs app -f` |
| **Acceder al contenedor** | `docker compose exec app bash` |
| **Reiniciar app** | `docker compose restart app` |
| **Reconstruir imagen** | `docker compose build --no-cache` |

---

## 🌙 FIN DEL DÍA

### Opción 1: Dejar corriendo (recomendado)
```bash
# No hacer nada - mañana solo editas código
```

### Opción 2: Liberar recursos
```bash
docker compose stop
```

### Opción 3: Limpieza completa
```bash
docker compose down
```

---

## 🆘 EMERGENCIAS

### Resetear todo
```bash
docker compose down -v
docker compose build --no-cache
docker compose up -d
```

### Ver errores
```bash
docker compose logs app --tail=100
docker compose logs db --tail=100
```

---

## 📍 URLs y Puertos

- **App**: http://localhost:8000
- **API Docs**: http://localhost:8000/docs
- **DB**: localhost:3307 (user: clientes, pass: clientes123)

---

## ✅ WORKFLOW COMPLETO

```bash
# MAÑANA
git pull origin mysql
docker compose up -d

# TRABAJO (editar archivos en app/)
docker compose logs app -f  # Si necesitas ver logs

# COMMIT
git add .
git commit -m "Mi cambio"
git push origin mysql

# NOCHE (opcional)
docker compose stop
```
