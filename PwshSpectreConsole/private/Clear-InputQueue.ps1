# Required for unit test mocking in Read-SpectrePause
# This drains the input buffer so if the user has pressed enter or any other key, it won't be read by the following prompt
function Clear-InputQueue {
    while ([System.Console]::KeyAvailable) {
        $null = [System.Console]::ReadKey($true)
    }
}