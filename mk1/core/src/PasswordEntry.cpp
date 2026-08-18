#include "crusader/PasswordEntry.hpp"

#include <ctime>
#include <utility>

#include <sodium.h>

namespace crusader {

void to_json(nlohmann::json& j, const PasswordEntry& entry) {
  j = nlohmann::json{
      {"id", entry.id},
      {"name", entry.name},
      {"username", entry.username},
      {"password", entry.password},
      {"url", entry.url},
      {"notes", entry.notes},
      {"createdAt", entry.createdAt},
      {"updatedAt", entry.updatedAt},
  };
}

void from_json(const nlohmann::json& j, PasswordEntry& entry) {
  j.at("id").get_to(entry.id);
  j.at("name").get_to(entry.name);
  j.at("username").get_to(entry.username);
  j.at("password").get_to(entry.password);
  j.at("url").get_to(entry.url);
  j.at("notes").get_to(entry.notes);
  j.at("createdAt").get_to(entry.createdAt);
  j.at("updatedAt").get_to(entry.updatedAt);
}

std::string generateEntryId() {
  unsigned char raw[16];
  randombytes_buf(raw, sizeof(raw));
  char hex[sizeof(raw) * 2 + 1];
  sodium_bin2hex(hex, sizeof(hex), raw, sizeof(raw));
  return std::string(hex);
}

std::string currentTimestamp() {
  std::time_t now = std::time(nullptr);
  std::tm utc{};
  gmtime_r(&now, &utc);
  char buf[32];
  std::strftime(buf, sizeof(buf), "%Y-%m-%dT%H:%M:%SZ", &utc);
  return std::string(buf);
}

PasswordEntry makeEntry(std::string name, std::string username, std::string password,
                         std::string url, std::string notes) {
  PasswordEntry entry;
  entry.id = generateEntryId();
  entry.name = std::move(name);
  entry.username = std::move(username);
  entry.password = std::move(password);
  entry.url = std::move(url);
  entry.notes = std::move(notes);
  entry.createdAt = currentTimestamp();
  entry.updatedAt = entry.createdAt;
  return entry;
}

void touch(PasswordEntry& entry) { entry.updatedAt = currentTimestamp(); }

}  // namespace crusader
