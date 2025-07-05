// QrScannerPage.qml
import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.6
import QZXing 3.3

Page {
    id: page

    property string supabaseUrl: "https://rgxmzhkosapntoiwdomg.supabase.co"
    property string supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJneG16aGtvc2FwbnRvaXdkb21nIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE3MTY3ODYsImV4cCI6MjA2NzI5Mjc4Nn0.ldRtDtg77-fqLk6n7ziXXI3RUEZ8GJm47yagBlzUyQw"
    property string tableName: "scanned_data"

    function insertToDatabase(qrData) {
        var xhr = new XMLHttpRequest();
        var url = supabaseUrl + "/rest/v1/" + tableName;
        var data = JSON.stringify({ text: qrData });

        xhr.open("POST", url);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.setRequestHeader("apikey", supabaseKey);
        xhr.setRequestHeader("Authorization", "Bearer " + supabaseKey);
        xhr.setRequestHeader("Prefer", "return=minimal");

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 201) {
                    console.log("Данные сохранены:", qrData)
                    pageStack.pop()
                } else {
                    console.error("Ошибка сохранения:", xhr.status, xhr.responseText)
                }
            }
        }
        xhr.send(data);
    }

    Camera {
        id: camera
        captureMode: Camera.CaptureViewfinder
        focus {
            focusMode: CameraFocus.FocusContinuous
            focusPointMode: CameraFocus.FocusPointAuto
        }
    }

    VideoOutput {
        id: videoOutput
        anchors.fill: parent
        source: camera
        autoOrientation: true
        filters: [zxingFilter]
    }

    QZXingFilter {
        id: zxingFilter
        decoder {
            enabledDecoders: QZXing.DecoderFormat_QR_CODE
            tryHarder: true
            onTagFound: {
                console.log("Найден QR:", tag)
                camera.stop()
                insertToDatabase(tag)
            }
        }

        captureRect: Qt.rect(0, 0, 640, 480)
    }

    Timer {
        interval: 300
        running: true
        repeat: false
        onTriggered: {
            if (videoOutput.sourceRect.width > 0 && videoOutput.sourceRect.height > 0) {
                zxingFilter.captureRect = Qt.rect(
                    0,
                    0,
                    videoOutput.sourceRect.width,
                    videoOutput.sourceRect.height
                )
                console.log("captureRect обновлён:", zxingFilter.captureRect)
            }
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height) * 0.7
        height: width
        color: "transparent"
        border {
            color: Theme.highlightColor
            width: 4
        }
    }

    Component.onCompleted: camera.start()
}

