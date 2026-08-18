#include <iostream>
#include <stdexcept>
#include <string>

#include <nlohmann/json.hpp>

#include "crusader/PasswordEntry.hpp"

using namespace crusader;

namespace {

void check(bool cond, const char* what) {
  if (!cond) throw std::runtime_error(std::string("FALLO: ") + what);
}

void testMakeEntryFillsIdAndTimestamps() {
  PasswordEntry entry = makeEntry("Ubisoft", "jugador123", "s3cr3t!");
  check(!entry.id.empty(), "makeEntry deberia generar un id");
  check(entry.id.size() == 32, "el id deberia ser 16 bytes en hexadecimal (32 caracteres)");
  check(entry.createdAt == entry.updatedAt, "createdAt y updatedAt deberian coincidir al crear");
  check(entry.name == "Ubisoft", "el nombre deberia guardarse tal cual");
}

void testTwoEntriesGetDifferentIds() {
  PasswordEntry a = makeEntry("A", "", "x");
  PasswordEntry b = makeEntry("B", "", "y");
  check(a.id != b.id, "dos entradas distintas deberian tener ids distintos");
}

void testTouchUpdatesTimestamp() {
  PasswordEntry entry = makeEntry("Ubisoft", "jugador123", "vieja");
  std::string createdAt = entry.createdAt;
  entry.password = "nueva";
  touch(entry);
  check(entry.createdAt == createdAt, "touch() no deberia tocar createdAt");
  check(!entry.updatedAt.empty(), "touch() deberia dejar updatedAt relleno");
}

void testJsonRoundTrip() {
  PasswordEntry original = makeEntry("Ubisoft", "jugador123", "s3cr3t!", "https://ubisoft.com", "cuenta principal");

  nlohmann::json j = original;
  PasswordEntry restored = j.get<PasswordEntry>();

  check(restored.id == original.id, "id deberia sobrevivir al viaje por JSON");
  check(restored.name == original.name, "name deberia sobrevivir al viaje por JSON");
  check(restored.username == original.username, "username deberia sobrevivir al viaje por JSON");
  check(restored.password == original.password, "password deberia sobrevivir al viaje por JSON");
  check(restored.url == original.url, "url deberia sobrevivir al viaje por JSON");
  check(restored.notes == original.notes, "notes deberia sobrevivir al viaje por JSON");
}

}  // namespace

int main() {
  try {
    testMakeEntryFillsIdAndTimestamps();
    testTwoEntriesGetDifferentIds();
    testTouchUpdatesTimestamp();
    testJsonRoundTrip();
  } catch (const std::exception& e) {
    std::cerr << e.what() << std::endl;
    return 1;
  }

  std::cout << "OK: todos los tests de PasswordEntry pasaron" << std::endl;
  return 0;
}
