import QtQuick 2.6
import Sailfish.Silica 1.0

Page {
    id: conductTestingPage
    objectName: "conductTestingPage"

    property int studentCount: 0

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
            text: qsTr("Провести тестирование")
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
        contentHeight: mainColumn.height + Theme.paddingLarge * 2

        Column {
            id: mainColumn
            width: parent.width * 0.9
            spacing: Theme.paddingLarge
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: Theme.paddingLarge * 2

            Label {
                text: qsTr("Выберите тему теста:")
                color: "#ECF0F1"
                font.pixelSize: Theme.fontSizeMedium
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
            }

            ComboBox {
                id: topicCombo
                width: parent.width
                label: qsTr("Темы тестов")
                menu: ContextMenu {
                    MenuItem { text: "Математика" }
                    MenuItem { text: "Информатика" }
                    MenuItem { text: "Физика" }
                }
                onCurrentIndexChanged: {
                    testTopicField.text = topicCombo.currentItem ? topicCombo.currentItem.text : ""
                }
            }

            TextField {
                id: testTopicField
                width: parent.width
                placeholderText: qsTr("Или введите тему вручную")
                color: "#ECF0F1"
                placeholderColor: "#7F8C8D"
                horizontalAlignment: Text.AlignLeft
            }

            Label {
                text: qsTr("Количество студентов: ") + conductTestingPage.studentCount
                color: "#ECF0F1"
                font.pixelSize: Theme.fontSizeMedium
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle {
                width: parent.width
                height: Theme.itemSizeMedium
                radius: height / 2  // Закругление равное половине высоты
                color: pressed ? "#3A4A52" : "#2A3A42"
                border.color: "#3A4A52"
                border.width: 1

                Label {
                    text: qsTr("Начать тестирование")
                    anchors.centerIn: parent
                    color: "#ECF0F1"
                    font.pixelSize: Theme.fontSizeMedium
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        var topic = testTopicField.text.length > 0 ? testTopicField.text :
                                (topicCombo.currentItem ? topicCombo.currentItem.text : "")
                        if (topic.length === 0) {
                            showBanner(qsTr("Выберите или введите тему"))
                            return
                        }
                        pageStack.push(Qt.resolvedUrl("StudentsVariantsPage.qml"), {
                            topic: topic,
                            studentCount: conductTestingPage.studentCount
                        })
                    }
                    onPressed: parent.color = "#3A4A52"
                    onReleased: parent.color = "#2A3A42"
                }
            }

            Rectangle {
                width: parent.width
                height: Theme.itemSizeMedium
                radius: height / 2
                color: pressed ? "#3A4A52" : "#2A3A42"
                border.color: "#3A4A52"
                border.width: 1

                Label {
                    text: qsTr("Проверить раздачу вариантов")
                    anchors.centerIn: parent
                    color: "#ECF0F1"
                    font.pixelSize: Theme.fontSizeMedium
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("VariantTestPage.qml"))
                    }
                    onPressed: parent.color = "#3A4A52"
                    onReleased: parent.color = "#2A3A42"
                }
            }
        }
    }
}
