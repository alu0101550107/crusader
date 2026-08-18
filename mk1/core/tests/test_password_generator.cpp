#include <cctype>
#include <iostream>
#include <stdexcept>
#include <string>

#include "crusader/PasswordGenerator.hpp"

using namespace crusader;

namespace {

void check(bool cond, const char* what) {
  if (!cond) throw std::runtime_error(std::string("FALLO: ") + what);
}

void testLengthIsRespected() {
  PasswordGeneratorOptions options;
  options.length = 24;
  std::string password = generatePassword(options);
  check(password.size() == 24, "la contraseña deberia tener la longitud pedida");
}

void testOnlyDigits() {
  PasswordGeneratorOptions options;
  options.length = 32;
  options.useUpper = false;
  options.useLower = false;
  options.useDigits = true;
  options.useSymbols = false;

  std::string password = generatePassword(options);
  for (char c : password) {
    check(std::isdigit(static_cast<unsigned char>(c)) != 0,
          "con solo digitos activados, todos los caracteres deberian ser digitos");
  }
}

void testOnlyUpper() {
  PasswordGeneratorOptions options;
  options.length = 32;
  options.useUpper = true;
  options.useLower = false;
  options.useDigits = false;
  options.useSymbols = false;

  std::string password = generatePassword(options);
  for (char c : password) {
    check(std::isupper(static_cast<unsigned char>(c)) != 0,
          "con solo mayusculas activadas, todos los caracteres deberian ser mayusculas");
  }
}

void testTwoPasswordsDiffer() {
  PasswordGeneratorOptions options;
  options.length = 20;
  check(generatePassword(options) != generatePassword(options),
        "dos llamadas deberian dar contraseñas distintas (con probabilidad abrumadora)");
}

void testRejectsZeroLength() {
  PasswordGeneratorOptions options;
  options.length = 0;
  bool threw = false;
  try {
    generatePassword(options);
  } catch (const std::invalid_argument&) {
    threw = true;
  }
  check(threw, "length == 0 deberia lanzar std::invalid_argument");
}

void testRejectsEmptyAlphabet() {
  PasswordGeneratorOptions options;
  options.useUpper = false;
  options.useLower = false;
  options.useDigits = false;
  options.useSymbols = false;
  bool threw = false;
  try {
    generatePassword(options);
  } catch (const std::invalid_argument&) {
    threw = true;
  }
  check(threw, "sin categorias activadas deberia lanzar std::invalid_argument");
}

}  // namespace

int main() {
  try {
    testLengthIsRespected();
    testOnlyDigits();
    testOnlyUpper();
    testTwoPasswordsDiffer();
    testRejectsZeroLength();
    testRejectsEmptyAlphabet();
  } catch (const std::exception& e) {
    std::cerr << e.what() << std::endl;
    return 1;
  }

  std::cout << "OK: todos los tests de PasswordGenerator pasaron" << std::endl;
  return 0;
}
