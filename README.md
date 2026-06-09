<p align="center">
  <img src="assets/maestro-banner.png" alt="Maestro" width="420">
</p>

<h1 align="center">Maestro</h1>

<p align="center">
  <b>Spec-Driven Agent Orchestration Framework</b><br>
  Un arnés (<i>harness</i>) para Claude Code que hace que los agentes de IA trabajen de forma
  <b>autónoma, verificable y disciplinada</b> sobre cualquier proyecto.
</p>

<p align="center">
  <a href="https://github.com/BlackSheep4/Maestro/wiki"><b>📖 Documentación completa (Wiki)</b></a>
</p>

---

## ¿Qué es Maestro?

**Maestro** no es una aplicación: es una **capa de control y orquestación** que envuelve a
los agentes de IA para que dejen de improvisar y empiecen a trabajar como un equipo
disciplinado. Se apoya en cuatro pilares:

1. **El repositorio ES el sistema de control.** El estado vive en disco y en Git
   (`AGENTS.md`, `feature_list.json`, `progress/`, `docs/`), nunca en el chat ni en la
   memoria del agente.
2. **Orquestación multi-agente con roles separados.** Cuatro subagentes con restricciones
   asimétricas: `leader` (orquesta, no codifica), `spec_author` (escribe specs, no toca
   código), `implementer` (ejecuta, no se autoaprueba), `reviewer` (verifica, no edita).
3. **Spec Driven Development (SDD).** Flujo `pending → spec_ready → in_progress → done` con
   una puerta de aprobación humana obligatoria y requirements en notación EARS antes de
   tocar código.
4. **Verificación ejecutable.** `init.sh` como árbitro objetivo, trazabilidad
   `R<n> → test` obligatoria, y hooks que ejecutan los tests tras cada edición.

Es **políglota**: el stack (lenguaje, comando de tests, rutas) vive en `harness.json`, así
que sirve igual para Python, Node, Go o Rust. No impone Node a tu proyecto — el CLI es
bash puro y lee JSON con `jq` o `python3`.

## Instalación

```bash
curl -fsSL https://raw.githubusercontent.com/BlackSheep4/Maestro/harness-sdd-uncle-bob/install.sh | bash
```

El instalador coloca el CLI `maestro` y los ficheros del harness en `~/.maestro/` y añade
`~/.maestro/bin` a tu `PATH` (editando tu `~/.zshrc` o `~/.bashrc`, sin `sudo`). Abre una
terminal nueva (o `source` tu rc) y ya tienes el comando `maestro`.

> **Requisitos:** `bash`, `git`/`curl`, y `jq` **o** `python3` (cualquiera de los dos).

**Variables de entorno del instalador:**

| Variable            | Por defecto              | Para qué |
|---------------------|--------------------------|----------|
| `MAESTRO_HOME`      | `~/.maestro`             | Dónde instalar |
| `MAESTRO_REF`       | `harness-sdd-uncle-bob`  | Rama/tag/sha del repo a instalar |
| `MAESTRO_REPO`      | `BlackSheep4/Maestro`    | `owner/repo` de origen |
| `MAESTRO_LOCAL_SRC` | —                        | Instala desde un clon local en vez de descargar |

## Inicio rápido

```bash
cd mi-proyecto       # nuevo o existente
maestro init         # instala el harness aquí (detecta greenfield/brownfield)
claude               # abre Claude Code: el agente completa el onboarding
```

`maestro init` despliega el andamiaje pero **no** genera `harness.json` ni hace onboarding:
eso lo hace el agente de Claude Code en la primera sesión. El CLI prepara el terreno; el
agente lo configura.

## Comandos

| Comando            | Qué hace |
|--------------------|----------|
| `maestro`          | Sin argumentos, muestra la ayuda |
| `maestro init`     | Instala el harness en el directorio actual (no pisa tu código; detecta greenfield/brownfield) |
| `maestro status`   | Tabla de features con color por estado (`done`/`in_progress`/`pending`/`blocked`/`spec_ready`) |
| `maestro check`    | Ejecuta `./init.sh` y propaga su exit code (apto para CI) |
| `maestro upgrade`  | Actualiza el harness preservando tu contenido (regiones `HARNESS:FILL`); nunca toca `feature_list.json`, `harness.json` ni `progress/` |
| `maestro version`  | Muestra la versión instalada |
| `maestro help`     | Muestra la ayuda |

### Actualizar a una versión nueva

```bash
# 1. Refresca el CLI y los templates en ~/.maestro
curl -fsSL https://raw.githubusercontent.com/BlackSheep4/Maestro/harness-sdd-uncle-bob/install.sh | bash
# 2. Aplica la actualización en tu proyecto (preserva tus HARNESS:FILL)
cd mi-proyecto && maestro upgrade
```

## Cómo funciona

Tras `maestro init` y el onboarding, le pides a Claude Code: **«implementa la siguiente
feature pendiente»**. El flujo ocurre en dos fases con una puerta de aprobación humana:

```
pending → [spec_author] → spec_ready → ⏸ HUMANO APRUEBA → in_progress → [implementer → reviewer] → done
```

1. **Spec.** El `leader` lanza al `spec_author`, que escribe
   `specs/<feature>/{requirements,design,tasks}.md` (requirements en EARS) y **para** a
   esperar tu aprobación.
2. **Código.** Tras tu «aprobado», el `implementer` ejecuta las tasks una a una y el
   `reviewer` verifica la trazabilidad `R<n> ↔ test`. Si aprueba, el `leader` marca la
   feature `done`.

Todo el rastro vive en disco (`specs/`, `progress/`), no en el chat — sobrevive a
reinicios y context windows reventadas.

👉 **La explicación detallada de cada pieza está en la [Wiki](https://github.com/BlackSheep4/Maestro/wiki):**
arquitectura, los cinco agentes, el flujo SDD, los ficheros y artefactos, y la referencia
completa del CLI.

## Licencia

MIT
