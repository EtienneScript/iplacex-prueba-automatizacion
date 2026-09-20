$ErrorActionPreference = "Stop"

$raiz = Split-Path -Parent $PSScriptRoot
$base = Join-Path $raiz "ambiente-prueba"
$activoRuta = Join-Path $base "ACTIVO.txt"
$anteriorRuta = Join-Path $base "ANTERIOR.txt"
$traficoRuta = Join-Path $base "TRAFICO.txt"
$historialRuta = Join-Path $base "HISTORIAL.txt"

function Leer-Valor([string]$ruta) {
    if (Test-Path $ruta) {
        return (Get-Content -Path $ruta -Raw).Trim()
    }
    return ""
}

$activo = Leer-Valor $activoRuta
$anterior = Leer-Valor $anteriorRuta

if ($anterior -ne "blue" -and $anterior -ne "green") {
    throw "No hay slot anterior. El rollback requiere al menos un despliegue Blue-Green previo."
}

$slotAnterior = Join-Path $base $anterior
if (-not (Test-Path (Join-Path $slotAnterior "RELEASE.txt"))) {
    throw "El slot $anterior no tiene una release para restaurar."
}

Set-Content -Encoding utf8 -Path $activoRuta -Value $anterior
Set-Content -Encoding utf8 -Path $anteriorRuta -Value $activo
Set-Content -Encoding utf8 -Path $traficoRuta -Value @"
estrategia=rollback
activo=$anterior
revertido_desde=$activo
porcentaje_activo=100
porcentaje_canary=0
"@

$fecha = Get-Date -Format "yyyy-MM-ddTHH:mm:ssK"
Add-Content -Encoding utf8 -Path $historialRuta -Value "$fecha ROLLBACK activo=$anterior desde=$activo"

Write-Host "Rollback Blue-Green: trafico 100% de vuelta en $anterior"
Get-Content $traficoRuta
Get-Content (Join-Path $slotAnterior "RELEASE.txt")
