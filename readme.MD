#########
READ ME:

By default, the script runs the main method in verbose mode 
The script will auto install the SpeedTest CLI if it is not present.

After you load the script - to run a test again without checking whether 
or not SpeedTest CLI is installed call
Start-NetSpeedTest -SkipInstallCheck

run
Start-NetSpeedTest -Verbose 

For debugging info.

You can place the URL of the Google Sheet WEB App
you want to paste to in gas-url.txt
or pass it via the parameter Start-NetSpeedTest -GoogleWebAppURL "my-url-here"

Reminder of how to set this script to run on a schedule:

Create a new trigger:
$t = New-JobTrigger -Once -At "10/05/2020 20:46" `
-RepetitionInterval (New-TimeSpan -Hours 2) -RepetitionDuration (New-TimeSpan -Days 60) `
-RandomDelay (New-TimeSpan -Minutes 20)

Use the trigger to create a scheduled job:
Register-ScheduledJob -Name NetSpeedTest1 `
-FilePath "C:\my-coding-projects\internet-tester\tester.ps1" -Trigger $t -RunNow

See the status of jobs:
Get-ScheduledJob

Disable future jobs:
Unregister-ScheduledJob -Id 1

Alerts (i.e. alerting user when packet loss has reached a certain threshold - alerting user when latency has jumped up 
at a shocking rate, etc.) is not yet implemented...
due to sloth and torpor.
