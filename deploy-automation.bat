@echo off
REM ====================================================================
REM SCRIPT DE AUTOMATIZACION - DESPLIEGUE A PRODUCCION (Windows)
REM ====================================================================
REM Automatiza el proceso de commit, push y merge a rama deploy
REM
REM USO:
REM   deploy-automation.bat                    # Detecta rama actual
REM   deploy-automation.bat main               # Especifica rama origen
REM   deploy-automation.bat feature/nueva-ui   # Desde feature branch
REM
REM PROCESO:
REM   1. Commit de todos los cambios en rama actual
REM   2. Push de rama actual
REM   3. Cambio a rama deploy
REM   4. Merge de rama origen a deploy
REM   5. Push de rama deploy
REM
REM REQUISITOS:
REM   - Git instalado (Git for Windows)
REM   - Git configurado (user.name, user.email)
REM   - Permisos de push al repositorio
REM   - Estar dentro de un repositorio Git
REM ====================================================================

REM Habilitar codificacion UTF-8 para mostrar emojis correctamente
chcp 65001 >nul 2>&1

REM Habilitar expansion de variables en tiempo de ejecucion
setlocal enabledelayedexpansion

REM --------------------------------------------------------------------
REM COLORES PARA CMD (usando codigo ANSI)
REM --------------------------------------------------------------------
REM Windows 10/11 soporta colores ANSI nativamente
set "COLOR_RESET=[0m"
set "COLOR_RED=[91m"
set "COLOR_GREEN=[92m"
set "COLOR_YELLOW=[93m"
set "COLOR_BLUE=[94m"
set "COLOR_CYAN=[96m"

REM --------------------------------------------------------------------
REM VALIDACIONES PREVIAS
REM --------------------------------------------------------------------

echo.
echo %COLOR_CYAN%VALIDANDO ENTORNO...%COLOR_RESET%
echo.

REM Verificar que Git esta instalado
where git >nul 2>&1
if errorlevel 1 (
    echo %COLOR_RED%ERROR: Git no esta instalado%COLOR_RESET%
    echo Descarga Git for Windows desde: https://git-scm.com/download/win
    pause
    exit /b 1
)

REM Verificar que estamos en un repositorio Git
git rev-parse --git-dir >nul 2>&1
if errorlevel 1 (
    echo %COLOR_RED%ERROR: No estas en un repositorio Git%COLOR_RESET%
    pause
    exit /b 1
)

REM Verificar que Git esta configurado
git config user.name >nul 2>&1
if errorlevel 1 (
    echo %COLOR_RED%ERROR: Git no esta configurado%COLOR_RESET%
    echo Ejecuta: git config --global user.name "Tu Nombre"
    pause
    exit /b 1
)

git config user.email >nul 2>&1
if errorlevel 1 (
    echo %COLOR_RED%ERROR: Git no esta configurado%COLOR_RESET%
    echo Ejecuta: git config --global user.email "tu@email.com"
    pause
    exit /b 1
)

echo %COLOR_GREEN%OK - Entorno validado correctamente%COLOR_RESET%

REM --------------------------------------------------------------------
REM DETECCION O PARAMETRO DE RAMA ORIGEN
REM --------------------------------------------------------------------

echo.
echo %COLOR_CYAN%IDENTIFICANDO RAMA DE ORIGEN...%COLOR_RESET%
echo.

