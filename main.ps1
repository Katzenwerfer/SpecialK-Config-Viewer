if (-not (Test-Path -Path '.\.ext\config.cpp')) {
    New-Item -Name '.ext' -ItemType Directory | Out-Null
    & curl.exe -LO --output-dir '.\.ext' 'https://github.com/SpecialKO/SpecialK/raw/refs/heads/main/src/config.cpp'
}

$content = Get-Content -Path '.\.ext\config.cpp' -Raw

$trimmedContent = $content | Select-String -Pattern 'static const std::initializer_list <param_decl_s> params_to_build[\s\S]+for \( auto& decl : params_to_build \)'

$configEntries = $trimmedContent.Matches.Value | Select-String -Pattern '(?:ConfigEntry|Keybind)\s*\([\s\S]+?(?=\),)\),(?=\r\n)' -AllMatches

$normalizedEntries = foreach ($entry in $configEntries.Matches.Value) {
    if ($entry -match 'ConfigEntry\s*\(([^,]+),\s*L"([\s\S]+?(?=" ?,)" ?,)\s*([^,]+),\s*L"([^"]+)",\s*L"([^"]+)"\),') {
        [PSCustomObject]@{
            Parameter   = $Matches[1] -replace '([^\s]+)(?:\s*([^\s]+))?', '$1$2'
            Description = $Matches[2] -replace '([^"]+)"(?:\s*L"([^"]+)")?(?:\s*L"([^"]+)")?,', '$1$2$3'
            IniFile     = $Matches[3]
            Section     = $Matches[4]
            Key         = $Matches[5]
        }
    }
    elseif ($entry -match 'Keybind\s*\( ?&([^,]+),\s*L"([\s\S]+?(?=" ?,)" ?,)\s*([^,]+),\s*L"([^"]+)"\),') {
        [PSCustomObject]@{
            Parameter   = $Matches[1] -replace '([^\s]+)(?:\s*([^\s]+))?', '$1$2'
            Description = $Matches[2] -replace '([^"]+)"(?:\s*L"([^"]+)")?(?:\s*L"([^"]+)")?,', '$1$2$3'
            IniFile     = $Matches[3]
            Section     = $Matches[4]
            Key         = $Matches[5]
        }
    }
}

if (Test-Path -Path '.\.out\config.csv') {
    Remove-Item -Path '.\.out\config.csv'
}
elseif (-not (Test-Path -Path '.\.out')) {
    New-Item -Name '.out' -ItemType Directory | Out-Null
}

$normalizedEntries | Export-Csv -Path '.\.out\config.csv'
