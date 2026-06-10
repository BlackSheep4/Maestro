#!/usr/bin/env bash
# install.sh — instalador de Maestro (uso: curl -fsSL .../install.sh | bash)
#
# Descarga el harness y el CLI `maestro` a ~/.maestro y pone `maestro` en el
# PATH. No requiere Node: el CLI es bash puro y lee JSON con jq o python3.
#
# Variables de entorno:
#   MAESTRO_HOME       destino (por defecto ~/.maestro)
#   MAESTRO_REF        rama/tag/sha del repo a instalar (por defecto, el último tag estable)
#   MAESTRO_REPO       owner/repo (por defecto BlackSheep4/Maestro)
#   MAESTRO_LOCAL_SRC  instala desde un clon local del harness en vez de descargar
#   MAESTRO_SUBDIR     subdirectorio del repo donde vive el harness (por defecto la raíz)

set -eu

MAESTRO_REPO="${MAESTRO_REPO:-BlackSheep4/Maestro}"
# NOTA: este valor lo actualiza automáticamente .github/workflows/release.yml
# en cada release. No lo edites a mano salvo que sepas lo que haces.
MAESTRO_REF="${MAESTRO_REF:-v1.0.0}"
MAESTRO_HOME="${MAESTRO_HOME:-$HOME/.maestro}"
# Subdirectorio del repo donde vive el harness. Vacío = raíz del repo.
SUBDIR="${MAESTRO_SUBDIR:-}"

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; CYAN=$'\033[0;36m'; YELLOW=$'\033[0;33m'; BOLD=$'\033[1m'; NC=$'\033[0m'
else
  GREEN=''; RED=''; CYAN=''; YELLOW=''; BOLD=''; NC=''
fi
ok()   { printf '%s✅ %s%s\n' "$GREEN" "$1" "$NC"; }
err()  { printf '%s❌ %s%s\n' "$RED" "$1" "$NC" >&2; }
info() { printf '%sℹ %s%s\n'  "$CYAN" "$1" "$NC"; }

# Ficheros que componen el harness (los que `maestro init` desplegará).
# El script `maestro` y este install.sh NO van aquí: son herramienta, no harness.
HARNESS_FILES="
AGENTS.md
CLAUDE.md
CHECKPOINTS.md
init.sh
harness.example.json
feature_list.json
docs/architecture.md
docs/conventions.md
docs/specs.md
docs/verification.md
.claude/settings.json
.claude/agents/leader.md
.claude/agents/spec_author.md
.claude/agents/implementer.md
.claude/agents/reviewer.md
.claude/agents/explorer.md
.claude/hooks/after_edit.sh
.claude/hooks/before_stop.sh
progress/current.md
"

download() { # <url> <dest>
  if command -v curl >/dev/null 2>&1; then curl -fsSL "$1" -o "$2"
  elif command -v wget >/dev/null 2>&1; then wget -qO "$2" "$1"
  else err "Necesito 'curl' o 'wget' para descargar Maestro."; exit 1; fi
}

# ── 1. Obtener el origen (descarga o fuente local) ──
TMP=""
cleanup() { [ -n "$TMP" ] && rm -rf "$TMP"; }
trap cleanup EXIT

if [ -n "${MAESTRO_LOCAL_SRC:-}" ]; then
  SRC="$MAESTRO_LOCAL_SRC"
  info "Instalando desde fuente local: $SRC"
else
  command -v tar >/dev/null 2>&1 || { err "Necesito 'tar' para descomprimir Maestro."; exit 1; }
  TMP="$(mktemp -d)"
  info "Descargando Maestro ($MAESTRO_REPO@$MAESTRO_REF)…"
  download "https://codeload.github.com/$MAESTRO_REPO/tar.gz/$MAESTRO_REF" "$TMP/maestro.tar.gz"
  tar -xzf "$TMP/maestro.tar.gz" -C "$TMP"
  SRC=""
  for d in "$TMP"/*/; do
    if [ -n "$SUBDIR" ]; then SRC="${d%/}/$SUBDIR"; else SRC="${d%/}"; fi
    break
  done
fi

[ -d "$SRC" ] || { err "No encuentro el harness en '$SRC'."; exit 1; }
[ -f "$SRC/maestro" ] || { err "No encuentro el script 'maestro' en '$SRC'."; exit 1; }

# ── 2. Instalar en MAESTRO_HOME ──
info "Instalando en $MAESTRO_HOME …"
mkdir -p "$MAESTRO_HOME/bin" "$MAESTRO_HOME/templates"
cp "$SRC/maestro" "$MAESTRO_HOME/bin/maestro"
chmod +x "$MAESTRO_HOME/bin/maestro"

missing=0
for rel in $HARNESS_FILES; do
  if [ ! -f "$SRC/$rel" ]; then err "Falta en el origen: $rel"; missing=1; continue; fi
  mkdir -p "$MAESTRO_HOME/templates/$(dirname "$rel")"
  cp "$SRC/$rel" "$MAESTRO_HOME/templates/$rel"
done
[ "$missing" -eq 0 ] || { err "El origen está incompleto; abortando."; exit 1; }

chmod +x "$MAESTRO_HOME/templates/init.sh" 2>/dev/null || true
chmod +x "$MAESTRO_HOME/templates/.claude/hooks/"*.sh 2>/dev/null || true

# ── 3. Poner maestro en el PATH (editar el rc del shell) ──
BIN_DIR="$MAESTRO_HOME/bin"
case "${SHELL:-}" in
  */zsh)  RC="$HOME/.zshrc" ;;
  */bash) RC="$HOME/.bashrc" ;;
  *)      RC="$HOME/.profile" ;;
esac

PATH_LINE="export PATH=\"$BIN_DIR:\$PATH\""
ON_PATH=0
case ":$PATH:" in *":$BIN_DIR:"*) ON_PATH=1 ;; esac

RC_EDITED=0
if [ "$ON_PATH" -eq 0 ]; then
  if [ -f "$RC" ] && grep -qF "$BIN_DIR" "$RC"; then
    :  # ya referenciado en el rc
  else
    printf '\n# Maestro harness\n%s\n' "$PATH_LINE" >> "$RC"
    RC_EDITED=1
  fi
fi

# ── 4. Resumen ──
echo
ok "Maestro instalado en $MAESTRO_HOME"
echo
if [ "$ON_PATH" -eq 1 ]; then
  echo "${BOLD}maestro${NC} ya está en tu PATH. Pruébalo:"
  echo "  maestro"
elif [ "$RC_EDITED" -eq 1 ]; then
  echo "Se añadió $BIN_DIR a tu PATH en ${BOLD}$RC${NC}."
  echo "Abre una terminal nueva, o ejecútalo ahora con:"
  echo "  ${BOLD}source $RC${NC}"
  echo "Después, prueba:"
  echo "  maestro"
else
  echo "Añade esta línea a tu shell rc para usar ${BOLD}maestro${NC}:"
  echo "  $PATH_LINE"
fi
echo
echo "Para instalar el harness en un proyecto: cd a tu proyecto y ejecuta 'maestro init'."
