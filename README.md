# ejemplo-harness — Notes CLI

Proyecto de ejemplo que demuestra los principios de **Harness Engineering**
aplicados a un CLI minimalista de notas en Python.

> El código de la aplicación es deliberadamente simple. Lo importante de
> este repo no es **qué** hace, sino **cómo** está estructurado para que un
> agente de IA pueda trabajar sobre él de forma autónoma y verificable.

## Cómo está organizado el arnés

| Pilar                                  | Manifestación en este repo                                                       |
|----------------------------------------|----------------------------------------------------------------------------------|
| **1. El repositorio ES el sistema**    | `AGENTS.md`, `init.sh`, `feature_list.json`, `specs/`, `progress/`, `docs/`      |
| **2. Orquestación multi-agente**       | `.claude/agents/leader.md`, `spec_author.md`, `implementer.md`, `reviewer.md`    |
| **3. Spec Driven Development**         | `docs/specs.md`, EARS notation, puerta de aprobación humana en `spec_ready`      |
| **4. Supervisión y mejora**            | `CHECKPOINTS.md`, hooks en `.claude/settings.json`, `tests/`                     |

## Para empezar

```bash
./init.sh
```

Si todo está verde, abre `AGENTS.md` y sigue desde ahí.

## Para usar la app (humanos)

```bash
python3 -m src.cli add "comprar pan" --body "y leche"
python3 -m src.cli list
```

## Probarlo tú mismo con Claude Code

Si te descargas el repo y abres Claude Code en la raíz, ya estás dentro del
arnés: `CLAUDE.md` fuerza al modelo a actuar como `leader` (orquesta, no
edita código) y `docs/specs.md` impone el flujo Spec Driven Development.

Receta rápida:

1. `./init.sh` — debe terminar verde.
2. Abre `feature_list.json` y deja al menos una feature con
   `status: "pending"` y `"sdd": true`. La #7 `cli_recent` ya está así.
3. Lanza Claude Code en la raíz del repo: `claude`.
4. Pídele: **«implementa la siguiente feature pendiente»**.

Lo que ocurre, en dos fases:

**Fase 1 — Spec.** El `leader` lanza un `spec_author` que escribe
`specs/<feature>/{requirements.md, design.md, tasks.md}` y deja la feature
en `spec_ready`. Luego **para y te pide aprobación**.

Tú lees los tres archivos en tu editor:

- `requirements.md` — qué debe hacer la feature, en EARS estricto.
- `design.md` — decisiones técnicas antes de escribir código.
- `tasks.md` — checklist de pasos discretos a ejecutar.

Cuando estés conforme, dices al chat «aprobado» (o pides cambios).

**Fase 2 — Código.** El `leader` transiciona la feature a `in_progress` y
lanza `implementer` (sigue las tasks una a una marcándolas `[x]`) y
después `reviewer` (verifica trazabilidad `R<n>` ↔ test y todas las tasks
completas).

Dónde queda la traza de cada subagente:

| Archivo                                  | Quién lo escribe   | Qué contiene                                                  |
|------------------------------------------|--------------------|---------------------------------------------------------------|
| `specs/<feature>/requirements.md`        | spec_author        | EARS requirements numeradas `R1`, `R2`, ...                  |
| `specs/<feature>/design.md`              | spec_author        | Decisiones técnicas + alternativa descartada                  |
| `specs/<feature>/tasks.md`               | spec_author        | Checklist; el implementer la va marcando `[x]`                |
| `progress/current.md`                    | leader             | Plan vivo de la sesión                                        |
| `progress/impl_<feature>.md`             | implementer        | Archivos tocados + mapa `R<n> → test` + output de los tests   |
| `progress/review_<feature>.md`           | reviewer           | Checklist contra `docs/`, `specs/<feature>/` y `CHECKPOINTS.md` |
| `feature_list.json`                      | leader/implementer | `pending` → `spec_ready` → `in_progress` → `done`             |
| `progress/history.md`                    | leader             | Resumen append-only al cerrar la sesión                       |

Abre `specs/` y `progress/` en tu editor mientras Claude trabaja: cada
informe aparece en cuanto el subagente termina. Esa es la regla
anti-teléfono-descompuesto en acción — el contenido no circula por chat,
vive en disco y queda versionado.

## Estructura

```
.
├── AGENTS.md              # Mapa para agentes (divulgación progresiva)
├── CHECKPOINTS.md         # Criterios de "estado final correcto"
├── feature_list.json      # Alcance: una feature a la vez
├── init.sh                # Verificación e inicialización
├── specs/<feature>/       # Spec por feature (Kiro-style)
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
│   ├── agents/            # leader, spec_author, implementer, reviewer
│   └── settings.json      # Hooks que automatizan la verificación
├── src/
│   ├── storage.py         # Persistencia atómica (JSON)
│   ├── notes.py           # Modelo de dominio
│   └── cli.py             # Interfaz argparse
└── tests/
    ├── test_storage.py
    ├── test_notes.py
    └── test_cli.py
```

## Aprendizajes que ilustra este proyecto

- **Divulgación progresiva** en `AGENTS.md`: el agente no recibe todas las
  reglas de golpe, recibe un mapa para buscarlas bajo demanda.
- **Una feature a la vez** validado por `init.sh` (rechaza más de un
  `in_progress` en `feature_list.json`).
- **Spec Driven Development** estilo Kiro: requirements (EARS) → design →
  tasks → code, con una puerta de aprobación humana antes de tocar código.
- **Estado en disco**, no en chat: `specs/`, `progress/current.md` y
  `history.md` sobreviven a reinicios y context windows reventadas.
- **Verificación ejecutable**: `init.sh` corre los tests reales y valida
  la presencia de specs para toda feature SDD.
- **Trazabilidad obligatoria**: cada `R<n>` se mapea a un test concreto;
  el reviewer rechaza si falta.
- **Patrón Leader-Spec-Implementer-Reviewer**: el leader no implementa,
  el spec_author no codifica, el implementer no se autoaprueba, el
  reviewer no edita código.
- **Anti teléfono-descompuesto**: los subagentes escriben sus resultados
  en archivos y solo devuelven una referencia ligera.
