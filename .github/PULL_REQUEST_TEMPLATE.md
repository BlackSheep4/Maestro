## Qué hace este PR

<!-- Descripción breve de los cambios -->

## Tipo de cambio

- [ ] PATCH — fix o corrección sin cambios estructurales
- [ ] MINOR — nueva funcionalidad compatible
- [ ] MAJOR — cambio que rompe compatibilidad

## Checklist

- [ ] El CI pasa localmente (`bash -n maestro && bash -n install.sh && bash -n init.sh`)
- [ ] Si es MINOR o MAJOR: `MAESTRO_VERSION` en el script `maestro` está actualizado
- [ ] Si es MINOR o MAJOR: `CHANGELOG.md` tiene la entrada correspondiente
- [ ] Si es MAJOR: `CHANGELOG.md` incluye guía de migración en `### Breaking Changes`
- [ ] Si se añaden ficheros al harness: están incluidos en la lista `HARNESS_FILES` de `install.sh`
- [ ] Si se añaden/modifican marcadores `HARNESS:FILL`: `maestro upgrade` sigue funcionando correctamente
