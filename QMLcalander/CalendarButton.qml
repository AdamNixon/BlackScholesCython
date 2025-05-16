import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    // Exposed properties
    property alias selectedDate: root.internalSelectedDate // Selected date
    property alias buttonText: dateButton.text // Button text for customization
    property bool buttonEnabled: true // Control button and calendar enabled state

    // Internal property to store the selected date
    property date internalSelectedDate: new Date()
    // Property to store the current month/year being viewed
    property date currentMonth: new Date()

    // Format date as a string (e.g., "YYYY-MM-DD")
    function formatDate(date) {
        return Qt.formatDate(date, "yyyy-MM-dd")
    }

    // Default size of the component
    width: dateButton.width
    height: dateButton.height

    // Button displaying the date
    Button {
        id: dateButton
        text: formatDate(root.internalSelectedDate)
        enabled: root.buttonEnabled // Controlled externally
        opacity: root.buttonEnabled ? 1.0 : 0.5 // Grey out when disabled
        onClicked: {
            if (root.buttonEnabled) {
                calendarWindow.visible = true
            }
        }
    }

    // Separate Window for the calendar
    Window {
        id: calendarWindow
        visible: false
        modality: Qt.ApplicationModal // Blocks interaction with main window
        width: 300
        height: 350
        title: "Select Date"

        // Position the window relative to the main window
        x: ApplicationWindow.window ? ApplicationWindow.window.x + (ApplicationWindow.window.width - width) / 2 : 0
        y: ApplicationWindow.window ? ApplicationWindow.window.y + (ApplicationWindow.window.height - height) / 2 : 0

        // Ensure window closes cleanly
        onClosing: {
            visible = false
        }

        // Background rectangle for the window
        Rectangle {
            anchors.fill: parent
            color: "#f0f0f0"
            border.color: "#333333"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10

                // Header: Month/Year and navigation
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Button {
                        text: "<"
                        onClicked: {
                            if (root.buttonEnabled) {
                                currentMonth = new Date(currentMonth.getFullYear(), currentMonth.getMonth() - 1, 1)
                            }
                        }
                        enabled: root.buttonEnabled
                        opacity: root.buttonEnabled ? 1.0 : 0.5
                    }

                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: Qt.formatDate(currentMonth, "MMMM yyyy")
                        font.bold: true
                    }

                    Button {
                        text: ">"
                        onClicked: {
                            if (root.buttonEnabled) {
                                currentMonth = new Date(currentMonth.getFullYear(), currentMonth.getMonth() + 1, 1)
                            }
                        }
                        enabled: root.buttonEnabled
                        opacity: root.buttonEnabled ? 1.0 : 0.5
                    }
                }

                // Day labels (Mon, Tue, etc.)
                Grid {
                    columns: 7
                    spacing: 2
                    Layout.fillWidth: true

                    Repeater {
                        model: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
                        Text {
                            width: (parent.width - 6 * parent.spacing) / 7
                            text: modelData
                            horizontalAlignment: Text.AlignHCenter
                            font.bold: true
                        }
                    }
                }

                // MonthGrid for date selection
                MonthGrid {
                    id: monthGrid
                    month: currentMonth.getMonth()
                    year: currentMonth.getFullYear()
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    enabled: root.buttonEnabled // Controlled externally
                    opacity: root.buttonEnabled ? 1.0 : 0.5 // Grey out when disabled

                    delegate: Text {
                        text: model.day
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        width: (monthGrid.width - 6 * monthGrid.spacing) / 7
                        height: (monthGrid.height - 6 * monthGrid.spacing) / 6
                        color: enabled ? "black" : "gray"

                        Rectangle {
                            anchors.fill: parent
                            color: model.date.toDateString() === root.internalSelectedDate.toDateString() ? "#0078d7" : "transparent"
                            radius: 5
                            z: -1
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: monthGrid.enabled
                            onClicked: {
                                root.internalSelectedDate = model.date
                                dateButton.text = formatDate(model.date)
                                calendarWindow.close() // Close the window
                            }
                        }
                    }
                }

                // Close button for the window
                Button {
                    text: "Close"
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: calendarWindow.close()
                }
            }
        }
    }
}