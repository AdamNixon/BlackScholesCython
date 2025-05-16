import QtQuick
import QtQuick.Controls

Button {
    id: customButton

    width: 150
    height: 40

    background: Rectangle {
        color: customButton.down ? "#bbbbbb" : "#dddddd"
        radius: 5
        border.color: "#888888"
        border.width: 1
    }

    contentItem: Text {
        text: customButton.text
        font.pixelSize: 16
        color: "#333333"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}