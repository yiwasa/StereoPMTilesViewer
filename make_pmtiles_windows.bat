@echo off
setlocal enabledelayedexpansion

REM ============================================================
REM GeoTIFF to PMTiles Converter for Windows
REM
REM Required input files in the same folder:
REM   left.tif
REM   right.tif
REM
REM Output files:
REM   left.pmtiles
REM   right.pmtiles
REM ============================================================

chcp 65001 >nul

echo ======================================
echo GeoTIFF to PMTiles Converter for Windows
echo ======================================

REM Move to the folder where this BAT file exists
cd /d "%~dp0"

set LEFT_TIF=left.tif
set RIGHT_TIF=right.tif
set LEFT_PMTILES=left.pmtiles
set RIGHT_PMTILES=right.pmtiles
set VENV_DIR=pmtiles_env

REM ------------------------------------------------------------
REM Check input files
REM ------------------------------------------------------------
if not exist "%LEFT_TIF%" (
    echo.
    echo ERROR: %LEFT_TIF% が見つかりません。
    echo make_pmtiles_windows.bat と同じフォルダに left.tif を置いてください。
    pause
    exit /b 1
)

if not exist "%RIGHT_TIF%" (
    echo.
    echo ERROR: %RIGHT_TIF% が見つかりません。
    echo make_pmtiles_windows.bat と同じフォルダに right.tif を置いてください。
    pause
    exit /b 1
)

REM ------------------------------------------------------------
REM Find Python
REM ------------------------------------------------------------
where py >nul 2>nul
if %ERRORLEVEL%==0 (
    set PYTHON_CMD=py -3
) else (
    where python >nul 2>nul
    if %ERRORLEVEL%==0 (
        set PYTHON_CMD=python
    ) else (
        echo.
        echo ERROR: Python が見つかりません。
        echo Python 3 をインストールしてから再実行してください。
        echo https://www.python.org/downloads/windows/
        pause
        exit /b 1
    )
)

echo.
echo [1/5] Python仮想環境を準備しています...
if not exist "%VENV_DIR%" (
    %PYTHON_CMD% -m venv "%VENV_DIR%"
    if errorlevel 1 (
        echo.
        echo ERROR: Python仮想環境の作成に失敗しました。
        pause
        exit /b 1
    )
)

call "%VENV_DIR%\Scripts\activate.bat"
if errorlevel 1 (
    echo.
    echo ERROR: Python仮想環境を有効化できませんでした。
    pause
    exit /b 1
)

echo.
echo [2/5] 必要な変換ツールをインストールしています...
python -m pip install --upgrade pip
if errorlevel 1 (
    echo.
    echo ERROR: pip の更新に失敗しました。
    pause
    exit /b 1
)

python -m pip install rasterio rio-pmtiles
if errorlevel 1 (
    echo.
    echo ERROR: rasterio または rio-pmtiles のインストールに失敗しました。
    echo インターネット接続を確認してください。
    pause
    exit /b 1
)

echo.
echo [3/5] 既存のPMTilesを削除しています...
if exist "%LEFT_PMTILES%" del /f /q "%LEFT_PMTILES%"
if exist "%RIGHT_PMTILES%" del /f /q "%RIGHT_PMTILES%"

echo.
echo [4/5] 左画像をPMTilesに変換しています...
rio pmtiles "%LEFT_TIF%" "%LEFT_PMTILES%" --format JPEG --resampling bilinear --tile-size 512
if errorlevel 1 (
    echo.
    echo ERROR: 左画像のPMTiles変換に失敗しました。
    pause
    exit /b 1
)

echo.
echo [5/5] 右画像をPMTilesに変換しています...
rio pmtiles "%RIGHT_TIF%" "%RIGHT_PMTILES%" --format JPEG --resampling bilinear --tile-size 512
if errorlevel 1 (
    echo.
    echo ERROR: 右画像のPMTiles変換に失敗しました。
    pause
    exit /b 1
)

echo.
echo ======================================
echo 完了しました
echo 次の2ファイルを確認してください
echo %LEFT_PMTILES%
echo %RIGHT_PMTILES%
echo ======================================

pause
endlocal
