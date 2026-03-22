if (-not (Test-Path -Path '.\.ext\config.cpp')) {
    New-Item -Name '.ext' -ItemType Directory
    & curl.exe -LO --output-dir '.\.ext' 'https://github.com/SpecialKO/SpecialK/raw/refs/heads/main/src/config.cpp'
}

$content = Get-Content -Path '.\.ext\config.cpp' -Raw

$configEntries = $content | Select-String -Pattern 'ConfigEntry\s*\([\s\S]+?(?=\),)\),(?=\r\n)' -AllMatches

$results = foreach ($entry in $configEntries.Matches.Value) {
    if ($entry -match 'ConfigEntry\s*\(([^,]+),\s*L"([^"]+)",\s*([^,]+),\s*L"([^"]+)",\s*L"([^"]+)"\)') {
        [PSCustomObject]@{
            Parameter   = $Matches[1]
            Description = $Matches[2]
            IniFile     = $Matches[3]
            Section     = $Matches[4]
            Key         = $Matches[5]
        }
    }
}

if (Test-Path -Path '.\.out\config.csv') {
    if (Test-Path -Path '.\.out') {
        New-Item -Name '.out' -ItemType Directory
    }
    Remove-Item -Path '.\.out\config.csv'
}

$results | Export-Csv -Path '.\.out\config.csv'
