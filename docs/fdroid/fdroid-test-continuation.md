# F-Droid: test de la receta — estado y continuación

> Creado el 15/08/2026 antes de dormir. Resumen de dónde quedamos y cómo
> continuar mañana.

## Qué está hecho ✅

- **Receta** validada con `fdroid readmeta` (exit 0):
  `retropod/fdroid/com.rchrdariza.retropod.yml`
- **Build reproducible** verificado dos veces con Flutter 3.44.9, SHA-256:
  `46eddb0a485fb814c06a5b08ed613de08df34073445dc85e6b14dff5b83d30b1`
  (guardado en `docs/fdroid/reference-build-1.13.0.sha256`)
- **fdroidserver 2.4.2 instalado** en `/home/richard/fdroidserver` (venv en
  `env/`), instalado desde git (modo oficial F-Droid), no AUR.

## Entorno de test configurado

El repo de prueba está en `/tmp/opencode/fdroid-test`:

- `fdroid init` ejecutado (genera `config.yml` con `sdk_path: $ANDROID_HOME`,
  `keystore.p12` temporal, `keyalias`=cachyosrzx).
- `metadata/com.rchrdariza.retropod.yml` copiado desde el repo de RetroPod.
- `srclibs/flutter.yml` agregado (definición oficial de fdroiddata:
  `RepoType: git`, `Repo: https://github.com/flutter/flutter.git`).
- El repo de test tiene `.git` con la metadata y config commiteadas
  (fdroid necesita git para `SOURCE_DATE_EPOCH`).

### Fixes del entorno que hicieron falta

1. **`pkg_resources` roto**: `setuptools` 84 en el venv no incluye
   `pkg_resources`. Se corrigió con:
   `/home/richard/fdroidserver/env/bin/pip install "setuptools<81"`
2. **`SOURCE_DATE_EPOCH: None`** en el primer `fdroid build`: faltaba git en
   el repo de prueba → `git init` + commit de metadata/config.
3. **`srclib flutter not found`**: fdroid lee las srclibs del directorio
   `srclibs/*.yml` del repo de fdroiddata; el pip install no lo trae, así que
   se copió la definición oficial de `srclibs/flutter.yml`.

## Dónde quedamos 🔄

- Comando de test ejecutado, **interrumpido a propósito** (descarga de
  Flutter 3.44.9 ~1GB + build completo, tarda ~15-30 min):

```bash
cd /tmp/opencode/fdroid-test
export ANDROID_HOME=/home/richard/Android/Sdk
/home/richard/fdroidserver/env/bin/fdroid build --test --verbose com.rchrdariza.retropod
```

- Antes de interrumpir ya había: clonado RetroPod en `@1974434`,
  checkout del commit, y ahora empezaría a descargar/checkout de la srclib
  flutter@3.44.9 y a ejecutar prebuild + build.

## Para continuar mañana

1. Ejecutar el comando de test de nuevo (desde `/tmp/opencode/fdroid-test`).
   Necesita red (descarga Flutter 3.44.9 y dependencias pub/gradle).
2. Si el build OK, verificar el SHA-256 del APK resultante contra:
   `46eddb0a485fb814c06a5b08ed613de08df34073445dc85e6b14dff5b83d30b1`
   (ojo: fdroid re-firma con su propio keystore, compárese el contenido
   desfirmado si se quiere estricto).
3. Si falla, mirar el log de build; los mantainers de fdroiddata ajustarán el
   resto (p. ej. `sdk_version`, build-tools).

## Después: abrir el request en fdroiddata

- Necesita token de GitLab (Personal Access Token, scope `api`) o abrir el
  issue a mano con el texto preparado.
- URL: https://gitlab.com/fdroid/fdroiddata/-/issues
- El texto del issue debe incluir: app = RetroPod, licencia MIT, repo
  https://github.com/RchrdAriza/RetroPod, la receta
  (`fdroid/com.rchrdariza.retropod.yml`), el checksum de referencia, y las
  notas de `/home/richard/RetroPod/docs/fdroid/submission.md`.

## Riesgos de review recordados

- La app pide desactivar optimización de batería (dep git
  `disable_battery_optimization`).
- Icons Flaticon: posible anti-feature `NonFreeAssets`.
- APK ~89 MB: valorar `--split-per-abi` tras la inclusión.