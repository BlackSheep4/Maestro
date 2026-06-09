# Spec Driven Development (SDD)

> Este proyecto sigue un flujo Kiro-style: requirements → design → tasks → code.
> El código no se escribe hasta que el spec está aprobado por un humano.

<!-- HARNESS:REQUIRED — no modificar: los agentes dependen de esta sección -->

## Estructura

Cada feature nueva (`"sdd": true` en `feature_list.json`) tiene una carpeta
dedicada en cuanto deja `pending`:

```
specs/<feature-name>/
├── requirements.md   # QUÉ se necesita (EARS notation)
├── design.md         # CÓMO se construirá (decisiones técnicas)
└── tasks.md          # PASOS concretos a implementar
```

El `feature-name` coincide con el campo `name` de `feature_list.json`.

## Estados de una feature

| Estado         | Significado                                                    |
|----------------|----------------------------------------------------------------|
| `pending`      | Sin spec. El `spec_author` es el primero en actuar.            |
| `spec_ready`   | Spec drafted. Esperando aprobación humana. NO se toca código.  |
| `in_progress`  | Spec aprobado. `implementer` trabajando.                       |
| `done`         | Código verde, `reviewer` aprobó, sesión cerrada.               |
| `blocked`      | Atascado. Razón en `progress/current.md`.                      |

## La puerta de aprobación humana

El flujo automático se detiene **una vez**: cuando el `spec_author` termina
sus tres archivos, marca la feature como `spec_ready` y para. El humano
lee `specs/<feature>/` y dice "aprobado" (o pide cambios).

Solo entonces el `leader` transiciona `spec_ready → in_progress` y lanza
el `implementer`.

```
pending → [spec_author: Fase 0 análisis] → ⏸ entrevista (si ambigüedad) → [spec_author: redacción] → spec_ready → ⏸ HUMANO → in_progress → [implementer → reviewer] → done
```

## Fase 0: Análisis de ambigüedad (pre-spec)

Antes de redactar el spec, el `spec_author` analiza los `acceptance` criteria
de la feature y, si detecta ambigüedad, formula al humano un bloque acotado de
preguntas cerradas. Es una entrevista breve, no una reunión de requisitos.

**Cuándo se activa.** Solo si **al menos un** `acceptance` criterion es
ambiguo. Si todos son suficientes (traducibles directamente a un `R<n>` EARS
sin decisiones arbitrarias), no hay entrevista y el flujo no se ralentiza.

**Qué hace ambiguo a un criterion.** Cumple al menos una de estas condiciones:

- No es verificable por un test concreto sin tomar una decisión arbitraria
  (p. ej. "debe ser eficiente").
- Describe el caso feliz pero no el comportamiento en error o caso límite
  relevante (p. ej. no dice qué pasa si el archivo está vacío).
- Usa lenguaje con más de una interpretación técnica válida
  (p. ej. "formato legible").
- Implica una decisión de diseño que el humano podría querer controlar
  (p. ej. estructura exacta de un archivo de salida, formato de un id).

**Límite de 3 preguntas.** Como máximo 3 preguntas, en un único bloque. El
límite es deliberado: acota el diálogo para que no se convierta en una reunión
de requisitos abierta. Si hay más ambigüedades, el `spec_author` prioriza las
que bloquean más requirements o afectan al comportamiento en errores. Las
preguntas son cerradas o semi-cerradas (con opciones o ejemplo), nunca
abiertas.

**Dónde quedan las respuestas.** El `spec_author` las persiste en
`progress/spec_interview_<name>.md` antes de redactar. No se quedan en el chat.

**Las respuestas son vinculantes.** Tienen el mismo peso que los `acceptance`
criteria originales: el spec no puede ignorarlas ni reinterpretarlas.

**Fallback a `blocked`.** Si tras la entrevista la ambigüedad persiste, o es
tan profunda que ni 3 preguntas la resuelven, el `spec_author` para con
`blocked`. La entrevista es el primer recurso; `blocked` es el último.

## requirements.md — EARS estricto

Las requirements se redactan en **EARS** (Easy Approach to Requirements
Syntax). Cada requirement es un párrafo numerado con uno de estos cinco
patrones:

