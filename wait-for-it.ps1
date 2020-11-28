param (
    [Parameter(Position = 0, mandatory = $true)][string]$hostname,
    [Parameter(Position = 1, mandatory = $true)][int]$port,
    [Parameter(Position = 2, mandatory = $false)][switch]$strict = $false,
    [Parameter(Position = 3, mandatory = $false)][switch]$quiet = $false,
    [Parameter(Position = 4, mandatory = $false)][int]$timeout = 15,
    [Parameter(Position = 5, mandatory = $false)][string]$command
)
# TODO: Implement use of quiet parameter
$scriptName = $MyInvocation.MyCommand.Name
$timer = [Diagnostics.Stopwatch]::StartNew()
$result = $false
if ($timeout -gt 0) {
    Write-Host "$scriptName`: waiting $timeout seconds for $hostname`:$port"
}
else {
    Write-Host "$scriptName`: waiting for $hostname`:$port without a timeout"
}
while (($timer.Elapsed.TotalSeconds -lt $timeout) -or $timeout -le 0 -and !$result) {
    # Try to connect
    $result = Test-NetConnection -ComputerName $hostname -Port $port -InformationLevel Quiet
}
# Get the time
$totalSecs = [math]::Round($timer.Elapsed.TotalSeconds,0)
if ($result) {
    # Port is available within timeout
    Write-Host "$scriptName`: $hostname`:$port is available after $totalSecs seconds"
    if ($command) {
        # TODO: Execute command
    } else {
        exit(0)
    }
} else {
    # Service is not available within timeout
    Write-Host "$scriptName`: timeout occurred after waiting $timeout seconds for $hostname`:$port"
    if ($strict) {
        # Not executing command because of strict mode
        Write-Host "$scriptName`: strict mode, refusing to execute subprocess"
        exit(1)
    } else {
        # Executing command if given, else return that service is not available
        if ($command) {
            # TODO: Execute command
        } else {
            exit(1)
        }
    }
}