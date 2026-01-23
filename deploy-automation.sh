#!/bin/bash

# ====================================================================
# SCRIPT DE AUTOMATIZACIÓN - DESPLIEGUE A PRODUCCIÓN
# ====================================================================
# Automatiza el proceso de commit, push y merge a rama deploy
#
# USO:
#   deploy-automation.sh                                     # Detecta rama actual
#   deploy-automation.sh main                                # Especifica rama origen
#   deploy-automation.sh feature/nueva-ui                    # Desde feature branch
#   deploy-automation.sh /path/to/proyecto main              # Con ruta del proyecto
#
# PROCESO:
#   1. Commit de todos los cambios en rama actual
#   2. Push de rama actual
#   3. Cambio a rama deploy
#   4. Merge de rama origen a deploy
#   5. Push de rama deploy
#
# REQUISITOS:
#   - Git configurado
#   - Permisos de push al repositorio
#   - Estar dentro de un repositorio Git (o especificar ruta)
# ====================================================================

# Detección automática de ruta del proyecto
# Si se pasa como parámetro 1, usar ese; si no, detectar directorio actual
if [[ "$1" == /* ]] || [[ "$1" == ./* ]]; then
    # Si el primer parámetro es una ruta absoluta o relativa
    PROJECT_DIR="$1"
    shift  # Quitar el primer parámetro
else
    # Si no se pasa ruta, usar el directorio actual
    PROJECT_DIR="."
fi

# Validar que el directorio existe
if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "\033[0;31m❌ ERROR: El directorio '$PROJECT_DIR' no existe\033[0m" >&2
    exit 1
fi

# Cambiar al directorio del proyecto
cd "$PROJECT_DIR" || exit 1

# --------------------------------------------------------------------
# CONFIGURACIÓN DE COLORES PARA OUTPUT
# --------------------------------------------------------------------
# Mejora la legibilidad de mensajes en terminal
COLOR_RESET='\033[0m'
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[1;33m'
COLOR_BLUE='\033[0;34m'
COLOR_CYAN='\033[0;36m'

# --------------------------------------------------------------------
# FUNCIONES AUXILIARES
# --------------------------------------------------------------------

# Imprime mensaje de error en rojo y termina script
error() {
    echo -e "${COLOR_RED}❌ ERROR: $1${COLOR_RESET}" >&2
    exit 1
}

# Imprime mensaje de éxito en verde
success() {
    echo -e "${COLOR_GREEN}✅ $1${COLOR_RESET}"
}

# Imprime mensaje informativo en azul
info() {
    echo -e "${COLOR_BLUE}ℹ️  $1${COLOR_RESET}"
}

# Imprime mensaje de advertencia en amarillo
warning() {
    echo -e "${COLOR_YELLOW}⚠️  $1${COLOR_RESET}"
}

# Imprime paso del proceso en cyan
step() {
    echo -e "\n${COLOR_CYAN}▶ $1${COLOR_RESET}"
}

# --------------------------------------------------------------------
# VALIDACIONES PREVIAS
# --------------------------------------------------------------------

step "Validando entorno..."

# Verificar que estamos dentro de un repositorio Git
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    error "No estás en un repositorio Git"
fi

# Verificar que Git está configurado
if ! git config user.name > /dev/null 2>&1; then
    error "Git no está configurado. Ejecuta: git config --global user.name 'Tu Nombre'"
fi

if ! git config user.email > /dev/null 2>&1; then
    error "Git no está configurado. Ejecuta: git config --global user.email 'tu@email.com'"
fi

success "Entorno validado correctamente"

# --------------------------------------------------------------------
# DETECCIÓN O PARÁMETRO DE RAMA ORIGEN
# --------------------------------------------------------------------

step "Identificando rama de origen..."

# Si se pasa parámetro, usar ese; si no, detectar rama actual
if [ -n "$1" ]; then
    SOURCE_BRANCH="$1"
    info "Rama especificada como parámetro: $SOURCE_BRANCH"
    
    # Verificar que la rama existe
    if ! git show-ref --verify --quiet refs/heads/"$SOURCE_BRANCH"; then
        error "La rama '$SOURCE_BRANCH' no existe localmente"
    fi
    
    # Cambiar a la rama especificada
    info "Cambiando a rama $SOURCE_BRANCH..."
    git checkout "$SOURCE_BRANCH" || error "No se pudo cambiar a rama $SOURCE_BRANCH"
else
    # Detectar rama actual automáticamente
    SOURCE_BRANCH=$(git branch --show-current)
    
    # Validar que se pudo detectar la rama
    if [ -z "$SOURCE_BRANCH" ]; then
        error "No se pudo detectar la rama actual. Pasa la rama como parámetro: ./deploy-automation.sh nombre-rama"
    fi
    
    info "Rama actual detectada: $SOURCE_BRANCH"
fi

# Validación: No permitir ejecutar desde deploy (loop infinito)
if [ "$SOURCE_BRANCH" = "deploy" ]; then
    error "No puedes ejecutar este script desde la rama 'deploy'. Cámbiate a otra rama primero."
fi

success "Rama de origen: $SOURCE_BRANCH"

# --------------------------------------------------------------------
# VERIFICAR ESTADO DEL REPOSITORIO
# --------------------------------------------------------------------

step "Verificando estado del repositorio..."

# Verificar si hay cambios para commitear
if git diff-index --quiet HEAD --; then
    warning "No hay cambios pendientes en la rama $SOURCE_BRANCH"
    info "Saltando el commit..."
    SKIP_COMMIT=true
else
    info "Se detectaron cambios pendientes"
    SKIP_COMMIT=false
    
    # Mostrar resumen de cambios
    echo ""
    git status --short
    echo ""
fi

# --------------------------------------------------------------------
# COMMIT DE CAMBIOS EN RAMA ORIGEN
# --------------------------------------------------------------------

if [ "$SKIP_COMMIT" = false ]; then
    step "Haciendo commit de todos los cambios..."
    
    # Mensaje de commit predefinido
    COMMIT_MESSAGE="Preparación al pase de producción"
    
    # Agregar todos los cambios (tracked y untracked)
    info "Agregando archivos al staging area..."
    git add -A || error "Error al agregar archivos"
    
    # Hacer commit
    info "Creando commit con mensaje: '$COMMIT_MESSAGE'"
    git commit -m "$COMMIT_MESSAGE" || error "Error al hacer commit"
    
    success "Commit realizado exitosamente"
    
    # Mostrar hash del commit
    COMMIT_HASH=$(git rev-parse --short HEAD)
    info "Hash del commit: $COMMIT_HASH"
fi

# --------------------------------------------------------------------
# PUSH DE RAMA ORIGEN
# --------------------------------------------------------------------

step "Haciendo push de rama $SOURCE_BRANCH..."

# Obtener nombre del remote (usualmente 'origin')
REMOTE=$(git remote | head -n 1)
if [ -z "$REMOTE" ]; then
    error "No se encontró un remote configurado"
fi

info "Remote detectado: $REMOTE"

# Hacer push de la rama actual
info "Ejecutando: git push $REMOTE $SOURCE_BRANCH"
if git push "$REMOTE" "$SOURCE_BRANCH"; then
    success "Push de $SOURCE_BRANCH completado"
else
    error "Error al hacer push de $SOURCE_BRANCH. Verifica tu conexión y permisos."
fi

# --------------------------------------------------------------------
# CAMBIO A RAMA DEPLOY
# --------------------------------------------------------------------

step "Cambiando a rama deploy..."

# Verificar si la rama deploy existe localmente
if git show-ref --verify --quiet refs/heads/deploy; then
    info "Rama deploy existe localmente"
    git checkout deploy || error "Error al cambiar a rama deploy"
else
    # Si no existe localmente, intentar crearla desde remoto
    warning "Rama deploy no existe localmente"
    
    if git show-ref --verify --quiet refs/remotes/"$REMOTE"/deploy; then
        info "Creando rama deploy desde $REMOTE/deploy"
        git checkout -b deploy "$REMOTE"/deploy || error "Error al crear rama deploy"
    else
        # Si tampoco existe en remoto, preguntar si crear
        warning "Rama deploy no existe ni local ni remotamente"
        read -p "¿Deseas crear la rama deploy desde $SOURCE_BRANCH? (s/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            info "Creando nueva rama deploy..."
            git checkout -b deploy || error "Error al crear rama deploy"
        else
            error "Operación cancelada por el usuario"
        fi
    fi
fi

success "Ahora estás en rama deploy"

# --------------------------------------------------------------------
# ACTUALIZAR RAMA DEPLOY DESDE REMOTO
# --------------------------------------------------------------------

step "Actualizando rama deploy desde remoto..."

# Intentar hacer pull (puede fallar si la rama es nueva)
if git pull "$REMOTE" deploy 2>/dev/null; then
    success "Rama deploy actualizada desde remoto"
else
    info "No se pudo actualizar desde remoto (posiblemente rama nueva)"
fi

# --------------------------------------------------------------------
# MERGE DE RAMA ORIGEN A DEPLOY
# --------------------------------------------------------------------

step "Mergeando $SOURCE_BRANCH en deploy..."

info "Ejecutando: git merge $SOURCE_BRANCH"

# Intentar merge
if git merge "$SOURCE_BRANCH" --no-edit -m "Merge $SOURCE_BRANCH -> deploy: Preparación al pase de producción"; then
    success "Merge completado exitosamente"
    
    # Mostrar último commit
    LAST_COMMIT=$(git log -1 --oneline)
    info "Último commit en deploy: $LAST_COMMIT"
else
    error "Conflictos de merge detectados. Resuélvelos manualmente y ejecuta:
    git merge --continue
    git push $REMOTE deploy"
fi

# --------------------------------------------------------------------
# PUSH DE RAMA DEPLOY
# --------------------------------------------------------------------

step "Haciendo push de rama deploy..."

info "Ejecutando: git push $REMOTE deploy"

if git push "$REMOTE" deploy; then
    success "Push de deploy completado"
else
    error "Error al hacer push de deploy. Verifica tu conexión y permisos."
fi

# --------------------------------------------------------------------
# RESUMEN FINAL
# --------------------------------------------------------------------

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║          🎉 DESPLIEGUE COMPLETADO EXITOSAMENTE 🎉          ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
success "Rama origen: $SOURCE_BRANCH"
success "Rama destino: deploy"
success "Cambios enviados al servidor remoto"
echo ""
info "El workflow de GitHub Actions se ejecutará automáticamente"
info "Monitorea el despliegue en: https://github.com/<tu-usuario>/<tu-repo>/actions"
echo ""
warning "Recuerda regresar a tu rama de trabajo:"
echo "  git checkout $SOURCE_BRANCH"
echo ""

# --------------------------------------------------------------------
# OPCIÓN DE REGRESAR A RAMA ORIGEN
# --------------------------------------------------------------------

read -p "¿Deseas regresar a la rama $SOURCE_BRANCH ahora? (S/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    git checkout "$SOURCE_BRANCH"
    success "De vuelta en rama $SOURCE_BRANCH"
fi

echo ""
info "Script finalizado con éxito ✨"
exit 0
