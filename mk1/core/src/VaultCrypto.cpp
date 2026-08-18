#include "crusader/VaultCrypto.hpp"

#include <stdexcept>

namespace crusader {

bool init() { return sodium_init() >= 0; }

Salt generateSalt() {
  Salt salt;
  randombytes_buf(salt.data(), salt.size());
  return salt;
}

Key deriveKey(const std::string& masterPassword, const Salt& salt,
              std::uint64_t opslimit, std::size_t memlimit, int alg) {
  Key key;
  int rc = crypto_pwhash(key.data(), key.size(), masterPassword.data(),
                          masterPassword.size(), salt.data(), opslimit,
                          memlimit, alg);
  if (rc != 0) {
    throw std::runtime_error("crypto_pwhash: memoria insuficiente para derivar la clave");
  }
  return key;
}

Bytes encrypt(const Bytes& plaintext, const Key& key) {
  Bytes out(kNonceBytes + plaintext.size() + crypto_aead_chacha20poly1305_ietf_ABYTES);
  unsigned char* nonce = out.data();
  unsigned char* ciphertext = out.data() + kNonceBytes;
  unsigned long long ciphertextLen = 0;

  randombytes_buf(nonce, kNonceBytes);

  crypto_aead_chacha20poly1305_ietf_encrypt(
      ciphertext, &ciphertextLen, plaintext.data(), plaintext.size(),
      nullptr, 0, nullptr, nonce, key.data());

  out.resize(kNonceBytes + ciphertextLen);
  return out;
}

std::optional<Bytes> decrypt(const Bytes& nonceAndCiphertext, const Key& key) {
  if (nonceAndCiphertext.size() < kNonceBytes + crypto_aead_chacha20poly1305_ietf_ABYTES) {
    return std::nullopt;
  }

  const unsigned char* nonce = nonceAndCiphertext.data();
  const unsigned char* ciphertext = nonceAndCiphertext.data() + kNonceBytes;
  unsigned long long ciphertextLen = nonceAndCiphertext.size() - kNonceBytes;

  Bytes plaintext(ciphertextLen - crypto_aead_chacha20poly1305_ietf_ABYTES);
  unsigned long long plaintextLen = 0;

  int rc = crypto_aead_chacha20poly1305_ietf_decrypt(
      plaintext.data(), &plaintextLen, nullptr, ciphertext, ciphertextLen,
      nullptr, 0, nonce, key.data());
  if (rc != 0) {
    return std::nullopt;
  }

  plaintext.resize(plaintextLen);
  return plaintext;
}

}  // namespace crusader
