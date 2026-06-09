# CHECKPOINTS — Evaluación del estado final

> En sistemas multi-agente no se evalúa el camino, se evalúa el destino.
> Estos son los checkpoints objetivos que un juez (humano o IA) puede usar
> para decidir si el proyecto está sano.

<!-- HARNESS:REQUIRED — no modificar: los agentes dependen de esta sección -->

## C1 — El arnés está completo

- [ ] Existen los archivos base: `AGENTS.md`, `init.sh`, `feature_list.json`,
      `harness.json`, `progress/current.md`.
- [ ] Existen los 4 docs: `docs/architecture.md`, `docs/conventions.md`,
      `docs/specs.md`, `docs/verification.md`.
- [ ] `./init.sh` termina con exit code 0.
- [ ] Si el proyecto es brownfield: existe `progress/explorer_brownfield.md`
      y `feature_list.json` tiene al menos una feature `done`.

## C2 — El estado es coherente

- [ ] Como mucho una feature en `in_progress` en `feature_list.json`.
- [ ] Toda feature `done` tiene tests asociados que pasan.
- [ ] `progress/current.md` está vacío o describe la sesión activa
      (no contiene basura de sesiones anteriores).

## C3 — El código respeta la arquitectura

- [ ] No hay código de debug suelto (p. ej. prints de depuración), ni TODOs
      sin contexto.

<!-- /HARNESS:REQUIRED -->

<!-- HARNESS:FILL — el agente rellena esto durante el onboarding leyendo harness.json. Reemplaza este bloque por dos items concretos usando `src_dir` de harness.json:
- [ ] `<src_dir>/` solo contiene los módulos previstos en `docs/architecture.md`.
- [ ] No hay dependencias no declaradas en `feature_list.json`.
Donde `<src_dir>` es el valor de `stack.src_dir` en harness.json. -->

<!-- /HARNESS:FILL -->

<!-- HARNESS:REQUIRED — no modificar: los agentes dependen de esta sección -->

## C4 — La verificación es real

- [ ] Cada módulo del código fuente tiene al menos un test que cubre el camino
      feliz y al menos un camino de error.

<!-- /HARNESS:REQUIRED -->

<!-- HARNESS:FILL — el agente rellena esto durante el onboarding leyendo harness.json. Reemplaza este bloque por dos items concretos usando `test_dir`, `src_dir` y `test_cmd` de harness.json:
- [ ] `<test_dir>/` tiene al menos un test por módulo de `<src_dir>/`.
- [ ] `<test_cmd>` muestra > 0 tests y todos verdes.
Donde `<test_dir>` es `stack.test_dir`, `<src_dir>` es `stack.src_dir` y `<test_cmd>` es `stack.test_cmd` en harness.json. -->

<!-- /HARNESS:FILL -->

<!-- HARNESS:REQUIRED — no modificar: los agentes dependen de esta sección -->

## C5 — La sesión se cerró bien

- [ ] No hay archivos sin trackear sospechosos (`*.tmp`, `__pycache__`
      fuera del `.gitignore`).
- [ ] `progress/history.md` tiene una entrada por la última sesión.
- [ ] La última feature trabajada está reflejada en su estado correcto.

## C6 — Spec Driven Development

- [ ] Toda feature con `"sdd": true` en estado `spec_ready`, `in_progress`
      o `done` tiene su carpeta `specs/<name>/` con los 3 archivos:
      `requirements.md`, `design.md`, `tasks.md`.
- [ ] `requirements.md` usa EARS estricto (ver `docs/specs.md`).
- [ ] Toda feature `done` con `"sdd": true` tiene todas sus tasks marcadas
      `[x]` en `tasks.md`.
- [ ] Cada `R<n>` de `requirements.md` está cubierto por al menos un test
      concreto en `<test_dir>/` (valor de `stack.test_dir` en `harness.json`,
      rellenado por el agente durante el onboarding).

<!-- /HARNESS:REQUIRED -->

---

**Cómo usar este archivo:** un agente revisor (`.claude/agents/reviewer.md`)
recorre cada checkbox, marca `[x]` o `[ ]`, y rechaza el cierre de sesión
si quedan boxes vacíos en C1-C6.
