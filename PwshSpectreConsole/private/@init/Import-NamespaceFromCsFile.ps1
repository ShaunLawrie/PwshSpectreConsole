$global:SpectreConsoleNamespaces = @{
    "PwshSpectreConsole.VTCodes"   = @{
        Path                 = "$PSScriptRoot\..\classes\PwshSpectreConsole.VTCodes.cs"
        Imported             = $false
        ReferencedAssemblies = @()
    }
    "PwshSpectreConsole.Recording" = @{
        Path                 = "$PSScriptRoot\..\classes\PwshSpectreConsole.Recording.cs"
        Imported             = $false
        ReferencedAssemblies = @(
            "netstandard",
            "Spectre.Console",
            "Spectre.Console.Json",
            "System.Text.RegularExpressions",
            "System.Text.Encodings.Web",
            "System.Text.Json",
            "System.Console",
            "System.Threading",
            "System.Threading.Thread",
            "System.Threading.Tasks",
            "System.Collections"
        )
    }
}

<#
.SYNOPSIS
    Imports a namespace from a C# file.

.DESCRIPTION
    The Import-FromCsFile function imports a namespace from a C# file. It adds the C# file as a type using the Add-Type cmdlet.
    This is temporary, if we're embedding C# code in a module, we should be using the C# compiler to compile the code into a DLL.

.PARAMETER Namespace
    Specifies the C# Namespace to import.
#>
function Import-NamespaceFromCsFile {
    param(
        [ValidateSet('PwshSpectreConsole.VTCodes', 'PwshSpectreConsole.Recording')]
        [string]$Namespace
    )
    $thisFile = $global:SpectreConsoleNamespaces[$Namespace]
    if ($thisFile.Imported -eq $false) {
        Add-Type -Path $thisFile.Path -ReferencedAssemblies $thisFile.ReferencedAssemblies
        $thisFile.Imported = $true
    }
}
