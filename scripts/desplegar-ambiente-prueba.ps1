$ErrorActionPreference = "Stop"

$raiz = Split-Path -Parent $PSScriptRoot
$destino = Join-Path $raiz "ambiente-prueba"
$jar = Get-ChildItem -Path (Join-Path $raiz "target") -Filter "*.jar" |
    Where-Object { $_.Name -notlike "original-*" } |
    Select-Object -First 1

if (-not $jar) {
    throw "No hay JAR en target/. Ejecuta primero: .\mvnw.cmd package -DskipUnitTests=true -DskipITs=true -DskipATs=true"
}

New-Item -ItemType Directory -Force -Path $destino | Out-Null
Copy-Item -Force $jar.FullName (Join-Path $destino $jar.Name)

$commit = ""
try {
    $commit = (git -C $raiz rev-parse --short HEAD 2>$null)
} catch {
    $commit = "desconocido"
}

@"
ambiente=prueba
artefacto=$($jar.Name)
version=1.0.0-SNAPSHOT
commit=$commit
fecha=$(Get-Date -Format "yyyy-MM-ddTHH:mm:ssK")
estado=desplegado
"@ | Set-Content -Encoding utf8 (Join-Path $destino "RELEASE.txt")

Write-Host "Desplegado en ambiente de prueba: $destino"
Get-Content (Join-Path $destino "RELEASE.txt")
