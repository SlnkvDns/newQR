import QtQuick 2.6
import Sailfish.Silica 1.0
import ru.auroraos.QrCodeReader 1.0

Page {
    id: testPage
    property var scannedPlaces: []
    property string selectedRoom: ""
    property bool isLoadingRooms: false
    ListModel {
        id: roomListModel
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
            text: "Результаты раздачи вариантов"
            anchors.centerIn: parent
            font.pixelSize: Theme.fontSizeLarge
            color: "#ECF0F1"
        }
    }

    VariantDistributor {
        id: variantDistributor
    }

    // Подписываемся на сигнал здесь
    Component.onCompleted: {
        supabase.uniqueValuesLoaded.connect(loadRoomsCallback)
        supabase.desksByRoomLoaded.connect(loadDesksCallback)

        console.log("Компонент загружен, начинаем загрузку аудиторий")
        loadRooms()
    }

    function loadRooms() {
        if (isLoadingRooms || roomListModel.count > 0) return;

        isLoadingRooms = true
        console.log("Загружаем список аудиторий...")
        supabase.loadUniqueValues("scanned_data", "room")
    }

    function loadRoomsCallback(values) {
        console.log("Получены значения аудиторий:", JSON.stringify(values))
        roomListModel.clear()
        isLoadingRooms = false

        if (values.length === 0) {
            roomListModel.append({ text: "Нет доступных аудиторий" })
        } else {
            for (var i = 0; i < values.length; i++) {
                var roomValue = values[i]
                if (roomValue && roomValue.trim().length > 0 && roomValue !== "--") {
                    roomListModel.append({ text: roomValue })
                    console.log("Добавлено в модель:", roomValue)
                }
            }
        }

        console.log("Количество элементов в roomListModel:", roomListModel.count)
    }

    function loadDesksCallback(desks) {
        console.log("Получены места:", desks)
        scannedPlaces = desks || []
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

            function loadDesksForRoom(room) {
                console.log("Загружаем места для аудитории:", room)
                if (supabase) {
                    supabase.loadDesksByRoom(room)
                } else {
                    console.log("supabase не инициализирован")
                }
            }

            ValueButton {
                id: roomSelectorButton
                width: parent.width
                label: "Аудитория"
                value: selectedRoom !== "" ? selectedRoom : "Выберите аудиторию"
                onClicked: {
                    console.log("Кнопка нажата, проверяем данные...")
                    console.log("roomListModel.count:", roomListModel.count)

                    if (roomListModel.count === 0 && !isLoadingRooms) {
                        isLoadingRooms = true
                        supabase.loadUniqueValues("scanned_data", "room")
                    } else {
                        var dlg = roomMenuDialog.createObject(testPage, {"parent": testPage})
                        if (dlg) {
                            console.log("Диалог создан, открываем...")
                            dlg.open()
                        } else {
                            console.log("Ошибка: диалог не создан")
                        }
                    }
                }
            }

            TextField {
                id: variantCountField
                width: parent.width
                placeholderText: "Введите количество вариантов"
                inputMethodHints: Qt.ImhDigitsOnly
            }

            Button {
                width: parent.width
                text: "Выполнить распределение"
                enabled: scannedPlaces.length > 0
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

    Component {
        id: roomMenuDialog
        Dialog {
            id: roomPicker
            canAccept: true
            allowedOrientations: Orientation.All

            Column {
                width: parent.width
                spacing: Theme.paddingLarge

                DialogHeader {
                    acceptText: "Выбрать"
                    cancelText: "Отмена"
                }

                SilicaListView {
                    width: parent.width
                    height: contentHeight > 0 ? contentHeight : parent.height - y
                    model: roomListModel
                    clip: true

                    delegate: ListItem {
                        width: parent.width
                        height: Theme.itemSizeMedium

                        Label {
                            anchors.centerIn: parent
                            text: model.text
                            color: "red"
                        }

                        onClicked: {
                            selectedRoom = model.text
                            roomSelectorButton.value = model.text
                            mainColumn.loadDesksForRoom(model.text)
                            roomPicker.accept()
                            console.log("Выбрана аудитория:", model.text)
                        }
                    }
                }
            }

            onAccepted: {
                console.log("Диалог принят")
            }

            onRejected: {
                console.log("Диалог закрыт")
            }
        }
    }

    function distributeVariants() {
        var positions = scannedPlaces.length === 0 ? generateTestPositions() : scannedPlaces
        var variantCount = parseInt(variantCountField.text) || 5
        var result = variantDistributor.distributeVariants(positions, variantCount)

        resultsView.model = Object.keys(result).map(function(key) {
            return {
                place: key,
                variantNum: result[key],
                row: parseInt(key.match(/р(\d+)м/)[1] || 0),
                seat: parseInt(key.match(/м(\d+)/)[1] || 0)
            }
        }).sort(sortByRowAndSeat)
    }

    function generateTestPositions() {
        var positions = []
        for (var row = 1; row <= 5; row++) {
            for (var seat = 1; seat <= 6; seat++) {
                positions.push("р" + row + "м" + seat)
            }
        }
        return positions
    }

    function sortByRowAndSeat(a, b) {
        return a.row === b.row ? a.seat - b.seat : a.row - b.row
    }
}
