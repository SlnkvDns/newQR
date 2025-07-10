import QtQuick 2.6
import Sailfish.Silica 1.0

Page {
    id: processingPage
    property string qrCodeData: ""

    property string supabaseUrl: "https://rgxmzhkosapntoiwdomg.supabase.co"
    property string supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJneG16aGtvc2FwbnRvaXdkb21nIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE3MTY3ODYsImV4cCI6MjA2NzI5Mjc4Nn0.ldRtDtg77-fqLk6n7ziXXI3RUEZ8GJm47yagBlzUyQw"

    property bool isSaving: false
    property bool saveSuccess: false
    property string errorMessage: ""

    Rectangle {
        anchors.fill: parent
        color: "#22333B"
    }

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

    Rectangle {
        id: cardRect
        width: parent.width * 0.9
        height: 300
        radius: 40
        color: "#8EA8C3"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -Theme.itemSizeLarge * 1.5

        Column {
            anchors.centerIn: parent
            width: parent.width * 0.9
            spacing: Theme.paddingLarge * 2

            Text {
                text: qsTr("Аудитория: ") + (jsonData.room || "не указано")
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeLarge
                color: "#2C3E50"
                font.bold: true
            }

            Text {
                text: qsTr("Номер места: ") + (jsonData.desk || "не указано")
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
                    text: qsTr("Отметиться")
                    color: "#2C3E50"
                    font.pixelSize: Theme.fontSizeMedium
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: saveToSupabase()
                }
            }
        }
    }

    Label {
        id: statusLabel
        anchors {
            top: cardRect.bottom
            topMargin: Theme.paddingLarge * 2
            horizontalCenter: parent.horizontalCenter
        }
        width: parent.width - 2 * Theme.horizontalPageMargin
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
        font.pixelSize: Theme.fontSizeMedium


        text: saveSuccess
              ? qsTr("Успешно сохранено!")
              : (errorMessage !== "" ? errorMessage : "")
        color: saveSuccess ? Theme.highlightColor : Theme.errorColor
        visible: saveSuccess || errorMessage !== ""
    }


    Text {
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            margins: Theme.paddingLarge
        }
        text: qsTr("Вы сможете покинуть приложение после отметки")
        font.pixelSize: Theme.fontSizeSmall
        color: "#BDC3C7"
        wrapMode: Text.Wrap
        width: parent.width * 0.8
        horizontalAlignment: Text.AlignHCenter
    }

    property var jsonData: {
        try {
            return JSON.parse(qrCodeData);
        } catch(e) {
            console.log("Ошибка парсинга JSON:", e);
            return {};
        }
    }

    function saveToSupabase() {
        isSaving = true;
        saveSuccess = false;
        errorMessage = "";

        var attendanceData = {
            room: jsonData.room,
            desk: jsonData.desk,
            check_in_time: new Date().toISOString(),
            student_login: jsonData.student_login
        };

        var xhr = new XMLHttpRequest();
        xhr.open("POST", supabaseUrl + "/rest/v1/scanned_data", true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.setRequestHeader("apikey", supabaseKey);
        xhr.setRequestHeader("Authorization", "Bearer " + supabaseKey);
        xhr.setRequestHeader("Prefer", "return=minimal");

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                isSaving = false;
                if (xhr.status >= 200 && xhr.status < 300) {
                    saveSuccess = true;
                    console.log("Данные успешно сохранены в Supabase");
                } else {
                    errorMessage = qsTr("Ошибка при сохранении: ") +
                                 (xhr.statusText || qsTr("неизвестная ошибка"));
                    console.error("Ошибка Supabase:", xhr.status, xhr.responseText);
                }
            }
        };

        xhr.send(JSON.stringify(attendanceData));
    }
}
