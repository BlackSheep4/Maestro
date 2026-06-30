# Roadmap: Gate de calidad espejado local↔CI

> Estado: **definido, sin implementar.** Fruto de una sesión de brainstorming.
> Cuando se decida implementar, este documento es el punto de partida para el
> `spec_author`. Relacionado con [pr-release-flow](pr-release-flow.md): el `ci.yml`
> que ese flujo genera ya espeja `init.sh`, así que este gate se monta encima.

## Resumen en una línea

Extender el gate del harness de "un `test_cmd`" a una lista declarativa de
**checks de calidad** en `harness.json`, que `init.sh` ejecuta y `ci.yml` espeja
gratis (ya corre `init.sh`).

## Punto de partida

Hoy el espejo local↔CI existe pero es mínimo: `ci.yml` corre `./init.sh`, e
`init.sh` ejecuta **un solo** `test_cmd` (los unitarios). No hay lint, ni
integración, ni código muerto, ni complejidad. La tensión central: Maestro es
**políglota**, pero "código muerto", "spaghetti" y "convenciones del lenguaje"
se hacen con herramientas **específicas de cada lenguaje**. El reto no es "qué
checks", es **cómo declararlos sin hardcodear cada lenguaje**.

## Decisiones tomadas (sesión de brainstorming)

| Tema | Resolución |
|------|-----------|
| **Mecanismo** | `checks` declarativos en `harness.json` → corridos por `init.sh` → espejo CI automático (DRY, fuente única de verdad). |
| **Categorías** | **Todas**: correctitud (unit+integración), estilo (lint+format+typecheck), salud (código muerto+complejidad/duplicación), seguridad (deps+secretos). |
| **Severidad** | **Todo bloquea** (estricto) en fase 1. |
| **Quién configura** | Agente propone desde **catálogo por lenguaje** en `harness.example.json`; humano aprueba. |

## Riesgo conocido aceptado

**"Todo bloquea" + "todas las categorías" + brownfield = harness rojo el día 1.**
En un proyecto heredado con deuda (código muerto real, funciones complejas, deps
vulnerables), un gate estricto-total falla en el primer PR. La red de seguridad
es que el agente **propone** y el humano **aprueba** el set de checks: en
brownfield se puede arrancar aprobando menos checks (o varios como `warn`) e ir
subiendo. Mitigación estructural (baseline/ratchet) → fase 2.

## Esquema (`harness.json`)

```json
"checks": [
  {"name": "lint",       "cmd": "ruff check .",      "severity": "block"},
  {"name": "typecheck",  "cmd": "mypy src",          "severity": "block"},
  {"name": "deadcode",   "cmd": "vulture src",       "severity": "block"},
  {"name": "complexity", "cmd": "radon cc -n C src", "severity": "block"},
  {"name": "security",   "cmd": "pip-audit",         "severity": "block"}
]
```

El campo `severity` se mantiene para poder relajar a `warn` en fase 2; en fase 1
todo es `block`.

## Categorías → herramientas concretas (catálogo)

| Categoría | Python | Node/TS | Go | Rust |
|-----------|--------|---------|-----|------|
| Lint/format | ruff | eslint+prettier | gofmt+go vet | clippy+rustfmt |
| Typecheck | mypy | tsc | (compilador) | (compilador) |
| Código muerto | vulture | ts-prune | staticcheck | cargo-machete |
| Complejidad/dup | radon/lizard | jscpd | gocyclo | — |
| Seguridad | pip-audit | npm audit | govulncheck | cargo-audit |

## Artefactos a construir

1. `harness.json`: esquema `checks[]` (nombre + comando + severidad).
2. `harness.example.json`: catálogo por lenguaje (categoría → herramienta + hint
   de instalación).
3. `init.sh`: runner que itera `checks`, corre cada uno con `[OK]/[FAIL]` por
   check, y bloquea (`EXIT_CODE=1`) si alguno falla.
4. `ci.yml` / `ci.setup`: el setup ahora instala también los linters, no solo las
   deps de test.
5. Onboarding (explorer brownfield / greenfield): proponer el set de checks desde
   el catálogo según el stack → aprobación humana.
6. Docs: documentar el sistema de checks en `docs/verification.md`.

## Decisiones abiertas (fase de spec)

- **Brownfield estricto** → ¿baseline/ratchet (fallar solo en violaciones
  *nuevas*)? Fase 2.
- **Integración** suele necesitar servicios (DB/docker) → fase 1 solo comando;
  servicios fase 2.
- **Rendimiento**: 8 checks en cada `init.sh` local puede ser lento → ¿split
  rápido-local / completo-CI? Choca un poco con "espejo puro".
- **Instalación de herramientas**: el catálogo debe emparejar cada tool con su
  comando de install (para `ci.setup`).

## Frontera de fases

- **Fase 1 (esta tanda):** checks declarativos, todo bloquea, catálogo +
  onboarding, un comando por check, espejo vía `init.sh`.
- **Fase 2 (aparcada):** severidad por-check relajable, baseline/ratchet para
  brownfield, servicios de integración, split rápido/completo.
