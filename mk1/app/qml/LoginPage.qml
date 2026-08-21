import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Crusader

Page {
    id: page
    title: "Crusader"

    // Fondo usando el Singleton
    background: Rectangle {
        color: Theme.background

        Image {
            anchors.fill: parent
            source: "assets/crusader_phone_background.png"
            fillMode: Image.PreserveAspectCrop   // cubre todo sin deformarse
            opacity: 0.28                         // clave: bajo, si no, tapa el texto
        }
    }

    Connections {
        target: biometric
        function onUnlockFinished(success, password, errorMessage) {
            if (success) {
                if (vault.unlock(password)) {
                    page.StackView.view.push("EntriesPage.qml");
                } else {
                    errorLabel.text = vault.errorMessage;
                }
            } else if (errorMessage !== "Cancelado") {
                errorLabel.text = errorMessage;
            }
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.85, 340)
        spacing: 16

        // Título con la tipografía y color de acento
        Label {
            text: "CRUSADER"
            font.family: Theme.fontFamily
            font.pixelSize: 24 * Window.window.scaleFactor
            font.bold: true
            font.letterSpacing: 6
            color: Theme.accent
            Layout.alignment: Qt.AlignHCenter
        }

        // Campo de entrada estilizado
        TextField {
            id: masterPasswordField
            Layout.fillWidth: true
            placeholderText: "Contraseña Maestra"
            font.family: Theme.fontFamily
            color: Theme.foreground
            echoMode: showPasswordCheck.checked ? TextInput.Normal : TextInput.Password
            focus: true
            onTextChanged: errorLabel.text = ""
            background: Rectangle {
                color: "#161616"
                border.color: masterPasswordField.activeFocus ? Theme.accent : "#333333"
                border.width: 1
                radius: 4
            }
        }

        Label {
            id: errorLabel
            color: "#ff5555"
            visible: text.length > 0
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            font.family: Theme.fontFamily
            font.pixelSize: 12 * Window.window.scaleFactor
        }

        CheckBox {
            id: showPasswordCheck
            text: "Mostrar contraseña"
            font.pixelSize: 12 * Window.window.scaleFactor
            font.family: Theme.fontFamily

            // 1. Personalización del texto
            contentItem: Text {
                text: showPasswordCheck.text
                font: showPasswordCheck.font
                color: Theme.accent
                verticalAlignment: Text.AlignVCenter
                leftPadding: showPasswordCheck.indicator.width + showPasswordCheck.spacing
            }

            // 2. Personalización del recuadro y del "check"
            indicator: Rectangle {
                implicitWidth: 16 * Window.window.scaleFactor
                implicitHeight: 16 * Window.window.scaleFactor
                x: showPasswordCheck.leftPadding
                y: parent.height / 2 - height / 2
                radius: 3
                color: "#161616"
                border.color: showPasswordCheck.checked ? Theme.accent : "#444444"

                // Cuadrado interno cuando está marcado
                Rectangle {
                    width: 8 * Window.window.scaleFactor
                    height: 8 * Window.window.scaleFactor
                    anchors.centerIn: parent
                    radius: 1
                    color: Theme.accent
                    visible: showPasswordCheck.checked
                }
            }
        }

        // Botón personalizado con color de acento
        Button {
            id: unlockButton
            text: "DESBLOQUEAR"
            Layout.fillWidth: true
            onClicked: {
                if (vault.unlock(masterPasswordField.text)) {
                    page.StackView.view.push("EntriesPage.qml");
                } else {
                    errorLabel.text = vault.errorMessage;
                }
            }

            contentItem: Text {
                text: unlockButton.text
                font.family: Theme.fontFamily
                font.bold: true
                color: Theme.background // Texto oscuro sobre fondo acento
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                color: unlockButton.pressed ? Qt.darker(Theme.accent, 1.2) : Theme.accent
                radius: 4
            }
        }

        // Secundario: outline, como "Generar contraseña segura" en
        // AddEntryPage.qml -- DESBLOQUEAR sigue siendo la accion principal.
        Button {
            id: biometricButton
            text: "USAR HUELLA"
            Layout.fillWidth: true
            visible: biometric.available && biometric.enabled
            onClicked: biometric.unlock()

            contentItem: Text {
                text: biometricButton.text
                font.family: Theme.fontFamily
                font.pixelSize: 12 * Window.window.scaleFactor
                color: Theme.accent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                color: biometricButton.pressed ? "#1c1c1c" : "transparent"
                border.color: Theme.accent
                border.width: 1
                radius: 4
            }
        }
    }
}
