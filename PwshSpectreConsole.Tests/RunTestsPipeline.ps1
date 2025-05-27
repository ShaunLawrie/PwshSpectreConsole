# Run the unit tests for the module PwshSpectreConsole while in a pipeline
$modulePath = Resolve-Path -Path "..\PwshSpectreConsole\"
$env:PSModulePath = @($env:PSModulePath, $modulePath) -join ":"

# Execute the tests excluding the ones tagged with "ExcludeCI"
Invoke-Pester -CI -ExcludeTag "ExcludeCI"