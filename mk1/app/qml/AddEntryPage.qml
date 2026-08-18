import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Crusader

Page {
    id: page
    title: editingEntryId.length > 0 ? "Editar" : "Nuevo"

    // No vacio => venimos de EntryDetailPage.qml editando una entrada
    // existente: page.StackView.view.push("AddEntryPage.qml", { editingEntryId: id })
    property string editingEntryId: ""

    Component.onCompleted: {
        if (editingEntryId.length === 0)
            return;
        var details = vault.entryDetails(editingEntryId);
        nameField.text = details.name;
        usernameField.text = details.username;
        passwordField.text = details.password;
        urlField.text = details.url;
        notesField.text = details.notes;
    }

    background: Rectangle {
        color: Theme.background

        Image {
            anchors.fill: parent
            source: "assets/crusader_phone_background_blurred.png"
            fillMode: Image.PreserveAspectCrop   // cubre todo sin deformarse
            opacity: 0.28                         // clave: bajo, si no, tapa el texto
        }
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
                text: editingEntryId.length > 0 ? "Editar:" : "Nuevo:"
                font.family: Theme.fontFamily
                font.bold: true
                font.letterSpacing: 2
                font.pixelSize: 16 * Window.window.scaleFactor
                color: Theme.foreground
                Layout.fillWidth: true
            }

            ToolButton {
                id: backButton
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
                onClicked: {
                    page.StackView.view.replace("EntriesPage.qml");
                }
            }
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.85, 340)
        spacing: 16

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Label {
                text: "Nombre:"
                font.family: Theme.fontFamily
                font.pixelSize: 13 * Window.window.scaleFactor
                font.bold: true
                color: Theme.accent
            }

            TextField {
                id: nameField
                Layout.fillWidth: true
                placeholderText: "Nombre de la cuenta"
                font.family: Theme.fontFamily
                color: Theme.foreground
                focus: true
                onTextChanged: errorLabel.text = ""
                background: Rectangle {
                    color: "#161616"
                    border.color: nameField.activeFocus ? Theme.accent : "#333333"
                    border.width: 1
                    radius: 4
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Label {
                text: "Usuario (opcional):"
                font.family: Theme.fontFamily
                font.pixelSize: 13 * Window.window.scaleFactor
                color: Theme.foreground
                opacity: 0.7
            }

            TextField {
                id: usernameField
                Layout.fillWidth: true
                placeholderText: "usuario o email"
                font.family: Theme.fontFamily
                color: Theme.foreground
                background: Rectangle {
                    color: "#161616"
                    border.color: usernameField.activeFocus ? Theme.accent : "#333333"
                    border.width: 1
                    radius: 4
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Label {
                text: "Contraseña:"
                font.family: Theme.fontFamily
                font.pixelSize: 13 * Window.window.scaleFactor
                font.bold: true
                color: Theme.accent
            }

            RowLayout {
                Layout.fillWidth: true

                TextField {
                    id: passwordField
                    Layout.fillWidth: true
                    placeholderText: "Contraseña de la cuenta"
                    font.family: Theme.fontFamily
                    color: Theme.foreground
                    echoMode: showPasswordCheck.checked ? TextInput.Normal : TextInput.Password
                    onTextChanged: errorLabel.text = ""
                    background: Rectangle {
                        color: "#161616"
                        border.color: passwordField.activeFocus ? Theme.accent : "#333333"
                        border.width: 1
                        radius: 4
                    }
                }

                CheckBox {
                    id: showPasswordCheck
                    text: "Mostrar"
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
            }

            // Secundario: outline, no compite visualmente con "Guardar".
            Button {
                id: genSecurePasswButton
                text: "Generar contraseña segura"
                Layout.fillWidth: true
                onClicked: {
                    passwordField.text = vault.generatePassword(20, true, true, true, true);
                    showPasswordCheck.checked = true;
                }

                contentItem: Text {
                    text: genSecurePasswButton.text
                    font.family: Theme.fontFamily
                    font.pixelSize: 12 * Window.window.scaleFactor
                    color: Theme.accent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: genSecurePasswButton.pressed ? "#1c1c1c" : "transparent"
                    border.color: Theme.accent
                    border.width: 1
                    radius: 4
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Label {
                text: "URL (opcional):"
                font.family: Theme.fontFamily
                font.pixelSize: 13 * Window.window.scaleFactor
                color: Theme.foreground
                opacity: 0.7
            }

            TextField {
                id: urlField
                Layout.fillWidth: true
                placeholderText: "https://..."
                font.family: Theme.fontFamily
                color: Theme.foreground
                background: Rectangle {
                    color: "#161616"
                    border.color: urlField.activeFocus ? Theme.accent : "#333333"
                    border.width: 1
                    radius: 4
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Label {
                text: "Notas (opcional):"
                font.family: Theme.fontFamily
                font.pixelSize: 13 * Window.window.scaleFactor
                color: Theme.foreground
                opacity: 0.7
            }

            TextArea {
                id: notesField
                Layout.fillWidth: true
                Layout.preferredHeight: 70 * Window.window.scaleFactor
                placeholderText: "Notas adicionales"
                wrapMode: TextArea.Wrap
                font.family: Theme.fontFamily
                color: Theme.foreground
                background: Rectangle {
                    color: "#161616"
                    border.color: notesField.activeFocus ? Theme.accent : "#333333"
                    border.width: 1
                    radius: 4
                }
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

        // Primario: solido, mismo estilo que DESBLOQUEAR/REGISTRARSE en las
        // otras paginas -- consistencia entre pantallas.
        Button {
            id: saveButton
            text: editingEntryId.length > 0 ? "GUARDAR CAMBIOS" : "GUARDAR"
            Layout.fillWidth: true
            Layout.topMargin: 8
            // Nombre y contraseña son los unicos obligatorios -- el resto
            // de campos son opcionales, no entran en esta condicion.
            enabled: nameField.text.length > 0 && passwordField.text.length > 0
            onClicked: {
                var success = editingEntryId.length > 0 ? vault.updateEntry(editingEntryId, nameField.text, usernameField.text, passwordField.text, urlField.text, notesField.text) : vault.addEntry(nameField.text, usernameField.text, passwordField.text, urlField.text, notesField.text);
                if (success) {
                    page.StackView.view.replace("EntriesPage.qml");
                } else {
                    errorLabel.text = vault.errorMessage;
                }
            }

            contentItem: Text {
                text: saveButton.text
                font.family: Theme.fontFamily
                font.bold: true
                color: Theme.background
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                color: saveButton.pressed ? Qt.darker(Theme.accent, 1.2) : Theme.accent
                radius: 4
                opacity: saveButton.enabled ? 1 : 0.4
            }
        }
    }
}