REM Si se pasa parametro, usar ese; si no, detectar rama actual
if "%~1"=="" (
    REM Detectar rama actual automaticamente
    for /f "tokens=*" %%i in ('git branch --show-current') do set SOURCE_BRANCH=%%i
    
    if "!SOURCE_BRANCH!"=="" (
        echo %COLOR_RED%ERROR: No se pudo detectar la rama actual%COLOR_RESET%
        echo Pasa la rama como parametro: deploy-automation.bat nombre-rama
        pause
        exit /b 1
    )
    
    echo %COLOR_BLUE%INFO: Rama actual detectada: !SOURCE_BRANCH!%COLOR_RESET%
) else (
    set SOURCE_BRANCH=%~1
    echo %COLOR_BLUE%INFO: Rama especificada como parametro: !SOURCE_BRANCH!%COLOR_RESET%
    
    REM Verificar que la rama existe
    git show-ref --verify --quiet refs/heads/!SOURCE_BRANCH! >nul 2>&1
    if errorlevel 1 (
        echo %COLOR_RED%ERROR: La rama '!SOURCE_BRANCH!' no existe localmente%COLOR_RESET%
        pause
        exit /b 1
    )
    
    REM Cambiar a la rama especificada
    echo %COLOR_BLUE%INFO: Cambiando a rama !SOURCE_BRANCH!...%COLOR_RESET%
    git checkout !SOURCE_BRANCH!
    if errorlevel 1 (
        echo %COLOR_RED%ERROR: No se pudo cambiar a rama !SOURCE_BRANCH!%COLOR_RESET%
        pause
        exit /b 1
    )
)

REM Validacion: No permitir ejecutar desde deploy
if "!SOURCE_BRANCH!"=="deploy" (
    echo %COLOR_RED%ERROR: No puedes ejecutar este script desde la rama 'deploy'%COLOR_RESET%
    echo Cambiate a otra rama primero.
    pause
    exit /b 1
)

echo %COLOR_GREEN%OK - Rama de origen: !SOURCE_BRANCH!%COLOR_RESET%

REM --------------------------------------------------------------------
REM VERIFICAR ESTADO DEL REPOSITORIO
REM --------------------------------------------------------------------

echo.
echo %COLOR_CYAN%VERIFICANDO ESTADO DEL REPOSITORIO...%COLOR_RESET%
echo.

REM Verificar si hay cambios para commitear
git diff-index --quiet HEAD -- >nul 2>&1
if errorlevel 1 (
    echo %COLOR_BLUE%INFO: Se detectaron cambios pendientes%COLOR_RESET%
    echo.
    git status --short
    echo.
    set SKIP_COMMIT=false
) else (
    echo %COLOR_YELLOW%AVISO: No hay cambios pendientes en la rama !SOURCE_BRANCH!%COLOR_RESET%
    echo %COLOR_BLUE%INFO: Saltando el commit...%COLOR_RESET%
    set SKIP_COMMIT=true
)

REM --------------------------------------------------------------------
REM COMMIT DE CAMBIOS EN RAMA ORIGEN
REM --------------------------------------------------------------------

if "!SKIP_COMMIT!"=="false" (
    echo.
    echo %COLOR_CYAN%HACIENDO COMMIT DE TODOS LOS CAMBIOS...%COLOR_RESET%
    echo.
    
    REM Mensaje de commit predefinido
    set COMMIT_MESSAGE=Preparacion al pase de produccion
    
    REM Agregar todos los cambios
    echo %COLOR_BLUE%INFO: Agregando archivos al staging area...%COLOR_RESET%
    git add -A
    if errorlevel 1 (
        echo %COLOR_RED%ERROR: Error al agregar archivos%COLOR_RESET%
        pause
        exit /b 1
    )
    
    REM Hacer commit
    echo %COLOR_BLUE%INFO: Creando commit con mensaje: '!COMMIT_MESSAGE!'%COLOR_RESET%
    git commit -m "!COMMIT_MESSAGE!"
    if errorlevel 1 (
        echo %COLOR_RED%ERROR: Error al hacer commit%COLOR_RESET%
        pause
        exit /b 1
    )
    
    echo %COLOR_GREEN%OK - Commit realizado exitosamente%COLOR_RESET%
    
    REM Mostrar hash del commit
    for /f "tokens=*" %%i in ('git rev-parse --short HEAD') do set COMMIT_HASH=%%i
    echo %COLOR_BLUE%INFO: Hash del commit: !COMMIT_HASH!%COLOR_RESET%
)

