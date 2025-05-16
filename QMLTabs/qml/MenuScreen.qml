import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"

Item {
    id: menuScreen

    property var contentWindow: null

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        onClicked: {
            console.log("MenuScreen clicked, raising main window")
            root.raise()
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 20

        CustomButton {
            text: "Open Tabs"
            onClicked: {
                console.log("Opening ContentScreen")
                if (!contentWindow) {
                    var component = Qt.createComponent("ContentScreen.qml")
                    if (component.status === Component.Ready) {
                        contentWindow = component.createObject(root)
                        contentWindow.show()
                        contentWindow.raise()
                        contentWindow.onClosing.connect(function() { contentWindow = null })
                        console.log("ContentScreen created and shown")
                    } else {
                        console.error("Error loading ContentScreen:", component.errorString())
                    }
                } else {
                    contentWindow.raise()
                    console.log("ContentScreen already open, raised")
                }
            }
            Layout.alignment: Qt.AlignHCenter
        }

        // Additional buttons can be added here
    }
}