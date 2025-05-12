import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Effects

ApplicationWindow {
    visible: true
    width: 800
    height: 600
    title: "Table Filter App"
    Material.theme: Material.Light
    Material.accent: Material.Blue

    // Custom theme properties
    QtObject {
        id: theme
        property color highlight: "#1976D2"  // Bold blue
        property color hover: "#EEEEEE"      // Light grey
        property color border: "#e0e0e0"
        property int radius: 8
    }

    // Hidden Text component for measuring
    Text {
        id: textMetrics
        font.pixelSize: 14
        visible: false
    }

    // Calculate column widths based on content
    QtObject {
        id: columnWidths
        property var widths: [100, 100, 100] // Default minimum widths
        property int padding: 24 // Left margin (12) + extra padding

        function updateWidths() {
            var newWidths = [100, 100, 100]
            for (var row = 0; row < tableModel.rowCount(); row++) {
                var sourceRow = tableModel.mapToSource(tableModel.index(row, 0)).row
                var name = sourceModel.data(sourceModel.index(sourceRow, 0), Qt.DisplayRole)
                var type = sourceModel.data(sourceModel.index(sourceRow, 1), Qt.DisplayRole)
                var desc = sourceModel.data(sourceModel.index(sourceRow, 2), Qt.DisplayRole)

                // Measure text widths
                textMetrics.text = name || ""
                newWidths[0] = Math.max(newWidths[0], textMetrics.width + padding)
                textMetrics.text = type || ""
                newWidths[1] = Math.max(newWidths[1], textMetrics.width + padding)
                textMetrics.text = desc || ""
                newWidths[2] = Math.max(newWidths[2], textMetrics.width + padding)
            }
            // Ensure total width fits tableView, scale if needed
            var totalWidth = newWidths[0] + newWidths[1] + newWidths[2]
            if (totalWidth > tableView.width) {
                var scale = tableView.width / totalWidth
                newWidths = newWidths.map(w => Math.floor(w * scale))
            }
            widths = newWidths
            console.log("Updated column widths:", widths, "tableView.width:", tableView.width)
        }
    }

    // Update column widths on model changes or tableView width changes
    Connections {
        target: tableModel
        function onRowsInserted() { columnWidths.updateWidths() }
        function onRowsRemoved() { columnWidths.updateWidths() }
        function onDataChanged() { columnWidths.updateWidths() }
        function onModelReset() { columnWidths.updateWidths() }
    }

    // Delay initial width calculation until layout is resolved
    Timer {
        id: initialWidthTimer
        interval: 0
        running: true
        repeat: false
        onTriggered: {
            columnWidths.updateWidths()
            console.log("Initial width calculation triggered")
        }
    }

    // Update widths when tableView width changes
    Binding {
        target: columnWidths
        property: "widths"
        value: { columnWidths.updateWidths(); return columnWidths.widths }
        when: tableView.widthChanged()
    }

    // Model to track hovered rows
    ListModel {
        id: hoveredRowsModel
        function setHovered(row, isHovered) {
            for (var i = 0; i < count; i++) {
                if (get(i).row === row) {
                    if (!isHovered) {
                        remove(i)
                    }
                    return
                }
            }
            if (isHovered) {
                append({row: row})
            }
        }
        function isRowHovered(row) {
            for (var i = 0; i < count; i++) {
                if (get(i).row === row) {
                    return true
                }
            }
            return false
        }
    }

    // Force UI refresh on selection change
    Connections {
        target: sourceModel
        function onSelectedItemsChanged() {
            tableModel.invalidate()
            tableView.forceLayout()
            console.log("Selected items changed")
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12
        anchors.margins: 12

        // Search bar
        TextField {
            id: searchField
            Layout.fillWidth: true
            placeholderText: "Search..."
            padding: 12
            font.pixelSize: 16
            onTextChanged: tableModel.setFilterText(text)

            background: Rectangle {
                radius: theme.radius
                border.color: searchField.activeFocus ? Material.accent : "#cccccc"
                border.width: 1
                color: "white"
            }
        }

        // Clear selection button
        Button {
            text: "Clear Selection"
            Layout.alignment: Qt.AlignRight
            Material.elevation: 1
            enabled: sourceModel.selectedItems.length > 0
            onClicked: sourceModel.clearSelection()

            background: Rectangle {
                radius: theme.radius
                color: parent.hovered ? theme.hover : "white"
                border.color: Material.accent
                border.width: 1
            }

            Behavior on opacity { NumberAnimation { duration: 200 } }
        }

        // Main content: Table and Selected Items
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12

            // Table view
            Pane {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Material.elevation: 2
                padding: 0
                background: Rectangle {
                    radius: theme.radius
                    color: "white"
                }

                TableView {
                    id: tableView
                    anchors.fill: parent
                    model: tableModel
                    clip: true
                    reuseItems: false

                    delegate: Rectangle {
                        implicitWidth: columnWidths.widths[column]
                        implicitHeight: 40
                        border.color: theme.border
                        border.width: 1
                        property int sourceRow: tableModel.mapToSource(tableModel.index(row, 0)).row
                        property bool isSelected: sourceModel.isSelected(sourceRow)
                        property bool isHovered: hoveredRowsModel.isRowHovered(row)
                        color: isSelected ? theme.highlight : (isHovered ? theme.hover : "white")

                        onIsSelectedChanged: console.log("Row:", row, "SourceRow:", sourceRow, "isSelected:", isSelected, "Column:", column)
                        onIsHoveredChanged: console.log("Row:", row, "isHovered:", isHovered)

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: display
                            font.pixelSize: 14
                            elide: Text.ElideRight
                            width: parent.width - 12
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                var sourceIndex = tableModel.mapToSource(tableModel.index(row, 0))
                                console.log("Clicked: row=", row, "sourceRow=", sourceIndex.row, "select=", !sourceModel.isSelected(sourceIndex.row))
                                sourceModel.setSelected(sourceIndex.row, !sourceModel.isSelected(sourceIndex.row))
                            }
                            onEntered: hoveredRowsModel.setHovered(row, true)
                            onExited: hoveredRowsModel.setHovered(row, false)
                        }

                        Behavior on color {
                            ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }
                        }

                        layer.enabled: isSelected
                        layer.effect: MultiEffect {
                            shadowEnabled: true
                            shadowColor: "#20000000"
                            shadowOpacity: 0.3
                            shadowHorizontalOffset: 2
                            shadowVerticalOffset: 2
                            shadowBlur: 8
                        }

                        Component.onCompleted: console.log("Row:", row, "SourceRow:", sourceRow, "Selected:", isSelected, "Column:", column)
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
                                width: columnWidths.widths[index]
                                height: 40
                                color: Material.color(Material.Grey, Material.Shade200)
                                border.color: theme.border
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData
                                    font.bold: true
                                    font.pixelSize: 14
                                    color: Material.color(Material.Grey, Material.Shade900)
                                    elide: Text.ElideRight
                                    width: parent.width - 12
                                }
                            }
                        }
                    }

                    ScrollBar.vertical: ScrollBar {}
                    ScrollBar.horizontal: ScrollBar {}
                }
            }

            // Selected items display
            Pane {
                Layout.preferredWidth: 200
                Layout.fillHeight: true
                Material.elevation: 2
                background: Rectangle {
                    radius: theme.radius
                    color: "white"
                }

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8

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
                                anchors.leftMargin: 8
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