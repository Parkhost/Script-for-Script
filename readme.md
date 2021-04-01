# Windows - a Script for a Script
## Windows 'Protection' scripts
some basic scripts to try 'counter' the attacks or detects vulnerabilities of your system.
Attempting to make Windows 10 more secure?
---

# Schedule task detection
Check on event if schedule task is created / updated or enabled.
Kicks in another script which disables the tasks and checks if it is on the 'allow list'.
[PoC Source](https://enigma0x3.net/2016/05/25/userland-persistence-with-scheduled-tasks-and-com-handler-hijacking/) Scheduled tasks can be abused to do some peculiar stuff

### Info
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

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ParkHost/Windows-Script_for_Script/master/Check%20SCtask/Create-ScheduleTaskEvent.ps1'))
```


## Todo / Ideas:
- [x] Preform (automatic) actions to this event
- [x] Exclusion list of tasks that may always run
- [x] Auto block without notice - Manage a central allow list on github
    - [x] Auto block on action and arguments
    - [x] Cache - sha checksum
    - [ ] (Custom) Exclusion list - clone repo and upload your own allow_tasks.json (see the upload script..)

- [ ] Run a scan to eliminate all 'bad' tasks - or report only...
- [ ] Upload unauthorized tasks details to database.

---

# CVE Mitre check
Get all your installed applications with version.
Do a check against the CVE Mitre database if any known vulnerabilities are present of the specific application and version.
Give a report back to the user.

already have a bash script to create a mongodb out of Mitre Github.
Also builded, in one of my previous project, a javascript (native) API around it :\
I going to rebuild it in Python or Feathersjs.

- [x] Get all application names and version numbers.
- [ ] Check the data against [Mitre CVE database.](https://cve.mitre.org/)
- [ ] Notice user if anything is detected.
