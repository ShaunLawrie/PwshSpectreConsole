using namespace Spectre.Console
using namespace System.Management.Automation

class ValidateSpectreColor : ValidateArgumentsAttribute {
    ValidateSpectreColor() : base() { }
    [void]Validate([object] $Color, [EngineIntrinsics]$EngineIntrinsics) {
        # Handle hex colors
        if ($Color -match '^#[A-Fa-f0-9]{6}$') {
            return
        }
        # Handle an explicitly defined spectre color object
        if ($Color -is [Color]) {
            return
        }
        $spectreColors = [Color] | Get-Member -Static -Type Properties | Select-Object -ExpandProperty Name
        $result = $spectreColors -contains $Color
        if ($result -eq $false) {
            throw "'$Color' is not in the list of valid Spectre colors ['$($spectreColors -join ''', ''')']"
        }
    }
}

class ArgumentCompletionsSpectreColors : ArgumentCompleterAttribute {
    ArgumentCompletionsSpectreColors() : base({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
            $options = [Color] | Get-Member -Static -Type Properties | Select-Object -ExpandProperty Name
            return $options | Where-Object { $_ -like "$wordToComplete*" }
        }) { }
}

class SpectreConsoleTableBorder : IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $lookup = [TableBorder] | Get-Member -Static -MemberType Properties | Select-Object -ExpandProperty Name
        return $lookup
    }
}

class SpectreConsoleBoxBorder : IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $lookup = [BoxBorder] | Get-Member -Static -MemberType Properties | Select-Object -ExpandProperty Name
        return $lookup
    }
}

class SpectreConsoleJustify : IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $lookup = [Justify].GetEnumNames()
        return $lookup
    }
}

class SpectreConsoleSpinner : IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $lookup = [Spinner+Known] | Get-Member -Static -MemberType Properties | Select-Object -ExpandProperty Name
        return $lookup
    }
}

class SpectreConsoleTreeGuide : IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $lookup = [TreeGuide] | Get-Member -Static -MemberType Properties | Select-Object -ExpandProperty Name
        return $lookup
    }
}
class ColorTransformationAttribute : ArgumentTransformationAttribute {
    [object] Transform([EngineIntrinsics]$engine, [object]$inputData) {
        if ($InputData -is [Color]) {
            return $InputData
        }
        if ($InputData.StartsWith('#')) {
            $hexBytes = [System.Convert]::FromHexString($InputData.Substring(1))
            return [Color]::new($hexBytes[0], $hexBytes[1], $hexBytes[2])
        }
        if ($InputData -is [String]) {
            return [Color]::$InputData
        }
        throw [System.ArgumentException]::new("Cannot convert '$InputData' to [Spectre.Console.Color]")
    }
}
