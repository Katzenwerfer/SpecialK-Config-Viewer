if (-not (Test-Path -Path '.\.ext\config.cpp')) {
    New-Item -Name '.ext' -ItemType Directory
    & curl.exe -LO --output-dir '.\.ext' 'https://github.com/SpecialKO/SpecialK/raw/refs/heads/main/src/config.cpp'
}

$content = Get-Content -Path '.\.ext\config.cpp'

$configEntries = $content | Where-Object {
    $PSItem -match '^\s*ConfigEntry'
}

$results = foreach ($entry in $configEntries) {
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
