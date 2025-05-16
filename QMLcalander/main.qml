import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    visible: true
    width: 400
    height: 300
    title: "Date Picker App"

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 10

        // First CalendarButton with checkbox
        RowLayout {
            spacing: 10

            CalendarButton {
                id: calendarButton
                selectedDate: new Date() // Current date
                buttonEnabled: !checkBox.checked // Controlled by checkbox
                onSelectedDateChanged: {
                    console.log("First button date changed to:", selectedDate)
                }
            }

            CheckBox {
                id: checkBox
                text: "Disable Calendar"
            }
        }

        // Second CalendarButton with separate checkbox (demonstrates reusability)
        RowLayout {
            spacing: 10

            CalendarButton {
                id: anotherCalendarButton
                selectedDate: new Date(2025, 5, 1) // June 1, 2025
                buttonEnabled: !anotherCheckBox.checked // Controlled by second checkbox
                onSelectedDateChanged: {
                    console.log("Second button date changed to:", selectedDate)
                }
            }

            CheckBox {
                id: anotherCheckBox
                text: "Disable Calendar"
            }
        }
    }
}