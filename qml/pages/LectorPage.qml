import QtQuick 2.6
import Sailfish.Silica 1.0

Page {
    id: teacherPage
    objectName: "teacherPage"

    property int studentCount: 0

    Rectangle {
        anchors.fill: parent
        color: "#22333B"
    }

    Rectangle {
        width: parent.width
        height: Theme.itemSizeLarge
        color: "#1F252A"

        Text {
            text: qsTr("Преподаватель")
            anchors.centerIn: parent
            font.pixelSize: Theme.fontSizeLarge
            color: "#ECF0F1"
        }
    }

    SilicaFlickable {
        anchors {
            top: parent.top
            topMargin: Theme.itemSizeLarge
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        contentHeight: contentColumn.height

        Column {
            id: contentColumn
            width: parent.width
            spacing: Theme.paddingLarge
            anchors.horizontalCenter: parent.horizontalCenter
            padding: Theme.paddingLarge

            // Ввод количества студентов
            Row {
                spacing: Theme.paddingMedium
                width: parent.width * 0.9
                anchors.horizontalCenter: parent.horizontalCenter

                Label {
                    text: qsTr("Количество студентов:")
                    color: "#ECF0F1"
                    font.pixelSize: Theme.fontSizeMedium
                }

                TextField {
                    id: studentCountField
                    width: parent.width * 0.2
                    placeholderText: "5"
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            // Кнопки друг под другом
            Column {
                spacing: Theme.paddingMedium
                width: parent.width * 0.6
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: parent.width
                    height: 50
                    radius: 25
                    color: "#AEDBA8"

                    Text {
                        anchors.centerIn: parent
                        text: qsTr("Подтвердить")
                        color: "#2C3E50"
                        font.pixelSize: Theme.fontSizeMedium
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            var count = parseInt(studentCountField.text)
                            if (!isNaN(count) && count > 0) {
                                studentsModel.clear()
                                for (var i = 1; i <= count; i++) {
                                    studentsModel.append({
                                        desk: i.toString(),
                                        student: "Студент " + i,
                                        status: "Ожидание"
                                    })
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 50
                    radius: 25
                    color: "#8EA8C3"

                    Text {
                        anchors.centerIn: parent
                        text: qsTr("Раздать варианты")
                        color: "#2C3E50"
                        font.pixelSize: Theme.fontSizeMedium
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            for (var i = 0; i < studentsModel.count; i++) {
                                studentsModel.setProperty(i, "status", "Вариант " + (i + 1))
                            }
                        }
                    }
                }
            }

            // Заголовок таблицы
            Row {
                spacing: 2
                width: parent.width * 0.95
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle { width: parent.width * 0.25; height: 40; color: "#1F252A"
                    Text { anchors.centerIn: parent; text: qsTr("Парта"); color: "#ECF0F1"; font.pixelSize: Theme.fontSizeSmall }
                }

                Rectangle { width: parent.width * 0.35; height: 40; color: "#1F252A"
                    Text { anchors.centerIn: parent; text: qsTr("Студент"); color: "#ECF0F1"; font.pixelSize: Theme.fontSizeSmall }
                }

                Rectangle { width: parent.width * 0.4; height: 40; color: "#1F252A"
                    Text { anchors.centerIn: parent; text: qsTr("Статус"); color: "#ECF0F1"; font.pixelSize: Theme.fontSizeSmall }
                }
            }

            // Таблица студентов
            Repeater {
                model: ListModel { id: studentsModel }

                Row {
                    spacing: 2
                    width: parent.width * 0.95
                    height: 40
                    anchors.horizontalCenter: parent.horizontalCenter

                    Rectangle {
                        width: parent.width * 0.25
                        height: 40
                        color: "#2A3A42"
                        Text { anchors.centerIn: parent; text: model.desk; color: "#ECF0F1"; font.pixelSize: Theme.fontSizeSmall }
                    }

                    Rectangle {
                        width: parent.width * 0.35
                        height: 40
                        color: "#2A3A42"
                        Text { anchors.centerIn: parent; text: model.student; color: "#ECF0F1"; font.pixelSize: Theme.fontSizeSmall }
                    }

                    Rectangle {
                        width: parent.width * 0.4
                        height: 40
                        color: "#2A3A42"
                        Text { anchors.centerIn: parent; text: model.status; color: "#ECF0F1"; font.pixelSize: Theme.fontSizeSmall }
                    }
                }
            }
        }
    }
}
