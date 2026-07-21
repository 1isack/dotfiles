import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

ShellRoot {
    id: root

    property var colors: ({
        background: "#1e1e2e",
        foreground: "#cdd6f4",
        color0:  "#45475a",
        color1:  "#f38ba8",
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
                    color4: data.colors.color4,
                    color8: data.colors.color8
                }
            } catch (e) {}
        }
    }

    // --- Player state ---
    Item {
        id: player
        property string artist: ""
        property string title: ""
        property string artUrl: ""
        property real length: 0     // seconds
        property real position: 0   // seconds
        property string status: "Stopped"

        function refresh() {
            metaProc.running = true
        }

        Process {
            id: metaProc
            command: ["sh", "-c",
                "playerctl metadata --format '{{artist}}|{{title}}|{{mpris:artUrl}}|{{mpris:length}}|{{status}}' 2>/dev/null; echo -n '||'; playerctl position 2>/dev/null"]
            stdout: StdioCollector {
                onStreamFinished: {
                    const parts = text.split("||")
                    const meta = (parts[0] || "").trim().split("|")
                    if (meta.length >= 5) {
                        player.artist = meta[0]
                        player.title = meta[1]
                        player.artUrl = meta[2]
                        player.length = parseFloat(meta[3] || "0") / 1000000
                        player.status = meta[4]
                    } else {
                        player.status = "Stopped"
                    }
                    player.position = parseFloat(parts[1] || "0")
                }
            }
        }

        Timer {
            interval: 800
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: player.refresh()
        }
    }

    function fmtTime(sec) {
        if (isNaN(sec) || sec < 0) sec = 0
        const m = Math.floor(sec / 60)
        const s = Math.floor(sec % 60)
        return m + ":" + (s < 10 ? "0" + s : s)
    }

    // --- Cava visualizer (persistent process, raw ascii to stdout) ---
    Item {
        id: cava
        property var bars: []

        Process {
            id: cavaProc
            command: ["cava", "-p", Quickshell.env("HOME") + "/.config/cava/quickshell-config"]
            running: true
            stdout: SplitParser {
                onRead: line => {
                    cava.bars = line.split(";").filter(x => x.length > 0).map(x => parseInt(x))
                }
            }
        }
    }

    // --- Volume ---
    Item {
        id: audio
        property int vol: 0

        Process {
            id: volProc
            command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
            stdout: SplitParser {
                onRead: line => {
                    const m = line.match(/Volume:\s*([\d.]+)/)
                    if (m) audio.vol = Math.round(parseFloat(m[1]) * 100)
                }
            }
        }
        Timer {
            interval: 1500
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: volProc.running = true
        }
    }

    PanelWindow {
        id: win
        implicitWidth: 380
        implicitHeight: 560
        color: "transparent"

        anchors { bottom: true }
        margins { bottom: 4 }
        exclusiveZone: 0

        Rectangle {
            anchors.fill: parent
            color: root.colors.background
            radius: 0
            border.color: root.colors.color8
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 10

                // Album art
                Rectangle {
                    Layout.preferredWidth: 240
                    Layout.preferredHeight: 240
                    Layout.alignment: Qt.AlignHCenter
                    color: root.colors.color0
                    radius: 0
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: player.artUrl
                        fillMode: Image.PreserveAspectCrop
                        visible: player.artUrl !== ""
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: player.artUrl === ""
                        text: "\uf001"
                        font.family: "GeistMono Nerd Font"
                        font.pointSize: 40
                        color: root.colors.foreground
                    }
                }

                // Title / artist
                Text {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: player.title !== "" ? player.title : "Nothing playing"
                    color: root.colors.foreground
                    font.family: "GeistMono Nerd Font"
                    font.pointSize: 12
                    font.bold: true
                    elide: Text.ElideRight
                }
                Text {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: player.artist
                    color: root.colors.color8
                    font.family: "GeistMono Nerd Font"
                    font.pointSize: 10
                    elide: Text.ElideRight
                }

                // Cava bars
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    spacing: 2
                    Repeater {
                        model: cava.bars
                        delegate: Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignBottom
                            radius: 0
                            color: root.colors.color4
                            height: 4 + (modelData / 7) * 36
                        }
                    }
                }

                // Progress bar (seekable)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 6
                    radius: 0
                    color: root.colors.color0

                    Rectangle {
                        width: player.length > 0 ? parent.width * (player.position / player.length) : 0
                        height: parent.height
                        radius: 0
                        color: root.colors.color4
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: mouse => {
                            if (player.length <= 0) return
                            const frac = mouse.x / width
                            Quickshell.execDetached(["playerctl", "position", (frac * player.length).toFixed(1)])
                        }
                    }
                }

                // Time labels
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: root.fmtTime(player.position)
                        color: root.colors.color8
                        font.family: "GeistMono Nerd Font"
                        font.pointSize: 9
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: "-" + root.fmtTime(player.length - player.position)
                        color: root.colors.color8
                        font.family: "GeistMono Nerd Font"
                        font.pointSize: 9
                    }
                }

                // Playback controls
                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 24

                    Text {
                        text: "\uf048"
                        font.family: "GeistMono Nerd Font"
                        font.pointSize: 16
                        color: root.colors.foreground
                        MouseArea { anchors.fill: parent; onClicked: Quickshell.execDetached(["playerctl", "previous"]) }
                    }
                    Text {
                        text: player.status === "Playing" ? "\uf04c" : "\uf04b"
                        font.family: "GeistMono Nerd Font"
                        font.pointSize: 20
                        color: root.colors.color4
                        MouseArea { anchors.fill: parent; onClicked: Quickshell.execDetached(["playerctl", "play-pause"]) }
                    }
                    Text {
                        text: "\uf051"
                        font.family: "GeistMono Nerd Font"
                        font.pointSize: 16
                        color: root.colors.foreground
                        MouseArea { anchors.fill: parent; onClicked: Quickshell.execDetached(["playerctl", "next"]) }
                    }
                }

                // Volume
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Text {
                        text: "\uf028"
                        font.family: "GeistMono Nerd Font"
                        font.pointSize: 12
                        color: root.colors.foreground
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 6
                        radius: 0
                        color: root.colors.color0

                        Rectangle {
                            width: parent.width * (audio.vol / 100)
                            height: parent.height
                            radius: 0
                            color: root.colors.color4
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: mouse => {
                                const pct = Math.max(0, Math.min(100, Math.round((mouse.x / width) * 100)))
                                Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", pct / 100 + ""])
                                audio.vol = pct
                            }
                        }
                    }
                    Text {
                        text: audio.vol + "%"
                        color: root.colors.color8
                        font.family: "GeistMono Nerd Font"
                        font.pointSize: 9
                    }
                }
            }
        }
    }
}