| Patrón         | Plantilla                                                   |
|----------------|-------------------------------------------------------------|
| **Ubicuo**     | `El sistema DEBE <acción>.`                                 |
| **Evento**     | `CUANDO <disparador>, el sistema DEBE <acción>.`            |
| **Estado**     | `MIENTRAS <estado>, el sistema DEBE <acción>.`              |
| **Opcional**   | `DONDE <feature opcional>, el sistema DEBE <acción>.`       |
| **No deseado** | `SI <evento no deseado> ENTONCES el sistema DEBE <acción>.` |

Reglas duras:

- Cada requirement tiene un id estable: `R1`, `R2`, ...
- Cada requirement DEBE ser verificable por al menos un test concreto.
- No mezcles varios `DEBE` en un mismo requirement. Si hay más de uno, parte.
- No uses verbos blandos ("podría", "puede", "soporta"). Solo `DEBE` / `NO DEBE`.

<!-- /HARNESS:REQUIRED -->

<!-- HARNESS:FILL — ejemplo de requirements.md con el dominio de TU proyecto. Sustituye el ejemplo de abajo por uno escrito contra una feature y un comando/endpoint reales de tu proyecto, manteniendo la sintaxis EARS y los ids R<n>. -->

Ejemplo (sustitúyelo por uno de TU dominio):

```markdown
## R1
CUANDO el usuario ejecuta `python -m src.cli recent`, el sistema DEBE
imprimir hasta 5 notas ordenadas por `created_at` descendente.

## R2
SI el flag `--limit` recibe un valor <= 0 ENTONCES el sistema DEBE
imprimir un mensaje de error en stderr y salir con código != 0.
```

<!-- /HARNESS:FILL -->

<!-- HARNESS:REQUIRED — no modificar: los agentes dependen de esta sección -->

## design.md — decisiones técnicas

Captura **antes** de tocar código:

- Qué archivos se crean / modifican.
- Qué firmas nuevas aparecen (funciones, clases, comandos).
- Qué excepciones se reutilizan o se añaden.
- Qué alternativa se descartó y por qué (mínimo una).

NO es ingeniería desde primeros principios — apóyate en
`docs/architecture.md` y `docs/conventions.md`. El `design.md` documenta los
puntos donde tu feature roza la frontera de esas reglas.

## tasks.md — checklist ejecutable

Pasos discretos en orden, cada uno con checkbox. Cada task referencia al
menos un `R<n>` que cubre.

<!-- /HARNESS:REQUIRED -->

<!-- HARNESS:FILL — ejemplo de tasks.md con el dominio de TU proyecto. Sustituye el ejemplo de abajo por tasks escritas contra los archivos y la feature reales de tu proyecto, manteniendo el formato `[ ] T<n> — ... Cubre: R<n>`. -->

Ejemplo (sustitúyelo por uno de TU dominio):

```markdown
- [ ] T1 — Añadir `cmd_recent` en `src/cli.py`. Cubre: R1, R3.
- [ ] T2 — Registrar subparser `recent` con flag `--limit`. Cubre: R1, R2.
- [ ] T3 — Añadir `test_recent_default_limit` en `tests/test_cli.py`. Cubre: R1.
- [ ] T4 — Añadir `test_recent_invalid_limit` en `tests/test_cli.py`. Cubre: R2.
```

<!-- /HARNESS:FILL -->

<!-- HARNESS:REQUIRED — no modificar: los agentes dependen de esta sección -->

El `implementer` marca `[x]` cada task al completarla. El `reviewer`
rechaza si queda alguna `[ ]` sin justificación documentada.

## Trazabilidad (regla dura)

- Cada test en `tests/` debe poder mapearse a un `R<n>` de su spec.
- Cada `R<n>` debe tener al menos un test concreto.
- El `reviewer` comprueba esta correspondencia explícitamente y rechaza
  si falta.

El `implementer` documenta el mapa en `progress/impl_<name>.md`:

```markdown
## Trazabilidad
- R1 → `test_<feature>_<caso_feliz>`
- R2 → `test_<feature>_<caso_error>`
- R3 → `test_<feature>_<caso_alternativo>`
```

## Cuándo NO aplica SDD

Las features con `"sdd": false` o sin el campo `sdd` NO tienen spec. SDD solo
se aplica hacia adelante.

<!-- /HARNESS:REQUIRED -->
