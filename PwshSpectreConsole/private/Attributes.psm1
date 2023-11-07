class ValidateSpectreColor : System.Management.Automation.ValidateArgumentsAttribute 
{
    ValidateSpectreColor() : base() { }
    [void]Validate([object] $Color, [System.Management.Automation.EngineIntrinsics]$EngineIntrinsics) {
        # Handle hex colors
        if($Color -match '^#[A-Fa-f0-9]{6}$') {
            return
        }

        $spectreColors = [Spectre.Console.Color] | Get-Member -Static -Type Properties | Select-Object -ExpandProperty Name
        $result = $spectreColors -contains $Color
        if($result -eq $false) {
            throw "'$Color' is not in the list of valid Spectre colors ['$($spectreColors -join ''', ''')']" 
        }
    }
}

class ArgumentCompletionsSpectreColors : System.Management.Automation.ArgumentCompleterAttribute 
{
    ArgumentCompletionsSpectreColors() : base({
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
        $options = [Spectre.Console.Color] | Get-Member -Static -Type Properties | Select-Object -ExpandProperty Name
        return $options | Where-Object { $_ -like "$wordToComplete*" }
    }) { }
}

<#
# Get all emoji codes

[Spectre.Console.Emoji+Known].GetMembers().Name | ForEach-Object {
  ":" + ($_ -creplace "([a-z])([A-Z0-9])", '$1_$2').ToLower().Trim() + ": " + [Spectre.Console.Emoji+Known]::$_
}
#>