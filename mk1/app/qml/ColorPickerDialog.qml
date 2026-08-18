import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Crusader

// Selector de color propio -- deliberadamente NO usa ColorDialog
// (QtQuick.Dialogs): ese componente no expone background/contentItem para
// re-estilarlo, y forzarlo habria significado adoptar un estilo Qt Quick
// Controls global que rompe el aspecto ya afinado del resto de la app
// (TextField/Button con background propio en cada pagina). Con deslizadores
// RGB simples, el aspecto entero lo controlamos nosotros.
Dialog {
    id: picker
    modal: true
    anchors.centerIn: parent
    width: Math.min(parent ? parent.width - 40 : 300, 300)

    // Color de entrada/salida: se fija antes de abrir y se lee tras aceptar
    // (ver SettingsPage.qml).
    property color pickedColor: "white"

    // Copia de trabajo que mueven los deslizadores -- pickedColor no
    // cambia hasta pulsar "Aceptar", para poder cancelar sin dejar rastro.
    property real r: 1
    property real g: 1
    property real b: 1

    onOpened: {
        r = pickedColor.r;
        g = pickedColor.g;
        b = pickedColor.b;
    }

    onAccepted: pickedColor = Qt.rgba(r, g, b, 1.0)

    background: Rectangle {
        color: Theme.background
        border.color: Theme.accent
        border.width: 1
        radius: 4
    }

    header: Label {
        text: "Elegir color"
        color: Theme.accent
        font.bold: true
        font.family: Theme.fontFamily
        padding: 12
    }

    footer: RowLayout {
        width: picker.width
        spacing: 8

        Button {
            id: cancelButton
            text: "Cancelar"
            Layout.fillWidth: true
            Layout.margins: 8
            onClicked: picker.reject()
            contentItem: Text {
                text: cancelButton.text
                color: Theme.foreground
                font.family: Theme.fontFamily
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                color: "transparent"
                border.color: "#444444"
                border.width: 1
                radius: 4
            }
        }
        Button {
            id: acceptButton
            text: "Aceptar"
            Layout.fillWidth: true
            Layout.margins: 8
            onClicked: picker.accept()
            contentItem: Text {
                text: acceptButton.text
                color: Theme.background
                font.family: Theme.fontFamily
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                color: Theme.accent
                radius: 4
            }
        }
    }

    ColumnLayout {
        width: picker.availableWidth
        spacing: 10 * Window.window.scaleFactor

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40 * Window.window.scaleFactor
            radius: 4
            color: Qt.rgba(picker.r, picker.g, picker.b, 1.0)
            border.color: Theme.accent
            border.width: 1
        }

        RowLayout {
            Layout.fillWidth: true
            Label {
                text: "R"
                color: Theme.foreground
                font.family: Theme.fontFamily
            }
            Slider {
                from: 0
                to: 1
                value: picker.r
                Layout.fillWidth: true
                onMoved: picker.r = value
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Label {
                text: "G"
                color: Theme.foreground
                font.family: Theme.fontFamily
            }
            Slider {
                from: 0
                to: 1
                value: picker.g
                Layout.fillWidth: true
                onMoved: picker.g = value
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Label {
                text: "B"
                color: Theme.foreground
                font.family: Theme.fontFamily
            }
            Slider {
                from: 0
                to: 1
                value: picker.b
                Layout.fillWidth: true
                onMoved: picker.b = value
            }
        }
    }
}
