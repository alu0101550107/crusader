#include <iostream>
#include <stdexcept>
#include <string>

#include "crusader/VaultCrypto.hpp"

using namespace crusader;

namespace {

void check(bool cond, const char* what) {
  if (!cond) throw std::runtime_error(std::string("FALLO: ") + what);
}

void testRoundTrip() {
  Salt salt = generateSalt();
  Key key = deriveKey("contraseña maestra de prueba", salt);

  Bytes plaintext = {'h', 'o', 'l', 'a'};
  Bytes ciphertext = encrypt(plaintext, key);

  auto decrypted = decrypt(ciphertext, key);
  check(decrypted.has_value(), "decrypt() deberia tener exito con la clave correcta");
  check(*decrypted == plaintext, "el texto descifrado deberia coincidir con el original");
}

void testWrongPassword() {
  Salt salt = generateSalt();
  Key correctKey = deriveKey("contraseña correcta", salt);
  Key wrongKey = deriveKey("otra contraseña", salt);

  Bytes ciphertext = encrypt({'s', 'e', 'c', 'r', 'e', 't', 'o'}, correctKey);

  auto decrypted = decrypt(ciphertext, wrongKey);
  check(!decrypted.has_value(), "decrypt() deberia fallar con la clave incorrecta");
}

void testTamperedCiphertextIsRejected() {
  Salt salt = generateSalt();
  Key key = deriveKey("contraseña", salt);

  Bytes ciphertext = encrypt({'d', 'a', 't', 'o', 's'}, key);
  ciphertext.back() ^= 0xFF;  // corrompe el ultimo byte (dentro del tag de Poly1305)

  auto decrypted = decrypt(ciphertext, key);
  check(!decrypted.has_value(), "decrypt() deberia rechazar datos manipulados");
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
    testTamperedCiphertextIsRejected();
  } catch (const std::exception& e) {
    std::cerr << e.what() << std::endl;
    return 1;
  }

  std::cout << "OK: todos los tests de VaultCrypto pasaron" << std::endl;
  return 0;
}
