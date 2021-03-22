# Global settings
$ErrorActionPreference = 'Stop'
#Requires -RunAsAdministrator
# make sure this runs on windows 10 and windows powershell only
if (!([System.Environment]::OSVersion.Version.Major -eq '10')) {
    Throw "Only use this in a Windows 10 environment"
    Exit 1
}
if ($PSVersionTable.PSVersion.Major -gt 5) {
    Throw 'Please run this in Windows Powershell, not core'
    Exit 1
}
# Disable Powershell Version 2
Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root
# define path
$PATH = "C:\Temp\Windows Protection\"
#logging
if (Test-Path -Path 'C:\Temp') {
    New-Item -ItemType Directory "C:\Temp\Windows Protection" -Force -ErrorAction SilentlyContinue > $null
}
else {
    New-Item -ItemType Directory "C:\Temp" -Force -ErrorAction SilentlyContinue > $null
    New-Item -ItemType Directory "C:\Temp\Windows Protection" -Force -ErrorAction SilentlyContinue > $null
}

## check and set security audit 
$audit_check = AuditPol /get /subcategory:'Other Object Access Events'
if ($audit_check.split(' ')[-2] -eq 'Success') {
    write-host 'Auditing is Enabled'
}
else {
    try {
        AuditPol /set /subcategory:'Other Object Access Events' > $null
    }
    catch {
        Throw 'Failed to enable audit security policy'
    }
}
function Get-AllowList {
    [CmdletBinding()]
    param ( 
        [Parameter(Mandatory = $true)] [String] $FilePath
    )
    $params = @{
        uri     = "https://raw.githubusercontent.com/ParkHost/Windows-Script_for_Script/tree/master/Check%20SCtask/templates/" + $FilePath.split('\')[-1]
        Outfile = "$($PATH)allow-tasks.json"
    }
    Try {
        Invoke-RestMethod @params
    } catch {
        Throw "Failed to retrieve new task list, $($Error[0])"
    }
}


Function Watch-ScheduledTaskEvents {
    [CmdletBinding()]
    param (
        [Parameter()] [String] $TaskName
    )
    ## Create custom schedule task which triggers on the events: 'A scheduled task was updated.' and 'A scheduled task was created.'.
    $class = Get-CimClass MSFT_TaskEventTrigger root/Microsoft/Windows/TaskScheduler
    $trigger = $class | New-CimInstance -ClientOnly
    $trigger.Enabled = $true
    $trigger.Subscription = '<QueryList><Query Id="0" Path="Security"><Select
Path="Security">*[System[Provider[@Name=''Microsoft-Windows-Security-Auditing''] and
(EventID=4699 or EventID=4698 or EventID=4700 or EventID=4702)]] and *[EventData[Data[@Name=TaskName]!="\Action-ScheduleTask"]</Select></Query></QueryList>'


    # setting params and creating sctask
    $ActionParameters = @{
        Execute  = 'C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe'
        Argument = "-NoProfile -NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -file `"$($PATH)$($TaskName).ps1`""
    }
    $RegSchTaskParameters = @{
        TaskName    = "$($TaskName)"
        Description = 'Runs when a new task schedule is created'
        TaskPath    = '\'
        Action      = New-ScheduledTaskAction @ActionParameters
        Principal   = New-ScheduledTaskPrincipal -UserId 'SYSTEM'-LogonType ServiceAccount -RunLevel Highest
        Settings    = New-ScheduledTaskSettingsSet
        Trigger     = $Trigger

    }
    Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/ParkHost/Windows-Script_for_Script/master/Check%20SCtask/Action-ScheduleTask.ps1' -OutFile "$($PATH)$($TaskName).ps1"
    Register-ScheduledTask @RegSchTaskParameters -Force > $null
}

Get-AllowList -FilePath "$($PATH)allow_tasks.json"
Watch-ScheduledTaskEvents -TaskName 'Action-ScheduleTask'