REM --------------------------------------------------------------------
REM PUSH DE RAMA ORIGEN
REM --------------------------------------------------------------------

echo.
echo %COLOR_CYAN%HACIENDO PUSH DE RAMA !SOURCE_BRANCH!...%COLOR_RESET%
echo.

REM Obtener nombre del remote (usualmente 'origin')
for /f "tokens=*" %%i in ('git remote') do set REMOTE=%%i & goto :found_remote
:found_remote

if "!REMOTE!"=="" (
    echo %COLOR_RED%ERROR: No se encontro un remote configurado%COLOR_RESET%
    pause
    exit /b 1
)

echo %COLOR_BLUE%INFO: Remote detectado: !REMOTE!%COLOR_RESET%
echo %COLOR_BLUE%INFO: Ejecutando: git push !REMOTE! !SOURCE_BRANCH!%COLOR_RESET%

git push !REMOTE! !SOURCE_BRANCH!
if errorlevel 1 (
    echo %COLOR_RED%ERROR: Error al hacer push de !SOURCE_BRANCH!%COLOR_RESET%
    echo Verifica tu conexion y permisos.
    pause
    exit /b 1
)

echo %COLOR_GREEN%OK - Push de !SOURCE_BRANCH! completado%COLOR_RESET%

REM --------------------------------------------------------------------
REM CAMBIO A RAMA DEPLOY
REM --------------------------------------------------------------------

echo.
echo %COLOR_CYAN%CAMBIANDO A RAMA DEPLOY...%COLOR_RESET%
echo.

REM Verificar si la rama deploy existe localmente
git show-ref --verify --quiet refs/heads/deploy >nul 2>&1
if errorlevel 1 (
    REM Si no existe localmente, intentar desde remoto
    echo %COLOR_YELLOW%AVISO: Rama deploy no existe localmente%COLOR_RESET%
    
    git show-ref --verify --quiet refs/remotes/!REMOTE!/deploy >nul 2>&1
    if errorlevel 1 (
        REM No existe ni local ni remotamente
        echo %COLOR_YELLOW%AVISO: Rama deploy no existe ni local ni remotamente%COLOR_RESET%
        set /p CREAR="Deseas crear la rama deploy desde !SOURCE_BRANCH!? (s/N): "
        
        if /i "!CREAR!"=="s" (
            echo %COLOR_BLUE%INFO: Creando nueva rama deploy...%COLOR_RESET%
            git checkout -b deploy
            if errorlevel 1 (
                echo %COLOR_RED%ERROR: Error al crear rama deploy%COLOR_RESET%
                pause
                exit /b 1
            )
        ) else (
            echo %COLOR_RED%Operacion cancelada por el usuario%COLOR_RESET%
            pause
            exit /b 1
        )
    ) else (
        REM Existe en remoto, crear desde ahi
        echo %COLOR_BLUE%INFO: Creando rama deploy desde !REMOTE!/deploy%COLOR_RESET%
        git checkout -b deploy !REMOTE!/deploy
        if errorlevel 1 (
            echo %COLOR_RED%ERROR: Error al crear rama deploy%COLOR_RESET%
            pause
            exit /b 1
        )
    )
) else (
    REM La rama deploy existe localmente
    echo %COLOR_BLUE%INFO: Rama deploy existe localmente%COLOR_RESET%
    git checkout deploy
    if errorlevel 1 (
        echo %COLOR_RED%ERROR: Error al cambiar a rama deploy%COLOR_RESET%
        pause
        exit /b 1
    )
)

echo %COLOR_GREEN%OK - Ahora estas en rama deploy%COLOR_RESET%

REM --------------------------------------------------------------------
REM ACTUALIZAR RAMA DEPLOY DESDE REMOTO
REM --------------------------------------------------------------------

echo.
echo %COLOR_CYAN%ACTUALIZANDO RAMA DEPLOY DESDE REMOTO...%COLOR_RESET%
echo.

