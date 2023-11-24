using namespace Spectre.Console
using namespace System.Management.Automation
class ValidateSpectreColor : ValidateArgumentsAttribute {
    ValidateSpectreColor() : base() { }
    [void]Validate([object] $Color, [EngineIntrinsics]$EngineIntrinsics) {
        # Handle hex colors
        if ($Color -match '^#[A-Fa-f0-9]{6}$') {
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
# cant use the same approach on colors as that breaks the hex colors validation.
class SpectreConsoleColor : IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $lookup = [Color] | Get-Member -Static -MemberType Properties | Select-Object -ExpandProperty Name
        return $lookup
    }
}
# just testing Transformation. This is not used at the moment.
class HexColorTransformAttribute : ArgumentTransformationAttribute {
    [Object] Transform([EngineIntrinsics]$engineIntrinsics, [Object]$Color) {
        if ($Color -is [Color]) {
            return $Color
        }
        if ($Color -match '^#[A-Fa-f0-9]{6}$') {
            $hexString = $Color -replace '^#'
            $hexBytes = [System.Convert]::FromHexString($hexString)
            return [Color]::new($hexBytes[0], $hexBytes[1], $hexBytes[2]).ToMarkup()
        } else {
            # throw?
            return [Color]::$Color
        }
    }
}
<#
# Get all emoji codes

[Spectre.Console.Emoji+Known].GetMembers().Name | ForEach-Object {
  ":" + ($_ -creplace "([a-z])([A-Z0-9])", '$1_$2').ToLower().Trim() + ": " + [Spectre.Console.Emoji+Known]::$_
}
#>
