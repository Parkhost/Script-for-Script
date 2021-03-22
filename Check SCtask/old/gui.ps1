# Function New-ScheduleTaskAction {
#     [CmdletBinding()]
#     param (
#         [Parameter(Mandatory = $true)] [String] $TaskName
#     )
#     if (Get-ScheduledTask -taskName $TaskName -ErrorAction SilentlyContinue) {
#         # Start-ScheduledTask -TaskName $TaskName 
#         #continue
#     }
#     else {
#         $ActionParameters = @{
#             Execute  = 'C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe'
#             Argument = "-NoProfile -NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -file `"$($PATH)$($TaskName).ps1`""
#         }
#         $RegSchTaskParameters = @{
#             TaskName    = $TaskName
#             Description = 'Activates the schedule task alert dialog to user'
#             TaskPath    = '\'
#             Action      = New-ScheduledTaskAction @ActionParameters
#             Principal   = New-ScheduledTaskPrincipal -UserId "$($env:USERDOMAIN)\$($env:USERNAME)" -LogonType ServiceAccount -RunLevel Highest
#             Settings    = New-ScheduledTaskSettingsSet
        
#         }
#         try {
#             Register-ScheduledTask @RegSchTaskParameters -Force
#             # Start-ScheduledTask -TaskName $TaskName 
#         }
#         catch {
#             $result.failed = $true
#             $result.msg = "Failed to start/run schedule task, $($Error[0])"
#             return $result
#         }
#     }
# }

# New-ScheduleTaskAction -TaskName 'Alert-Dialog'



#-------------


# [string[]]$string = $null
# foreach ($key in $result.Keys) {
#     $string += "
#         $($key) = $($result[$key])"
# }
# $noquote = $string.replace("`"", "")
# $script = @"
#     `$wshell = New-Object -ComObject Wscript.Shell
#     `$uinput = `$wshell.Popup("Keep the following scheduled task blocked?
#     $($noquote)",0,"ALERT!",20)
    
#     `$uinput > "$($PATH)input.txt"
#     "$($result.taskName)" >> "$($PATH)input.txt"
#     if(`$uinput -eq '6'){
#         "$($result.taskName)" >> "$($PATH)block.txt"    
#     } else {
#         "$($result.taskName)" >> "$($PATH)unblock.txt"
#     }
# "@
# try {
#     $script > "$($PATH)$($TaskName).ps1"
# }
# catch {
#     $result.failed = $true
#     $result.msg = "Failed to create Dialog script: $($Error[0])"
#     return $result
# }
# ## create schedule task / script (show dialog) or activate it if user is logged in
# if (!(Get-ScheduledTask -TaskName "$($TaskName)")) {
#     New-ScheduleTaskAction -TaskName "$($TaskName)"
# }
# Start-ScheduledTask -TaskName "$($TaskName)"
# start-sleep 1
# Unregister-ScheduledTask -Taskname "$($TaskName)" -Confirm:$false > $null
# Watch-Output -file "$($PATH)input.txt"