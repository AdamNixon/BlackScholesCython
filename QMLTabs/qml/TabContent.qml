import QtQuick
import QtQuick.Controls

Item {
    id: tabContent

    property string text: ""

    Rectangle {
        anchors.fill: parent
        color: "#f0f0f0"

        Text {
            anchors.centerIn: parent
            text: tabContent.text
            font.pixelSize: 16
            wrapMode: Text.Wrap
            width: parent.width - 20
        }
    }
}