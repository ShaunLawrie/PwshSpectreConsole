class ValidateSpectreSpinner : System.Management.Automation.ValidateArgumentsAttribute 
{
    ValidateSpectreSpinner() : base() { }
    [void]Validate([object] $Argument, [System.Management.Automation.EngineIntrinsics]$EngineIntrinsics) {
        $options = [Spectre.Console.Spinner+Known] | Get-Member -Static -Type Properties | Select-Object -ExpandProperty Name
        $result = $options -contains $Argument
        if($result -eq $false) {
            throw "'$Argument' is not in the list of valid Spectre options ['$($options -join ''', ''')']" 
        }
    }
}

class ArgumentCompletionsSpectreSpinners : System.Management.Automation.ArgumentCompleterAttribute 
{
    ArgumentCompletionsSpectreSpinners() : base({
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
        $options = [Spectre.Console.Spinner+Known] | Get-Member -Static -Type Properties | Select-Object -ExpandProperty Name
        return $options | Where-Object { $_ -like "$wordToComplete*" }
    }) { }
}