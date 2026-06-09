#!/usr/bin/env bash
# init.sh — Verificación e inicialización del entorno
#
# Este script lo ejecuta el agente al COMENZAR una sesión y antes de
# declarar cualquier tarea como `done`. Si falla, la sesión no debe avanzar.
#
# Salida esperada: códigos de salida claros y bloques marcados con [OK]/[FAIL].

set -u
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

ok()    { printf "${GREEN}[OK]${NC}    %s\n" "$1"; }
warn()  { printf "${YELLOW}[WARN]${NC}  %s\n" "$1"; }
fail()  { printf "${RED}[FAIL]${NC}  %s\n" "$1"; }

EXIT_CODE=0

echo "── 1. Verificando entorno ─────────────────────────────"

# harness.json es obligatorio
if [ ! -f "harness.json" ]; then
  fail "Falta harness.json — el agente debe generarlo (protocolo de onboarding de CLAUDE.md) antes de ejecutar init.sh"
  exit 1
fi
ok "Existe harness.json"

# Leer configuración del stack con python3
# (python3 es la única dependencia de runtime que el harness puede asumir:
#  el bloque 3 también lo requiere para validar feature_list.json)
STACK_LANGUAGE=$(python3 -c "import json; d=json.load(open('harness.json')); print(d['stack']['language'])")
HAS_VERSION_CHECK=$(python3 -c "import json; d=json.load(open('harness.json')); print('yes' if 'version_check' in d['stack'] else 'no')")

if [ "$HAS_VERSION_CHECK" = "yes" ]; then
  VERSION_CMD=$(python3 -c "import json; d=json.load(open('harness.json')); print(d['stack']['version_check']['command'])")
  MIN_VERSION=$(python3 -c "import json; d=json.load(open('harness.json')); print(d['stack']['version_check']['min_version'])")
  PARSE_MODE=$(python3 -c "import json; d=json.load(open('harness.json')); print(d['stack']['version_check']['parse'])")

  # Obtener versión actual
  VERSION_OUTPUT=$(bash -c "$VERSION_CMD" 2>&1)
  VERSION_OK=$(python3 - <<PY
import sys, re
output = """$VERSION_OUTPUT"""
parse = "$PARSE_MODE"
min_ver = "$MIN_VERSION"

def strip_prefix(s):
    return re.sub(r'^[^0-9]*', '', s)

if parse == "semver_second_word":
    parts = output.strip().split()
    raw = parts[1] if len(parts) > 1 else ""
elif parse == "semver_first_word":
    raw = output.strip().split()[0] if output.strip() else ""
elif parse == "semver_regex":
    # Extrae el primer token con forma de versión de toda la salida.
    # Robusto frente a salidas como "go version go1.21.5 linux/amd64",
    # donde el número no cae en una posición de palabra fija.
    m = re.search(r"\d+\.\d+(?:\.\d+)?", output)
    raw = m.group(0) if m else ""
else:
    raw = ""

version = strip_prefix(raw)
try:
    actual = tuple(int(x) for x in version.split(".")[:3])
    minimum = tuple(int(x) for x in min_ver.split(".")[:3])
    print("ok" if actual >= minimum else f"fail:{version}")
except:
    print("fail:unparseable")
PY
)

  if [ "$VERSION_OK" = "ok" ]; then
    ok "$STACK_LANGUAGE -> $VERSION_OUTPUT (>= $MIN_VERSION requerido)"
  else
    FOUND_VERSION=$(echo "$VERSION_OK" | cut -d: -f2)
    fail "$STACK_LANGUAGE versión $FOUND_VERSION encontrada, se requiere >= $MIN_VERSION"
    exit 1
  fi
else
  ok "Stack: $STACK_LANGUAGE (sin verificación de versión configurada)"
fi

echo ""
echo "── 2. Verificando archivos base del arnés ──────────────"

for f in AGENTS.md feature_list.json harness.json progress/current.md docs/architecture.md docs/conventions.md docs/specs.md docs/verification.md CHECKPOINTS.md; do
  if [ ! -f "$f" ]; then
    fail "Falta archivo base: $f"
    EXIT_CODE=1
  else
    ok "Existe $f"
  fi
done

echo ""
echo "── 3. Validando feature_list.json y specs ─────────────"

python3 - <<'PY'
import json, os, sys
try:
    data = json.load(open("feature_list.json"))
    valid = {"pending", "spec_ready", "in_progress", "done", "blocked"}
    in_progress = [f for f in data["features"] if f["status"] == "in_progress"]
    if len(in_progress) > 1:
        print(f"[FAIL]  Hay {len(in_progress)} features en in_progress (máximo 1)")
        sys.exit(1)
    requires_spec = {"spec_ready", "in_progress", "done"}
    spec_errors = []
    for f in data["features"]:
        if f["status"] not in valid:
            print(f"[FAIL]  Estado inválido en feature {f['id']}: {f['status']}")
            sys.exit(1)
        if f.get("sdd") and f["status"] in requires_spec:
            spec_dir = os.path.join("specs", f["name"])
            for fname in ("requirements.md", "design.md", "tasks.md"):
                if not os.path.isfile(os.path.join(spec_dir, fname)):
                    spec_errors.append(
                        f"feature {f['id']} ({f['name']}) en {f['status']} "
                        f"sin {spec_dir}/{fname}"
                    )
    if spec_errors:
        for e in spec_errors:
            print(f"[FAIL]  {e}")
        sys.exit(1)
    print(f"[OK]    feature_list.json válido ({len(data['features'])} features)")
    print(f"[OK]    Specs presentes para features sdd con estado no-pending")
except SystemExit:
    raise
except Exception as e:
    print(f"[FAIL]  feature_list.json o specs inválidos: {e}")
    sys.exit(1)
PY

if [ $? -ne 0 ]; then EXIT_CODE=1; fi

echo ""
echo "── 4. Ejecutando tests ─────────────────────────────────"

TEST_DIR=$(python3 -c "import json; d=json.load(open('harness.json')); print(d['stack']['test_dir'])")
TEST_CMD=$(python3 -c "import json; d=json.load(open('harness.json')); print(d['stack']['test_cmd'])")

if [ ! -d "$TEST_DIR" ]; then
  warn "Carpeta $TEST_DIR/ no existe todavía"
elif [ -z "$(find "$TEST_DIR" -type f ! -name '.*' 2>/dev/null | head -1)" ]; then
  # Greenfield recién inicializado: el directorio de tests existe pero está
  # vacío. No es un fallo — todavía no hay nada que ejecutar. (pytest, por
  # ejemplo, saldría con código 5 "no tests collected" y lo marcaría en rojo.)
  warn "Carpeta $TEST_DIR/ existe pero no contiene tests todavía"
elif bash -c "$TEST_CMD" 2>&1; then
  ok "Todos los tests pasan"
else
  fail "Hay tests rotos"
  EXIT_CODE=1
fi

echo ""
echo "── 5. Resumen ──────────────────────────────────────────"

if [ $EXIT_CODE -eq 0 ]; then
  ok "Entorno listo. Puedes empezar a trabajar."
else
  fail "Entorno NO está listo. Resuelve los errores antes de avanzar."
fi

exit $EXIT_CODE
