@echo off
rem ****************************************************
rem ***                                              ***
rem *** Script to find column distinct counts  given *** 
rem *** the schema and objects (tables and views)    *** 
rem *** to process                                   ***
rem *** Author  : John Mee                           ***
rem *** Date    : 25 / 11 /2024                      ***
rem *** Version : A                                  ***
rem ***                                              ***
rem ****************************************************

rem ****************************
rem *** Script Configuration ***
rem ****************************
:Configuration
title configuration
echo configuration...
set home_drive=C:
set home_directory=%working_drive%\Tech_Notes\Postgres_Tech_Notes\get_column_counts_by_schema_object
set working_drive=C:
set working_directory=%working_drive%\Tech_Notes\Postgres_Tech_Notes\get_column_counts_by_schema_object
set PGPASSWORD=!9Sparrowdrive!
set psqlm="C:\Program Files\PostgreSQL\14\bin\psql.exe"
set psqlconn=%psqlm% -h localhost -U postgres -d Icasework -Atq --csv
set ps1=C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -nologo

set psleep=%ps1% sleep
set config_file=objects_to_process.txt
set/a cleanse_config_file=0
set/a pattern_line_counter=0
set/a avg_processing_time=0

for /f "tokens=1-3 delims=/ " %%a in  ('date/t') do (set day=%%a&& set month=%%b&& set year=%%c)
for /f "tokens=1-3 delims=: " %%d in  ('%ps1% get-date -Format ^"HH:mm:ss ^"') do (set hours=%%d&& set minutes=%%e&& set seconds=%%f)

rem ****************************
rem *** Startup              ***
rem ****************************
:Startup
title startup
echo startup...
%psleep% 1

echo start_date_time : %year%_%month%_%day%_%hours%_%minutes%_%seconds%

%working_drive%
cd %working_directory%

echo. > section_csv_1.csv 
del /f /q section*.csv

rem **************************************
rem *** create cleanse_config_file.ps1 ***
rem *** powershell file                ***
rem *** this removes all non           ***
rem *** white space characters         ***
rem **************************************
:create_cleanse_config_powershell
title create_cleanse_config_file
echo create_cleanse_config_file...
%psleep% 1

echo. > cleanse_config.ps1
del /f cleanse_config.ps1

echo param >> cleanse_config.ps1
echo ( >> cleanse_config.ps1
echo   [string]$longfilename=""  >> cleanse_config.ps1
echo ) >> cleanse_config.ps1
echo $outputfilename=$longfilename.Substring(0,$longfilename.lastIndexOf('.')) + ".tmp"  >> cleanse_config.ps1
echo ((Get-Content -Path ($longfilename)).ToLower() ^| foreach {$_ -replace '[^^_a-zA-Z0-9\s]',''})^|  ? {$_.trim() -ne ""} ^| Set-content -Path $outputfilename  >> cleanse_config.ps1


rem **************************************
rem *** create cleanse_dq_script.ps1   ***
rem *** this removes all double quote  ***
rem *** characters                     ***
rem **************************************
:create_cleanse_dq_script
title create_cleanse_dq_script
echo create_cleanse_dq_script...
%psleep% 1

echo. > cleanse_dq_script.ps1
del /f cleanse_dq_script.ps1

echo param >> cleanse_dq_script.ps1
echo ( >> cleanse_dq_script.ps1
echo  [string]$inputfilename="",>> cleanse_dq_script.ps1
echo  [string]$outputfilename="" >> cleanse_dq_script.ps1
echo ) >> cleanse_dq_script.ps1 >> cleanse_dq_script.ps1
echo ((Get-Content -Path ($inputfilename)).ToLower() ^| foreach {$_ -replace '[^"]',''})^|  ? {$_.trim() -ne ""} ^| Set-content -Path $outputfilename  >> cleanse_dq_script.ps1

rem ******************************************
rem *** create pattern_counter_in_file.ps1 ***
rem *** search a specified  file for lines ***
rem *** containing a search pattern        ***
rem *** and report the linecount           ***
rem ******************************************
:create_pattern_counter_in_file
echo. > pattern_counter_in_file.ps1
del /f pattern_counter_in_file.ps1

