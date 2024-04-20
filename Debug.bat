@echo off
:loop
cls
echo %time%
echo.
type posicion.txt
timeout /t 0 /nobreak >nul
goto loop