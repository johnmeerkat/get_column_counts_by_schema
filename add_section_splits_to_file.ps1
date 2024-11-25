<# #################################################################################### #>
<# ###                                                                              ### #>
<# ### Powershell script to add section break files to a postgres script            ### #>
<# ### this is required as postgres psql does not have a flush command to           ### #>
<# ### write output to a file while it has an open file handle                      ### #>
<# ###                                                                              ### #>
<# ### Parameter 1 : input [data type string] - the postgres script file to process ### #>
<# ### Parameter 2 : ouput [data type string] - the postgras script file to contain ### #>
<# ###               the updated script                                             ### #>
<# ###                                                                              ### #>
<# ###      Author  : John Mee                                                      ### #>
<# ###      Date    : 25 /11 / 2024                                                 ### #>
<# ###      Version : A                                                             ### #>
<# ###                                                                              ### #>
<# #################################################################################### #>
param (
  [string]$inputfilename="",
  [string]$outputfilename=""
) 

[int]$section_switch_file=0;
[int]$linecounter=0;
[int]$totalfilelinecount=(Get-Content -Path $inputfilename).Count;

$section_switch_file++;		
    "\r " | Out-File -FilePath $outputfilename -Encoding ascii -Append;
	"\o " | Out-File -FilePath $outputfilename -Encoding ascii -Append; 
    "select to_char(now(),'HH24:MI:SS') ||' processing_section_csv_" + $section_switch_file + ".csv';" | Out-File -FilePath $outputfilename -Encoding ascii -Append;	
	"\o " + "section_csv_" + $section_switch_file + ".csv" | Out-File -FilePath $outputfilename -Encoding ascii -Append;

foreach($line in Get-Content $inputfilename) 
{
	$linecounter++; 
    if ($linecounter%20 -eq 0 )
	{
      $section_switch_file++;		
      "\o" | Out-File -FilePath $outputfilename -Encoding ascii -Append;
      "select to_char(now(),'HH24:MI:SS') ||' processing_section_csv_" + $section_switch_file + ".csv';" | Out-File -FilePath $outputfilename -Encoding ascii -Append;	
	  "\o " + "section_csv_" + $section_switch_file + ".csv" | Out-File -FilePath $outputfilename -Encoding ascii -Append;
	}

    $line | Out-File -FilePath $outputfilename -Encoding ascii -Append
  
    if ($linecounter -eq  $totalfilelinecount)
	{
      "\o" | Out-File -FilePath $outputfilename -Encoding ascii -Append;
	}
}