echo param >> pattern_counter_in_file.ps1
echo ( >> pattern_counter_in_file.ps1
echo   [string]$filename="", >> pattern_counter_in_file.ps1
echo   [string]$match1="" >> pattern_counter_in_file.ps1
echo ) >> pattern_counter_in_file.ps1
echo (select-string -Path $filename -Pattern $match1 -AllMatches).Matches.count; >> pattern_counter_in_file.ps1


rem *************************************
rem *** if the config_file            ***
rem *** objects_to_process.txt        ***  
rem *** is defined then cleanse it to ***
rem *** objects_to_process.tmp        ***
rem *************************************
:cleanse_config_file
title cleanse_config_file
echo cleanse_config_file
%psleep% 1

set/a cleanse_config_file=0
if defined config_file set/a cleanse_config_file=1

if %cleanse_config_file% EQU 1 %ps1% .\cleanse_config.ps1 %config_file%

rem ********************************
rem *** Call local subroutine to ***
rem *** create schema_script     ***
rem ********************************
:call_schema_script
title call_schema_script
echo call_schema_script...
%psleep% 1 

call :create_schema_script

rem *******************************
rem *** run to schema script    ***
rem *** exclude extra schema    ***
rem *** such as                 ***
rem *** information_schema      ***
rem *******************************
:run_schema_script
echo. > schema.txt
del /f schema.txt

%psqlconn% -f schema.sql -o schema.txt

rem ********************************
rem *** Call local subroutine to ***
rem *** create and run main_db   *** 
rem *** script per schema        ***
rem ********************************
:call_main_db_script

for /f "delims=" %%a in (schema.txt) do (call :process_schema_script %%a)

rem ****************************
rem *** Local Cleanup        ***
rem ****************************
:localcleanup
title localcleanup
echo localcleanup...
%psleep% 3

echo. > cleanse_config.ps1
del /f cleanse_config.ps1

echo. > cleanse_dq_script.ps1
del /f  cleanse_dq_script.ps1

echo. > pattern_counter_in_file.ps1
del /f pattern_counter_in_file.ps1

echo. > %schema%_%object%_01.sql
del /f  %schema%_%object%_01.sql

echo. > %schema%_%object%_02.sql
del /f  %schema%_%object%_02.sql

echo. > %schema%_%object%_03.sql
del /f  %schema%_%object%_03.sql

echo. > %schema%_%object%_03.tmp
del /f  %schema%_%object%_03.tmp

echo. > %schema%_%object%_04.sql
del /f  %schema%_%object%_04.sql

echo. > %schema%_%object%_m.sql
del /f  %schema%_%object%_m.sql

echo. > schema.sql
del /f  schema.sql

echo. > schema.txt
del /f  schema.txt

echo. > objects_to_process.tmp
del /f  objects_to_process.tmp

echo. > section_csv_1.csv
del /f  section*.csv     

for /f "tokens=1-3 delims=/ " %%a in  ('date/t') do (set day=%%a&& set month=%%b&& set year=%%c)
for /f "tokens=1-3 delims=: " %%d in  ('%ps1% get-date -Format ^"HH:mm:ss ^"') do (set hours=%%d&& set minutes=%%e&& set seconds=%%f)

echo end_date_time : %year%_%month%_%day%_%hours%_%minutes%_%seconds%

%psleep% 3

set working_drive=
set working_directory=
set psqlm=
set PGPASSWORD=
set workfile1=
set workfile2=
set workfile3=
set okay_to_process=
set ps1=
set psleep=
set psqlconn=
set seconds=
set section_counter=
set sum1=
set time_per_section=
set year=
set avg_processing_time=
set cleanse_config_file=
set config_file=
set day=
set elapsed_time=
set hours=
set minutes=
set month=
set nominal_processing_time=
set pattern_line_counter=

