# Mocks, some functions aren't using spectre console features and need to be mocked for the demo

# Remember how many times some mocks are called
$script:mocks = @{
    "Read-SpectrePause" = 1
    "Get-LastKeyPressed" = 0
    "Get-LastChatKeyPressed" = 0
}

function Read-SpectrePauseMock {
    param (
        [string] $Message,
        [switch] $NoNewline
    )
    Write-SpectreHost "`n$Message" -NoNewline
    Start-Sleep -Milliseconds (2000 * $script:mocks["Read-SpectrePause"])
    Write-SpectreHost ("`r" + (" " * $Message.Length))
    Write-SpectreHost ("`e[2A" | Get-SpectreEscapedText)
    $script:mocks["Read-SpectrePause"]++
}

function Get-LastKeyPressed {
    Start-Sleep -Milliseconds 1000
    $keys = @("DownArrow", "DownArrow", "DownArrow", "DownArrow", "DownArrow", "DownArrow", "DownArrow", "DownArrow", "Escape")
    $selectedKey = $keys[$script:mocks["Get-LastKeyPressed"]]
    $script:mocks["Get-LastKeyPressed"]++
    return @{
        Key = $selectedKey
    }
}

function Get-LastChatKeyPressedMock {
    $keys = @("H", "e", "l", "l", "o", " ", "w", "o", "r", "l", "d!", "Enter",
              "T", "h", "a", "n", "k", "s", " ", "f", "o", "r", " ", "t", "h", "e", " ", "d", "e", "m", "o", "Enter", "ctrl-c")

    if ($script:mocks["Get-LastChatKeyPressed"] -eq 0) {
        Start-Sleep -Seconds 4
    } else {
        Start-Sleep -Milliseconds 250
    }

    $selectedKey = $keys[$script:mocks["Get-LastChatKeyPressed"]]
    $script:mocks["Get-LastChatKeyPressed"]++

    if ($selectedKey -eq "ctrl-c") {
        return @{
            Key = "C"
            KeyChar = "C"
            Modifiers = "Control"
        }
    }

    return @{
        Key = $selectedKey
        KeyChar = $selectedKey
    }
}

function Start-SpectreRecordingMock {
    param (
        [string] $RecordingType,
        [switch] $CountdownAndClear
    )
    for($i = 3; $i -gt 0; $i--) {
        Write-SpectreHost "`r:red_circle: Recording starting in $i"
        Start-Sleep -Seconds 1
        Write-SpectreHost ("`e[1A                                  " | Get-SpectreEscapedText) -NoNewline
    }
    Write-SpectreHost ("`rRecording started" | Get-SpectreEscapedText)
    Start-Sleep -Seconds 1
}

function Stop-SpectreRecordingMock {
    $result = '<pre style="font-size:90%;font-family:consolas,''Courier New'',monospace">' + "`n"
    $result += '<span>Hello</span><span> </span><span style="color: #FF0000">world</span>' + "`n"
    $result += '</pre>'
    return $result
}

function Test-SpectreSixelSupportMock {
    return $false
}