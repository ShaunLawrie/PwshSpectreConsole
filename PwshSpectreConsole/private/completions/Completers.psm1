using namespace System.Management.Automation

class ValidateSpectreColor : ValidateArgumentsAttribute {

    static[void]ValidateItem([object] $ItemColor) {
        # Handle hex colors
        if ($ItemColor -match '^#[A-Fa-f0-9]{6}$') {
            return
        }
        # Handle an explicitly defined spectre color object
        if ($ItemColor -is [Spectre.Console.Color]) {
            return
        }
        $spectreColors = [Spectre.Console.Color] | Get-Member -Static -Type Properties | Select-Object -ExpandProperty Name
        $result = $spectreColors -contains $ItemColor
        if ($result -eq $false) {
            throw "'$ItemColor' is not in the list of valid Spectre colors ['$($spectreColors -join ''', ''')']"
        }
    }

    ValidateSpectreColor() : base() { }
    [void]Validate([object] $Color, [EngineIntrinsics]$EngineIntrinsics) {
        [ValidateSpectreColor]::ValidateItem($Color)
    }
}

class ValidateSpectreColorTheme : ValidateArgumentsAttribute {
    ValidateSpectreColorTheme() : base() { }
    [void]Validate([object] $Colors, [EngineIntrinsics]$EngineIntrinsics) {
        if ($Colors -isnot [hashtable]) {
            throw "Color theme must be a hashtable of Spectre Console color names and values"
        }
        foreach ($color in $Colors.GetEnumerator()) {
            [ValidateSpectreColor]::ValidateItem($color.Value)
        }
    }
}

class ValidateSpectreTreeItem : ValidateArgumentsAttribute {

    static[void]ValidateItem([object] $TreeItem) {
        # These objects are already renderable
        if ($TreeItem -isnot [hashtable]) {
            throw "Input for Spectre Tree must be a hashtable with 'Value' (and the optional 'Children') keys"
        }

        if ($TreeItem.Keys -notcontains "Value") {
            throw "Input for Spectre Tree must be a hashtable with 'Value' (and the optional 'Children') keys"
        }

        if ($TreeItem.Keys -contains "Children") {
            if ($TreeItem.Children -isnot [array]) {
                throw "Children must be an array of tree items (hashtables with 'Value' and 'Children' keys)"
            }
            foreach ($child in $TreeItem.Children) {
                [ValidateSpectreTreeItem]::ValidateItem($child)
            }
        }
    }

    [void]Validate([object] $TreeItem, [EngineIntrinsics]$EngineIntrinsics) {
        [ValidateSpectreTreeItem]::ValidateItem($TreeItem)
    }
}

class ArgumentCompletionsSpectreColors : ArgumentCompleterAttribute {
    ArgumentCompletionsSpectreColors() : base({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
            $options = [Spectre.Console.Color] | Get-Member -Static -Type Properties | Select-Object -ExpandProperty Name
            return $options | Where-Object { $_ -like "$wordToComplete*" }
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