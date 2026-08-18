# Capa de conexion entre core/ (cripto+almacenamiento, sin Qt) y la
# interfaz Qt Quick/QML. Solo se compila con -DCRUSADER_BUILD_APP=ON (ver
# CMakeLists.txt raiz) para no obligar a tener Qt6 instalado solo para
# trabajar en core/.

set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2)

# Sin esta llamada, qt6_add_qml_module no deja el modulo QML en un estado
# que Android pueda resolver en tiempo de ejecucion (ver el mismo problema,
# ya diagnosticado, en templar/mk3/phone/CMakeLists.txt).
qt_standard_project_setup(REQUIRES 6.5)

if(POLICY QTP0001)
  qt_policy(SET QTP0001 NEW)
endif()

qt6_add_executable(crusader_app
  src/main.cpp
  src/VaultController.cpp
  src/PasswordEntryListModel.cpp
)
target_link_libraries(crusader_app PRIVATE
  crusader_core
  Qt6::Quick
  Qt6::QuickControls2
)

if(ANDROID)
  # Manifest propio (android/AndroidManifest.xml) en vez del que genera Qt
  # por defecto -- solo para fijar el package id y el nombre visible de la
  # app. A diferencia de Templar, no hace falta una Activity propia (sin
  # camara/JNI) ni empaquetar OpenSSL (la app no usa red en absoluto).
  set_target_properties(crusader_app PROPERTIES
    QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android"
    QT_ANDROID_TARGET_SDK_VERSION 34
  )
endif()

# El "pragma Singleton" dentro de Theme.qml no basta por si solo -- sin
# esta propiedad, qt6_add_qml_module lo trata como un tipo instanciable
# normal (genera "Theme 1.0 qml/theme/Theme.qml" en el qmldir en vez de
# "singleton Theme 1.0 qml/theme/Theme.qml"), y Theme.background fallaria en
# tiempo de ejecucion.
set_source_files_properties(qml/theme/Theme.qml PROPERTIES QT_QML_SINGLETON_TYPE true)

qt6_add_qml_module(crusader_app
  URI Crusader
  VERSION 1.0
  QML_FILES
    qml/Main.qml
    qml/LoginPage.qml
    qml/SetupPage.qml
    qml/EntriesPage.qml
    qml/AddEntryPage.qml
    qml/EntryDetailPage.qml
    qml/SettingsPage.qml
    qml/ColorPickerDialog.qml
    qml/theme/Theme.qml
  RESOURCES
    qml/assets/crusader_icon.png
    qml/assets/crusader_phone_background.png
    qml/assets/crusader_phone_background_blurred.png
)
