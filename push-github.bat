@echo off
setlocal
title NullMaps - Day code len GitHub
cd /d "%~dp0"

echo(
echo ==================================================
echo   Day code NullMaps len GitHub
echo   Repo: https://github.com/LogZu2k/nullmaps
echo ==================================================
echo(

REM --- Kiem tra git da cai chua ---
where git >nul 2>&1
if errorlevel 1 (
  echo [LOI] Khong tim thay Git tren may. Cai tu https://git-scm.com/download/win
  echo       roi khoi dong lai may va chay lai file nay.
  pause
  exit /b 1
)

REM --- Xoa file khoa ket neu con sot ---
if exist ".git\index.lock" (
  echo [*] Don file khoa cu...
  del /f /q ".git\index.lock" >nul 2>&1
)

REM --- Tro toi repo dich (repo moi: LogZu2k/nullmaps) ---
echo [*] Dat dia chi repo dich...
git remote set-url origin https://github.com/LogZu2k/nullmaps.git 2>nul || git remote add origin https://github.com/LogZu2k/nullmaps.git

echo [1/3] Ghi nhan thay doi...
git add -A
if errorlevel 1 ( echo [LOI] git add that bai. & pause & exit /b 1 )

REM --- Xin cau ghi chu cho lan luu nay ---
set "MSG="
set /p MSG="Nhap ghi chu ngan cho lan luu nay (Enter de dung mac dinh): "
if "%MSG%"=="" set "MSG=Update NullMaps"

echo(
echo [2/3] Luu lai (commit)...
git commit -m "%MSG%"
if errorlevel 1 (
  echo [!] Khong co gi moi de luu, hoac commit that bai. Van thu day len...
)

echo(
echo [3/3] Day len GitHub...
echo       Neu hien cua so dang nhap GitHub, hay dang nhap de cho phep.
git push -u origin HEAD
if errorlevel 1 (
  echo(
  echo [LOI] Day len that bai. Ly do thuong gap:
  echo   - Chua dang nhap GitHub: chay lai file nay va lam theo cua so dang nhap hien ra.
  echo   - Hoac cai "Git Credential Manager" de luu dang nhap.
  echo   Chup man hinh chu do o tren va gui lai neu can tro giup.
  pause
  exit /b 1
)

echo(
echo ==================================================
echo   XONG! Code da len https://github.com/LogZu2k/nullmaps
echo ==================================================
pause
