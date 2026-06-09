# Verificación — Cómo demostrar que el trabajo funciona

> Regla de oro: **el agente no dice "funciona", lo demuestra**.
> Toda feature termina con evidencia ejecutable, no con afirmaciones.

<!-- HARNESS:REQUIRED — no modificar: los agentes dependen de esta sección -->

## La regla de oro

El agente **no dice "funciona", lo demuestra**. Toda feature termina con
evidencia ejecutable (tests verdes, salida real del programa), nunca con una
afirmación de que "debería funcionar".

## Niveles de verificación (concepto)

### Nivel 1 — Tests unitarios (obligatorio)

Toda función pública en el código de la aplicación tiene al menos un test que:

1. Cubre el camino feliz.
2. Cubre al menos un camino de error si la función puede fallar.

### Nivel 2 — Test de integración (obligatorio para features de interfaz)

Las features que añaden una superficie de usuario (comando CLI, endpoint de
API, etc.) se verifican ejecutando la aplicación **real** contra un recurso
temporal y aislado (un archivo temporal, una base de datos efímera), no contra
mocks del mundo exterior.

### Nivel 3 — Smoke test end-to-end (opcional pero recomendado)

Antes de cerrar la sesión, ejecuta un flujo completo de principio a fin contra
un recurso temporal y límpialo al terminar.

### Nivel 4 — Trazabilidad de requirements (obligatorio para features con `"sdd": true`)

Cada `R<n>` de `specs/<name>/requirements.md` debe poder mapearse a al
menos un test concreto. El `reviewer` rechaza si falta cobertura.

El `implementer` documenta el mapa en `progress/impl_<name>.md`:

```markdown
## Trazabilidad
- R1 → `test_<feature>_<caso_feliz>`
- R2 → `test_<feature>_<caso_error>`
- R3 → `test_<feature>_<caso_alternativo>`
```

## Anti-patrones (no hacer)

- ❌ "He añadido el comando, debería funcionar." → falta test ejecutable.
- ❌ Test que solo verifica que la función no lanza excepción. → tiene que
  comprobar el resultado concreto.
- ❌ Mockear el filesystem / la red en lugar de usar un recurso temporal real.
- ❌ Marcar la feature como `done` sin pasar `./init.sh`.

## Verificación final antes de cerrar

```bash
./init.sh           # debe terminar en verde
```

Si `./init.sh` está rojo, **no** marques nada como `done`. Anota el bloqueo
en `progress/current.md` con estado `blocked` en `feature_list.json`.

<!-- /HARNESS:REQUIRED -->

<!-- HARNESS:FILL — rellena esto con los comandos concretos de TU proyecto. Borra las instrucciones entre corchetes y sustitúyelas por los comandos reales de tu stack. Si un agente encuentra esta sección con los placeholders sin rellenar, debe preguntar al humano lo necesario y completarla antes de declarar trabajo como verificado. -->

## Comando de tests unitarios (Nivel 1)

[El comando exacto que ejecuta la suite de tests de TU proyecto. Ejemplos:

 - Python (unittest): `python3 -m unittest discover -s tests -v`
 - Python (pytest):   `pytest -q`
 - Node:              `npm test`
 - Go:                `go test ./...`

 Sustituye por el comando real de TU proyecto.]

## Test de integración (Nivel 2)

[Un ejemplo de test de integración real usando el stack de TU proyecto: arranca
 la aplicación real contra un recurso temporal y comprueba la salida. Ejemplos:

 CLI en Python:
 ```python
 import subprocess, tempfile, os
 with tempfile.TemporaryDirectory() as d:
     env = {**os.environ, "NOTES_FILE": os.path.join(d, "notes.json")}
     out = subprocess.check_output(
         ["python3", "-m", "src.cli", "add", "hola", "--body", "mundo"],
         env=env, text=True,
     )
     assert "id=" in out
 ```

 API web (pytest + httpx):
 ```python
 def test_create_note(client):
     resp = client.post("/notes", json={"title": "hola", "body": "mundo"})
     assert resp.status_code == 201
     assert resp.json()["id"]
 ```

 Sustituye por un test de integración real de TU stack.]

## Smoke test end-to-end (Nivel 3)

[El comando o secuencia que ejercita TU proyecto de principio a fin contra un
 recurso temporal. Ejemplo:

 ```bash
 NOTES_FILE=/tmp/notes_demo.json python3 -m src.cli add "test" --body "x"
 NOTES_FILE=/tmp/notes_demo.json python3 -m src.cli list
 rm /tmp/notes_demo.json
 ```

 Sustituye por el flujo end-to-end real de TU proyecto.]

<!-- /HARNESS:FILL -->
