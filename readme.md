# Windows 10 protection scripts
some basic scripts to try 'counter' the attacks or detects vulnerabilities of your system.
Trying to make Windows more secure, without eating all the resource which most AV's does..

---

# Schedule task detection
Check on event if schedule task is created or updated.
Kicks in another script which disables the tasks and checks if it is on the 'allow list'.
Tried to disable all the scheduled tasks, some are 'Access is denied' as SYSTEM..

## Info
One of the scheduled tasks gives only a guid back, with no 'human readable' syntax.
I cannot find what this guid does nor where it referring to. 
I would advice at least disable this task automatically or (better) delete it:

> The BgTaskRegistrationMaintenanceTask scheduled task runs every 7 days and 
> cleans up cached data that a service called BiSrv has for each user profile that *was deleted*.

[source](https://techcommunity.microsoft.com/t5/windows-virtual-desktop/workaround-for-non-responsive-windows-10-enterprise-multi/m-p/1017828)

```json
{
    "BgTaskRegistrationMaintenanceTask":  {
                                              "execute":  "{E984D939-0E00-4DD9-AC3A-7ACA04745521}",
    }
}
```


## Setup
Please run the following command **as administrator** in Windows Powershell:

```ps
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ParkHost/Windows-Script_for_Script/master/Check%20SCtask/Create-ScheduleTaskEvent.ps1'))
```


## Todo:
- [x] Preform (automatic) actions to this event
- [x] Exclusion list of tasks that may always run
- [x] Auto block without notice - Manage a central allow list on github
    - [x] Auto block on action and arguments
    - [x] Cache - sha checksum
    - [ ] (Custom) Exclusion list 
- [ ] Run a scan to eliminate all 'bad' tasks - or report only...
- [ ] Upload unauthorized tasks details to database.

---

# CVE Mitre check
Idea, get all application names and version numbers.
Check this data against the CVE mitre database.
Notice user if anything is detected
