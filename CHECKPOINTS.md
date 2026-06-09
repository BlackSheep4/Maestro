# CHECKPOINTS — Evaluación del estado final

> En sistemas multi-agente no se evalúa el camino, se evalúa el destino.
> Estos son los checkpoints objetivos que un juez (humano o IA) puede usar
> para decidir si el proyecto está sano.

## C1 — El arnés está completo

- [ ] Existen los 4 archivos base: `AGENTS.md`, `init.sh`, `feature_list.json`,
      `progress/current.md`.
- [ ] Existen los 3 docs: `docs/architecture.md`, `docs/conventions.md`,
      `docs/verification.md`.
- [ ] `./init.sh` termina con exit code 0.

## C2 — El estado es coherente

- [ ] Como mucho una feature en `in_progress` en `feature_list.json`.
- [ ] Toda feature `done` tiene tests asociados que pasan.
- [ ] `progress/current.md` está vacío o describe la sesión activa
      (no contiene basura de sesiones anteriores).

## C3 — El código respeta la arquitectura

- [ ] `src/` solo contiene los módulos previstos en `docs/architecture.md`.
- [ ] No hay dependencias externas en `requirements.txt` (debe estar vacío
      o no existir).
- [ ] No hay `print()` sueltos para debug, ni TODOs sin contexto.

## C4 — La verificación es real

- [ ] `tests/` tiene al menos un test por módulo de `src/`.
- [ ] Los tests usan `tempfile.TemporaryDirectory()`, no mocks de fs.
- [ ] `python3 -m unittest discover -s tests -v` muestra > 0 tests
      y todos verdes.

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
      concreto en `tests/`.

---

**Cómo usar este archivo:** un agente revisor (`.claude/agents/reviewer.md`)
recorre cada checkbox, marca `[x]` o `[ ]`, y rechaza el cierre de sesión
si quedan boxes vacíos en C1-C6.
