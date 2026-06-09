#!/usr/bin/env bash
# Hook Stop.
#
# Fuerza una verificación completa antes de cerrar la sesión. Durante el
# onboarding (harness.json todavía no existe) no hay entorno que verificar:
# salir limpio en lugar de imprimir un falso "[harness] init.sh FALLÓ" cada vez
# que el agente se detiene a hacer las preguntas de stack.
set -u

if [ ! -f harness.json ]; then
  echo "[harness] onboarding en curso (sin harness.json todavía) — verificación omitida"
  exit 0
fi

if ./init.sh > /tmp/harness_init.log 2>&1; then
  echo "[harness] init.sh OK"
else
  echo "[harness] init.sh FALLÓ — revisa /tmp/harness_init.log antes de cerrar"
  tail -20 /tmp/harness_init.log
fi
