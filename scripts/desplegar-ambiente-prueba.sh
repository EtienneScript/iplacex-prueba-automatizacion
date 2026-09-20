#!/usr/bin/env sh
set -eu

raiz="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
destino="$raiz/ambiente-prueba"

jar="$(find "$raiz/target" -maxdepth 1 -name '*.jar' ! -name 'original-*' | head -n 1)"
if [ -z "$jar" ]; then
  echo "No hay JAR en target/. Ejecuta primero: ./mvnw package -DskipUnitTests=true -DskipITs=true -DskipATs=true" >&2
  exit 1
fi

mkdir -p "$destino"
cp -f "$jar" "$destino/"

commit="$(git -C "$raiz" rev-parse --short HEAD 2>/dev/null || echo desconocido)"

cat > "$destino/RELEASE.txt" <<EOF
ambiente=prueba
artefacto=$(basename "$jar")
version=1.0.0-SNAPSHOT
commit=$commit
fecha=$(date -Iseconds)
estado=desplegado
EOF

echo "Desplegado en ambiente de prueba: $destino"
cat "$destino/RELEASE.txt"
