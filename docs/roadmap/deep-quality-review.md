# Roadmap: Profundidad de la revisión de calidad (juicio + huecos seguridad/rendimiento)

> Estado: **anotada, sin definir del todo.** Captura los huecos detectados el
> 2026-07-01; **falta una pasada de definición** (decisiones con AskUserQuestion)
> antes de implementar. Extiende [ci-quality-gate](ci-quality-gate.md): añade
> tools al catálogo de `checks` **y** convierte parte de la calidad en *juicio*
> del `reviewer`, no solo enforcement mecánico. Debe ir **después** de
> ci-quality-gate.

## Contexto: qué cubre hoy el flujo SDD (tres capas)

1. **Tests — instruido explícitamente.** Unitarios (feliz + error), integración
   (interfaces, recurso real no mocks), smoke e2e, trazabilidad `R<n>→test`.
   Nativo y fuerte (`docs/verification.md`, implementer, reviewer, CHECKPOINTS).
2. **Convenciones/arquitectura — juicio del reviewer, pero project-specific.** El
   reviewer rechaza contra `docs/conventions.md` (estilo, linter, nombres,
   errores) y `docs/architecture.md`. El contenido lo rellena el humano/explorer.
3. **Calidad automática — mecánica.** El gate de `checks` en `init.sh`
   (ci-quality-gate) corre lint/format/typecheck/deadcode/complejidad/seguridad.
   No es juicio: `init.sh` se pone rojo si el tool detecta algo.

## Huecos detectados (lo que motiva esta feature)

- **Seguridad = solo escaneo de dependencias** (pip-audit/npm audit). Falta:
  secretos hardcodeados, SAST (inyección, patrones inseguros), y **el reviewer no
  está instruido para razonar sobre seguridad** (authz, inyección).
- **Optimización / rendimiento: no lo cubre nadie.** Ni tool ni instrucción de
  agente. Hueco total.
- **Código muerto y complejidad son mecánicos-only.** Los tumba el tool, pero el
  reviewer no ejerce *juicio* sobre ellos.

## Dos direcciones (probablemente ambas)

**(a) Ampliar el catálogo de `checks`** (enforcement mecánico):
- Escaneo de secretos: `gitleaks` (multi-lenguaje) sobre el árbol.
- SAST ligero: `bandit` (Python), `semgrep` (multi-lenguaje con rulesets).
- Se añaden como checks nuevos (`secrets`, `sast`) al catálogo por lenguaje de
  `harness.example.json`; `init.sh` ya los corre.

**(b) Rúbrica de revisión explícita en `reviewer.md`** (juicio, no tool):
- Añadir dimensiones que el reviewer DEBE considerar y citar (fichero:línea):
  seguridad (inyección, authz, secretos, manejo de input no confiable) y
  rendimiento (algoritmos O(n²) evitables, I/O en bucles, queries N+1).
- Posiblemente también que `spec_author` anote consideraciones de seguridad/
  rendimiento en `design.md` cuando la feature las tenga.

## Decisiones abiertas (para la pasada de definición)

- **Tooling de seguridad:** ¿gitleaks + semgrep (multi-lenguaje) o bandit
  (Python-only) según stack? ¿Ambos? ¿severidad block o warn?
- **Rendimiento:** difícil de automatizar (contextual). ¿Solo rúbrica del
  reviewer, o también un harness de benchmarks (pesado → fase 2+)?
- **Rúbrica del reviewer:** ¿checklist prescriptivo o juicio abierto? Riesgo de
  ruido / falsos positivos si es demasiado estricto.
- **Dónde encaja:** ¿solo `reviewer`, o también `spec_author` (notas en design)?
- **Alcance:** proyectos generados (como el resto de features de esta línea).

## Relación / orden

- Depende de **ci-quality-gate** (extiende su catálogo de `checks` y su
  `docs/verification.md` Nivel 5, y toca `reviewer.md`).
- Encaja como fase 3 de la línea de calidad; no arrancar hasta que
  ci-quality-gate esté mergeado.
