import QtQuick 2.6
import Sailfish.Silica 1.0
import "../models"
Page {
    id: page

    property var client: AttendanceModel {
        onDataUpdated: {
            busyIndicator.running = false
            noStudentsLabel.visible = client.mergedAttendance.length === 0
            console.log(" Данные посещаемости обновлены, студентов:", client.mergedAttendance.length)
        }

        onSaveCompleted: function(success) {
            if (success) {
                console.log(" Изменения успешно сохранены в базу данных")
            } else {
                console.error(" Не удалось сохранить изменения")
            }
        }
    }

    property bool showPresentOnly: false
    property string currentSubject: "Математика"
    property string currentGroup: "ИТ-21"

    property var displayedStudents: getDisplayedStudents()

    function getDisplayedStudents() {
        if (showPresentOnly) {
            var present = []
            for (var i = 0; i < client.mergedAttendance.length; i++) {
                if (client.mergedAttendance[i].status === "Пр") {
                    present.push(client.mergedAttendance[i])
                }
            }
            return present
        }
        return client.mergedAttendance
    }

    Component.onCompleted: {
        busyIndicator.running = true
        client.updateData()
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {
//            highlightColor: "transparent"
//            colorScheme: "transparent"

            backgroundColor: "transparent"
            MenuItem {
                text: qsTr("Обновить данные")
                onClicked: {
                    busyIndicator.running = true
                    client.updateData()
                }
            }
            MenuItem {
                text: showPresentOnly ? qsTr("Показать всех") : qsTr("Только присутствующие")
                onClicked: showPresentOnly = !showPresentOnly
            }
            MenuItem {
                text: qsTr("Сохранить изменения")
                enabled: client.hasChanges
                onClicked: client.saveChanges()
            }
        }

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader {
                title: qsTr("Табель посещаемости")
            }
            Rectangle {
                width: parent.width
                height: Theme.itemSizeSmall
                color: Theme.rgba(Theme.highlightBackgroundColor, 0.1)

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.horizontalPageMargin
                    anchors.rightMargin: Theme.horizontalPageMargin
                    spacing: Theme.paddingMedium

                    Label {
                        width: parent.width * 0.7
                        text: currentGroup
                        color: Theme.highlightColor
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Label {
                        width: parent.width * 0.3
                        text: currentSubject
                        color: Theme.secondaryHighlightColor
                        horizontalAlignment: Text.AlignRight
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }


            Row {
                width: parent.width - 2*Theme.horizontalPageMargin
                x: Theme.horizontalPageMargin
                spacing: Theme.paddingMedium

                Label {
                    width: parent.width * 0.6
                    text: qsTr("ФИО")
                    font.bold: true
                    color: Theme.highlightColor
                }

                Label {
                    width: parent.width * 0.2
                    text: qsTr("Статус")
                    font.bold: true
                    color: Theme.highlightColor

                }


                Label {
                    width: parent.width * 0.1
                    text: qsTr("Парта")
                    font.bold: true
                    color: Theme.highlightColor

                }
            }


            Rectangle {
                width: parent.width
                height: 1
                color: Theme.secondaryColor
                opacity: 0.5
            }


            Repeater {
                model: displayedStudents

                delegate: AttendanceRow {
                    width: parent.width
                    studentId: modelData.id
                    studentName: modelData.name
                    roomNumber: modelData.room
                    deskNumber: modelData.desk
                    attendanceStatus: modelData.status
                    isAttend: modelData.status === "Пр"
                    onStatusChanged: {
                        for (var i = 0; i < client.mergedAttendance.length; i++) {
                            if (client.mergedAttendance[i].id === studentId) {
                                client.mergedAttendance[i].status = newStatus
                                client.updateChangesFlag()
                                break
                            }
                        }
                        isAttend = newStatus === "Пр"
                    }

                    onSeatChanged: {

                        for (var i = 0; i < client.mergedAttendance.length; i++) {


                            if (client.mergedAttendance[i].id === studentId) {

                                client.mergedAttendance[i].desk = newDesk

                                client.updateChangesFlag()
                                break
                            }
                        }
                    }
                }
            }


            Label {
                id: noStudentsLabel
                width: parent.width - 2*Theme.horizontalPageMargin
                x: Theme.horizontalPageMargin
                visible: false
                text: qsTr("Нет данных о студентах")
                color: Theme.secondaryColor
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
            }
        }
    }
    BusyIndicator {
        id: busyIndicator
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
        running: false
    }

}
