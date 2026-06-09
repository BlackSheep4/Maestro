# Harness SDD — plantilla genérica

Plantilla de **arnés (harness)** para desarrollar cualquier proyecto con
agentes de IA aplicando **Spec Driven Development**. No es una aplicación: es
el andamiaje que envuelve a tu código para que un agente trabaje sobre él de
forma autónoma, verificable y reproducible desde la primera sesión.

> Esta rama es la **plantilla limpia**: no trae código de aplicación. `src/`,
> `tests/` y `specs/` están vacíos, `feature_list.json` no tiene features y
> `harness.json` no existe todavía — **lo genera el agente** en la primera
> sesión (onboarding). A partir de ahí el arnés se puebla solo, feature a
> feature.

El arnés es **políglota**: el stack (lenguaje, versión mínima, comando de
tests, rutas) vive en `harness.json` y `init.sh` lo lee de ahí. Sirve igual
para Python, Node, Go o Rust. (Requisito del propio arnés: `python3` disponible
para parsear la configuración JSON.)

## Cómo está organizado el arnés

| Pilar                                  | Manifestación en este repo                                                       |
|----------------------------------------|----------------------------------------------------------------------------------|
| **1. El repositorio ES el sistema**    | `AGENTS.md`, `init.sh`, `feature_list.json`, `specs/`, `progress/`, `docs/`      |
| **2. Orquestación multi-agente**       | `.claude/agents/leader.md`, `spec_author.md`, `implementer.md`, `reviewer.md`, `explorer.md` |
| **3. Spec Driven Development**         | `docs/specs.md`, EARS notation, puerta de aprobación humana en `spec_ready`      |
| **4. Supervisión y mejora**            | `CHECKPOINTS.md`, hooks en `.claude/settings.json` (+`.claude/hooks/`), `init.sh`|

## Para empezar

Abre Claude Code en la raíz del repo y pídele que arranque. El agente actúa
como `leader` (lo fuerza `CLAUDE.md`) y ejecuta el **protocolo de onboarding**:

1. Como `harness.json` no existe, te hace 3 preguntas de stack (lenguaje y
   versión mínima, comando de tests, rutas de código y tests) y genera
   `harness.json` por ti, consultando `harness.example.json` como referencia.
2. Rellena automáticamente las secciones `HARNESS:FILL` mecánicas de los `docs/`
   y `CHECKPOINTS.md` con los valores del stack.
3. Detecta el modo:
   - **Greenfield** (sin código en `src_dir`): te pregunta qué feature quieres
     construir primero y la inscribe como `pending` en `feature_list.json`.
   - **Brownfield** (ya hay código): lanza el `explorer`, que infiere las
     features existentes, te las propone y —tras tu aprobación— escribe el
     `feature_list.json` inicial.
4. Ejecuta `./init.sh`, que debe terminar en verde.

`./init.sh` se puede ejecutar a mano una vez exista `harness.json`; antes de
eso falla a propósito y te remite al onboarding.

## Trabajar con Claude Code

Con `harness.json` generado y al menos una feature `pending`, pídele:
**«implementa la siguiente feature pendiente»**. El flujo ocurre en dos fases
con una **puerta de aprobación humana** entre ellas:

**Fase 1 — Spec.** El `leader` lanza un `spec_author` que escribe
`specs/<feature>/{requirements.md, design.md, tasks.md}` y deja la feature en
`spec_ready`. Luego **para y te pide aprobación**.

Tú lees los tres archivos en tu editor:

- `requirements.md` — qué debe hacer la feature, en EARS estricto.
- `design.md` — decisiones técnicas antes de escribir código.
- `tasks.md` — checklist de pasos discretos a ejecutar.

Cuando estés conforme, dices al chat «aprobado» (o pides cambios).

**Fase 2 — Código.** El `leader` transiciona la feature a `in_progress` y
lanza `implementer` (sigue las tasks una a una marcándolas `[x]`) y después
`reviewer` (verifica trazabilidad `R<n>` ↔ test y todas las tasks completas).
Si el `reviewer` aprueba, **el leader** marca la feature `done` y vuelca el
resumen a `progress/history.md`.

Dónde queda la traza de cada subagente:

