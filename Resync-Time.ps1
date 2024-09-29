try {

    # Set time source to time.windows.com
    Start-Process -FilePath "C:\Windows\System32\w32tm.exe" -ArgumentList '/config /manualpeerlist:"time.windows.com" /syncfromflags:MANUAL /reliable:YES /update' -Wait -WindowStyle Hidden -ErrorAction Stop

    # Resync the time immediately
    Start-Process -FilePath "C:\Windows\System32\w32tm.exe" -ArgumentList '/resync' -Wait -WindowStyle Hidden -ErrorAction Stop

    # Create a scheduled task to resync time daily at 10 AM

    $action = New-ScheduledTaskAction -Execute 'w32tm.exe' -Argument '/resync'

    $trigger = New-ScheduledTaskTrigger -Daily -At 10:00AM

    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

    Register-ScheduledTask -TaskName "DailyTimeSync" -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description "Sync system time with time.windows.com daily at 10 AM" -Force -ErrorAction Stop

    # Verify the task was created successfully

    if (-not(Get-ScheduledTask -TaskName "DailyTimeSync" -ErrorAction SilentlyContinue)) {
        Exit 1
    }

} catch {
    Write-Host "Task not created"
    Exit 1
}