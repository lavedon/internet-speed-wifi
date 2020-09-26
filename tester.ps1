function Start-NetSpeedTest {
    [CmdletBinding(PositionalBinding=$false)]
    param
    (
        [parameter(Mandatory=$false)]
        [String]$GoogleSheetURL,

        # What is the minimum % of packetloss
        # Before an alert is raised.
        [parameter(Mandatory=$false)]
        [int]$MinPacketAlert,

        # What is the minimum % of jitter 
        # Before an alert is raised.
        [parameter(Mandatory=$false)]
        [int]$MinJitter,

        # Download CLI to a different location
        [parameter(Mandatory=$false)]
        [string]$DownloadLocation = "$($Env:ProgramData)\SpeedtestCLI",

        # Turn off Wi-Fi tests
        [switch]
        $WiFiOff,

        # Don't check if SpeedtestCLI failed
        [switch]
        $SkipInstallCheck,

        # Don't start a job/use tash scheduler
        # Run only once 
        [switch]
        $Once
    )

    begin {

function Get-SpeedTestCLI {
    param(
        [parameter(Mandatory=$false)]
        [string]$DownloadURL = ""
    )
    try {
        $TestDownloadLocation = Test-Path $DownloadLocation;
        if (!$TestDownloadLocation) {
            new-item $DownloadLocation -ItemType Directory -force;
            Invoke-WebRequest -Uri $DownloadURL -OutFile "$($DownloadLocation)\speedtest.zip";
            Expand-Archive "$(DownloadLocation)\speedtest.zip" -DestinationPath $DownloadLocation -Force;

        }
    }
    catch {
        write-host "The download and extraction of SpeedtestCLI failed. Error: $($_.Exception.Message)"
        exit 1
    }
}

function Set-Results {
    param()
    try {
        # Execulte the Speed Test with an output of JSON
        $SpeedtestResults = & "$($DownloadLocation)\speedtest.exe" --format=json

        [PSCustomObject]$SpeedtestObj = @{
            time = $SpeedtestResults.time;
            downloadSpeed = $SpeedtestResults.download.bandwidth;
            uploadSpeed = $SpeedtestResults.upload.bandwidth;
            packetLoss = $SpeedtestResults.packetLoss;
            jitter = $SpeedtestResults.ping.jitter;
            latency = $SpeedtestResults.ping.latency;
            serverHost = $SpeedtestResults.server.host;
            serverLocation = $SpeedtestResults.server.location;
            serverIp = $SpeedtestResults.server.ip;
            ourIP = $SpeedtestResults.interface.externalIp;
            vpn = $SpeedtestResults.interface.isVpn;
            isp = $SpeedtestResults.isp;
            resultsURL = $SpeedtestResults.result.url;
        }

        #Export Object to text file
        $SpeedtestObj | Out-File -Path "$($DownloadLocation)\LastResults.txt" -Force
        # Place Date between blocks
        Get-Date | Out-File "C:\users\Luke\Desktop\all-speed-tests.txt" -Append -NoClobber
        $SpeedtestObj | Out-File -Path "$($DownloadLocation)\all-speed-tests.txt" -Append -NoClobber
        $SpeedtestObj | Export-CSV -Path "$($DoanloadLocation)\all-speed-tests.csv" -Append -NoTypeInformation -NoClobber


        # @TODO also append a CSV File 
        }
    catch {
        Write-Host "Could not get Speed Test results from SpeedTest CLI.  Error: $($_.Exception.Message)" 
        }
    }
    # Main Part of Code
    if(!$SkipInstallCheck) {
        Get-SpeedTestCLI;
    }
    Set-Results;
    #End begin block
    }
}