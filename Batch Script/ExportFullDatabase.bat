@echo off

:: Set some variables
set bkupdir=C:\cpti_resources\CMS_Backup\
set mysqldir="C:\Program Files\MySQL\MySQL Server 5.7\"
set fulldir=%bkupdir%FULL\Manual\
set dbuser=backup_user
set dbpass=Bkup1234
set dbname=fairmont_cms_live

echo Exporting %dbname% database started.

:: ========================== Creation of folder if not exist ============================
:: Create CMS_DB_Backup folder if not exist
if not exist %bkupdir% (
	echo Creating %bkupdir% Directory.
	mkdir %bkupdir%
)

:: Create Full backup folder if not exist
if not exist %fulldir% (
	echo Creating %fulldir% Directory.
	mkdir %fulldir%
)
:: ========================== End of Creation of folder ======================

:GETTIME

:: get the date and then parse it into variables
:: Get the date base on this format "MM/dd/yyyy"
:: source: https://stackoverflow.com/questions/19131029/how-to-get-date-in-bat-file
FOR /f "usebackq" %%i IN (`PowerShell ^(Get-Date^).ToString^('MM/dd/yyyy'^)`) DO (
 set dateNow=%%i
 for /F "tokens=1-3 delims=/ " %%i in ("%%i") do (
	set mm=%%i
	set dd=%%j
	set yy=%%k
 )
)

:: get the time and then parse it into variables
for /F "tokens=5-8 delims=:. " %%i in ('echo.^| time ^| find "current" ') do (
set hh=%%i
set ii=%%j
set ss=%%k
)

:: If this is the second time through then go to the end of the file
if "%endtime%"=="1" goto END

:: Create the filename suffix
set fn=_%yy%%mm%%dd%_%hh%%ii%
set datefn=_%yy%%mm%%dd%

echo.
:: Write 
echo Start Time = %yy%-%mm%-%dd% %hh%:%ii%:%ss%

:: Run mysqldump
%mysqldir%bin\mysqldump --user=%dbuser% --password=%dbpass% %dbname% -f --single-transaction --skip-add-locks > %fulldir%CMS_FullBackup_%fn%.sql

echo End Time = %yy%-%mm%-%dd% %hh%:%ii%:%ss% 
echo.

echo Exporting %dbname% database was done.
echo.

pause