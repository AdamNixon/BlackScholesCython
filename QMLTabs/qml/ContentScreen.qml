import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../controllers/content_controller.js" as ContentController

Window {
    id: contentScreen
    width: 600
    height: 400
    visible: true
    title: qsTr("Tabbed Content")

    onActiveChanged: {
        console.log("ContentScreen active:", active)
        if (active) {
            raise()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10

        TabBar {
            id: tabBar
            Layout.fillWidth: true

            Repeater {
                model: tabModel
                TabButton {
                    text: model.title
                }
            }
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tabBar.currentIndex

            Repeater {
                model: tabModel
                TabContent {
                    text: model.content
                }
            }
        }
    }

    Button {
        text: qsTr("Close")
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: 10
        onClicked: {
            console.log("Closing ContentScreen")
            ContentController.closeWindow(contentScreen)
        }
    }
}