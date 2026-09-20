#!/usr/bin/env sh
set -eu

raiz="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
base="$raiz/ambiente-prueba"

leer() {
  if [ -f "$1" ]; then
    tr -d '\r' < "$1" | tr -d '\n'
  fi
}

activo="$(leer "$base/ACTIVO.txt")"
anterior="$(leer "$base/ANTERIOR.txt")"

if [ "$anterior" != "blue" ] && [ "$anterior" != "green" ]; then
  echo "No hay slot anterior. El rollback requiere al menos un despliegue Blue-Green previo." >&2
  exit 1
fi

if [ ! -f "$base/$anterior/RELEASE.txt" ]; then
  echo "El slot $anterior no tiene una release para restaurar." >&2
  exit 1
fi

printf '%s' "$anterior" > "$base/ACTIVO.txt"
printf '%s' "$activo" > "$base/ANTERIOR.txt"

cat > "$base/TRAFICO.txt" <<EOF
estrategia=rollback
activo=$anterior
revertido_desde=$activo
porcentaje_activo=100
porcentaje_canary=0
EOF

fecha="$(date -Iseconds)"
echo "$fecha ROLLBACK activo=$anterior desde=$activo" >> "$base/HISTORIAL.txt"

echo "Rollback Blue-Green: trafico 100% de vuelta en $anterior"
cat "$base/TRAFICO.txt"
cat "$base/$anterior/RELEASE.txt"
