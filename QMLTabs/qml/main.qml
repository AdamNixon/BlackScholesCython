import QtQuick
import QtQuick.Controls

ApplicationWindow {
    id: root
    visible: true
    width: 600
    height: 400
    title: qsTr("PySide6 QML App")

    onActiveChanged: {
        console.log("Main window active:", active)
        if (active) {
            raise()
        }
    }

    MenuScreen {
        anchors.fill: parent
    }
}