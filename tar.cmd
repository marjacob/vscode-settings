@echo off

where /q tar.exe

if errorlevel 1 (
	echo %0: Windows 10 build 17063 or newer required
	exit /b 1
)

tar.exe %*
