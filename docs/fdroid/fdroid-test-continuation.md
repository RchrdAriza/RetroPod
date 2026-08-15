# F-Droid: test de la receta — estado y resultados

> Creado el 15/08/2026 antes de dormir. Continuado y resuelto el mismo día:
> el build de test se ejecutó a fondo y la receta quedó validada.

## Resultado final

- **`fdroid build --test --verbose com.rchrdariza.retropod` → `1 build succeeded`**,
  ejecutado dos veces sobre el mismo directorio de build en
  `/tmp/opencode/fdroid-test`.
- **Build reproducible**: los dos APKs desfirmados son byte-idénticos
  (hash del árbol desfirmado =
  `d9b83e767b63d7b19a7fafabd152ae5075dfe995ad49ffcde79831dc273c4306`
  para la receta final; el de `6bbcaf0` fue
  `bfb9308f59603f13c08c3e8040b1f5ab1bea7cf14ccf2e157fe3405cddfff3da`).
- **Corrección importante de la receta**: el build original apuntaba al tag
  `1.13.0` (commit `1974434`), que es **anterior** a todo el trabajo de
  preparación F-Droid: en ese commit la licencia era BSD (ClassiPod) y las
  fuentes Helvetica (propietarias). Tras los hallazgos se creó el tag
  **`1.14.0`** (versionCode 27) en GitHub con todos los arreglos (MIT +
  LiberationSans + sin donate) y la receta referencia ese tag:
  `commit: 1.14.0`. Los commits sueltos `6bbcaf0`/`07c5ed6` no se usan:
  el último no está en el remoto.

## Verify checksum — matiz importante

- El hash del APK de fdroid **no coincide** con el de referencia
  (`46eddb0...`). Causa raíz diagnosticada:
  - `libflutter.so` es **idéntico** y la sección `.text` de `libapp.so`
    también (código máquina reproducible).
  - Difieren `.rodata`, `.eh_frame` y el build-id **solo porque el snapshot
    AOT de Dart embebe la ruta absoluta del checkout**
    (`/home/richard/RetroPod` vs `/tmp/opencode/fdroid-test/build/...`),
    lo que desalinea todos los offsets posteriores.
  - Como F-Droid siempre builda en la misma ruta en su build server, la
    reproducibilidad real (dos builds = mismo APK) se cumple; la comparación
    byte-a-byte con un build local solo es posible si ambos usan el mismo
    directorio.

## Qué está hecho

- Receta validada con `fdroid readmeta` (exit 0):
  `fdroid/com.rchrdariza.retropod.yml`.
- fdroidserver 2.4.2 en `/home/richard/fdroidserver` (venv en `env/`),
  instalado desde git (modo oficial F-Droid).
- Entorno de test en `/tmp/opencode/fdroid-test`:
  - `fdroid init` (keystore.p12 temporal, keyalias cachyosrzx).
  - `metadata/com.rchrdariza.retropod.yml` (ahora con commit `6bbcaf0`).
  - `srclibs/flutter.yml` oficial (`RepoType: git`,
    `Repo: https://github.com/flutter/flutter.git`).
  - Repo con `.git` (necesario para `SOURCE_DATE_EPOCH`).
- Build de prueba ejecutado **dos veces** sobre el commit `6bbcaf0`
  (costó ~4-5 min por build con caches ya calientes en el segundo).

## Fixes del entorno que hicieron falta

1. **`pkg_resources` roto**: setuptools 84 no incluye `pkg_resources`; se
   instaló `setuptools<81` en `/home/richard/fdroidserver/env`.
2. **`SOURCE_DATE_EPOCH: None`**: faltaba git en el repo → `git init` +
   commit de metadata/config.
3. **`srclib flutter not found`**: las srclibs viven fuera del pip install;
   se copió la definición oficial de `srclibs/flutter.yml`.
4. **Checkout fallido con `07c5ed6`**: ese commit no está en GitHub, y fdroid
   clona desde el remoto. Solución: apuntar al commit remoto `6bbcaf0`.

## Próximos pasos

1. Abrir el request en fdroiddata (https://gitlab.com/fdroid/fdroiddata/-/issues)
   con la receta `fdroid/com.rchrdariza.retropod.yml`, el checksum de
   referencia y las notas de `docs/fdroid/submission.md`. Precisa token de
   GitLab (scope `api`) o hacerlo a mano con el texto preparado.

## Hecho en esta sesión (15/08/2026)

- **Tag `1.14.0` creado y publicado** en GitHub
  (release https://github.com/RchrdAriza/RetroPod/releases/tag/1.14.0).
- Receta actualizada a `versionName: 1.14.0`, `versionCode: 27`,
  `commit: 1.14.0`, `CurrentVersion/CurrentVersionCode` sincronizados.
- `fdroid readmeta` OK y dos builds del tag `1.14.0` reproducibles
  (árbol desfirmado `d9b83e76...`, 88.7 MB).
- Nota: hubo dos builds de fdroid compitiendo por el mismo `build/` en
  `/tmp/opencode/fdroid-test` (uno lanzado fuera de la sesión); se mató el
  duplicado y el build final quedó limpio.

## Riesgos de review recordados

- La app pide desactivar optimización de batería (dep git
  `disable_battery_optimization`).
- Icons Flaticon: posible anti-feature `NonFreeAssets`.
- APK ~89 MB: valorar `--split-per-abi` tras la inclusión.