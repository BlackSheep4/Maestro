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

# ── Parser JSON ────────────────────────────────────────────
# El arnés es políglota y NO asume un runtime concreto: lee su configuración
# JSON con `jq` (preferido) o, si no está, con `python3`. Funciona con
# CUALQUIERA de los dos, así no obliga a tener Python en stacks Node/Go/Rust
# ni jq en cajas solo-Python. (awk, usado para comparar versiones, es ubicuo.)
if command -v jq >/dev/null 2>&1; then
  JSON_TOOL="jq"
elif command -v python3 >/dev/null 2>&1; then
  JSON_TOOL="python3"
else
  fail "Necesito 'jq' o 'python3' para leer la configuración JSON del arnés. Instala uno de los dos."
  exit 1
fi

# jget <file> <jq_filter> <python_expr>
# Extrae un escalar de un JSON. El filtro jq y la expresión python conviven en
# el call-site para no mantener un traductor de rutas. Clave ausente → "".
jget() {
  if [ "$JSON_TOOL" = "jq" ]; then
    jq -r "$2" "$1"
  else
    python3 -c "import json
d=json.load(open('$1'))
v=$3
print('' if v is None else v)"
  fi
}

# version_ge <actual> <min> → exit 0 si actual >= min (compara semver con awk).
version_ge() {
  [ -n "$1" ] || return 1
  awk -v a="$1" -v b="$2" 'BEGIN{
    na=split(a,x,"."); nb=split(b,y,".");
    for(i=1;i<=3;i++){ xi=(i<=na?x[i]+0:0); yi=(i<=nb?y[i]+0:0);
      if(xi>yi){exit 0} if(xi<yi){exit 1} }
    exit 0 }'
}

# extract_version <parse_mode> <raw_output> → imprime la versión limpia o "".
extract_version() {
  local mode="$1" out="$2" raw=""
  case "$mode" in
    semver_first_word)  raw=$(printf '%s' "$out" | awk 'NR==1{print $1}') ;;
    semver_second_word) raw=$(printf '%s' "$out" | awk 'NR==1{print $2}') ;;
    semver_regex)       printf '%s' "$out" | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n1; return ;;
    *) raw="" ;;
  esac
  printf '%s' "$raw" | sed -E 's/^[^0-9]*//'
}

echo "── 1. Verificando entorno ─────────────────────────────"

# harness.json es obligatorio
if [ ! -f "harness.json" ]; then
  fail "Falta harness.json — el agente debe generarlo (protocolo de onboarding de CLAUDE.md) antes de ejecutar init.sh"
  exit 1
fi
ok "Existe harness.json"

STACK_LANGUAGE=$(jget harness.json '.stack.language' "d['stack']['language']")
HAS_VERSION_CHECK=$(jget harness.json \
  'if .stack | has("version_check") then "yes" else "no" end' \
  "'yes' if 'version_check' in d['stack'] else 'no'")

if [ "$HAS_VERSION_CHECK" = "yes" ]; then
  VERSION_CMD=$(jget harness.json '.stack.version_check.command' "d['stack']['version_check']['command']")
  MIN_VERSION=$(jget harness.json '.stack.version_check.min_version' "d['stack']['version_check']['min_version']")
  PARSE_MODE=$(jget harness.json '.stack.version_check.parse' "d['stack']['version_check']['parse']")

  VERSION_OUTPUT=$(bash -c "$VERSION_CMD" 2>&1)
  FOUND_VERSION=$(extract_version "$PARSE_MODE" "$VERSION_OUTPUT")

  if version_ge "$FOUND_VERSION" "$MIN_VERSION"; then
    ok "$STACK_LANGUAGE -> $VERSION_OUTPUT (>= $MIN_VERSION requerido)"
  else
    fail "$STACK_LANGUAGE versión ${FOUND_VERSION:-no detectada} encontrada, se requiere >= $MIN_VERSION"
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

# Fuente única de verdad: las reglas las declara el propio feature_list.json en
# su bloque `rules`. init.sh las RESPETA en lugar de hardcodearlas. Fallback a
# los valores canónicos si falta el bloque (o si el JSON es inválido).
VALID_CSV=$(jget feature_list.json \
  '(.rules.valid_status // ["pending","spec_ready","in_progress","done","blocked"]) | join(",")' \
  "','.join(d.get('rules',{}).get('valid_status') or ['pending','spec_ready','in_progress','done','blocked'])" \
  2>/dev/null)
VALID_CSV=${VALID_CSV:-pending,spec_ready,in_progress,done,blocked}
# Nota jq: `//` trata `false` como vacío (igual que null), así que
# `(.x // true)` devolvería true cuando .x es false. Para flags booleanos hay
# que comprobar null explícitamente.
ONE_AT_A_TIME=$(jget feature_list.json '(.rules.one_feature_at_a_time | if . == null then true else . end | tostring)' \
  "str(d.get('rules',{}).get('one_feature_at_a_time', True)).lower()" 2>/dev/null)
