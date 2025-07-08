import QtQuick 2.6
import Sailfish.Silica 1.0

Page {
    id: confirmationPage
    objectName: "confirmationPage"
    property string deskNumber: "DESK_A1"

    Rectangle {
        anchors.fill: parent
        color: "#22333B"
    }

    // Верхний апбар
    Rectangle {
        width: parent.width
        height: Theme.itemSizeMedium
        color: "#1F252A"

        Text {
            text: qsTr("Подтверждение присутствия")
            anchors.centerIn: parent
            font.pixelSize: Theme.fontSizeLarge
            color: "#ECF0F1"
        }
    }

    // Голубой прямоугольник
    Rectangle {
        id: cardRect
        width: parent.width * 0.9
        height: 300
        radius: 40
        color: "#8EA8C3"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -Theme.itemSizeLarge * 1.5 // Чуть выше центра

        Column {
            anchors.centerIn: parent
            width: parent.width * 0.9
            spacing: Theme.paddingLarge * 2

            Text {
                text: qsTr("Ваша парта: %1").arg(deskNumber)
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeLarge
                color: "#2C3E50"
                font.bold: true
            }

            Rectangle {
                id: customButton
                width: parent.width * 0.6
                height: Theme.itemSizeLarge * 0.7
                radius: 30
                color: "#AEDBA8"
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    anchors.centerIn: parent
                    text: qsTr("Получить вариант")
                    color: "#2C3E50"
                    font.pixelSize: Theme.fontSizeMedium
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log("Запрос варианта для парты", deskNumber)
                    }
                }
            }
        }
    }

    // Надпись прямо над голубым прямоугольником
    Text {
        text: qsTr("Присутствие подтверждено")
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: cardRect.top
        anchors.bottomMargin: Theme.paddingLarge
        font.pixelSize: Theme.fontSizeLarge
        color: "#ECF0F1"
    }

    // Нижний текст
    Text {
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            margins: Theme.paddingLarge
        }
        text: qsTr("Вы сможете покинуть эту страницу в конце пары")
        font.pixelSize: Theme.fontSizeSmall
        color: "#BDC3C7"
        wrapMode: Text.Wrap
        width: parent.width * 0.8
        horizontalAlignment: Text.AlignHCenter
    }
}
