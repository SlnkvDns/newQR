import QtQuick 2.6
import Sailfish.Silica 1.0

Page {
    id: uploadTestsPage
    objectName: "uploadTestsPage"

    ListModel {
        id: testsModel
        ListElement { subject: "Математика"; topic: "Алгебра"; editable: true }
        ListElement { subject: "Информатика"; topic: "Основы программирования"; editable: true }
        ListElement { subject: "Физика"; topic: "Механика"; editable: true }
        ListElement { subject: "Химия"; topic: "Органическая химия"; editable: true }
    }

    Rectangle {
        anchors.fill: parent
        color: "#22333B"
    }

    Rectangle {
        id: header
        width: parent.width
        height: Theme.itemSizeLarge
        color: "#1F252A"
        z: 1

        Text {
            text: qsTr("Загрузить тесты")
            anchors.centerIn: parent
            font.pixelSize: Theme.fontSizeLarge
            color: "#ECF0F1"
        }
    }

    SilicaFlickable {
        anchors {
            top: header.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        contentHeight: contentColumn.height + Theme.paddingLarge * 2
        clip: true

        Column {
            id: contentColumn
            width: parent.width * 0.9
            spacing: Theme.paddingMedium
            anchors.horizontalCenter: parent.horizontalCenter
            topPadding: Theme.paddingLarge * 1.5

            Rectangle {
                id: addTestButton
                width: parent.width
                height: Theme.itemSizeMedium
                radius: height/2
                color: "#2A3A42"
                border.color: "#3A4A52"
                border.width: 1

                Label {
                    text: qsTr("Добавить тест")
                    anchors.centerIn: parent
                    color: "#ECF0F1"
                    font.pixelSize: Theme.fontSizeMedium
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: addNewTest()
                }
            }

            Item {
                width: parent.width
                height: Theme.paddingLarge * 1.5
            }

            Repeater {
                model: testsModel
                delegate: Rectangle {
                    width: parent.width
                    height: Theme.itemSizeMedium
                    radius: height/2
                    color: "#2A3A42"
                    border.color: "#3A4A52"
                    border.width: 1

                    Row {
                        anchors {
                            fill: parent
                            leftMargin: Theme.paddingLarge
                            rightMargin: Theme.paddingMedium
                        }
                        spacing: Theme.paddingMedium

                        Label {
                            text: subject + ": " + topic
                            color: "#ECF0F1"
                            font.pixelSize: Theme.fontSizeMedium
                            width: parent.width - (editable ? Theme.iconSizeMedium : 0) - Theme.paddingMedium
                            maximumLineCount: 1
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Rectangle {
                            visible: editable
                            width: Theme.iconSizeMedium
                            height: Theme.iconSizeMedium
                            radius: width/2
                            color: "transparent"
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                source: "image://theme/icon-m-edit"
                                width: parent.width
                                height: parent.height
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: editTest(index)
                            }
                        }
                    }
                }
            }
        }
    }

    function addNewTest() {
        console.log("Добавление нового теста")
        // pageStack.push(Qt.resolvedUrl("AddTestPage.qml"))
    }

    function editTest(index) {
        console.log("Редактирование теста:", testsModel.get(index).subject, testsModel.get(index).topic)
        // pageStack.push(Qt.resolvedUrl("EditTestPage.qml"), {
        //     testIndex: index,
        //     testData: testsModel.get(index)
        // })
    }

    function updateTestsModel() {

    }

    Component.onCompleted: {
        updateTestsModel()
    }
}
