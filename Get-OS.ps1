<#
.Synopsis
   Get operating system details.
.DESCRIPTION
   This script enables you to get operating system details from remote windows computers and saves the output in .csv file. 
.INPUTS
   $ServerList = "C:\Temp\ServerList.txt"
.OUTPUTS
   $OSReport = "$C:\Temp\OSReport_$(Get-Date -Format yyyy-MM-dd_HH-mm-ss).csv"
#>

#Write the server names in a text file and replace the path below with yours.
$ServerList = "C:\Temp\ServerList.txt"

#By default the output file (.csv) is saved in the user's document folder. You can replace below path if you want to save the output in the location of your choice.
$OSReport = "$env:USERPROFILE\Documents\OSReport_$(Get-Date -Format yyyy-MM-dd_HH-mm-ss).csv"

$ComputerName = Get-Content -Path $ServerList
$HashTable = @()

foreach ($Computer in $ComputerName) {

    try {
        $OS = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $Computer -ErrorAction Stop

            $Properties = [Ordered]@{'ComputerName' = $Computer;
                                     'Operating System' = $OS.Caption;
                                     'OS Architecture' = $OS.OSArchitecture;
                                     'OS Version' = $OS.Version;
                                     'OS Build Number' = $OS.BuildNumber
                                     }

            $PSObject = New-Object -TypeName PSObject -Property $Properties

            $HashTable += $PSObject

            Write-Output -InputObject $PSObject


    } catch {
            $FailureReason = $Error[0].Exception.Message.ToString()
            
            $Properties = [Ordered]@{'ComputerName' = $Computer;
                                     'Operating System' = $FailureReason;
                                     'OS Architecture' = 'NA';
                                     'OS Version' = 'NA';
                                     'OS Build Number' = 'NA'
                                     }

            $PSObject = New-Object -TypeName PSObject -Property $Properties

            $HashTable += $PSObject

            Write-Output -InputObject $PSObject
    }

}

$HashTable | Export-Csv -NoTypeInformation -Path $OSReport