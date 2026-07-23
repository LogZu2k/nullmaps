@echo off
setlocal enabledelayedexpansion
title NullMaps - Khoi dong ban do
cd /d "%~dp0"

echo(
echo ==================================================
echo   NullMaps - dang khoi dong ban do Ho Tay / Ha Noi
echo ==================================================
echo(

REM --- Buoc 1: kiem tra Docker da cai chua ---
where docker >nul 2>&1
if errorlevel 1 (
  echo [LOI] Khong tim thay Docker tren may nay.
  echo       Hay cai "Docker Desktop" tu https://www.docker.com/products/docker-desktop
  echo       roi khoi dong lai may va chay lai file nay.
  echo(
  pause
  exit /b 1
)

REM --- Buoc 2: kiem tra Docker da chay chua ---
echo [1/4] Kiem tra Docker dang chay...
docker info >nul 2>&1
if errorlevel 1 (
  echo       Docker chua chay. Dang mo Docker Desktop, vui long doi...
  start "" "Docker Desktop"
  set /a _w=0
  :waitdocker
  timeout /t 3 >nul
  docker info >nul 2>&1
  if not errorlevel 1 goto dockerok
  set /a _w+=3
  if !_w! GEQ 120 (
    echo [LOI] Docker khong khoi dong sau 2 phut. Hay mo Docker Desktop thu cong roi chay lai.
    pause
    exit /b 1
  )
  echo       ...van dang doi Docker ^(!_w!s^)
  goto waitdocker
)
:dockerok
echo       Docker OK.
echo(

REM --- Buoc 3: build ban do neu chua co ---
if exist "data\vietnam.pmtiles" (
  echo [2/4] Da co ban do vietnam.pmtiles - bo qua buoc build.
) else (
  echo [2/4] Chua co ban do. Dang build lan dau ^(5-20 phut, cho chut nhe^)...
  echo       Man hinh se chay nhieu chu - do la binh thuong, dung dong cua so.
  docker run --rm -v "%cd%\data:/data" ghcr.io/onthegomap/planetiler:latest ^
    --osm-path=/data/raw/vietnam-latest.osm.pbf --download ^
    --maxzoom=16 --output=/data/vietnam.pmtiles --force
  if errorlevel 1 (
    echo [LOI] Build ban do that bai. Xem chu do o tren va gui lai cho toi.
    pause
    exit /b 1
  )
  echo       Build xong.
)
echo(

REM --- Buoc 4: bat cac dich vu ---
echo [3/4] Dang bat dich vu ban do...
docker compose up -d martin demo
if errorlevel 1 (
  echo [LOI] Khong bat duoc dich vu. Chay lenh sau roi gui ket qua cho toi:
  echo       docker compose logs martin
  pause
  exit /b 1
)
echo(

REM --- Cho martin san sang roi mo trinh duyet ---
echo [4/4] Dang cho ban do san sang...
set /a _t=0
:waitmap
timeout /t 2 >nul
curl -s -o nul "http://localhost:8081/" 2>nul
if not errorlevel 1 goto mapok
set /a _t+=2
if !_t! GEQ 40 (
  echo       Ban do chua phan hoi sau 40s - van thu mo trinh duyet.
  goto mapok
)
goto waitmap
:mapok
echo(
echo ==================================================
echo   XONG! Dang mo ban do trong trinh duyet...
echo   Dia chi: http://localhost:8081
echo ==================================================
start "" "http://localhost:8081"
echo(
echo   De TAT ban do sau nay, chay file: stop-nullmaps.bat
echo(
pause
