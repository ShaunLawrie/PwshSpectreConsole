using module "..\..\private\completions\Completers.psm1"
using module "..\..\private\completions\Transformers.psm1"

<#
.SYNOPSIS
Formats an error record/exception into a Spectre Console Exception which supports syntax highlighting.

.DESCRIPTION
Formats an error record/exception into a Spectre Console Exception which supports syntax highlighting.  
See https://spectreconsole.net/exceptions for more information.

.PARAMETER Exception
The error/exception object to format.

.PARAMETER ExceptionFormat
The format to use when rendering the exception. The default value is "Default".

.PARAMETER ExceptionStyle
The style to use when rendering the exception provided as a hashtable. e.g. 
```
@{
    Message        = "red"
    Exception      = "white"
    Method         = "yellow"
    ParameterType  = "blue"
    ParameterName  = "silver"
    Parenthesis    = "silver"
    Path           = "Yellow"
    LineNumber     = "blue"
    Dimmed         = "grey"
    NonEmphasized  = "silver"
}
```

.EXAMPLE
# **Example 1**
# This example demonstrates how to format an exception into a Spectre Console Exception with syntax highlighting.
try {
    Get-ChildItem -BadParam -ErrorAction Stop
} catch {
    $_ | Format-SpectreException -ExceptionFormat ShortenEverything
}
#>
function Format-SpectreException {
    [Reflection.AssemblyMetadata("title", "Format-SpectreException")]
    param(
        [Parameter(ValueFromPipeline, Mandatory)]
        [object] $Exception,
        [ValidateSet([SpectreConsoleExceptionFormats], ErrorMessage = "Value '{0}' is invalid. Try one of: {1}")]
        [string] $ExceptionFormat = "Default",
        [ColorThemeTransformationAttribute()]
        [hashtable] $ExceptionStyle = @{
            Message        = "Red"
            Exception      = "White"
            Method         = [Spectre.Console.Color]::Pink3
            ParameterType  = "Grey69"
            ParameterName  = $script:DefaultValueColor
            Parenthesis    = $script:DefaultValueColor
            Path           = [Spectre.Console.Color]::Pink3
            LineNumber     = "Blue"
            Dimmed         = "Grey"
            NonEmphasized  = $script:DefaultValueColor
        }
    )

    $requiredExceptionStyleKeys = @("Message", "Exception", "Method", "ParameterType", "ParameterName", "Parenthesis", "Path", "LineNumber", "Dimmed", "NonEmphasized")
    if (($requiredExceptionStyleKeys | ForEach-Object { $ExceptionStyle.Keys -contains $_ }) -contains $false) {
        throw "ExceptionStyle must contain the following keys: $($requiredExceptionStyleKeys -join ', ')"
    }

    if ($Exception -is [System.Management.Automation.ErrorRecord]) {
        $exceptionObject = $Exception.Exception
    } elseif ($Exception -is [System.Exception]) {
        $exceptionObject = $Exception
    } else {
        throw "Invalid exception object type $($Exception.GetType().FullName). Must be of type [System.Management.Automation.ErrorRecord] or [System.Exception]."
    }

    $exceptionSettings = [Spectre.Console.ExceptionSettings]::new()
    $exceptionSettings.Format = [Spectre.Console.ExceptionFormats]::$ExceptionFormat
    $exceptionSettings.Style = [Spectre.Console.ExceptionStyle]::new()
    $exceptionSettings.Style.Message = [Spectre.Console.Style]::new($ExceptionStyle.Message)
    $exceptionSettings.Style.Exception = [Spectre.Console.Style]::new($ExceptionStyle.Exception)
    $exceptionSettings.Style.Method = [Spectre.Console.Style]::new($ExceptionStyle.Method)
    $exceptionSettings.Style.ParameterType = [Spectre.Console.Style]::new($ExceptionStyle.ParameterType)
    $exceptionSettings.Style.ParameterName = [Spectre.Console.Style]::new($ExceptionStyle.ParameterName)
    $exceptionSettings.Style.Parenthesis = [Spectre.Console.Style]::new($ExceptionStyle.Parenthesis)
    $exceptionSettings.Style.Path = [Spectre.Console.Style]::new($ExceptionStyle.Path)
    $exceptionSettings.Style.LineNumber = [Spectre.Console.Style]::new($ExceptionStyle.LineNumber)
    $exceptionSettings.Style.Dimmed = [Spectre.Console.Style]::new($ExceptionStyle.Dimmed)
    $exceptionSettings.Style.NonEmphasized = [Spectre.Console.Style]::new($ExceptionStyle.NonEmphasized)

    return [Spectre.Console.ExceptionExtensions]::GetRenderable($exceptionObject, $exceptionSettings)
}
