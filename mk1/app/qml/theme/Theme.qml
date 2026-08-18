pragma Singleton
import QtQuick

// Paleta compartida por toda la interfaz -- mismos valores por defecto que
// templar::client::Theme::defaults() (ver templar/mk3/client/src/Theme.cpp),
// pero sin los campos especificos de chat (ownMessage/peerMessage/
// systemMessage) que aqui no aplican, y sin QSettings: si algun dia hace
// falta una pantalla de Ajustes que permita cambiar el color en caliente,
// basta con quitar "readonly" de estas propiedades.
QtObject {
    readonly property color background: "#0a0a0a"
    readonly property color foreground: "#d8d8d8"
    readonly property color accent: "#33ff33"
    readonly property string fontFamily: "JetBrains Mono"
}
