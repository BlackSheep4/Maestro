# Roadmap: Mandato de tests enriquecido (el agente ESCRIBE más tipos de test)

> Estado: **anotada, sin definir del todo.** Necesita una pasada de definición
> (AskUserQuestion) antes de implementar. Extiende [ci-quality-gate](ci-quality-gate.md),
> pero por un **eje distinto**: ci-quality-gate es enforcement **mecánico**
> (linters/escáneres en `init.sh`); esto es lo que el **agente autor de tests
> escribe**.

## Qué se quiere (intención del humano)

Que el agente que redacta y escribe los tests (el `implementer`, guiado por el
`spec_author`, `docs/verification.md` y el `reviewer`) **tenga que producir una
batería de tests más completa y categorizada**, no solo "un test por función".
En concreto:

- **Unitarios con cobertura objetivo (≥ 80%)** — no basta con "hay un test"; hay
  un umbral de cobertura que cumplir.
- **Integración** — ya existe como Nivel 2, se mantiene/refuerza.
- **Seguridad** — tests que verifican propiedades de seguridad: input malicioso
  rechazado/saneado, authz (usuario A no accede a recurso de B), secretos no se
  loguean/filtran.
- **Rendimiento / optimización** — tests que verifican presupuestos: latencia
  máxima, nº de llamadas/queries (evitar N+1), cotas de complejidad.
- **etc.** (la lista es ampliable por categoría).

## En qué se traduce (dónde toca)

- **`docs/verification.md`** — ampliar los "Niveles de verificación": unitarios
  **con umbral de cobertura**, integración, seguridad, rendimiento. Definir qué
  significa cada categoría y cuándo aplica.
- **`spec_author`** — al redactar el spec, **decide qué categorías de test aplican
  a esa feature** (no toda feature necesita test de rendimiento o seguridad) y las
  incluye en `tasks.md`/`requirements.md`.
- **`implementer`** — escribe los tests de cada categoría aplicable, no solo
  unitarios.
- **`reviewer`** — **enforcea**: exige las categorías spec-eadas y el **umbral de
  cobertura** (rechaza si < 80% o si falta una categoría requerida).
- **`harness.json`** — comando de cobertura (stack-specific: `pytest --cov`,
  `jest --coverage`, `go test -cover`) y umbral; posiblemente `init.sh` lo verifica.
- **`feature_list.json` (rules)** — `min_coverage: 80` como regla configurable.

## Decisiones abiertas (para la pasada de definición)

- **Cobertura:** ¿80% global o por-módulo? ¿medida con qué comando (stack-specific
  en `harness.json`)? ¿la verifica `init.sh` (gate) o solo el reviewer?
- **Categorías obligatorias vs condicionales:** seguridad/rendimiento no aplican a
  toda feature. ¿Quién decide la aplicabilidad? (propuesta: el `spec_author`, por
  feature, y el humano lo aprueba en la puerta del spec).
- **Tests de rendimiento:** presupuestos de tiempo son **flaky** en CI. ¿Aserciones
  sobre nº de llamadas/complejidad (más estables) o benchmark con umbral de
  regresión (pesado)?
- **Tests de seguridad:** ¿qué patrones concretos por categoría (inyección, authz,
  secretos)? Hará falta guía/ejemplos en `verification.md` para que el agente sepa
  qué escribir.
- **Alcance:** proyectos generados (como el resto de la línea de calidad).

## Relación

- **Complementa** a ci-quality-gate: aquello es calidad **mecánica** (el tool
  detecta), esto es calidad **autorada** (el agente escribe el test). Van juntas
  pero son ejes distintos.
- La idea de escáneres de seguridad (gitleaks/semgrep) y la rúbrica de juicio del
  reviewer que se barajó antes son **otra cosa** (enforcement mecánico + revisión);
  si se quieren, encajan mejor como fase 2 de ci-quality-gate, no aquí.
- Ir **después** de ci-quality-gate (reusa su `verification.md` Nivel 5 y el
  esquema de `harness.json`).
