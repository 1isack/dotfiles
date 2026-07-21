import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

ShellRoot {
    id: root

    property var colors: ({
        background: "#1e1e2e",
        foreground: "#cdd6f4",
        color0:  "#45475a",
        color1:  "#f38ba8",
        color3:  "#f9e2af",
        color4:  "#89b4fa",
        color8:  "#585b70"
    })

    FileView {
        id: walFile
        path: Quickshell.env("HOME") + "/.cache/wal/colors.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                const data = JSON.parse(text())
                root.colors = {
                    background: data.special.background,
                    foreground: data.special.foreground,
                    color0: data.colors.color0,
                    color1: data.colors.color1,
                    color3: data.colors.color3,
                    color4: data.colors.color4,
                    color8: data.colors.color8
                }
            } catch (e) {}
        }
    }

    NotificationServer {
        id: notifServer
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true
        actionsSupported: true
        keepOnReload: false

        onNotification: notification => {
            notification.tracked = true
        }
    }

    function urgencyColor(urgency) {
        // 0 = Low, 1 = Normal, 2 = Critical (freedesktop order)
        if (urgency === 2) return root.colors.color1
        if (urgency === 0) return root.colors.color8
        return root.colors.color4
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property var modelData
            screen: modelData

            anchors { top: true; bottom: true }
            implicitWidth: 340
            exclusiveZone: 0
            color: "transparent"
            mask: Region { item: notifColumn }

            ColumnLayout {
                id: notifColumn
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 12
                width: 320
                spacing: 8

                Repeater {
                    model: notifServer.trackedNotifications

                    delegate: Rectangle {
                        id: card
                        required property Notification modelData
                        Layout.fillWidth: true
                        Layout.preferredHeight: contentCol.implicitHeight + 24
                        color: root.colors.background
                        border.color: root.urgencyColor(modelData.urgency)
                        border.width: 2
                        radius: 0

                        Timer {
                            running: true
                            interval: modelData.expireTimeout > 0 ? modelData.expireTimeout : 5000
                            onTriggered: modelData.expire()
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton
                            onClicked: modelData.dismiss()
                        }

                        ColumnLayout {
                            id: contentCol
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.margins: 12
                            spacing: 4

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Image {
                                    visible: modelData.image !== "" || modelData.appIcon !== ""
                                    source: modelData.image !== "" ? modelData.image : modelData.appIcon
                                    Layout.preferredWidth: 28
                                    Layout.preferredHeight: 28
                                    fillMode: Image.PreserveAspectFit
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.summary
                                    color: root.colors.foreground
                                    font.family: "GeistMono Nerd Font"
                                    font.pointSize: 10
                                    font.bold: true
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: modelData.appName
                                    color: root.colors.color8
                                    font.family: "GeistMono Nerd Font"
                                    font.pointSize: 8
                                }
                            }

                            Text {
                                visible: modelData.body !== ""
                                Layout.fillWidth: true
                                text: modelData.body
                                color: root.colors.foreground
                                font.family: "GeistMono Nerd Font"
                                font.pointSize: 9
                                wrapMode: Text.WordWrap
                                maximumLineCount: 4
                                elide: Text.ElideRight
                            }

                            RowLayout {
                                visible: modelData.actions.length > 0
                                Layout.fillWidth: true
                                spacing: 6

                                Repeater {
                                    model: modelData.actions
                                    delegate: Rectangle {
                                        required property var modelData
                                        Layout.preferredHeight: 24
                                        Layout.preferredWidth: actionText.implicitWidth + 16
                                        color: root.colors.color0
                                        radius: 0

                                        Text {
                                            id: actionText
                                            anchors.centerIn: parent
                                            text: parent.modelData.text
                                            color: root.colors.foreground
                                            font.family: "GeistMono Nerd Font"
                                            font.pointSize: 8
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: parent.modelData.invoke()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