%home_drive%
cd %home_directory%
goto master_exit
rem +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
rem +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
rem ++++++++++++++++++++++++++++++++++++++++++++
rem +++ Subroutine Section Start            ++++
rem ++++++++++++++++++++++++++++++++++++++++++++
rem ++++++++++++++++++++++++++++++++++
rem +++ create_schema_script start +++
rem +++ exclude schema such as     +++
rem +++ public,information_schema, +++
rem +++ jdbc,support               +++
rem ++++++++++++++++++++++++++++++++++
:create_schema_script
title create_schema_script
echo create_schema_script...
%psleep% 3
echo. > schema.sql
del /f  schema.sql

echo \set echo none >>schema.sql
echo select schema_name >>schema.sql
echo from information_schema.schemata >>schema.sql
echo where schema_name not in >>schema.sql
echo ('pg_toast', >>schema.sql
echo 'pg_catalog', >>schema.sql
echo 'public', >>schema.sql
echo 'information_schema', >>schema.sql
echo 'jdbc', >>schema.sql
echo 'bristol', >>schema.sql
echo 'support'); >>schema.sql
echo \q >> schema.sql

goto :eof
rem ++++++++++++++++++++++++++++++++++
rem +++ create_schema_script end   +++
rem ++++++++++++++++++++++++++++++++++
rem +++++++++++++++++++++++++++++++++++++++++++++++++++++++
rem +++++++++++++++++++++++++++++++++++++++++
rem +++ create and run the main database  +++
rem +++ script for each schema start      +++
rem +++++++++++++++++++++++++++++++++++++++++
:process_schema_script
title main_db_script
echo main_db_script...
%psleep% 3
set schema=%1

if %cleanse_config_file% NEQ 1 goto :localskip
 for /f "delims=" %%a in (objects_to_process.tmp) do (call :process_config_for_each_schema %schema% %%a)

:localskip
set schema=
goto :eof
rem +++++++++++++++++++++++++++++++++++++++++
rem +++ create and run the main database  +++ 
rem +++ script for each schema end        +++
rem +++++++++++++++++++++++++++++++++++++++++
rem +++++++++++++++++++++++++++++++++++++++++++++++++++++++
rem +++++++++++++++++++++++++++++++++++++++++
rem +++ There is a config file to         +++
rem +++ process run this against          +++
rem +++ each schema                       +++
rem +++++++++++++++++++++++++++++++++++++++++
:process_config_for_each_schema
title process_config_for_each_schema
echo process_config_for_each_schema...
%psleep% 1
set schema=%1
set object=%2

echo. > %schema%_%object%_01.sql
del /f  %schema%_%object%_01.sql

echo. > %schema%_%object%_02.sql
del /f  %schema%_%object%_02.sql

echo. > %schema%_%object%_03.sql
del /f  %schema%_%object%_03.sql

echo. > %schema%_%object%_03.tmp
del /f  %schema%_%object%_03.tmp

echo. > %schema%_%object%_04.sql
del /f  %schema%_%object%_04.sql

echo. > %schema%_%object%_m.sql
del /f  %schema%_%object%_m.sql

echo. > %schema%_%object%_m.csv
del /f /q %schema%_%object%_m.csv

echo. > %schema%_%object%_m.tmp
del /f /q %schema%_%object%_m.tmp

echo. > %schema%_%object%_1.csv
del /f /q %schema%_%object%_1.csv

echo. > %schema%_%object%_2.csv
del /f /q %schema%_%object%_2.csv

echo SELECT 'select ''%schema%,%object%,'^|^|column_name^|^|',''^|^| count(distinct('^|^| column_name ^|^|')) as row_counter from '^|^| table_name ^|^|';' as cursor_string >> %schema%_%object%_01.sql
echo FROM information_schema.columns >> %schema%_%object%_01.sql
echo WHERE table_name = '%object%' >> %schema%_%object%_01.sql
echo AND table_schema = '%schema%' >> %schema%_%object%_01.sql
echo order by ordinal_position >> %schema%_%object%_01.sql

echo creating file %schema%_%object%_m.sql
%psqlconn% -f %schema%_%object%_01.sql -o %schema%_%object%_03.sql

