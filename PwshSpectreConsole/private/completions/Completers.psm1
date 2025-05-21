using namespace System.Management.Automation

class ArgumentCompletionsSpectreColors : ArgumentCompleterAttribute {
    ArgumentCompletionsSpectreColors() : base({
            param(
                [string] $commandName,
                [string] $parameterName,
                [string] $wordToComplete,
                [Language.CommandAst] $commandAst,
                [System.Collections.IDictionary] $fakeBoundParameters
            )
            foreach ($Color in ([Spectre.Console.Color] | Get-Member -Static -Type Properties).Name) {
                if ($Color -like "$wordToComplete*") {
                    [CompletionResult]::new(
                        <# completionText #> $Color,
                        <# listItemText #>   ([Spectre.Console.Markup]::new($Color, [Spectre.Console.Style]::new([Spectre.Console.Color]::$Color)) | Out-SpectreHost),
                        <# resultType #>     'ParameterValue',
                        <# toolTip #>        $Color
                    )
                }
            }
        }) { }
}

class SpectreConsoleTableBorder : IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $lookup = [Spectre.Console.TableBorder] | Get-Member -Static -MemberType Properties | Select-Object -ExpandProperty Name
        return $lookup
    }
}

class SpectreConsoleBoxBorder : IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $lookup = [Spectre.Console.BoxBorder] | Get-Member -Static -MemberType Properties | Select-Object -ExpandProperty Name
        return $lookup
    }
}

class SpectreConsoleJustify : IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $lookup = [Spectre.Console.Justify].GetEnumNames()
        return $lookup
    }
}

class SpectreConsoleHorizontalAlignment : IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $lookup = [Spectre.Console.HorizontalAlignment].GetEnumNames()
        return $lookup
    }
}

class SpectreConsoleVerticalAlignment : IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $lookup = [Spectre.Console.VerticalAlignment].GetEnumNames()
        return $lookup
    }
}

class SpectreConsoleSpinner : IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $lookup = [Spectre.Console.Spinner+Known] | Get-Member -Static -MemberType Properties | Select-Object -ExpandProperty Name
        return $lookup
    }
}

class SpectreConsoleTreeGuide : IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $lookup = [Spectre.Console.TreeGuide] | Get-Member -Static -MemberType Properties | Select-Object -ExpandProperty Name
        return $lookup
    }
}

class SpectreConsoleExceptionFormats : IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $lookup = [Spectre.Console.ExceptionFormats] | Get-Member -Static -MemberType Properties | Select-Object -ExpandProperty Name
        return $lookup
    }
}
