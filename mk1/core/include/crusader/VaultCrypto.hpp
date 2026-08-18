#pragma once

#include <array>
#include <cstdint>
#include <optional>
#include <string>
#include <vector>

#include <sodium.h>

namespace crusader {

using Bytes = std::vector<unsigned char>;

inline constexpr std::size_t kKeyBytes = crypto_aead_chacha20poly1305_ietf_KEYBYTES;
inline constexpr std::size_t kNonceBytes = crypto_aead_chacha20poly1305_ietf_NPUBBYTES;
inline constexpr std::size_t kSaltBytes = crypto_pwhash_SALTBYTES;

using Key = std::array<unsigned char, kKeyBytes>;
using Salt = std::array<unsigned char, kSaltBytes>;

// Inicializa libsodium. Hay que llamarla una vez al arrancar la app, antes
// de usar cualquier otra funcion de este fichero.
bool init();

// Sal aleatoria nueva para una boveda nueva. Se guarda junto al archivo
// cifrado -- no es secreta.
Salt generateSalt();

// Deriva la clave de cifrado a partir de la contraseña maestra y la sal,
// usando Argon2id. La contraseña maestra en si nunca se guarda en disco.
//
// opslimit/memlimit/alg tienen valores por defecto, pero VaultFile los
// guarda explicitamente en cada archivo y los vuelve a pasar aqui al leer
// -- asi el dia que estos valores por defecto cambien (para endurecerlos),
// las bovedas ya creadas se siguen pudiendo abrir con los parametros con
// los que se cifraron de verdad.
Key deriveKey(const std::string& masterPassword, const Salt& salt,
              std::uint64_t opslimit = crypto_pwhash_OPSLIMIT_INTERACTIVE,
              std::size_t memlimit = crypto_pwhash_MEMLIMIT_INTERACTIVE,
              int alg = crypto_pwhash_ALG_ARGON2ID13);

// Cifra plaintext con ChaCha20-Poly1305. Genera un nonce aleatorio nuevo en
// cada llamada y lo antepone al resultado: devuelve nonce || ciphertext+tag.
Bytes encrypt(const Bytes& plaintext, const Key& key);

// Descifra el resultado de encrypt(). Devuelve std::nullopt si la
// contraseña maestra es incorrecta o los datos estan corruptos/manipulados
// (el tag de autenticacion no valida).
std::optional<Bytes> decrypt(const Bytes& nonceAndCiphertext, const Key& key);

}  // namespace crusader
