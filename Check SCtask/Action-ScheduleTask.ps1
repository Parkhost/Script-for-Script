#Requires -RunAsAdministrator
$ErrorActionPreference = 'Stop'
$result = @{}
$taskObj = @{}
$PATH = "C:\Temp\Windows Protection\"
#logging
if (!(Test-Path -Path "$($PATH)Allow_tasks.json")) {
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ParkHost/Windows-Script_for_Script/master/Check%20SCtask/Create-ScheduleTaskEvent.ps1'))
    }
    catch {
        Throw "Failed to run the initial setup $($Error[0])"
    }
}
Function New-TaskObj {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] $Task
    )
    if ([string]::IsNullOrEmpty($task.Actions.Execute)) {
        if ($Task.Actions.Classid -eq '{E984D939-0E00-4DD9-AC3A-7ACA04745521}') {
            $exec = '{E984D939-0E00-4DD9-AC3A-7ACA04745521}'
            #continue
        }
        elseif (Test-Path -LiteralPath "Registry::HKEY_CLASSES_ROOT\CLSID\$($Task.Actions.ClassId)\LocalServer32") {
            $exec = (Get-ItemProperty -LiteralPath "Registry::HKEY_CLASSES_ROOT\CLSID\$($Task.Actions.ClassId)\LocalServer32").'(default)'
            #continue
        }
        elseif (!(Test-Path -LiteralPath "Registry::HKEY_CLASSES_ROOT\CLSID\$($Task.Actions.ClassId)\InprocServer32")) {
            $appID = (Get-ItemProperty -LiteralPath "Registry::HKEY_CLASSES_ROOT\CLSID\$($Task.Actions.ClassId)").AppID
            $exec = (Get-ItemProperty -LiteralPath "Registry::HKEY_CLASSES_ROOT\AppID\$($appID)\").'(default)'
        }
        else {
            $exec = (Get-ItemProperty -LiteralPath "Registry::HKEY_CLASSES_ROOT\CLSID\$($Task.Actions.ClassId)\InprocServer32").'(default)'
        }
        $obj = @{
            taskpath = $Task.taskpath
            execute  = $exec
        }
    }
    else {
        if ([string]::IsNullOrEmpty($task.Actions.arguments)) {
            $obj = @{
                taskpath = $task.taskpath
                execute  = $task.Actions.Execute
            }
        }
        else {
            $obj = @{
                taskpath  = $task.taskpath
                execute   = $task.Actions.Execute
                arguments = $task.Actions.arguments
            }
        }
    }
    $taskObj[$task.taskname] = $obj
    return $taskObj
}

Function Test-List {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [String] $FilePath
    )
    if (!(Test-Path -Path $FilePath)) {
        Throw "File not found in $($FilePath)"
    }
    $checksum = Get-Content -Raw $FilePath.replace('.json', '_checksum.txt')
    if ((Get-Filehash $FilePath).Hash -eq $checksum) {
        continue
    }
    else {
        $params = @{
            uri     = "https://raw.githubusercontent.com/ParkHost/Windows-Script_for_Script/tree/master/Check%20SCtask/templates/" + $FilePath.split('\')[-1]
            Outfile = $FilePath
        }
        Try {
            Invoke-RestMethod @params
        }
        catch {
            Throw "Failed to retrieve new task list, $($Error[0])"
        }
    }
}

Function Lock-ScheduleTask {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [String] $FilePath # 'C:\Temp\PS_Security_features\Check SCtask\allow_tasks.json'
    )
    if ($result.taskname -eq '\Action-ScheduleTask') {
        continue
    }
    # default disable the task
    # try {
    # $result.State = (Get-ScheduledTask -TaskName $result.taskname.split('\')[-1]).State
    #Get-ScheduledTask -TaskName $result.taskname.split('\')[-1] # | Disable-ScheduledTask > $null
    # }
    # catch {
    # Throw "Failed to stop or disable the schedule task: $($Error[0])"
    # }
    try {
        $file = ConvertFrom-Json -InputObject (Get-Content -Raw -Path $FilePath)
    }
    catch {
        Throw 'Failed to find the authorized task list, please rerun the initial setup' + $Error[0]
    }
    if ($file."$($result.taskname.split('\')[-1])") {
        $current_obj = $file."$($result.taskname.split('\')[-1])"
        $output = @{}
        foreach ($note in ($current_obj.psobject.Members).Where( { $_.MemberType -eq 'NoteProperty' })) {
            $output.add($note.name, $note.value)
        }
    }
    else {
        Get-ScheduledTask -TaskPath $output.taskpath -TaskName $task.split('\')[-1] | Disable-ScheduledTask > $null
        continue
    }
    $object = New-TaskObj -task (Get-ScheduledTask -TaskName $result.taskname.split('\')[-1])
    if (!(Compare-Object -ReferenceObject $object.Values -DifferenceObject $output)) {
        Get-ScheduledTask -TaskPath $output.taskpath -TaskName $task.split('\')[-1] | Enable-ScheduledTask > $null
    }
    else { Get-ScheduledTask -TaskPath $output.taskpath -TaskName $task.split('\')[-1] | Disable-ScheduledTask > $null }
}

# get the appopriate log events
[int]$cevents = 10
do {
    $events = (Get-WinEvent -LogName 'Security' -MaxEvents $cevents).Where( { $_.id -eq '4698' -or $_.id -eq '4699' -or $_.id -eq '4700' -or $_.id -eq '4702' })
    [int]$cevents = ([int]$cevents * 2)
} until ($events)

# get taskname
[xml]$xml = $events[0].ToXml()
foreach ($row in $xml.Event.EventData.Data.GetEnumerator()) {
    if ($row.Name -eq 'TaskName') {
        if ([string]::IsNullOrEmpty($row.'#text')) {
            Throw "Failed to retrieve Taskname out of Event data"
        }
        else {
            $result.taskname = $row.'#text'
        }
    }
}

### lock the schedule task that has been executed
Lock-ScheduleTask -FilePath "$($PATH)allow_tasks.json" 
Test-List -FilePath "$($PATH)allow_tasks.json" 

