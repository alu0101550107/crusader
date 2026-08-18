#pragma once

#include <optional>
#include <string>
#include <vector>

#include "crusader/PasswordEntry.hpp"

namespace crusader {

// Cifra entries con masterPassword y (sobre)escribe path por completo: cada
// guardado genera una sal y un nonce nuevos, asi que el archivo resultante
// es autocontenido -- no hace falta leer el archivo anterior para guardar.
bool saveVault(const std::string& path, const std::string& masterPassword,
               const std::vector<PasswordEntry>& entries);

// Lee y descifra path. Devuelve std::nullopt si el archivo no existe, no
// tiene el formato esperado, o masterPassword es incorrecta.
std::optional<std::vector<PasswordEntry>> loadVault(const std::string& path,
                                                      const std::string& masterPassword);

}  // namespace crusader
