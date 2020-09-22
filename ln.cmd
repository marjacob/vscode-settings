@echo off

set SeCreateSymbolicLinkPrivilege=0

for /f %%i in ('whoami /priv /nh') do (
	if "%%i"=="SeCreateSymbolicLinkPrivilege" (
		set SeCreateSymbolicLinkPrivilege=1
	)
)

if %SeCreateSymbolicLinkPrivilege% neq 1 (
	echo %0: SeCreateSymbolicLinkPrivilege required
) else (
	mklink %*
)

exit /b %errorlevel%
