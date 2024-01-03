# Required for unit test mocking in Read-SpectrePause
# Set the cursor to an arbitrary window position
function Set-CursorPosition {
    param (
        [int] $X,
        [int] $Y
    )
    [Console]::SetCursorPosition($X, $Y)
}