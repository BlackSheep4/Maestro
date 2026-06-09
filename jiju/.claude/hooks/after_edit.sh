#!/usr/bin/env bash
# Hook PostToolUse(Edit|Write).
#
# Corre la suite de tests SOLO cuando se ha tocado código de `src/` o `tests/`,
# y solo si `harness.json` ya existe. En cualquier otro caso (editar docs,
# progress/, specs/, o estar todavía en onboarding) sale en silencio: ejecutar
# toda la suite en cada escritura de markdown es ruidoso e inútil.
set -u

payload=$(cat)

# Durante el onboarding harness.json aún no existe: nada que verificar.
[ -f harness.json ] || exit 0

# El payload del hook trae la ruta del archivo editado en tool_input.file_path.
path=$(printf '%s' "$payload" | python3 -c \
  "import sys, json; print((json.load(sys.stdin).get('tool_input') or {}).get('file_path', ''))" \
  2>/dev/null) || exit 0

case "$path" in
  */src/*|*/tests/*|src/*|tests/*) ;;
  *) exit 0 ;;
esac

cmd=$(python3 -c "import json; print(json.load(open('harness.json'))['stack']['test_cmd'])" 2>/dev/null) || exit 0
bash -c "$cmd" 2>&1 | tail -3
