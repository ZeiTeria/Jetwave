@echo off
setlocal

cd /d "%~dp0"

echo ============================================
echo   JetWave - Sync with GitHub
echo ============================================
echo.

where git >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Git is not installed or not on PATH.
    echo Please install Git from https://git-scm.com/downloads
    echo.
    pause
    exit /b 1
)

echo [1/4] Fetching latest changes from GitHub...
git fetch origin
if errorlevel 1 (
    echo [ERROR] Fetch failed. Check your internet connection.
    pause
    exit /b 1
)

echo.
echo [2/4] Pulling latest changes (merge)...
git pull origin main
if errorlevel 1 (
    echo.
    echo [ERROR] Pull failed - likely a merge conflict.
    echo Open this folder in a Git tool or ask for help to resolve it.
    pause
    exit /b 1
)

set TIMESTAMP=%date% %time%

echo.
echo [3/4] Checking for local changes to commit...
git diff --quiet
set HAS_UNSTAGED=%errorlevel%
git diff --cached --quiet
set HAS_STAGED=%errorlevel%
set HAS_UNTRACKED=0
for /f %%i in ('git ls-files --others --exclude-standard') do set HAS_UNTRACKED=1

if "%HAS_UNSTAGED%%HAS_STAGED%%HAS_UNTRACKED%"=="000" (
    echo No local changes to commit.
) else (
    git add -A
    git commit -m "Auto sync update: %TIMESTAMP%"
    if errorlevel 1 (
        echo [ERROR] Commit failed.
        pause
        exit /b 1
    )
)

echo.
echo [4/4] Pushing to GitHub...
git push origin main
if errorlevel 1 (
    echo.
    echo [ERROR] Push failed. Ask for help before retrying.
    pause
    exit /b 1
)

echo.
echo ============================================
echo   Done, everything is synced with GitHub.
echo ============================================
echo.
pause
