add_library(crusader_core STATIC
  src/VaultCrypto.cpp
  src/PasswordEntry.cpp
  src/VaultFile.cpp
  src/PasswordGenerator.cpp
)
target_include_directories(crusader_core PUBLIC include)

# nlohmann/json es de solo cabecera -- se vendoriza el .hpp en third_party/
# para usar la misma version en escritorio y en Android sin depender de que
# el sysroot de Android tenga el paquete del sistema (no lo tiene).
add_library(nlohmann_json INTERFACE)
target_include_directories(nlohmann_json INTERFACE
  ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/nlohmann_json/include)
target_link_libraries(crusader_core PUBLIC nlohmann_json)

if(ANDROID)
  # No hay libsodium del sistema para Android -- se usa el precompilado en
  # third_party/ (mismo build que ya se usaba en el proyecto Templar, NDK
  # r27c). Solo arm64-v8a por ahora: es la unica ABI que necesitamos porque
  # las pruebas se hacen contra un movil fisico, no el emulador.
  set(_sodium_root "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/libsodium-android/${CMAKE_ANDROID_ARCH_ABI}")
  if(NOT EXISTS "${_sodium_root}/lib/libsodium.a")
    message(FATAL_ERROR
      "No se encuentra libsodium precompilado para ${CMAKE_ANDROID_ARCH_ABI} en "
      "${_sodium_root}.")
  endif()
  add_library(crusader_sodium STATIC IMPORTED)
  set_target_properties(crusader_sodium PROPERTIES
    IMPORTED_LOCATION "${_sodium_root}/lib/libsodium.a"
    INTERFACE_INCLUDE_DIRECTORIES "${_sodium_root}/include"
  )
  target_link_libraries(crusader_core PUBLIC crusader_sodium)
else()
  find_package(PkgConfig REQUIRED)
  pkg_check_modules(SODIUM REQUIRED IMPORTED_TARGET libsodium)
  target_link_libraries(crusader_core PUBLIC PkgConfig::SODIUM)
endif()

if(NOT ANDROID)
  add_executable(crusader_core_tests
    tests/test_vault_crypto.cpp
  )
  target_link_libraries(crusader_core_tests PRIVATE crusader_core)
  add_test(NAME vault_crypto_tests COMMAND crusader_core_tests)

  add_executable(crusader_password_entry_tests
    tests/test_password_entry.cpp
  )
  target_link_libraries(crusader_password_entry_tests PRIVATE crusader_core)
  add_test(NAME password_entry_tests COMMAND crusader_password_entry_tests)

  add_executable(crusader_vault_file_tests
    tests/test_vault_file.cpp
  )
  target_link_libraries(crusader_vault_file_tests PRIVATE crusader_core)
  add_test(NAME vault_file_tests COMMAND crusader_vault_file_tests)

  add_executable(crusader_password_generator_tests
    tests/test_password_generator.cpp
  )
  target_link_libraries(crusader_password_generator_tests PRIVATE crusader_core)
  add_test(NAME password_generator_tests COMMAND crusader_password_generator_tests)
endif()