| Archivo                                  | Quién lo escribe   | Qué contiene                                                  |
|------------------------------------------|--------------------|---------------------------------------------------------------|
| `specs/<feature>/requirements.md`        | spec_author        | EARS requirements numeradas `R1`, `R2`, ...                  |
| `specs/<feature>/design.md`              | spec_author        | Decisiones técnicas + alternativa descartada                  |
| `specs/<feature>/tasks.md`               | spec_author        | Checklist; el implementer la va marcando `[x]`                |
| `progress/spec_interview_<feature>.md`   | spec_author        | Preguntas de clarificación y respuestas del humano (si las hubo) |
| `progress/current.md`                    | leader             | Plan vivo de la sesión                                        |
| `progress/impl_<feature>.md`             | implementer        | Archivos tocados + mapa `R<n> → test` + output de los tests   |
| `progress/review_<feature>.md`           | reviewer           | Checklist contra `docs/`, `specs/<feature>/` y `CHECKPOINTS.md` |
| `progress/explorer_brownfield.md`        | explorer           | Razonamiento del onboarding brownfield                        |
| `feature_list.json`                      | leader             | `pending` → `spec_ready` → `in_progress` → `done`             |
| `progress/history.md`                    | leader             | Resumen append-only al cerrar la sesión                       |

Abre `specs/` y `progress/` en tu editor mientras Claude trabaja: cada informe
aparece en cuanto el subagente termina. Esa es la regla anti-teléfono-
descompuesto en acción — el contenido no circula por chat, vive en disco y
queda versionado.

## Estructura

```
.
├── AGENTS.md              # Mapa para agentes (divulgación progresiva)
├── CLAUDE.md              # Carga automática: fuerza el rol leader + onboarding
├── CHECKPOINTS.md         # Criterios de "estado final correcto"
├── feature_list.json      # Alcance: una feature a la vez (vacío en la plantilla)
├── harness.json           # Config del stack (lo genera el agente en onboarding)
├── harness.example.json   # Referencia de stacks para el agente (no editar a mano)
├── init.sh                # Verificación e inicialización (políglota vía harness.json)
├── specs/<feature>/       # Spec por feature (Kiro-style), creado al dejar pending
│   ├── requirements.md    # EARS notation
│   ├── design.md          # Decisiones técnicas
│   └── tasks.md           # Checklist de implementación
├── progress/
│   ├── current.md         # Sesión activa (estado vivo)
│   └── history.md         # Bitácora append-only
├── docs/
│   ├── architecture.md    # Qué significa "buen trabajo"
│   ├── conventions.md     # Estilo, nombres, errores
│   ├── specs.md           # Proceso SDD: EARS, 3 archivos, aprobación humana
│   └── verification.md    # Cómo demostrar que funciona
├── .claude/
│   ├── agents/            # leader, spec_author, implementer, reviewer, explorer
│   ├── hooks/             # Scripts de los hooks (after_edit, before_stop)
│   └── settings.json      # Hooks que automatizan la verificación
├── src/                   # Tu código (lo genera el implementer)
└── tests/                 # Tus tests (los genera el implementer)
```

## Aprendizajes que ilustra esta plantilla

- **Divulgación progresiva** en `AGENTS.md`: el agente no recibe todas las
  reglas de golpe, recibe un mapa para buscarlas bajo demanda.
- **Una feature a la vez** validado por `init.sh` (rechaza más de un
  `in_progress` en `feature_list.json`).
- **Spec Driven Development** estilo Kiro: requirements (EARS) → design →
  tasks → code, con una puerta de aprobación humana antes de tocar código.
- **Estado en disco**, no en chat: `specs/`, `progress/current.md` y
  `history.md` sobreviven a reinicios y context windows reventadas.
- **Verificación ejecutable**: `init.sh` corre los tests reales y valida la
  presencia de specs para toda feature SDD.
- **Trazabilidad obligatoria**: cada `R<n>` se mapea a un test concreto; el
  reviewer rechaza si falta.
- **Separación de roles**: el leader orquesta pero no escribe `src/`/`tests/`;
  el spec_author no codifica; el implementer no se autoaprueba; el reviewer no
  edita código; el leader marca `done` solo con un veredicto APPROVED.
- **Anti teléfono-descompuesto**: los subagentes escriben sus resultados en
  archivos y solo devuelven una referencia ligera.
