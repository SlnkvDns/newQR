import QtQuick 2.6
import Sailfish.Silica 1.0

Page {
    id: viewResultsPage
    objectName: "viewResultsPage"

    property var resultsModel: [
        { name: "Студент 1", desk: "1", score: "8/10" },
        { name: "Студент 2", desk: "2", score: "6/10" },
        { name: "Студент 3", desk: "3", score: "10/10" },
        { name: "Студент 4", desk: "4", score: "7/10" },
        { name: "Студент 5", desk: "5", score: "9/10" },
        { name: "Студент 6", desk: "6", score: "5/10" }
    ]

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
            text: qsTr("Результаты тестирования")
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
        contentHeight: resultsColumn.height + Theme.paddingLarge * 2
        clip: true

        Column {
            id: resultsColumn
            width: parent.width * 0.9
            anchors.horizontalCenter: parent.horizontalCenter
            topPadding: Theme.paddingLarge
            spacing: Theme.paddingMedium

            Label {
                text: qsTr("Список результатов")
                color: "#ECF0F1"
                font.pixelSize: Theme.fontSizeMedium
                anchors.horizontalCenter: parent.horizontalCenter
                font.bold: true
                bottomPadding: Theme.paddingMedium
            }

            Repeater {
                model: viewResultsPage.resultsModel

                Rectangle {
                    width: parent.width
                    height: Theme.itemSizeSmall + Theme.paddingSmall
                    color: "#2A3A42"
                    radius: Theme.paddingSmall
                    border.color: "#3A4A52"
                    border.width: 1

                    Row {
                        anchors {
                            fill: parent
                            margins: Theme.paddingMedium
                        }
                        spacing: Theme.paddingMedium

                        Label {
                            text: modelData.name
                            color: "#ECF0F1"
                            font.pixelSize: Theme.fontSizeSmall
                            width: parent.width * 0.4
                            elide: Text.ElideRight
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Label {
                            text: qsTr("Парта: ") + modelData.desk
                            color: "#ECF0F1"
                            font.pixelSize: Theme.fontSizeSmall
                            width: parent.width * 0.3
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Label {
                            text: modelData.score
                            color: "#ECF0F1"
                            font.pixelSize: Theme.fontSizeSmall
                            width: parent.width * 0.2
                            horizontalAlignment: Text.AlignRight
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
        }
    }
}
