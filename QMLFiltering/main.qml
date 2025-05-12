import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

ApplicationWindow {
    visible: true
    width: 800
    height: 600
    title: "Table Filter App"
    Material.theme: Material.Light
    Material.accent: Material.Blue

    ColumnLayout {
        anchors.fill: parent
        spacing: 10
        anchors.margins: 10

        // Search bar
        TextField {
            id: searchField
            Layout.fillWidth: true
            placeholderText: "Search..."
            padding: 10
            font.pixelSize: 16
            onTextChanged: tableModel.setFilterText(text)

            background: Rectangle {
                radius: 8
                border.color: searchField.activeFocus ? Material.accent : "#cccccc"
                border.width: 1
            }
        }

        // Main content: Table and Selected Items
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            // Table view
            TableView {
                id: tableView
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: tableModel
                selectionMode: SelectionMode.MultiSelection
                clip: true

                delegate: Rectangle {
                    implicitWidth: tableView.width / 3
                    implicitHeight: 40
                    border.color: "#e0e0e0"
                    border.width: 1
                    property int sourceRow: tableModel.mapToSource(tableModel.index(row, column)).row
                    color: sourceModel.isSelected(sourceRow) ? Material.color(Material.Blue, Material.Shade100) : "white"

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: display
                        font.pixelSize: 14
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            var sourceIndex = tableModel.mapToSource(tableModel.index(row, column))
                            sourceModel.setSelected(sourceIndex.row, !sourceModel.isSelected(sourceIndex.row))
                        }
                    }
                }

                // Column headers
                Row {
                    id: headerRow
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 1

                    Repeater {
                        model: ["Name", "Type", "Description"]
                        Rectangle {
                            width: tableView.width / 3
                            height: 40
                            color: Material.color(Material.Grey, Material.Shade200)
                            border.color: "#e0e0e0"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                font.bold: true
                                font.pixelSize: 14
                                color: Material.color(Material.Grey, Material.Shade900)
                            }
                        }
                    }
                }

                ScrollBar.vertical: ScrollBar {}
                ScrollBar.horizontal: ScrollBar {}
            }

            // Selected items display
            Pane {
                Layout.preferredWidth: 200
                Layout.fillHeight: true
                Material.elevation: 2
                background: Rectangle {
                    color: "white"
                    radius: 8
                }

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 5

                    Text {
                        text: "Selected Items"
                        font.bold: true
                        font.pixelSize: 16
                        color: Material.color(Material.Grey, Material.Shade900)
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: sourceModel.selectedItems

                        delegate: Rectangle {
                            width: parent.width
                            height: 30
                            color: "transparent"

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 5
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.name
                                font.pixelSize: 14
                            }
                        }

                        ScrollBar.vertical: ScrollBar {}
                    }
                }
            }
        }
    }
}