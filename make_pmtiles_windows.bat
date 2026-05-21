@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ============================================================
REM GeoTIFF to PMTiles Converter for Windows using QGIS Python
REM Fixed version: supports QGIS installed under "C:\Program Files\..."
REM
REM Put this BAT file in the same folder as:
REM   left.tif
REM   right.tif
REM
REM Output:
REM   left.pmtiles
REM   right.pmtiles
REM ============================================================

cd /d "%~dp0"

echo ======================================
echo GeoTIFF to PMTiles Converter for Windows
echo using QGIS Python
echo ======================================

set "LEFT_TIF=left.tif"
set "RIGHT_TIF=right.tif"
set "LEFT_PMTILES=left.pmtiles"
set "RIGHT_PMTILES=right.pmtiles"
set "VENV_DIR=pmtiles_env_qgis"

REM ------------------------------------------------------------
REM Check input files
REM ------------------------------------------------------------
if not exist "%LEFT_TIF%" (
    echo.
    echo ERROR: left.tif was not found.
    echo Put left.tif in the same folder as this BAT file.
    pause
    exit /b 1
)

if not exist "%RIGHT_TIF%" (
    echo.
    echo ERROR: right.tif was not found.
    echo Put right.tif in the same folder as this BAT file.
    pause
    exit /b 1
)

REM ------------------------------------------------------------
REM Find QGIS / OSGeo4W installation
REM ------------------------------------------------------------
set "QGIS_ROOT="

REM Standard standalone QGIS install path
for /d %%D in ("C:\Program Files\QGIS*") do (
    if exist "%%~fD\bin\o4w_env.bat" (
        set "QGIS_ROOT=%%~fD"
    )
)

REM Standard OSGeo4W install path
if not defined QGIS_ROOT (
    if exist "C:\OSGeo4W\bin\o4w_env.bat" (
        set "QGIS_ROOT=C:\OSGeo4W"
    )
)

if not defined QGIS_ROOT (
    echo.
    echo ERROR: QGIS or OSGeo4W was not found.
    echo This script searched these locations:
    echo   C:\Program Files\QGIS*
    echo   C:\OSGeo4W
    echo.
    echo If QGIS is installed in another folder, edit this BAT file and set QGIS_ROOT manually.
    echo Example:
    echo   set "QGIS_ROOT=C:\Program Files\QGIS 3.44.8"
    pause
    exit /b 1
)

echo.
echo QGIS_ROOT = %QGIS_ROOT%

REM Load OSGeo4W / QGIS environment
call "%QGIS_ROOT%\bin\o4w_env.bat"
if errorlevel 1 (
    echo.
    echo ERROR: Failed to load QGIS environment.
    pause
    exit /b 1
)

REM ------------------------------------------------------------
REM Find QGIS bundled Python
REM ------------------------------------------------------------
set "QGIS_PY="

for /d %%P in ("%QGIS_ROOT%\apps\Python*") do (
    if exist "%%~fP\python.exe" (
        set "QGIS_PY=%%~fP\python.exe"
    )
)

if not defined QGIS_PY (
    where python >nul 2>nul
    if %ERRORLEVEL%==0 (
        set "QGIS_PY=python"
    )
)

if not defined QGIS_PY (
    echo.
    echo ERROR: QGIS Python was not found.
    pause
    exit /b 1
)

echo QGIS_PY = %QGIS_PY%
"%QGIS_PY%" --version
if errorlevel 1 (
    echo.
    echo ERROR: Failed to run QGIS Python.
    pause
    exit /b 1
)

REM ------------------------------------------------------------
REM Create local virtual environment using QGIS Python
REM ------------------------------------------------------------
echo.
echo [1/5] Preparing local Python virtual environment...

if not exist "%VENV_DIR%" (
    "%QGIS_PY%" -m venv "%VENV_DIR%"
    if errorlevel 1 (
        echo.
        echo ERROR: Failed to create virtual environment.
        echo Try running this BAT file from the OSGeo4W Shell.
        pause
        exit /b 1
    )
)

call "%VENV_DIR%\Scripts\activate.bat"
if errorlevel 1 (
    echo.
    echo ERROR: Failed to activate virtual environment.
    pause
    exit /b 1
)

REM ------------------------------------------------------------
REM Install required tools into the local virtual environment
REM ------------------------------------------------------------
echo.
echo [2/5] Installing required tools into local virtual environment...
python -m pip install --upgrade pip
if errorlevel 1 (
    echo.
    echo ERROR: Failed to upgrade pip.
    pause
    exit /b 1
)

python -m pip install rasterio rio-pmtiles
if errorlevel 1 (
    echo.
    echo ERROR: Failed to install rasterio or rio-pmtiles.
    echo Check your internet connection.
    echo If this error continues, run this BAT file from the OSGeo4W Shell.
    pause
    exit /b 1
)

REM ------------------------------------------------------------
REM Remove existing outputs
REM ------------------------------------------------------------
echo.
echo [3/5] Removing existing PMTiles files...
if exist "%LEFT_PMTILES%" del /f /q "%LEFT_PMTILES%"
if exist "%RIGHT_PMTILES%" del /f /q "%RIGHT_PMTILES%"

REM ------------------------------------------------------------
REM Convert left.tif and right.tif
REM ------------------------------------------------------------
echo.
echo [4/5] Converting left.tif to left.pmtiles...
rio pmtiles "%LEFT_TIF%" "%LEFT_PMTILES%" --format JPEG --resampling bilinear --tile-size 512
if errorlevel 1 (
    echo.
    echo ERROR: Failed to convert left.tif.
    pause
    exit /b 1
)

echo.
echo [5/5] Converting right.tif to right.pmtiles...
rio pmtiles "%RIGHT_TIF%" "%RIGHT_PMTILES%" --format JPEG --resampling bilinear --tile-size 512
if errorlevel 1 (
    echo.
    echo ERROR: Failed to convert right.tif.
    pause
    exit /b 1
)

echo.
echo ======================================
echo Done.
echo Please check these files:
echo   %LEFT_PMTILES%
echo   %RIGHT_PMTILES%
echo ======================================

pause
endlocal