rem add_section_files_splits
rem to the sql generated file
:add_section_splits_to_files

ren %schema%_%object%_03.sql %schema%_%object%_03.tmp 
%ps1% .\add_section_splits_to_file.ps1 %schema%_%object%_03.tmp %schema%_%object%_03.sql

rem count the section splits 
rem parameter 1 file to scan
rem parameter 2 pattern to 
rem search for
rem return linecount
:pattern_line_counter

for /f %%a in ('%ps1% .\pattern_counter_in_file.ps1 %schema%_%object%_03.sql processing_section_csv') do (set /a pattern_line_counter=%%a)

rem concatonate_all_schema object files
rem object_0*.sql to the intermediate 
rem text file 
:concatonate_all_schema_object_0*.sql_files
echo \set ECHO_HIDDEN on >> %schema%_%object%_02.sql
echo \set ECHO queries  >> %schema%_%object%_02.sql
echo set search_path to %schema%; >> %schema%_%object%_02.sql

echo \q  >> %schema%_%object%_04.sql

echo. > %schema%_%object%_01.sql
del /f  %schema%_%object%_01.sql

copy /b %schema%_%object%_0*.sql %schema%_%object%_m.txt >nul 2>nul

rem now cleanse the double quotes  
rem out of the schema_object text file
echo remove double_quotes from %schema%_%object%_m.txt file

%ps1% .\cleanse_dq_script.ps1 %schema%_%object%_m.txt %schema%_%object%_m.sql

rem run the master_schema_object_script
rem to produce a set of csv files for the object
rem use the copy command to concatonate these 
rem in the correct order
:run_schema_object_script
echo generate csv files for object %schema%_%object%_m.sql

set/a avg_processing_time=3
set/a nominal_processing_time="avg_processing_time * pattern_line_counter" 

echo processing all columns for schema %schema% object %object% 
echo please allow %nominal_processing_time% minutes for processing.

%psqlconn% -f %schema%_%object%_m.sql 


copy /b /y section_csv_*.csv %schema%_%object%_m.csv > nul

echo schema,object,column name,distinct_counts > %schema%_%object%_1.csv

ren %schema%_%object%_m.csv %schema%_%object%_m.tmp

%ps1% .\cleanse_dq_script.ps1 %schema%_%object%_m.tmp %schema%_%object%_2.csv

echo schema,object,column name,distinct_counts > %schema%_%object%_1.csv

copy /b /y %schema%_%object%_*.csv %schema%_%object%_m.csv > nul


echo. > %schema%_%object%_02.sql
del /f  %schema%_%object%_02.sql

echo. > %schema%_%object%_03.sql
del /f  %schema%_%object%_03.sql

echo. > %schema%_%object%_03.tmp
del /f  %schema%_%object%_03.tmp

echo. > %schema%_%object%_04.sql
del /f  %schema%_%object%_04.sql

echo. > %schema%_%object%_m.txt
del /f  %schema%_%object%_m.txt

echo. > %schema%_%object%_m.sql
del /f  %schema%_%object%_m.sql

echo. > %schema%_%object%_m.tmp
del /f  %schema%_%object%_m.tmp

echo. > %schema%_%object%_1.csv
del /f  %schema%_%object%_1.csv

echo. > %schema%_%object%_2.csv
del /f  %schema%_%object%_2.csv

echo. > section_csv_1.csv
del /f  section*.csv  

set schema=
set object=
goto :eof
rem +++++++++++++++++++++++++++++++++++++++++
rem +++ There is a config file to         +++
rem +++ process so run it here end        +++
rem +++++++++++++++++++++++++++++++++++++++++
rem ++++++++++++++++++++++++++++++++++++++++++++
rem +++ Subroutine Section End              ++++
rem ++++++++++++++++++++++++++++++++++++++++++++
rem +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
rem +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
rem ****************************
rem *** Master Exit          ***
rem ****************************
:master_exit
title master_exit
echo master_exit...
set home_drive=
set home_directory=
rem exit 0



