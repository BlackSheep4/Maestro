# AGENTS.md — Mapa de navegación para agentes de IA

> Este archivo es el **punto de entrada** para cualquier agente que trabaje en este
> repositorio. NO es una biblia de reglas: es un **mapa**. Lee solo lo que
> necesites cuando lo necesites (divulgación progresiva).

---

## 1. Antes de empezar (obligatorio)

1. Si `harness.json` no existe, ejecuta el protocolo de onboarding de
   `CLAUDE.md` antes de cualquier otra cosa. Si existe, ejecuta `./init.sh`
   directamente y verifica que termina sin errores. Si falla, **para** y
   resuelve el entorno antes de tocar código. Si `feature_list.json` está
   vacío pero `src_dir` contiene código, el harness está en modo brownfield
   pendiente de onboarding: el `leader` debe lanzar el `explorer` antes de
   cualquier otra acción.
2. Lee `progress/current.md` para entender en qué estado quedó la última sesión.
3. Lee `feature_list.json`. Toda feature nueva (`"sdd": true`) pasa por
   **Spec Driven Development** — ver `docs/specs.md` y §4 de este archivo.
4. Lee `docs/specs.md` antes de tocar cualquier spec o feature `sdd: true`.
5. **Verifica que las secciones `HARNESS:FILL` de `docs/` están rellenas.** Los
   docs combinan secciones `HARNESS:REQUIRED` (reglas del harness, no se tocan)
   con secciones `HARNESS:FILL` (contexto del proyecto, las rellena el humano).
   Si alguna `HARNESS:FILL` aún contiene el placeholder original sin completar,
   formula al humano las preguntas necesarias para obtener esa información y
   rellena los gaps directamente con sus respuestas. Un harness con secciones
   `FILL` vacías produce specs y código incorrectos.

   **Reparto de quién rellena cada `HARNESS:FILL`** (aplica en greenfield y
   brownfield; ningún fichero queda sin dueño):

   | Fichero (`FILL`)          | Quién         | Fuente                                    |
   |---------------------------|---------------|-------------------------------------------|
   | `CHECKPOINTS.md`          | leader        | mecánico, desde `harness.json`            |
   | `docs/verification.md` (comando de tests) | leader | mecánico, desde `harness.json`     |
   | `docs/specs.md` (ejemplos)| leader        | ejemplo EARS ilustrativo con la invocación del stack (sin entrevista) |
   | `docs/architecture.md`    | explorer (brownfield) / leader+humano (greenfield) | código existente o respuestas del humano |
   | `docs/conventions.md`     | explorer (brownfield) / leader+humano (greenfield) | código existente o respuestas del humano |
   | `docs/verification.md` (ejemplos de integración) | leader+humano | dominio del proyecto |

   En brownfield el `explorer` cubre `architecture.md` y `conventions.md`; el
   resto los completa el leader (mecánicos) o preguntando al humano (de dominio).

## 2. Mapa del repositorio

