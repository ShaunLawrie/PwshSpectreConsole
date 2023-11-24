<#
    [ValidateSet([SpectreConsoleTableBorder],ErrorMessage="Value '{0}' is invalid. Try one of: {1}")]
    [ValidateSet([SpectreConsoleColor],ErrorMessage = "Value '{0}' is invalid. Try one of: {1}")]
    [ValidateSet([SpectreConsoleBoxBorder],ErrorMessage = "Value '{0}' is invalid. Try one of: {1}")]
    [ValidateSet([SpectreConsoleJustify],ErrorMessage = "Value '{0}' is invalid. Try one of: {1}")]
    [ValidateSet([SpectreConsoleSpinner],ErrorMessage = "Value '{0}' is invalid. Try one of: {1}")]
    [ValidateSet([SpectreConsoleTreeGuide],ErrorMessage = "Value '{0}' is invalid. Try one of: {1}")]
#>
class SpectreConsoleTableBorder : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $lookup = [Spectre.Console.TableBorder].GetProperties().Name
        return $lookup
    }
}
class SpectreConsoleColor : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $lookup = [Spectre.Console.Color].GetProperties().Name
        return $lookup
    }
}
class SpectreConsoleBoxBorder : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $lookup = [Spectre.Console.BoxBorder].GetProperties().Name
        return $lookup
    }
}
class SpectreConsoleJustify : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $lookup = [Spectre.Console.Justify].GetEnumNames()
        return $lookup
    }
}
class SpectreConsoleSpinner : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $lookup = [Spectre.Console.Spinner+Known].GetProperties().Name
        return $lookup
    }
}
#
class SpectreConsoleTreeGuide : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $lookup = [Spectre.Console.TreeGuide].GetProperties().Name
        return $lookup
    }
}
