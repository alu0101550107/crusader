import QtQuick
import QtQuick.Controls
import Crusader

ApplicationWindow {
    id: window

    readonly property bool isMobilePlatform: Qt.platform.os === "android" || Qt.platform.os === "ios"

    readonly property real minWindowWidth: 320
    readonly property real maxWindowWidth: 480
    readonly property real phoneAspectRatio: 19.5 / 9

    width: isMobilePlatform ? undefined : Math.max(minWindowWidth, Math.min(maxWindowWidth, Screen.desktopAvailableWidth * 0.28))
    height: isMobilePlatform ? undefined : Math.min(Screen.desktopAvailableHeight * 0.85, width * phoneAspectRatio)

    minimumWidth: isMobilePlatform ? undefined : width
    maximumWidth: isMobilePlatform ? undefined : width
    minimumHeight: isMobilePlatform ? undefined : height
    maximumHeight: isMobilePlatform ? undefined : height

    readonly property real referenceWidth: 400
    readonly property real scaleFactor: Math.max(0.85, Math.min(1.3, width / referenceWidth))

    visible: true
    title: "Crusader"
    color: Theme.background

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: vault.vaultExists ? "LoginPage.qml" : "SetupPage.qml"

        // Fade simple en vez del slide completo por defecto -- se aplica a
        // push()/pop()/replace() de cualquier pagina, porque estas
        // propiedades viven en el StackView, no en cada Page.
        pushEnter: Transition {
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 220
                easing.type: Easing.OutCubic
            }
        }
        pushExit: Transition {
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 220
                easing.type: Easing.InCubic
            }
        }
        popEnter: Transition {
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 220
                easing.type: Easing.OutCubic
            }
        }
        popExit: Transition {
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 220
                easing.type: Easing.InCubic
            }
        }
        replaceEnter: Transition {
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 220
                easing.type: Easing.OutCubic
            }
        }
        replaceExit: Transition {
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 220
                easing.type: Easing.InCubic
            }
        }
    }
}
