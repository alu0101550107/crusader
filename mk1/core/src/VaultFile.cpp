#include "crusader/VaultFile.hpp"

#include <cstdint>
#include <cstring>
#include <fstream>

#include <nlohmann/json.hpp>

#include "crusader/VaultCrypto.hpp"

namespace crusader {

namespace {

constexpr char kMagic[4] = {'C', 'R', 'S', 'V'};
constexpr std::uint16_t kFormatVersion = 1;

template <typename T>
void writeRaw(std::ofstream& out, const T& value) {
  out.write(reinterpret_cast<const char*>(&value), sizeof(value));
}

template <typename T>
bool readRaw(std::ifstream& in, T& value) {
  in.read(reinterpret_cast<char*>(&value), sizeof(value));
  return static_cast<bool>(in);
}

}  // namespace

bool saveVault(const std::string& path, const std::string& masterPassword,
               const std::vector<PasswordEntry>& entries) {
  const std::uint64_t opslimit = crypto_pwhash_OPSLIMIT_INTERACTIVE;
  const std::uint64_t memlimit = crypto_pwhash_MEMLIMIT_INTERACTIVE;
  const std::uint32_t alg = crypto_pwhash_ALG_ARGON2ID13;

  Salt salt = generateSalt();
  Key key = deriveKey(masterPassword, salt, opslimit, memlimit, alg);

  nlohmann::json root;
  root["entries"] = entries;
  std::string plaintextJson = root.dump();
  Bytes plaintext(plaintextJson.begin(), plaintextJson.end());
  Bytes encrypted = encrypt(plaintext, key);

  std::ofstream out(path, std::ios::binary | std::ios::trunc);
  if (!out) return false;

  out.write(kMagic, sizeof(kMagic));
  writeRaw(out, kFormatVersion);
  writeRaw(out, opslimit);
  writeRaw(out, memlimit);
  writeRaw(out, alg);
  out.write(reinterpret_cast<const char*>(salt.data()),
            static_cast<std::streamsize>(salt.size()));
  out.write(reinterpret_cast<const char*>(encrypted.data()),
            static_cast<std::streamsize>(encrypted.size()));

  return static_cast<bool>(out);
}

std::optional<std::vector<PasswordEntry>> loadVault(const std::string& path,
                                                      const std::string& masterPassword) {
  std::ifstream in(path, std::ios::binary);
  if (!in) return std::nullopt;

  char magic[4];
  in.read(magic, sizeof(magic));
  if (!in || std::memcmp(magic, kMagic, sizeof(kMagic)) != 0) return std::nullopt;

  std::uint16_t version = 0;
  std::uint64_t opslimit = 0;
  std::uint64_t memlimit = 0;
  std::uint32_t alg = 0;
  Salt salt;
  if (!readRaw(in, version) || version != kFormatVersion) return std::nullopt;
  if (!readRaw(in, opslimit) || !readRaw(in, memlimit) || !readRaw(in, alg)) return std::nullopt;
  in.read(reinterpret_cast<char*>(salt.data()), static_cast<std::streamsize>(salt.size()));
  if (!in) return std::nullopt;

  Bytes encrypted((std::istreambuf_iterator<char>(in)), std::istreambuf_iterator<char>());

  Key key = deriveKey(masterPassword, salt, opslimit, memlimit, static_cast<int>(alg));
  std::optional<Bytes> plaintext = decrypt(encrypted, key);
  if (!plaintext.has_value()) return std::nullopt;

  try {
    nlohmann::json root = nlohmann::json::parse(*plaintext);
    return root.at("entries").get<std::vector<PasswordEntry>>();
  } catch (const nlohmann::json::exception&) {
    return std::nullopt;
  }
}

}  // namespace crusader
