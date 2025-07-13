import QtQuick 2.6
import Sailfish.Silica 1.0
import ru.auroraos.QrCodeReader 1.0

Page {
    id: testPage

    property var scannedPlaces: []

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
            text: "Результаты раздачи вариантов"
            anchors.centerIn: parent
            font.pixelSize: Theme.fontSizeLarge
            color: "#ECF0F1"
        }
    }

    VariantDistributor {
        id: variantDistributor
    }

    SilicaFlickable {
        anchors {
            top: header.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        contentHeight: mainColumn.height

        Column {
            id: mainColumn
            width: parent.width * 0.95
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.paddingLarge

            Button {
                width: parent.width
                text: "Выполнить распределение"
                onClicked: distributeVariants()
            }

            ListView {
                id: resultsView
                width: parent.width
                height: testPage.height - header.height - Theme.itemSizeMedium - Theme.paddingLarge * 4
                model: []
                clip: true
                spacing: 1

                delegate: Rectangle {
                    width: parent.width
                    height: Theme.itemSizeSmall
                    color: index % 2 === 0 ? "#2A3A42" : "#22333B"

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.paddingMedium
                        anchors.rightMargin: Theme.paddingMedium
                        spacing: Theme.paddingMedium

                        Label {
                            width: parent.width * 0.4
                            text: modelData.place
                            color: "#ECF0F1"
                            font.pixelSize: Theme.fontSizeSmall
                            elide: Text.ElideRight
                        }

                        Label {
                            width: parent.width * 0.4
                            text: "Вар. " + modelData.variantNum
                            color: "#ECF0F1"
                            font.pixelSize: Theme.fontSizeSmall
                            font.bold: true
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }

                Label {
                    anchors.centerIn: parent
                    text: "Нет данных для отображения"
                    color: "#7F8C8D"
                    visible: resultsView.count === 0
                }
            }
        }
    }

    function distributeVariants() {
        var positions = scannedPlaces.length > 0 ? scannedPlaces : generateTestPositions();
        var result = variantDistributor.distributeVariants(positions, 5);

        resultsView.model = Object.keys(result).map(function(key) {
            return {
                place: key,
                variantNum: result[key],
                row: parseInt(key.match(/р(\d+)м/)[1]),
                seat: parseInt(key.match(/м(\d+)/)[1])
            };
        }).sort(sortByRowAndSeat);
    }

    function generateTestPositions() {
        var positions = [];
        for (var row = 1; row <= 5; row++) {
            for (var seat = 1; seat <= 6; seat++) {
                positions.push("р" + row + "м" + seat);
            }
        }
        return positions;
    }

    function sortByRowAndSeat(a, b) {
        return a.row === b.row ? a.seat - b.seat : a.row - b.row;
    }

    function loadScannedPlaces(places) {
        scannedPlaces = places;
    }
}
