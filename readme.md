# Get Column Counts by Schema Object
The main batch script is named [get_column_counts_by_schema_object.bat].
This batch script will create a set of csv files from a set of schema and set of object names.
# Usage
Step 1 - create a file named [objects.txt] and add the tables or views required for column processing on a newline
Step 2 - edit the very top configuration section of the batch file
         get_column_counts_by_schema_object.bat for the following setting

        home_drive          - the home drive from which the script is run
        home_directory      - the home directory from which the script is run
        working_drive       - the working drive to hold the derived csv files
        working_directory   - the working directory to hold the derived csv files
        PGPASSWORD          - The PGPASSWORD required for the psql connection     
        psqlm               - the local of the psql executable
                              (for example C:\Program Files\PostgreSQL\14\bin\psql.exe)
        psqlconn            - the connection string required for the postgres database connection 
                              (for example -h localhost -U postgres -d Icasework -Atq --csv)
        ps1                 - the location of the powershell executable
                              (for example C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -nologo)
        config_file         - the name of the file which contains the table or views to process
                              ( for example objects_to_process.txt )
 
Step 3 - run the batch script get_column_counts_by_schema_object.bat
         this will produce an on screen display of the progress the batch script is making.
         this is basically a loop around each schema as an outer loop with an inner loop 
         around each object given in the defined config_file.

 # Notes
   Author : John Mee
   Email  : john.mee@civica.co.uk
