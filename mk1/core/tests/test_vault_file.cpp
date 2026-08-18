#include <cstdio>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <stdexcept>
#include <string>

#include "crusader/PasswordEntry.hpp"
#include "crusader/VaultCrypto.hpp"
#include "crusader/VaultFile.hpp"

using namespace crusader;

namespace {

void check(bool cond, const char* what) {
  if (!cond) throw std::runtime_error(std::string("FALLO: ") + what);
}

std::string tempVaultPath() {
  return (std::filesystem::temp_directory_path() / "crusader_test_vault.bin").string();
}

void testRoundTrip() {
  std::string path = tempVaultPath();
  std::vector<PasswordEntry> entries = {
      makeEntry("Ubisoft", "jugador123", "s3cr3t!"),
      makeEntry("GitHub", "yo@example.com", "otra-clave", "https://github.com"),
  };

  check(saveVault(path, "contraseña maestra", entries), "saveVault deberia tener exito");

  auto loaded = loadVault(path, "contraseña maestra");
  check(loaded.has_value(), "loadVault deberia tener exito con la contraseña correcta");
  check(loaded->size() == entries.size(), "deberian recuperarse todas las entradas");
  check((*loaded)[0].name == "Ubisoft", "la primera entrada deberia ser Ubisoft");
  check((*loaded)[1].url == "https://github.com", "los campos opcionales deberian sobrevivir");

  std::remove(path.c_str());
}

void testWrongPassword() {
  std::string path = tempVaultPath();
  saveVault(path, "correcta", {makeEntry("A", "", "x")});

  auto loaded = loadVault(path, "incorrecta");
  check(!loaded.has_value(), "loadVault deberia fallar con la contraseña incorrecta");

  std::remove(path.c_str());
}

void testMissingFile() {
  auto loaded = loadVault("/ruta/que/no/existe/crusader.vault", "cualquiera");
  check(!loaded.has_value(), "loadVault deberia devolver nullopt si el archivo no existe");
}

void testCorruptedFile() {
  std::string path = tempVaultPath();
  saveVault(path, "contraseña", {makeEntry("A", "", "x")});

  // Corrompe un byte dentro del blob cifrado (despues de la cabecera).
  std::fstream f(path, std::ios::binary | std::ios::in | std::ios::out);
  f.seekp(0, std::ios::end);
  auto size = f.tellp();
  f.seekp(size - static_cast<std::streamoff>(1));
  f.put('\x00');
  f.close();

  auto loaded = loadVault(path, "contraseña");
  check(!loaded.has_value(), "loadVault deberia rechazar un archivo manipulado");

  std::remove(path.c_str());
}

}  // namespace

int main() {
  if (!init()) {
    std::cerr << "No se pudo inicializar libsodium" << std::endl;
    return 1;
  }

  try {
    testRoundTrip();
    testWrongPassword();
    testMissingFile();
    testCorruptedFile();
  } catch (const std::exception& e) {
    std::cerr << e.what() << std::endl;
    return 1;
  }

  std::cout << "OK: todos los tests de VaultFile pasaron" << std::endl;
  return 0;
}
