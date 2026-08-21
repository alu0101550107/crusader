import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Crusader

Page {
    id: page

    background: Rectangle {
        color: Theme.background
    }

    header: ToolBar {
        background: Rectangle {
            color: Theme.background
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 12

            Label {
                text: "AJUSTES:"
                font.family: Theme.fontFamily
                font.bold: true
                font.letterSpacing: 2
                font.pixelSize: 16 * Window.window.scaleFactor
                color: Theme.foreground
                Layout.fillWidth: true
            }

            ToolButton {
                implicitWidth: 36 * Window.window.scaleFactor
                implicitHeight: implicitWidth
                background: Item {}
                contentItem: Text {
                    text: "<"
                    color: Theme.foreground
                    opacity: 0.7
                    font.pixelSize: 18 * Window.window.scaleFactor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: page.StackView.view.pop()
            }
        }
    }

    // Instancia unica compartida por las tres filas -- editingProperty dice
    // a onAccepted en cual de las tres propiedades de Theme escribir.
    ColorPickerDialog {
        id: colorPicker
        property string editingProperty: ""
        onAccepted: {
            if (editingProperty === "background")
                Theme.background = pickedColor;
            else if (editingProperty === "foreground")
                Theme.foreground = pickedColor;
            else if (editingProperty === "accent")
                Theme.accent = pickedColor;
        }
    }

    // Se pide la contraseña maestra antes de activar la huella porque
    // BiometricBridge.enable() necesita cifrarla con la clave del
    // Keystore -- ver BiometricHelper.java.
    Dialog {
        id: biometricPasswordDialog
        modal: true
        anchors.centerIn: parent
        width: Math.min(parent ? parent.width - 40 : 300, 300)

        background: Rectangle {
            color: Theme.background
            border.color: Theme.accent
            border.width: 1
            radius: 4
        }

        header: Label {
            text: "Confirma tu contraseña maestra"
            color: Theme.accent
            font.bold: true
            font.family: Theme.fontFamily
            wrapMode: Text.WordWrap
            padding: 12
        }

        contentItem: TextField {
            id: biometricPasswordField
            placeholderText: "Contraseña maestra"
            echoMode: TextInput.Password
            font.family: Theme.fontFamily
            color: Theme.foreground
            background: Rectangle {
                color: "#161616"
                border.color: biometricPasswordField.activeFocus ? Theme.accent : "#333333"
                border.width: 1
                radius: 4
            }
        }

        footer: RowLayout {
            width: biometricPasswordDialog.width
            spacing: 8

            Button {
                text: "Cancelar"
                Layout.fillWidth: true
                Layout.margins: 8
                onClicked: biometricPasswordDialog.reject()
            }
            Button {
                text: "Confirmar"
                Layout.fillWidth: true
                Layout.margins: 8
                onClicked: biometricPasswordDialog.accept()
            }
        }

        onAccepted: {
            biometric.enable(biometricPasswordField.text);
            biometricPasswordField.text = "";
        }
        onRejected: biometricPasswordField.text = ""
        onOpened: biometricPasswordField.forceActiveFocus()
    }

    Connections {
        target: biometric
        function onEnableFinished(success, errorMessage) {
            if (!success)
                biometricErrorLabel.text = errorMessage;
        }
    }

    component ColorRow: RowLayout {
        property string label: ""
        property color swatchColor: "white"
        property string propertyName: ""
        Layout.fillWidth: true

        Label {
            text: label
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: 13 * Window.window.scaleFactor
            Layout.fillWidth: true
        }

        Rectangle {
            width: 40 * Window.window.scaleFactor
            height: 28 * Window.window.scaleFactor
            radius: 4
            color: swatchColor
            border.color: "#444444"
            border.width: 1

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    colorPicker.editingProperty = propertyName;
                    colorPicker.pickedColor = swatchColor;
                    colorPicker.open();
                }
            }
        }
    }

    ColumnLayout {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 24 * Window.window.scaleFactor
        width: Math.min(parent.width * 0.85, 340)
        spacing: 20 * Window.window.scaleFactor

        Label {
            text: "COLORES"
            color: Theme.accent
            font.family: Theme.fontFamily
            font.bold: true
            font.pixelSize: 12 * Window.window.scaleFactor
        }

        ColorRow {
            label: "Fondo"
            swatchColor: Theme.background
            propertyName: "background"
        }
        ColorRow {
            label: "Texto"
            swatchColor: Theme.foreground
            propertyName: "foreground"
        }
        ColorRow {
            label: "Acento"
            swatchColor: Theme.accent
            propertyName: "accent"
        }

        Button {
            id: resetButton
            text: "RESTAURAR VALORES POR DEFECTO"
            Layout.fillWidth: true
            Layout.topMargin: 12 * Window.window.scaleFactor
            onClicked: Theme.resetToDefaults()

            contentItem: Text {
                text: resetButton.text
                font.family: Theme.fontFamily
                font.pixelSize: 11 * Window.window.scaleFactor
                color: Theme.foreground
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                color: resetButton.pressed ? "#1c1c1c" : "transparent"
                border.color: "#444444"
                border.width: 1
                radius: 4
            }
        }

        // Oculto por completo si no hay hardware/huellas registradas (o en
        // escritorio, donde biometric.available siempre es false -- ver
        // BiometricBridge.cpp).
        Label {
            text: "SEGURIDAD"
            visible: biometric.available
            color: Theme.accent
            font.family: Theme.fontFamily
            font.bold: true
            font.pixelSize: 12 * Window.window.scaleFactor
            Layout.topMargin: 8 * Window.window.scaleFactor
        }

        RowLayout {
            visible: biometric.available
            Layout.fillWidth: true

            Label {
                text: "Desbloqueo con huella"
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: 13 * Window.window.scaleFactor
                Layout.fillWidth: true
            }

            Switch {
                id: biometricSwitch
                checked: biometric.enabled
                onClicked: {
                    // El clic ya cambio "checked" localmente y rompio el
                    // binding -- se restaura de inmediato para que el
                    // interruptor siempre refleje biometric.enabled de
                    // verdad, y la accion de activar/desactivar depende
                    // del estado anterior, no del visual a medio cambiar.
                    var wasEnabled = biometric.enabled;
                    checked = Qt.binding(function () {
                        return biometric.enabled;
                    });
                    if (wasEnabled)
                        biometric.disable();
                    else
                        biometricPasswordDialog.open();
                }
            }
        }

        Label {
            id: biometricErrorLabel
            visible: text.length > 0
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            color: "#ff5555"
            font.family: Theme.fontFamily
            font.pixelSize: 12 * Window.window.scaleFactor
        }
    }
}
