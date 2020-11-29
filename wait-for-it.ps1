<# 
.SYNOPSIS 
A powershell script to test wether a TCP service is or becomes available during a given timeout.
.DESCRIPTION
The MIT License (MIT)
Copyright (c) 2020 Lasse Wulff

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
#>
param (
    [Parameter(Position = 0, mandatory = $true)][string]$hostname ## Host or IP under test
, [Parameter(Position = 1, mandatory = $true)][int]$port ##TCP port under test
, [Parameter(Position = 2, mandatory = $false)][switch]$strict = $false ##Only execute subcommand if the test succeeds
, [Parameter(Position = 3, mandatory = $false)][switch]$quiet = $false ##Don't output any status messages
, [Parameter(Position = 4, mandatory = $false)][int]$timeout = 15 ##Timeout in seconds, zero for no timeout
, [Parameter(Position = 5, mandatory = $false)][string]$command ##Execute command with args after the test finishes
)

function print([String] $message)
{
    if (!$quiet)
    {
        Write-Host $message
    }
}
function connect([String] $server, [int] $port){
    try
    {
        $client = New-Object System.Net.Sockets.TcpClient($server, $port)
        $client.Dispose()
        $true
    }
    catch
    {
        $false
    }
}
$scriptName = $MyInvocation.MyCommand.Name
$timer = [Diagnostics.Stopwatch]::StartNew()
$result = $false
if ($timeout -gt 0)
{
    print("$scriptName`: waiting $timeout seconds for $hostname`:$port")
}
else
{
    print("$scriptName`: waiting for $hostname`:$port without a timeout")
}
while (($timer.Elapsed.TotalSeconds -lt $timeout) -or $timeout -le 0 -and !$result)
{
    # Try to connect
    $result = connect $hostname $port
}
# Get the time
$totalSecs = [math]::Round($timer.Elapsed.TotalSeconds, 0)
if ($result)
{
    # Port is available within timeout
    print("$scriptName`: $hostname`:$port is available after $totalSecs seconds")
    if ($command)
    {
        # TODO: Execute command
    }
    else
    {
        exit(0)
    }
}
else
{
    # Service is not available within timeout
    print("$scriptName`: timeout occurred after waiting $timeout seconds for $hostname`:$port")
    if ($strict)
    {
        # Not executing command because of strict mode
        print("$scriptName`: strict mode, refusing to execute subprocess")
        exit(1)
    }
    else
    {
        # Executing command if given, else return that service is not available
        if ($command)
        {
            # TODO: Execute command
        }
        else
        {
            exit(1)
        }
    }
}
