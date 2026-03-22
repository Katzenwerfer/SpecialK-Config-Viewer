if (-not (Test-Path -Path '.\.ext\config.cpp')) {
    New-Item -Name '.ext' -ItemType Directory
    & curl.exe -LO --output-dir '.\.ext' 'https://github.com/SpecialKO/SpecialK/raw/refs/heads/main/src/config.cpp'
}

$content = Get-Content -Path '.\.ext\config.cpp'
