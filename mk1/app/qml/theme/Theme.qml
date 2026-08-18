pragma Singleton
import QtQuick
import Qt.labs.settings

// Paleta compartida por toda la interfaz. Ya no son "readonly": se pueden
// cambiar en caliente desde SettingsPage.qml, y quedan guardadas entre
// arranques via Qt.labs.settings (equivalente QML de QSettings -- mismo
// mecanismo que usa templar::client::Theme, pero sin necesitar C++ para
// nada, ya que aqui solo son colores sueltos, no toda una hoja de estilos
// QSS). Es una preferencia del dispositivo, no de la boveda -- se guarda
// sin cifrar, separada por completo de core/ (que es lo unico que toca
// datos sensibles).
Item {
    readonly property color defaultBackground: "#0a0a0a"
    readonly property color defaultForeground: "#d8d8d8"
    readonly property color defaultAccent: "#33ff33"
    readonly property string defaultFontFamily: "JetBrains Mono"

    property alias background: settings.background
    property alias foreground: settings.foreground
    property alias accent: settings.accent
    property alias fontFamily: settings.fontFamily

    function resetToDefaults() {
        background = defaultBackground;
        foreground = defaultForeground;
        accent = defaultAccent;
        fontFamily = defaultFontFamily;
    }

    Settings {
        id: settings
        category: "Theme"
        property color background: defaultBackground
        property color foreground: defaultForeground
        property color accent: defaultAccent
        property string fontFamily: defaultFontFamily
    }
}