| Archivo / carpeta            | Qué contiene                                                                | Cuándo leerlo |
|------------------------------|-----------------------------------------------------------------------------|---------------|
| `feature_list.json`          | Lista de tareas con estado (`pending` / `spec_ready` / `in_progress` / `done` / `blocked`) | Siempre, al empezar |
| `harness.json`               | Configuración del stack del proyecto (lenguaje, versión mínima, comando de tests). Generado por el agente en la primera sesión mediante asunción dinámica. | Siempre, al empezar |
| `harness.example.json`       | Referencia de configuraciones para stacks comunes. El agente lo consulta al generar `harness.json`. No editar manualmente. | Solo el agente, durante onboarding |
| `progress/current.md`        | Estado de la sesión actual                                                  | Siempre, al empezar |
| `progress/history.md`        | Bitácora append-only de sesiones anteriores                                 | Si necesitas contexto histórico |
| `specs/<feature>/`           | `requirements.md` + `design.md` + `tasks.md` (Kiro-style)                   | Antes de implementar cualquier feature con `"sdd": true` |
| `progress/spec_interview_<feature>.md` | Preguntas de clarificación del `spec_author` y respuestas del humano | Si necesitas entender las decisiones que dieron forma a un spec |
| `docs/architecture.md`       | Qué significa "hacer un buen trabajo" en este proyecto                      | Antes de implementar |
| `docs/conventions.md`        | Reglas de estilo, nombres, estructura                                       | Antes de escribir código |
| `docs/specs.md`              | Proceso SDD: EARS notation, los 3 archivos, puerta de aprobación humana     | Antes de redactar o leer un spec |
| `docs/verification.md`       | Cómo verificar que tu trabajo funciona (incluye trazabilidad requirements)  | Antes de declarar una tarea como `done` |
| `CHECKPOINTS.md`             | Criterios objetivos de "estado final correcto"                              | Para auto-evaluarte |
| `.claude/agents/`            | Definiciones de subagentes (`leader`, `spec_author`, `implementer`, `reviewer`) | Si orquestas trabajo |
| `.claude/agents/explorer.md` | Agente de onboarding brownfield. Solo se ejecuta en la primera sesión de un proyecto con código existente. | Solo durante onboarding brownfield |
| `progress/explorer_brownfield.md` | Bitácora del onboarding brownfield: razonamiento del explorer, features inferidas, decisiones tomadas. | Si necesitas entender el estado inicial del harness |
| `src/`                       | Código de la aplicación                                                     | Para implementar |
| `tests/`                     | Tests automáticos                                                           | Para verificar |

## 3. Reglas duras (no negociables)

- **Una sola feature a la vez.** No mezcles cambios de varias tareas en la misma sesión.
- **No declares una tarea `done` sin pruebas verdes.** Ejecuta `./init.sh` y
  asegúrate de que el bloque de tests pasa al 100%.
- **No saltes la fase de spec.** Toda feature con `"sdd": true` debe pasar
  por `spec_author` y obtener aprobación humana antes de tocar código.
- **No saltes la puerta de aprobación humana.** El leader detiene el flujo
  en `spec_ready` y espera.
- **Documenta lo que haces** en `progress/current.md` mientras trabajas, no al final.
- **Deja el repositorio limpio** antes de cerrar la sesión (ver §5).
- **Si no sabes algo, busca en `docs/`** antes de inventarlo.

## 4. Flujo de trabajo (SDD)

```
pending → [spec_author] → spec_ready → ⏸ HUMANO → in_progress → [implementer → reviewer] → done
```

1. El leader detecta la primera feature `pending` con `"sdd": true`.
2. El leader lanza `spec_author`, que crea
   `specs/<name>/{requirements,design,tasks}.md` y marca el status como
   `spec_ready`.
3. **Pausa.** El humano lee el spec en `specs/<name>/` y aprueba (o pide cambios).
4. Una vez aprobado, el leader cambia el status a `in_progress` y lanza `implementer`.
5. El implementer ejecuta `tasks.md` una a una, marcándolas `[x]`.
6. El reviewer verifica trazabilidad `R<n>` ↔ test y tasks completas;
   aprueba o rechaza. Escribe su veredicto en `progress/review_<name>.md`.
7. Si el veredicto es `APPROVED`, **el leader** marca `done` y mueve el resumen
   a `progress/history.md`. Si es `CHANGES_REQUESTED`, el leader relanza al
   implementer con los cambios pedidos.

## 5. Cierre de sesión (lifecycle)

Antes de terminar:

1. Ejecuta `./init.sh` — todo verde.
2. Si la tarea está acabada: marca `status: "done"` en `feature_list.json`.
3. Mueve el resumen de `progress/current.md` al final de `progress/history.md`.
4. Vacía `progress/current.md` dejando solo la plantilla.
5. No dejes archivos temporales, ni `print()` de debug, ni TODOs sin contexto.

## 6. Si te bloqueas

- Relee la sección relevante de `docs/`.
- Si la herramienta no hace lo que esperas, **no inventes un workaround**:
  documenta el bloqueo en `progress/current.md` y para la sesión.
