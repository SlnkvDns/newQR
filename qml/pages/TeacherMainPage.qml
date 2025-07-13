import QtQuick 2.6
import Sailfish.Silica 1.0

Page {
    id: teacherMainPage
    objectName: "teacherMainPage"

    property int studentCount: 0
    property bool isCountConfirmed: false
    property var presentStudents: []

    property string errorMessage: ""

    Rectangle {
        anchors.fill: parent
        color: "#22333B"
    }

    Rectangle {
        id: header
        width: parent.width + 40
        height: Theme.itemSizeLarge
        color: "#1F252A"

        Text {
            text: qsTr("Экран преподавателя")
            anchors.centerIn: parent
            font.pixelSize: Theme.fontSizeLarge * 1.1
            color: "#ECF0F1"
            font.bold: true
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: mainColumn.height + Theme.paddingLarge * 10

        clip: true
        boundsBehavior: Flickable.DragAndOvershootBounds

        Column {
            id: mainColumn
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: Theme.paddingLarge * 10
            spacing: Theme.paddingLarge * 3
            width: parent.width * 0.85

            TextField {
                id: studentCountField
                width: parent.width
                placeholderText: qsTr("Введите количество студентов")
                color: "#ECF0F1"
                placeholderColor: "#7F8C8D"
                horizontalAlignment: Text.AlignLeft
                inputMethodHints: Qt.ImhDigitsOnly
                font.pixelSize: Theme.fontSizeLarge
                background: null

                onTextChanged: {
                    teacherMainPage.isCountConfirmed = false
                }
            }

            Rectangle {
                width: parent.width
                height: Theme.itemSizeExtraLarge - 50
                radius: height / 2
                color: "#2A3A42"
                border.color: "#3A4A52"
                border.width: 1

                Label {
                    text: qsTr("Подтвердить количество")
                    anchors.centerIn: parent
                    color: "#ECF0F1"
                    font.pixelSize: Theme.fontSizeLarge
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        var count = parseInt(studentCountField.text)
                        if (!isNaN(count) && count > 0) {
                            teacherMainPage.studentCount = count
                            teacherMainPage.isCountConfirmed = true

                            var tempList = []
                            for (var i = 1; i <= count; i++) {
                                tempList.push({ name: "Студент " + i, desk: i.toString() })
                            }
                            teacherMainPage.presentStudents = tempList

                        } else {
                            showBanner(qsTr("Введите корректное количество студентов"))
                        }
                    }
                }
            }

            Label {
                visible: teacherMainPage.isCountConfirmed
                text: qsTr("Количество подтверждено: ") + teacherMainPage.studentCount
                color: "#ECF0F1"
                font.pixelSize: Theme.fontSizeSmall
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Rectangle {
                width: parent.width
                height: Theme.paddingLarge * 2
                color: "transparent"
            }

            Rectangle {
                width: parent.width
                height: Theme.itemSizeExtraLarge - 50
                radius: height / 2
                color: "#1F252A"
                border.color: "#3A4A52"
                border.width: 1

                Label {
                    text: qsTr("Провести тестирование")
                    anchors.centerIn: parent
                    color: "#ECF0F1"
                    font.pixelSize: Theme.fontSizeLarge
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (teacherMainPage.isCountConfirmed && teacherMainPage.studentCount > 0) {
                            teacherMainPage.errorMessage = ""
                            pageStack.push(Qt.resolvedUrl("ConductTestingPage.qml"), { studentCount: teacherMainPage.studentCount })
                        } else {
                            teacherMainPage.errorMessage = qsTr("Сначала подтвердите количество студентов")
                        }
                    }
                }
            }

            Label {
                text: teacherMainPage.errorMessage
                visible: teacherMainPage.errorMessage.length > 0
                color: "red"
                font.pixelSize: Theme.fontSizeSmall
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Rectangle {
                width: parent.width
                height: Theme.itemSizeExtraLarge - 50
                radius: height / 2
                color: "#1F252A"
                border.color: "#3A4A52"
                border.width: 1

                Label {
                    text: qsTr("Загрузить тесты")
                    anchors.centerIn: parent
                    color: "#ECF0F1"
                    font.pixelSize: Theme.fontSizeLarge
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("UploadTestsPage.qml"))
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: Theme.itemSizeExtraLarge - 50
                radius: height / 2
                color: "#1F252A"
                border.color: "#3A4A52"
                border.width: 1

                Label {
                    text: qsTr("Просмотр результатов")
                    anchors.centerIn: parent
                    color: "#ECF0F1"
                    font.pixelSize: Theme.fontSizeLarge
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("ResultPage.qml"))
                    }

                }
            }

            Rectangle {
                width: parent.width
                height: 2
                color: "#3A4A52"
                opacity: 0.5
            }

            Label {
                text: qsTr("Присутствующие студенты")
                color: "#ECF0F1"
                font.pixelSize: Theme.fontSizeMedium
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Repeater {
                model: teacherMainPage.presentStudents

                Row {
                    width: parent.width
                    spacing: Theme.paddingMedium
                    anchors.horizontalCenter: parent.horizontalCenter

                    Label {
                        text: modelData.name
                        color: "#ECF0F1"
                        font.pixelSize: Theme.fontSizeSmall
                        width: parent.width * 0.65
                        elide: Text.ElideRight
                    }

                    Label {
                        text: qsTr("Парта: ") + modelData.desk
                        color: "#ECF0F1"
                        font.pixelSize: Theme.fontSizeSmall
                        width: parent.width * 0.3
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }
    }
}
