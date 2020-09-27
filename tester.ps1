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
        Write-Verbose "Looking for your installation of SpeedTest CLI";
        $TestDownloadLocation = Test-Path $DownloadLocation;
        if (!$TestDownloadLocation) {
            Write-Verbose "Downloading SpeedTest CLI"
            new-item $DownloadLocation -ItemType Directory -force;
            Invoke-WebRequest -Uri $DownloadURL -OutFile "$($DownloadLocation)\speedtest.zip";
            Write-Verbose "Extracting..."
            Expand-Archive "$(DownloadLocation)\speedtest.zip" -DestinationPath $DownloadLocation -Force;

        }
        else {
            Write-Verbose "Found. Already Installed..."
        }
    }
    catch {
        Write-Verbose "The download and extraction of SpeedtestCLI failed. Error: $($_.Exception.Message)"
        exit 1
    }
}

function Set-Results {
    param()
    try {
        # Execulte the Speed Test with an output of JSON
        Write-Verbose "Beginning speed test...";
        $SpeedtestResults = & "$($DownloadLocation)\speedtest.exe" --format=json
        Write-Verbose "Test completed...";
        
        $SpeedtestResults = $SpeedtestResults | ConvertFrom-Json
        [PSCustomObject]$SpeedtestObj = @{};

        $SpeedtestObj = [PSCustomObject]@{
            time = [string]$SpeedtestResults.timestamp
            downloadSpeed = [math]::Round($SpeedtestResults.download.bandwidth / 1000000 * 8, 4)
            uploadSpeed = [math]::Round($SpeedtestResults.upload.bandwidth / 1000000 * 8, 4)
            packetLoss = $SpeedtestResults.packetLoss
            jitter = [math]::Round($SpeedtestResults.ping.jitter, 4)
            latency = [math]::Round($SpeedtestResults.ping.latency, 4)
            serverHost = $SpeedtestResults.server.host
            serverLocation = $SpeedtestResults.server.location
            serverIp = $SpeedtestResults.server.ip
            ourIP = $SpeedtestResults.interface.externalIp
            vpn = [bool]$SpeedtestResults.interface.isVpn
            isp = $SpeedtestResults.isp
            resultsURL = $SpeedtestResults.result.url
        }

        Write-Verbose "Download Speed: $($SpeedtestObj.downloadSpeed) Upload Speed: $($SpeedtestObj.uploadSpeed)" 
        Write-Verbose "Latency $($SpeedtestObj.latency) Jitter: $($SpeedtestObj.jitter)"

        #Export Object to text file
        $SpeedtestObj | Out-File "$($DownloadLocation)\LastResults.txt" -Force
        # Place Date between blocks
        Get-Date | Out-File "C:\users\Luke\Desktop\all-speed-tests.txt" -Append -NoClobber -Force
        $SpeedtestObj | Out-File "$($DownloadLocation)\all-speed-tests.txt" -Append -NoClobber -Force
        $SpeedtestObj | Export-CSV "$($DownloadLocation)\all-speed-tests.csv" -Append -NoTypeInformation -NoClobber -Force
        Write-Verbose "Written to files."


        # @TODO also append a CSV File 
        }
    catch {
        Write-Verbose "Could not get Speed Test results from SpeedTest CLI.  Error: $($_.Exception.Message)" 
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