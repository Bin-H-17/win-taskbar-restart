@echo off
setlocal
set "SYS=%SystemRoot%\System32"

REM ============================================================
REM  Restart the Windows taskbar / desktop shell (explorer.exe)
REM
REM  [Important] explorer.exe lives in %SystemRoot%\, not in
REM  System32!  Pointing the restart at System32\explorer.exe
REM  means: explorer gets killed, the replacement never starts,
REM  desktop stays black + taskbar gone. This script validates
REM  the path first and retries the restart before giving up.
REM
REM  Also: restarting explorer leaves the IME candidate window
REM  dead (the candidate box is drawn by TextInputHost.exe;
REM  once explorer dies it stays a zombie: keystrokes register,
REM  no candidates show up), so the script rebuilds
REM  TextInputHost at the end.
REM ============================================================

set "EXP=%SystemRoot%\explorer.exe"

if not exist "%EXP%" (
  echo [ERROR] %EXP% not found
  echo         aborted, nothing was changed.
  "%SYS%\ping.exe" -n 6 127.0.0.1 >nul
  exit /b 1
)

echo [1/2] Restarting the taskbar ...
"%SYS%\taskkill.exe" /f /im explorer.exe >nul 2>&1
"%SYS%\ping.exe" -n 3 127.0.0.1 >nul
start "" "%EXP%"
"%SYS%\ping.exe" -n 3 127.0.0.1 >nul

REM ---- fallback: confirm explorer really came back, retry up to 3 times ----
set /a tries=0
:wait_exp
"%SYS%\tasklist.exe" /fi "imagename eq explorer.exe" 2>nul | "%SYS%\findstr.exe" /i explorer.exe >nul
if not errorlevel 1 goto exp_ok
set /a tries+=1
if %tries% GEQ 3 goto exp_fail
echo   explorer did not start, retry %tries% ...
start "" "%EXP%"
"%SYS%\ping.exe" -n 3 127.0.0.1 >nul
goto wait_exp

:exp_ok
echo [2/2] Rebuilding the IME host process ...
"%SYS%\taskkill.exe" /f /im TextInputHost.exe >nul 2>&1

echo.
echo Done. Click any text box, switch to a CJK input method and check
echo that the candidate window shows up again.
"%SYS%\ping.exe" -n 5 127.0.0.1 >nul
exit /b 0

:exp_fail
echo.
echo [WARN] explorer failed to start after several attempts.
echo        Start it manually: %EXP%
"%SYS%\ping.exe" -n 10 127.0.0.1 >nul
exit /b 1
