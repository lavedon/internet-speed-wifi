# #######################
# THANKS TO:
# Kelvin Tegelaar
# https://www.cyberdrain.com/monitoring-with-powershell-monitoring-internet-speeds/
# 
#@Todo set logging levels
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
        Write-Host "Looking for your installation of SpeedTest CLI";
        $TestDownloadLocation = Test-Path $DownloadLocation;
        if (!$TestDownloadLocation) {
            Write-Host "Downloading SpeedTest CLI"
            new-item $DownloadLocation -ItemType Directory -force;
            Invoke-WebRequest -Uri $DownloadURL -OutFile "$($DownloadLocation)\speedtest.zip";
            Write-Host "Extracting..."
            Expand-Archive "$(DownloadLocation)\speedtest.zip" -DestinationPath $DownloadLocation -Force;

        }
        else {
            Write-Host "Found. Already Installed..."
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
        Write-Host "Beginning speed test...";
        $SpeedtestResults = & "$($DownloadLocation)\speedtest.exe" --format=json
        Write-Host "Test completed...";
        
        [PSCustomObject]$SpeedtestObj = @{};

        $SpeedtestObj = [PSCustomObject]@{
            time = [string]$SpeedtestResults.timestamp
            downloadSpeed = $SpeedtestResults.download.bandwidth
            uploadSpeed = $SpeedtestResults.upload.bandwidth
            packetLoss = $SpeedtestResults.packetLoss
            jitter = $SpeedtestResults.ping.jitter
            latency = $SpeedtestResults.ping.latency
            serverHost = $SpeedtestResults.server.host
            serverLocation = $SpeedtestResults.server.location
            serverIp = $SpeedtestResults.server.ip
            ourIP = $SpeedtestResults.interface.externalIp
            vpn = [bool]$SpeedtestResults.interface.isVpn
            isp = $SpeedtestResults.isp
            resultsURL = $SpeedtestResults.result.url
        }

        Write-Host "Download Speed: $($SpeedtestObj.downloadSpeed) Upload Speed: $($SpeedtestObj.uploadSpeed)" -NoNewline
        Write-host "Latency $($SpeedtestObj.latency) Jitter: $($SpeedtestObj.jitter)"

        #Export Object to text file
        $SpeedtestObj | Out-File -Path "$($DownloadLocation)\LastResults.txt" -Force
        # Place Date between blocks
        Get-Date | Out-File "C:\users\Luke\Desktop\all-speed-tests.txt" -Append -NoClobber -Force
        $SpeedtestObj | Out-File -Path "$($DownloadLocation)\all-speed-tests.txt" -Append -NoClobber -Force
        $SpeedtestObj | Export-CSV -Path "$($DownloadLocation)\all-speed-tests.csv" -Append -NoTypeInformation -NoClobber -Force
        Write-Host "Written to files."


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