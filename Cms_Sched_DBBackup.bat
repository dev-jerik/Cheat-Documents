
@echo off
echo CMS Database Backup schedule started.
:: Set some variables
set bkupdir=C:\cpti_resources\CMS_DB_Backup\
set mysqldir="C:\Program Files\MySQL\MySQL Server 5.7\"
set logdir=%bkupdir%Logs\
set transactionsdir=%bkupdir%TRANSACTIONS\
set fulldir=%bkupdir%FULL\
set dbuser=backup_user
set dbpass=Bkup1234
set dbname=fairmont_cms_live
:: set zip=C:\GZip\bin\gzip.exe
set endtime=0

:: ========================== Creation of folder if not exist ============================
:: Create CMS_DB_Backup folder if not exist
if not exist %bkupdir% (
	echo Creating CMS_DB_Backup Directory.
	mkdir %bkupdir%
)
:: Create Logs folder if not exist
if not exist %logdir% (
	echo Creating CMS_DB_Backup's Logs Directory.
	mkdir %logdir%
)
:: Create Transactions folder if not exist
if not exist %transactionsdir% (
	echo Creating CMS_DB_Backup's Transactions Directory.
	mkdir %transactionsdir%
)
:: Create Full backup folder if not exist
if not exist %fulldir% (
	echo Creating CMS_DB_Backup' Full Directory.
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

:: Write to the log file
echo Beginning MySQLDump Process.
echo Beginning MySQLDump Process > %logdir%LOG%fn%.txt
echo Start Time = %yy%-%mm%-%dd% %hh%:%ii%:%ss%
echo Start Time = %yy%-%mm%-%dd% %hh%:%ii%:%ss% >> %logdir%LOG%fn%.txt
echo --------------------------- >> %logdir%LOG%fn%.txt
echo. >> %logdir%LOG%fn%.txt

:: Run mysqldump
echo Backing up TRANSACTIONS
echo Backing up TRANSACTIONS >> %logdir%LOG%fn%.txt
%mysqldir%bin\mysqldump --user=%dbuser% --password=%dbpass% %dbname%  adjustment adv_credit adv_credit_adjustment adv_credit_allocation adv_credit_allocation_adv_credit_type_link adv_credit_allocation_profile_link adv_credit_allocation_unit_link aor_number bill bill_invoice_type_link bulk_txn_detail bulk_txn_header calendar_event club_stats club_stats_detailed condo_dues_txn condo_dues_txn_unit_link credit_memo day_end day_end_detail debit_memo email_blast email_blast_detail facility_user folio_txn invoice late_charge late_charge_profile_link late_charge_unit_link multiple_adv_credit multiple_adv_credit_profile_link multiple_bill multiple_bill_invoice_type_link multiple_bill_profile_link multiple_bill_unit_link multiple_invoice multiple_invoice_profile_link multiple_invoice_unit_link or_number other_payment payment payment_detail period_end pos_txn rec_charge_txn rec_charge_txn_profile_link reservation reservation_adv_credit_link reservation_calendar_event_link reservation_charge reversal_history setup_audit_log system_task system_audit_log transfer_history txn_audit_log upload upload_detail bill_generation bill_generation_detail post_folio_to_billing post_folio_to_billing_folio_link forfeit_adv_credits forfeit_adv_credits_adv_credit_link -f --single-transaction --skip-add-locks > %bkupdir%TRANSACTIONS\CMS_TransBkup_%fn%.sql 2>>%logdir%LOG%fn%.txt


:: Get day of the week for filename suffix.
for /f %%d in ('"powershell (Get-Date -Format 'ddd').ToUpper()"') do set dow=%%d

:: Run mysqldump
echo Backing up FULL database
echo Backing up FULL database >> %logdir%LOG%fn%.txt
REM %mysqldir%\bin\mysqldump --user=%dbuser% --password=%dbpass% LMMS --skip-opt --quote-names --allow-keywords --complete-insert --single-transaction > %bkupdir%FULL\CMS_FullBackup_%fn%.sql
%mysqldir%bin\mysqldump --user=%dbuser% --password=%dbpass% %dbname% -f --single-transaction --skip-add-locks > %fulldir%CMS_FullBackup_%dow%.sql 2>>%logdir%LOG%fn%.txt


:: Get the last date of the month
for /f %%d in ('"powershell ((get-date).addmonths(1)).adddays(-(get-date ((get-date).addmonths(1)) -format dd)).toString('MM/dd/yyyy') "') do set lastDateOfTheMonth=%%d
:: Create a backup copy of cms for the end of the month if today is the last day of the month.
if %lastDateOfTheMonth% EQU %dateNow% (
	echo Create a backup copy of cms database for the month of %lastDateOfTheMonth%
	echo Create a backup copy of cms database for the month of %lastDateOfTheMonth% >> %logdir%LOG%fn%.txt
	echo %fulldir%CMS_FullBackup_%dow%.sql > %fulldir%CMS_FullBackup_%datefn%.sql
) 

echo Done...
echo Done... >> %logdir%LOG%fn%.txt

echo Deleting Transaction backups older than 30 days now
echo Deleting Transaction backups older than 30 days now >> %logdir%LOG%fn%.txt
Forfiles /P %transactionsdir% /M CMS_Trans*.sql /D -30 /C "cmd /c del /q @path" 2>>%logdir%LOG%fn%.txt


:: Go back and get the end time for the script
set endtime=1
goto :GETTIME

:END
:: Write to the log file
echo. >> %logdir%LOG%fn%.txt
echo --------------------------- >> %logdir%LOG%fn%.txt
echo MySQLDump Process Finished >> %logdir%LOG%fn%.txt
echo End Time = %yy%-%mm%-%dd% %hh%:%ii%:%ss% 
echo End Time = %yy%-%mm%-%dd% %hh%:%ii%:%ss% >> %logdir%LOG%fn%.txt
echo. >> %logdir%LOG%fn%.txt

REM pause
