cmake_minimum_required(VERSION 3.20)
if(POLICY CMP0167)
  cmake_policy(SET CMP0167 NEW)
endif()
project(crusader CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Debug)
endif()

add_compile_options(-Wall -Wextra)

if(NOT ANDROID)
  enable_testing()
endif()

# Apagado por defecto para no obligar a nadie que solo quiera trabajar en
# core/ (cripto+almacenamiento) a tener Qt6 instalado -- se activa a mano
# con -DCRUSADER_BUILD_APP=ON, o lo hace build_mobile.sh automaticamente
# para el build de Android.
option(CRUSADER_BUILD_APP "Compilar la app Qt Quick (escritorio o Android)" OFF)

add_subdirectory(core)

if(CRUSADER_BUILD_APP)
  add_subdirectory(app)
endif()
