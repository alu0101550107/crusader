#pragma once

#include <string>

#include <nlohmann/json.hpp>

namespace crusader {

struct PasswordEntry {
  std::string id;
  std::string name;
  std::string username;
  std::string password;
  std::string url;
  std::string notes;
  std::string createdAt;
  std::string updatedAt;
};

void to_json(nlohmann::json& j, const PasswordEntry& entry);
void from_json(const nlohmann::json& j, PasswordEntry& entry);

// Id aleatorio (128 bits, en hexadecimal) para una entrada nueva. Usa el
// mismo CSPRNG de libsodium que ya usamos para sales y nonces.
std::string generateEntryId();

// Marca temporal actual en UTC, formato ISO 8601.
std::string currentTimestamp();

// Crea una entrada nueva con id y marcas de tiempo ya rellenados.
PasswordEntry makeEntry(std::string name, std::string username, std::string password,
                         std::string url = "", std::string notes = "");

// Actualiza updatedAt a la hora actual (llamar tras modificar una entrada).
void touch(PasswordEntry& entry);

}  // namespace crusader
