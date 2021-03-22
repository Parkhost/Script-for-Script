$ErrorActionPreference = 'Stop'
$result = @{}

function Send-AuthTasks {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] $current_obj
    )

    $params = @{
        method      = 'POST'
        contentType = 'application-json'
        body        = ConvertTo-Json -InputObject $current_obj
        headers     =
        uri = 'https://api.example.com/authtasks' # lol?
    }
    return Invoke-RestMethod @params
}


function New-TaskObj {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] $current
    )
    foreach ($task in $current) {
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
                taskpath = $task.taskpath
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
        $result[$task.taskname] = $obj
    }
    
    return $result
}


$result
$current = Get-ScheduledTask # | Export-Csv -Path C:\Temp\test.csv -NoTypeInformation
$current_obj = New-TaskObj -current $current
(ConvertTo-Json -InputObject $current_obj) > C:\Temp\test.json
