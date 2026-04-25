@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "ROOT_DIR=%~dp0"
cd /d "%ROOT_DIR%"

set "VENV_DIR=%ROOT_DIR%.venv"
set "VENV_PY=%VENV_DIR%\Scripts\python.exe"
set "HOST=127.0.0.1"
set "PORT=5000"
set "RESEED=0"
set "RETRAIN=0"
set "SKIP_INSTALL=0"
set "FRESH=0"

if "%~1"=="" goto parse_done

:parse_args
if "%~1"=="" goto parse_done
if /I "%~1"=="--reseed" set "RESEED=1"& shift & goto parse_args
if /I "%~1"=="--retrain" set "RETRAIN=1"& shift & goto parse_args
if /I "%~1"=="--skip-install" set "SKIP_INSTALL=1"& shift & goto parse_args
if /I "%~1"=="--fresh" set "FRESH=1"& set "RESEED=1"& set "RETRAIN=1"& shift & goto parse_args
if /I "%~1"=="--help" goto usage
echo Unknown option: %~1
goto usage_fail

:parse_done
if "%FRESH%"=="1" (
	if exist medication_model.pkl del /q medication_model.pkl
	if exist .medagent.pid del /q .medagent.pid
	if exist .medagent.log del /q .medagent.log
)

where py >nul 2>nul
if %ERRORLEVEL%==0 (
	py -3.11 -c "import sys" >nul 2>nul && set "PYTHON_CMD=py -3.11"
	if not defined PYTHON_CMD py -3.12 -c "import sys" >nul 2>nul && set "PYTHON_CMD=py -3.12"
	if not defined PYTHON_CMD py -3.10 -c "import sys" >nul 2>nul && set "PYTHON_CMD=py -3.10"
	if not defined PYTHON_CMD set "PYTHON_CMD=py -3"
)
if not defined PYTHON_CMD (
	where python >nul 2>nul
	if %ERRORLEVEL%==0 set "PYTHON_CMD=python"
)
if not defined PYTHON_CMD (
	echo Python 3.10+ was not found. Install Python and retry.
	exit /b 1
)

if not exist "%VENV_PY%" (
	echo Creating virtual environment...
	call %PYTHON_CMD% -m venv .venv || exit /b 1
)

if "%SKIP_INSTALL%"=="0" (
	echo Installing dependencies...
	call "%VENV_PY%" -m pip install -r requirements.txt || exit /b 1
) else (
	echo Dependency installation skipped.
)

if "%RESEED%"=="1" (
	echo Reseeding dataset...
	call "%VENV_PY%" seed_data.py --force || exit /b 1
) else (
	echo Validating or creating dataset...
	call "%VENV_PY%" seed_data.py || exit /b 1
)

if "%RETRAIN%"=="1" (
	echo Training model...
	call "%VENV_PY%" prediction_model.py || exit /b 1
) else (
	if not exist medication_model.pkl (
		echo Training model...
		call "%VENV_PY%" prediction_model.py || exit /b 1
	) else (
		echo Training skipped: model artifact already exists.
	)
)

echo.
echo Starting MedAgent on http://%HOST%:%PORT%
echo Demo credentials:
echo   clinician / medagent123
echo   supervisor / medagent456
echo   researcher / medagent789
echo Press Ctrl+C to stop the server.
echo.

set "APP_HOST=%HOST%"
set "APP_PORT=%PORT%"
call "%VENV_PY%" app.py
exit /b %ERRORLEVEL%

:usage
echo Usage: run_windows.bat [--reseed] [--retrain] [--fresh] [--skip-install]
echo.
echo   --reseed        Force recreate patients.csv from patients_seed.csv
echo   --retrain       Force model retraining
echo   --fresh         Reset runtime artifacts and data before startup
echo   --skip-install  Skip dependency installation
exit /b 0

:usage_fail
echo.
echo Run run_windows.bat --help for usage.
exit /b 1
