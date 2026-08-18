#include "crusader/PasswordGenerator.hpp"

#include <cstdint>
#include <stdexcept>

#include <sodium.h>

namespace crusader {

namespace {

constexpr const char* kUpper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
constexpr const char* kLower = "abcdefghijklmnopqrstuvwxyz";
constexpr const char* kDigits = "0123456789";
constexpr const char* kSymbols = "!@#$%^&*()-_=+[]{}<>?";

}  // namespace

std::string generatePassword(const PasswordGeneratorOptions& options) {
  if (options.length == 0) {
    throw std::invalid_argument("la longitud debe ser mayor que 0");
  }

  std::string alphabet;
  if (options.useUpper) alphabet += kUpper;
  if (options.useLower) alphabet += kLower;
  if (options.useDigits) alphabet += kDigits;
  if (options.useSymbols) alphabet += kSymbols;

  if (alphabet.empty()) {
    throw std::invalid_argument("hay que activar al menos una categoria de caracteres");
  }

  std::string password;
  password.reserve(options.length);
  for (std::size_t i = 0; i < options.length; ++i) {
    // randombytes_uniform (no "% alphabet.size()") evita el sesgo de
    // modulo: con un modulo simple, algunos caracteres del alfabeto
    // saldrian ligeramente mas probables que otros.
    std::uint32_t index = randombytes_uniform(static_cast<std::uint32_t>(alphabet.size()));
    password += alphabet[index];
  }
  return password;
}

}  // namespace crusader
