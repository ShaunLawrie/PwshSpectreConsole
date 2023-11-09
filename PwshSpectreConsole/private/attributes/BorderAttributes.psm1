class ValidateSpectreBorder : System.Management.Automation.ValidateArgumentsAttribute 
{
    ValidateSpectreBorder() : base() { }
    [void]Validate([object] $Argument, [System.Management.Automation.EngineIntrinsics]$EngineIntrinsics) {
        $options = [Spectre.Console.BoxBorder] | Get-Member -Static -Type Properties | Select-Object -ExpandProperty Name
        $result = $options -contains $Argument
        if($result -eq $false) {
            throw "'$Argument' is not in the list of valid Spectre options ['$($options -join ''', ''')']" 
        }
    }
}

class ArgumentCompletionsSpectreBorders : System.Management.Automation.ArgumentCompleterAttribute 
{
    ArgumentCompletionsSpectreBorders() : base({
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
        $options = [Spectre.Console.BoxBorder] | Get-Member -Static -Type Properties | Select-Object -ExpandProperty Name
        return $options | Where-Object { $_ -like "$wordToComplete*" }
    }) { }
}