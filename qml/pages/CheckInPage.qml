// SPDX-FileCopyrightText: 2023 Open Mobile Platform LLC <community@omp.ru>
// SPDX-License-Identifier: BSD-3-Clause
import QtQuick 2.6
import QtMultimedia 5.6
import Sailfish.Silica 1.0
import Aurora.Controls 1.0


Page {
    id: processingPage
    property string qrCodeData: ""

    property string supabaseUrl: "https://rgxmzhkosapntoiwdomg.supabase.co"
    property string supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJneG16aGtvc2FwbnRvaXdkb21nIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE3MTY3ODYsImV4cCI6MjA2NzI5Mjc4Nn0.ldRtDtg77-fqLk6n7ziXXI3RUEZ8GJm47yagBlzUyQw"

    property bool isSaving: false
    property bool saveSuccess: false
    property string errorMessage: ""

    AppBar {
        id: pageHeader
        headerText: appWindow.appName
    }

    SilicaFlickable {
        anchors {
            top: pageHeader.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        contentHeight: contentColumn.height

        Column {
            id: contentColumn
            width: parent.width
            spacing: Theme.paddingLarge

            SectionHeader {
                text: qsTr("Информация о месте")
            }

            Label {
                width: parent.width - 2*Theme.horizontalPageMargin
                x: Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                text: qsTr("Аудитория: ") + (jsonData.room || "не указана")
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeMedium
            }

            Label {
                width: parent.width - 2*Theme.horizontalPageMargin
                x: Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                text: qsTr("Номер места: ") + (jsonData.desk || "не указано")
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeMedium
            }

            Button {
                id: checkInButton
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Отметиться")
                enabled: !isSaving && jsonData.room && jsonData.desk
                onClicked: saveToSupabase()

                BusyIndicator {
                    anchors.centerIn: parent
                    size: BusyIndicatorSize.Small
                    running: isSaving
                }
            }

            Label {
                visible: saveSuccess
                width: parent.width - 2*Theme.horizontalPageMargin
                x: Theme.horizontalPageMargin
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                text: qsTr("Успешно сохранено!")
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall
            }

            Label {
                visible: errorMessage !== ""
                width: parent.width - 2*Theme.horizontalPageMargin
                x: Theme.horizontalPageMargin
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                text: errorMessage
                color: Theme.errorColor
                font.pixelSize: Theme.fontSizeSmall
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("На страницу студента")
                onClicked: pageStack.push(Qt.resolvedUrl("StudentPage.qml"))
            }
        }
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
            student_id: "123456"
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
