$ErrorActionPreference = "Stop"

$raiz = Split-Path -Parent $PSScriptRoot
$base = Join-Path $raiz "ambiente-prueba"
$jar = Get-ChildItem -Path (Join-Path $raiz "target") -Filter "*.jar" |
    Where-Object { $_.Name -notlike "original-*" } |
    Select-Object -First 1

if (-not $jar) {
    throw "No hay JAR en target/. Ejecuta primero: .\mvnw.cmd package -DskipUnitTests=true -DskipITs=true -DskipATs=true"
}

function Leer-Valor([string]$ruta) {
    if (Test-Path $ruta) {
        return (Get-Content -Path $ruta -Raw).Trim()
    }
    return ""
}

function Escribir-Lineas([string]$ruta, [string]$contenido) {
    Set-Content -Encoding utf8 -Path $ruta -Value $contenido
}

New-Item -ItemType Directory -Force -Path $base | Out-Null

$activoRuta = Join-Path $base "ACTIVO.txt"
$anteriorRuta = Join-Path $base "ANTERIOR.txt"
$traficoRuta = Join-Path $base "TRAFICO.txt"
$historialRuta = Join-Path $base "HISTORIAL.txt"

$activo = Leer-Valor $activoRuta
if ($activo -ne "blue" -and $activo -ne "green") {
    $activo = ""
}

$slot = if ($activo -eq "blue") { "green" } elseif ($activo -eq "green") { "blue" } else { "blue" }
$slotDir = Join-Path $base $slot
New-Item -ItemType Directory -Force -Path $slotDir | Out-Null
Get-ChildItem $slotDir | Remove-Item -Force -Recurse
Copy-Item -Force $jar.FullName (Join-Path $slotDir $jar.Name)

$commit = "desconocido"
try {
    $commit = (git -C $raiz rev-parse --short HEAD 2>$null)
    if (-not $commit) { $commit = "desconocido" }
} catch {
    $commit = "desconocido"
}

$fecha = Get-Date -Format "yyyy-MM-ddTHH:mm:ssK"
Escribir-Lineas (Join-Path $slotDir "RELEASE.txt") @"
ambiente=prueba
slot=$slot
artefacto=$($jar.Name)
version=1.0.0-SNAPSHOT
commit=$commit
fecha=$fecha
estado=listo
estrategia=blue-green
"@

if ($activo) {
    Escribir-Lineas $traficoRuta @"
estrategia=canary
estable=$activo
canary=$slot
porcentaje_estable=90
porcentaje_canary=10
"@
    Write-Host "Canary: 10% en $slot, 90% sigue en $activo"
    Add-Content -Encoding utf8 -Path $historialRuta -Value "$fecha CANARY slot=$slot commit=$commit"
}

Escribir-Lineas $anteriorRuta $(if ($activo) { $activo } else { "" })
Escribir-Lineas $activoRuta $slot
Escribir-Lineas $traficoRuta @"
estrategia=blue-green
activo=$slot
anterior=$(if ($activo) { $activo } else { "ninguno" })
porcentaje_activo=100
porcentaje_canary=0
"@
Add-Content -Encoding utf8 -Path $historialRuta -Value "$fecha PROMOVER slot=$slot commit=$commit"

Write-Host "Blue-Green: trafico 100% en $slot (ambiente de prueba)"
Get-Content $traficoRuta
