# Crusader

Gestor de contraseñas local para Android (y escritorio Linux para desarrollo), escrito en C++/Qt 6. Sin servidor, sin red: la bóveda es un único archivo cifrado que vive en el almacenamiento privado de la app.

## Cripto

- **ChaCha20-Poly1305** (AEAD) para cifrar la bóveda completa.
- **Argon2id** para derivar la clave de cifrado a partir de la contraseña maestra. Los parámetros (opslimit/memlimit) se guardan en cada archivo, así endurecerlos en el futuro no rompe las bóvedas ya creadas.
- CSPRNG de **libsodium** para sales, nonces, ids de entrada y el generador de contraseñas.

Todo esto vive en `core/`, sin ninguna dependencia de Qt — se puede compilar y testear solo, sin la interfaz.

## Estructura

```
core/     Cripto + almacenamiento (VaultCrypto, VaultFile, PasswordEntry, PasswordGenerator)
app/      Interfaz Qt Quick/QML (VaultController expone core/ a QML)
third_party/
  libsodium-android/   libsodium precompilado para Android arm64-v8a
  nlohmann_json/       JSON for Modern C++ (vendorizado, header-only)
```

## Compilar

**Núcleo (sin Qt, escritorio):**
```bash
cmake -S . -B build
cmake --build build
ctest --test-dir build --output-on-failure
```

**App completa (requiere Qt6, `find_package` la resuelve por pkg-config en escritorio):**
```bash
cmake -S . -B build -DCRUSADER_BUILD_APP=ON
cmake --build build
./build/app/crusader_app
```

**Android** (requiere Qt para Android, Android SDK/NDK, JDK 17 -- ver `build_mobile.sh`):
```bash
./build_mobile.sh              # compila y genera el APK
./build_mobile.sh --install    # + lo instala en un dispositivo conectado por adb
```
