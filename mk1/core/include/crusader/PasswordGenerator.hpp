#pragma once

#include <cstddef>
#include <string>

namespace crusader {

struct PasswordGeneratorOptions {
  std::size_t length = 16;
  bool useUpper = true;
  bool useLower = true;
  bool useDigits = true;
  bool useSymbols = true;
};

// Genera una contraseña aleatoria, muestreando uniformemente el alfabeto
// pedido en options con el CSPRNG de libsodium.
//
// Lanza std::invalid_argument si length es 0, o si no se activa ninguna
// categoria de caracteres (no habria de donde elegir).
std::string generatePassword(const PasswordGeneratorOptions& options);

}  // namespace crusader