git pull !REMOTE! deploy >nul 2>&1
if errorlevel 1 (
    echo %COLOR_BLUE%INFO: No se pudo actualizar desde remoto (posiblemente rama nueva)%COLOR_RESET%
) else (
    echo %COLOR_GREEN%OK - Rama deploy actualizada desde remoto%COLOR_RESET%
)

REM --------------------------------------------------------------------
REM MERGE DE RAMA ORIGEN A DEPLOY
REM --------------------------------------------------------------------

echo.
echo %COLOR_CYAN%MERGEANDO !SOURCE_BRANCH! EN DEPLOY...%COLOR_RESET%
echo.

echo %COLOR_BLUE%INFO: Ejecutando: git merge !SOURCE_BRANCH!%COLOR_RESET%

git merge !SOURCE_BRANCH! --no-edit -m "Merge !SOURCE_BRANCH! -> deploy: Preparacion al pase de produccion"
if errorlevel 1 (
    echo %COLOR_RED%ERROR: Conflictos de merge detectados%COLOR_RESET%
    echo Resuelvelos manualmente y ejecuta:
    echo   git merge --continue
    echo   git push !REMOTE! deploy
    pause
    exit /b 1
)

echo %COLOR_GREEN%OK - Merge completado exitosamente%COLOR_RESET%

REM Mostrar ultimo commit
for /f "tokens=*" %%i in ('git log -1 --oneline') do set LAST_COMMIT=%%i
echo %COLOR_BLUE%INFO: Ultimo commit en deploy: !LAST_COMMIT!%COLOR_RESET%

REM --------------------------------------------------------------------
REM PUSH DE RAMA DEPLOY
REM --------------------------------------------------------------------

echo.
echo %COLOR_CYAN%HACIENDO PUSH DE RAMA DEPLOY...%COLOR_RESET%
echo.

echo %COLOR_BLUE%INFO: Ejecutando: git push !REMOTE! deploy%COLOR_RESET%

git push !REMOTE! deploy
if errorlevel 1 (
    echo %COLOR_RED%ERROR: Error al hacer push de deploy%COLOR_RESET%
    echo Verifica tu conexion y permisos.
    pause
    exit /b 1
)

echo %COLOR_GREEN%OK - Push de deploy completado%COLOR_RESET%

REM --------------------------------------------------------------------
REM RESUMEN FINAL
REM --------------------------------------------------------------------

echo.
echo ================================================================
echo           DESPLIEGUE COMPLETADO EXITOSAMENTE
echo ================================================================
echo.
echo %COLOR_GREEN%OK - Rama origen: !SOURCE_BRANCH!%COLOR_RESET%
echo %COLOR_GREEN%OK - Rama destino: deploy%COLOR_RESET%
echo %COLOR_GREEN%OK - Cambios enviados al servidor remoto%COLOR_RESET%
echo.
echo %COLOR_BLUE%INFO: El workflow de GitHub Actions se ejecutara automaticamente%COLOR_RESET%
echo %COLOR_BLUE%INFO: Monitorea el despliegue en: https://github.com/^<tu-usuario^>/^<tu-repo^>/actions%COLOR_RESET%
echo.
echo %COLOR_YELLOW%AVISO: Recuerda regresar a tu rama de trabajo:%COLOR_RESET%
echo   git checkout !SOURCE_BRANCH!
echo.

REM --------------------------------------------------------------------
REM OPCION DE REGRESAR A RAMA ORIGEN
REM --------------------------------------------------------------------

set /p REGRESAR="Deseas regresar a la rama !SOURCE_BRANCH! ahora? (S/n): "

if /i not "!REGRESAR!"=="n" (
    git checkout !SOURCE_BRANCH!
    echo %COLOR_GREEN%OK - De vuelta en rama !SOURCE_BRANCH!%COLOR_RESET%
)

echo.
echo %COLOR_CYAN%Script finalizado con exito%COLOR_RESET%
echo.
pause
exit /b 0
