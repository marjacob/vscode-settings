@echo off

where /q tar.exe

if errorlevel 1 (
	echo %0: Windows 10 build 17063 or newer required
) else (
	tar.exe %*
)

exit /b %errorlevel%
