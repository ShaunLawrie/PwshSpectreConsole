# Required for unit test mocking
function Get-HostWidth {
    return $Host.UI.RawUI.BufferSize.Width
}