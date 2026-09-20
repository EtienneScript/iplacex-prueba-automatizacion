#!/usr/bin/env sh
set -eu

raiz="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
base="$raiz/ambiente-prueba"

jar="$(find "$raiz/target" -maxdepth 1 -name '*.jar' ! -name 'original-*' | head -n 1)"
if [ -z "$jar" ]; then
  echo "No hay JAR en target/. Ejecuta primero: ./mvnw package -DskipUnitTests=true -DskipITs=true -DskipATs=true" >&2
  exit 1
fi

leer() {
  if [ -f "$1" ]; then
    tr -d '\r' < "$1" | tr -d '\n'
  fi
}

mkdir -p "$base"

activo="$(leer "$base/ACTIVO.txt")"
case "$activo" in
  blue|green) ;;
  *) activo="" ;;
esac

if [ "$activo" = "blue" ]; then
  slot="green"
elif [ "$activo" = "green" ]; then
  slot="blue"
else
  slot="blue"
fi

slot_dir="$base/$slot"
rm -rf "$slot_dir"
mkdir -p "$slot_dir"
cp -f "$jar" "$slot_dir/"

commit="$(git -C "$raiz" rev-parse --short HEAD 2>/dev/null || echo desconocido)"
fecha="$(date -Iseconds)"

cat > "$slot_dir/RELEASE.txt" <<EOF
ambiente=prueba
slot=$slot
artefacto=$(basename "$jar")
version=1.0.0-SNAPSHOT
commit=$commit
fecha=$fecha
estado=listo
estrategia=blue-green
EOF

if [ -n "$activo" ]; then
  cat > "$base/TRAFICO.txt" <<EOF
estrategia=canary
estable=$activo
canary=$slot
porcentaje_estable=90
porcentaje_canary=10
EOF
  echo "Canary: 10% en $slot, 90% sigue en $activo"
  echo "$fecha CANARY slot=$slot commit=$commit" >> "$base/HISTORIAL.txt"
  printf '%s' "$activo" > "$base/ANTERIOR.txt"
else
  : > "$base/ANTERIOR.txt"
fi

printf '%s' "$slot" > "$base/ACTIVO.txt"

anterior_txt="ninguno"
if [ -n "$activo" ]; then
  anterior_txt="$activo"
fi

cat > "$base/TRAFICO.txt" <<EOF
estrategia=blue-green
activo=$slot
anterior=$anterior_txt
porcentaje_activo=100
porcentaje_canary=0
EOF

echo "$fecha PROMOVER slot=$slot commit=$commit" >> "$base/HISTORIAL.txt"
echo "Blue-Green: trafico 100% en $slot (ambiente de prueba)"
cat "$base/TRAFICO.txt"
