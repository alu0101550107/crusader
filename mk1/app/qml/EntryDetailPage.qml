import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Crusader

Page {
    id: page
    title: "Detalle"

    // Se rellena al hacer push() desde EntriesPage.qml (ver su MouseArea):
    // page.StackView.view.push("EntryDetailPage.qml", { entryId: entryId })
    property string entryId: ""

    // vault.entryDetails() incluye la contraseña en claro -- se pide una
    // sola vez aqui (no en el modelo de la lista) y solo mientras esta
    // pagina esta abierta, igual que ya hacia AddEntryPage.qml al editar.
    property var entry: ({})

    Component.onCompleted: entry = vault.entryDetails(entryId) || {}

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
                text: "Detalle:"
                font.family: Theme.fontFamily
                font.bold: true
                font.letterSpacing: 2
                font.pixelSize: 16 * Window.window.scaleFactor
                color: Theme.foreground
                Layout.fillWidth: true
            }

            ToolButton {
                id: editButton
                implicitWidth: 36 * Window.window.scaleFactor
                implicitHeight: implicitWidth
                background: Item {}
                contentItem: Text {
                    text: "✏️"
                    color: Theme.foreground
                    opacity: 0.7
                    font.pixelSize: 18 * Window.window.scaleFactor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    page.StackView.view.push("AddEntryPage.qml", {
                        editingEntryId: page.entryId
                    });
                }
            }

            ToolButton {
                id: deleteButton
                implicitWidth: 36 * Window.window.scaleFactor
                implicitHeight: implicitWidth
                background: Item {}
                contentItem: Text {
                    text: "🗑️"
                    color: "#ff5555"
                    opacity: 0.85
                    font.pixelSize: 18 * Window.window.scaleFactor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: deleteConfirmDialog.open()
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
                onClicked: page.StackView.view.pop()
            }
        }
    }

    Dialog {
        id: deleteConfirmDialog
        modal: true
        anchors.centerIn: parent
        width: Math.min(parent ? parent.width - 40 : 300, 300)

        background: Rectangle {
            color: Theme.background
            border.color: "#ff5555"
            border.width: 1
            radius: 4
        }

        header: Label {
            text: "¿Eliminar esta entrada?"
            color: "#ff5555"
            font.bold: true
            font.family: Theme.fontFamily
            wrapMode: Text.WordWrap
            padding: 12
        }

        contentItem: Label {
            text: (page.entry.name || "Esta entrada") + " se borrará para siempre. Esta acción no se puede deshacer."
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: 12 * Window.window.scaleFactor
            wrapMode: Text.WordWrap
        }

        footer: RowLayout {
            width: deleteConfirmDialog.width
            spacing: 8

            Button {
                id: cancelDeleteButton
                text: "Cancelar"
                Layout.fillWidth: true
                Layout.margins: 8
                onClicked: deleteConfirmDialog.reject()
                contentItem: Text {
                    text: cancelDeleteButton.text
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
                id: confirmDeleteButton
                text: "Eliminar"
                Layout.fillWidth: true
                Layout.margins: 8
                onClicked: deleteConfirmDialog.accept()
                contentItem: Text {
                    text: confirmDeleteButton.text
                    color: Theme.background
                    font.family: Theme.fontFamily
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: "#ff5555"
                    radius: 4
                }
            }
        }

        onAccepted: {
            // target: null vacia la pila entera -- una vez borrada, no debe
            // quedar la propia pagina de detalle (de una entrada que ya no
            // existe) accesible con el boton "atras".
            if (vault.removeEntry(page.entryId)) {
                page.StackView.view.replace(null, "EntriesPage.qml");
            }
        }
    }

    // Helper invisible para copiar al portapapeles -- QML no tiene una
    // funcion Clipboard.setText() directa, pero cualquier TextEdit sabe
    // copiar su seleccion, asi que se usa uno oculto como intermediario.
    TextEdit {
        id: clipboardHelper
        visible: false
        function copyText(text) {
            clipboardHelper.text = text;
            clipboardHelper.selectAll();
            clipboardHelper.copy();
        }
    }

    // Aviso breve de que la copia funciono -- z alto y ultimo hijo de la
    // Page para quedar por encima de todo lo demas. opacity (no visible a
    // secas) para que el fade de entrada/salida se anime.
    Rectangle {
        id: toast
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 32 * Window.window.scaleFactor
        z: 1000
        radius: 8
        color: "#1c1c1c"
        border.color: Theme.accent
        border.width: 1
        opacity: 0
        visible: opacity > 0
        width: toastLabel.implicitWidth + 32 * Window.window.scaleFactor
        height: toastLabel.implicitHeight + 18 * Window.window.scaleFactor

        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }
        }

        function show(message) {
            toastLabel.text = message;
            opacity = 1;
            toastTimer.restart();
        }

        Timer {
            id: toastTimer
            interval: 1500
            onTriggered: toast.opacity = 0
        }

        Label {
            id: toastLabel
            anchors.centerIn: parent
            color: Theme.accent
            font.family: Theme.fontFamily
            font.pixelSize: 12 * Window.window.scaleFactor
        }
    }

    Pane {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 20 * Window.window.scaleFactor
        width: Math.min(parent.width * 0.9, 380 * Window.window.scaleFactor)

        background: Rectangle {
            color: "#121212"
            border.color: "#262626"
            border.width: 1
            radius: 8
        }

        ColumnLayout {
            width: parent.width
            spacing: 12 * Window.window.scaleFactor

            RowLayout {
                spacing: 10 * Window.window.scaleFactor
                Layout.fillWidth: true

                Rectangle {
                    Layout.preferredWidth: 36 * Window.window.scaleFactor
                    Layout.preferredHeight: Layout.preferredWidth
                    radius: 6
                    color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                    border.color: Theme.accent

                    Label {
                        text: "🔑"
                        anchors.centerIn: parent
                        font.pixelSize: 18 * Window.window.scaleFactor
                    }
                }

                ColumnLayout {
                    spacing: 2
                    Layout.fillWidth: true

                    Label {
                        text: page.entry.name || ""
                        color: Theme.foreground
                        font.family: Theme.fontFamily
                        font.bold: true
                        font.pixelSize: 15 * Window.window.scaleFactor
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                    Label {
                        text: page.entry.url || page.entry.username || ""
                        visible: text.length > 0
                        color: "#777777"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11 * Window.window.scaleFactor
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#222222"
            }

            GroupBox {
                id: dataGroupBox
                title: "DATOS DE ACCESO"
                Layout.fillWidth: true

                label: Label {
                    text: dataGroupBox.title
                    color: Theme.accent
                    font.family: Theme.fontFamily
                    font.pixelSize: 10 * Window.window.scaleFactor
                    font.bold: true
                    leftPadding: 4
                }

                background: Rectangle {
                    color: "transparent"
                    border.color: "#222222"
                    radius: 4
                }

                ColumnLayout {
                    width: parent.width
                    spacing: 8 * Window.window.scaleFactor

                    RowLayout {
                        Layout.fillWidth: true
                        Label {
                            text: "USUARIO:"
                            color: "#888888"
                            font.family: Theme.fontFamily
                            font.pixelSize: 11 * Window.window.scaleFactor
                            Layout.preferredWidth: 70 * Window.window.scaleFactor
                        }
                        Label {
                            text: page.entry.username && page.entry.username.length > 0 ? page.entry.username : "Sin usuario"
                            color: Theme.foreground
                            font.family: Theme.fontFamily
                            font.pixelSize: 12 * Window.window.scaleFactor
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        ToolButton {
                            implicitWidth: 28 * Window.window.scaleFactor
                            implicitHeight: implicitWidth
                            background: Item {}
                            visible: (page.entry.username || "").length > 0
                            contentItem: Text {
                                text: "📋"
                                font.pixelSize: 13 * Window.window.scaleFactor
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                clipboardHelper.copyText(page.entry.username || "");
                                toast.show("Usuario copiado");
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Label {
                            text: "CONTRASEÑA:"
                            color: "#888888"
                            font.family: Theme.fontFamily
                            font.pixelSize: 11 * Window.window.scaleFactor
                            Layout.preferredWidth: 70 * Window.window.scaleFactor
                        }
                        Label {
                            id: passwordLabel
                            text: passwordVisible ? (page.entry.password || "") : "••••••••••••"
                            color: Theme.accent
                            font.family: Theme.fontFamily
                            font.pixelSize: 12 * Window.window.scaleFactor
                            elide: Text.ElideRight
                            Layout.fillWidth: true

                            property bool passwordVisible: false
                        }
                        ToolButton {
                            id: revealButton
                            implicitWidth: 28 * Window.window.scaleFactor
                            implicitHeight: implicitWidth
                            background: Item {}
                            property bool active: false
                            contentItem: Text {
                                text: revealButton.active ? "🙈" : "👁"
                                font.pixelSize: 13 * Window.window.scaleFactor
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                revealButton.active = !revealButton.active;
                                passwordLabel.passwordVisible = revealButton.active;
                            }
                        }
                        ToolButton {
                            implicitWidth: 28 * Window.window.scaleFactor
                            implicitHeight: implicitWidth
                            background: Item {}
                            contentItem: Text {
                                text: "📋"
                                font.pixelSize: 13 * Window.window.scaleFactor
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                clipboardHelper.copyText(page.entry.password || "");
                                toast.show("Contraseña copiada");
                            }
                        }
                    }
                }
            }

            Label {
                text: "NOTAS"
                visible: (page.entry.notes || "").length > 0
                color: "#666666"
                font.family: Theme.fontFamily
                font.pixelSize: 10 * Window.window.scaleFactor
                font.bold: true
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.preferredHeight: 80 * Window.window.scaleFactor
                visible: (page.entry.notes || "").length > 0
                clip: true

                TextArea {
                    text: page.entry.notes || ""
                    readOnly: true
                    selectByMouse: true
                    wrapMode: TextEdit.Wrap
                    font.family: Theme.fontFamily
                    font.pixelSize: 11 * Window.window.scaleFactor
                    color: Theme.foreground

                    background: Rectangle {
                        color: "#0a0a0a"
                        border.color: "#222222"
                        radius: 4
                    }
                }
            }
        }
    }
}