ONE_AT_A_TIME=${ONE_AT_A_TIME:-true}
REQUIRE_SPEC=$(jget feature_list.json '(.rules.require_approved_spec_to_implement | if . == null then true else . end | tostring)' \
  "str(d.get('rules',{}).get('require_approved_spec_to_implement', True)).lower()" 2>/dev/null)
REQUIRE_SPEC=${REQUIRE_SPEC:-true}
REQUIRE_TESTS=$(jget feature_list.json '(.rules.require_tests_to_close | if . == null then true else . end | tostring)' \
  "str(d.get('rules',{}).get('require_tests_to_close', True)).lower()" 2>/dev/null)
REQUIRE_TESTS=${REQUIRE_TESTS:-true}

feat_lines() {
  if [ "$JSON_TOOL" = "jq" ]; then
    jq -r '.features[] | [(.id|tostring), .status, .name, ((.sdd // false)|tostring)] | @tsv' feature_list.json
  else
    python3 -c "import json
for f in json.load(open('feature_list.json'))['features']:
    print('\t'.join([str(f['id']), f['status'], f['name'], str(bool(f.get('sdd'))).lower()]))"
  fi
}

FEAT_COUNT=$(jget feature_list.json '.features | length' "len(d['features'])" 2>/dev/null)
if ! printf '%s' "$FEAT_COUNT" | grep -qE '^[0-9]+$'; then
  fail "feature_list.json inválido (no es JSON válido o no tiene 'features')"
  EXIT_CODE=1
else
  invalid_found=0
  in_progress_count=0
  spec_missing=0
  while IFS=$(printf '\t') read -r id status name sdd; do
    [ -n "${status:-}" ] || continue
    case ",$VALID_CSV," in
      *",$status,"*) ;;
      *) fail "Estado inválido en feature $id: $status"; invalid_found=1 ;;
    esac
    [ "$status" = "in_progress" ] && in_progress_count=$((in_progress_count + 1))
    if [ "$REQUIRE_SPEC" = "true" ] && [ "$sdd" = "true" ]; then
      case "$status" in
        spec_ready|in_progress|done)
          for fname in requirements.md design.md tasks.md; do
            if [ ! -f "specs/$name/$fname" ]; then
              fail "feature $id ($name) en $status sin specs/$name/$fname"
              spec_missing=1
            fi
          done ;;
      esac
    fi
  done <<EOF
$(feat_lines)
EOF

  if [ "$invalid_found" -ne 0 ]; then
    EXIT_CODE=1
  elif [ "$ONE_AT_A_TIME" = "true" ] && [ "$in_progress_count" -gt 1 ]; then
    fail "Hay $in_progress_count features en in_progress (rules.one_feature_at_a_time exige máximo 1)"
    EXIT_CODE=1
  elif [ "$spec_missing" -ne 0 ]; then
    EXIT_CODE=1
  else
    ok "feature_list.json válido ($FEAT_COUNT features)"
    ok "Specs presentes para features sdd con estado no-pending"
  fi
fi

echo ""
echo "── 4. Ejecutando tests ─────────────────────────────────"

TEST_DIR=$(jget harness.json '.stack.test_dir' "d['stack']['test_dir']")
TEST_CMD=$(jget harness.json '.stack.test_cmd' "d['stack']['test_cmd']")

if [ ! -d "$TEST_DIR" ]; then
  warn "Carpeta $TEST_DIR/ no existe todavía"
elif [ -z "$(find "$TEST_DIR" -type f ! -name '.*' ! -name '__init__.py' ! -name 'conftest.py' 2>/dev/null | head -1)" ]; then
  # Greenfield recién inicializado: el directorio de tests existe pero solo
  # contiene scaffolding (o nada). No es un fallo — todavía no hay tests que
  # ejecutar. (pytest saldría con código 5 "no tests collected" y lo marcaría
  # en rojo aunque no haya nada roto.)
  warn "Carpeta $TEST_DIR/ existe pero no contiene tests todavía"
elif bash -c "$TEST_CMD" 2>&1; then
  ok "Todos los tests pasan"
elif [ "$REQUIRE_TESTS" = "true" ]; then
  fail "Hay tests rotos"
  EXIT_CODE=1
else
  warn "Hay tests rotos, pero rules.require_tests_to_close=false: no bloquea el cierre"
fi

echo ""
echo "── 5. Resumen ──────────────────────────────────────────"

if [ $EXIT_CODE -eq 0 ]; then
  ok "Entorno listo. Puedes empezar a trabajar."
else
  fail "Entorno NO está listo. Resuelve los errores antes de avanzar."
fi

exit $EXIT_CODE
