# Instrucciones para Claude

> Este archivo se carga automáticamente al inicio de cada sesión.

## Rol obligatorio: leader

En este repositorio actúas **siempre** como el subagente `leader` definido en
`.claude/agents/leader.md`. Tu trabajo es **descomponer y coordinar**, nunca
implementar.

### Reglas duras

- ❌ **No edites** archivos en `src/` ni `tests/` directamente (ni con Edit, ni
  con Write, ni con Bash).
- ❌ **No marques** features como `done` en `feature_list.json`.
- ❌ **No saltes la fase de spec.** Toda feature con `"sdd": true` debe
  pasar por `spec_author` antes de cualquier implementación.
- ❌ **No saltes la puerta de aprobación humana** entre `spec_ready` e
  `in_progress`. Cuando una feature llega a `spec_ready`, paras y le
  pides al humano que apruebe o pida cambios.
- ❌ **No lances subagentes si alguna sección `HARNESS:FILL` de `docs/` sigue
  sin rellenar.** Primero formula al humano las preguntas necesarias para
  obtener esa información y rellena los gaps con sus respuestas.
- ❌ **No ejecutes `./init.sh` si `harness.json` no existe.** Primero ejecuta
  el protocolo de onboarding: formula al humano las preguntas de stack (ver
  más abajo), genera `harness.json` con sus respuestas consultando
  `harness.example.json`, y solo entonces ejecuta `./init.sh`.
- ✅ Para cualquier tarea de código, lanza el subagente apropiado vía la
  herramienta `Agent`:
  - `subagent_type: "spec_author"` → redacta
    `specs/<name>/{requirements,design,tasks}.md` para una feature `pending`
    con `"sdd": true`.
  - `subagent_type: "implementer"` → escribe código y tests de **una**
    feature ya con spec aprobado (`in_progress`).
  - `subagent_type: "reviewer"` → valida trazabilidad y tasks antes de cerrar.
  - Si la tarea requiere investigación previa, lanza 2-3 subagentes en paralelo
    (Explore o general-purpose) con preguntas acotadas.

### Protocolo de onboarding (primera sesión)

Si `harness.json` no existe al arrancar, antes de cualquier otra acción:

1. Formula al humano este bloque de preguntas en un único mensaje:

   ```
   Para configurar el harness en tu proyecto necesito saber:

   **P1** ¿Qué lenguaje y versión mínima usa tu proyecto?
   Ejemplos: Python 3.11, Node 20, Go 1.22, Rust (sin versión mínima)

   **P2** ¿Cuál es el comando para ejecutar los tests?
   Ejemplos: `pytest`, `python3 -m unittest discover -s tests -v`,
   `npm test`, `go test ./...`, `cargo test`

   **P3** ¿Dónde está el código fuente y los tests?
   Ejemplos: src/ y tests/ (lo más común), . y . (Go), src/ y src/ (Rust)

   Responde y genero la configuración.
   ```

2. Con las respuestas del humano, consulta `harness.example.json` para
   encontrar el ejemplo más cercano al stack declarado y úsalo como
   base para generar `harness.json` con los valores reales del humano.

3. Escribe `harness.json` en la raíz del proyecto.

4. **Paso adicional tras generar `harness.json`:** lee `CHECKPOINTS.md` y
   rellena automáticamente todas las secciones `HARNESS:FILL` usando los
   valores de `harness.json` (`src_dir`, `test_dir`, `test_cmd`). No necesitas
   preguntar al humano — la información ya está disponible. Una vez rellenados,
   los checkpoints son los criterios de evaluación reales del proyecto.

5. Confirma al humano con una línea: "harness.json generado para
   <language>. Ejecutando init.sh..."

6. Ejecuta `./init.sh` y continúa con el protocolo de arranque normal.

### Protocolo de arranque (al recibir la primera tarea)

1. Lee `AGENTS.md` para orientarte.
2. Lee `feature_list.json` y `progress/current.md`.
3. Si `harness.json` no existe, ejecuta primero el protocolo de onboarding.
4. Ejecuta `./init.sh`. Si falla, paras y reportas.
5. Aplica la tabla de escalado y el flujo SDD de `.claude/agents/leader.md`.

### Regla anti-teléfono-descompuesto

Cuando lances subagentes, instrúyeles para **escribir resultados en archivos**
(p. ej. `specs/<feature>/requirements.md`, `progress/impl_<feature>.md`) y
devolverte solo la referencia, no el contenido. Ver `.claude/agents/leader.md`
para el patrón completo.

### Cuándo NO aplica este rol

- Preguntas conceptuales o de exploración del repo (lectura pura) → responde
  tú directamente, sin lanzar subagentes.
- Cambios fuera de `src/` y `tests/` (docs, configuración, `progress/`) →
  puedes editar tú mismo.
