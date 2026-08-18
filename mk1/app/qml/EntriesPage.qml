import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Crusader

Page {
    id: page

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
                text: "MIS CUENTAS"
                font.family: Theme.fontFamily
                font.bold: true
                font.letterSpacing: 2
                font.pixelSize: 16 * Window.window.scaleFactor
                color: Theme.foreground
                Layout.fillWidth: true
            }

            ToolButton {
                id: settingsButton
                implicitWidth: 36 * Window.window.scaleFactor
                implicitHeight: implicitWidth
                background: Item {}
                contentItem: Text {
                    text: "⚙️"
                    color: Theme.foreground
                    opacity: 0.7
                    font.pixelSize: 18 * Window.window.scaleFactor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: page.StackView.view.push("SettingsPage.qml")
            }

            ToolButton {
                id: lockButton
                implicitWidth: 36 * Window.window.scaleFactor
                implicitHeight: implicitWidth
                background: Item {}
                contentItem: Text {
                    text: "🔒"
                    color: Theme.foreground
                    opacity: 0.7
                    font.pixelSize: 18 * Window.window.scaleFactor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    vault.lock();
                    page.StackView.view.replace("LoginPage.qml");
                }
            }
        }
    }

    ListView {
        id: entriesList
        anchors.fill: parent
        anchors.margins: 16 * Window.window.scaleFactor
        spacing: 10 * Window.window.scaleFactor
        clip: true
        model: vault.entries
        ScrollBar.vertical: ScrollBar {}

        delegate: Rectangle {
            width: entriesList.width
            height: 64 * Window.window.scaleFactor
            radius: 12
            color: "#161616"
            border.color: "#262626"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 12

                Rectangle {
                    Layout.preferredWidth: 36 * Window.window.scaleFactor
                    Layout.preferredHeight: 36 * Window.window.scaleFactor
                    radius: width / 2
                    color: Theme.accent

                    Text {
                        anchors.centerIn: parent
                        text: name.length > 0 ? name.charAt(0).toUpperCase() : "?"
                        font.family: Theme.fontFamily
                        font.bold: true
                        color: Theme.background
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        Layout.fillWidth: true
                        text: name
                        color: Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: 15 * Window.window.scaleFactor
                        elide: Text.ElideRight
                    }
                    Text {
                        Layout.fillWidth: true
                        text: username.length > 0 ? username : "Sin usuario"
                        color: Theme.foreground
                        opacity: 0.55
                        font.family: Theme.fontFamily
                        font.pixelSize: 12 * Window.window.scaleFactor
                        elide: Text.ElideRight
                    }
                }

                Text {
                    text: "›"
                    color: Theme.foreground
                    opacity: 0.4
                    font.pixelSize: 20 * Window.window.scaleFactor
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: page.StackView.view.push("EntryDetailPage.qml", {
                    entryId: entryId
                })
            }
        }
    }

    Label {
        anchors.centerIn: parent
        visible: entriesList.count === 0
        width: parent.width * 0.7
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        text: "Todavía no tienes ninguna cuenta guardada.\nPulsa + para añadir la primera."
        color: Theme.foreground
        opacity: 0.5
        font.family: Theme.fontFamily
        font.pixelSize: 13 * Window.window.scaleFactor
    }

    RoundButton {
        id: addButton
        radius: width / 2
        width: 56 * Window.window.scaleFactor
        height: width
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20 * Window.window.scaleFactor

        contentItem: Text {
            text: "+"
            color: Theme.background
            font.family: Theme.fontFamily
            font.bold: true
            font.pixelSize: 26 * Window.window.scaleFactor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            radius: addButton.radius
            color: addButton.pressed ? Qt.darker(Theme.accent, 1.2) : Theme.accent
        }

        onClicked: page.StackView.view.push("AddEntryPage.qml")
    }
}
