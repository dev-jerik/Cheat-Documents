@echo off
Rem // Run this batch file on the task scheduler every week at 1:00 o clock in the morning.

setlocal EnableExtensions DisableDelayedExpansion

rem // Define constants here:
set "_ROOT=C:\cpti_resources\CMS_DB_Backup\Full"
set "_PATTERN=*.sql"
set "_LIST=%TEMP%\%~n0.tmp"
set "_ARCHIVER=%ProgramFiles%\7-Zip\7z.exe"

rem // Get current date in locale-independent format:
for /F "tokens=2 delims==" %%D in ('wmic OS get LocalDateTime /VALUE') do set "TDATE=%%D"
set "TDATE=%TDATE:~,8%"

rem // Create a list file containing all files to move to the archive:
rem // Zip database backup older than 1 day now.
> "%_LIST%" (
    for /F "delims=" %%F in ('
        forfiles /S /P "%_ROOT%" /M "%_PATTERN%" /D -1 /C "cmd /C echo @path"
    ') do echo(%%~F
) && (
    rem // Archive all listed files at once and delete the processed files finally:
    "%_ARCHIVER%" a -sdel "%_ROOT%\Archive_%TDATE%.zip" @"%_LIST%"
    rem // Delete the list file:
    del "%_LIST%"
)

endlocal
exit /B