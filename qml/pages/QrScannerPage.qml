import QtQuick 2.6
import QtMultimedia 5.6
import Sailfish.Silica 1.0
import Amber.QrFilter 1.0
import Aurora.Controls 1.0

Page {
    id: recognitionPage
    objectName: "recognitionPage"

    property string studentLogin: ""

    onVisibleChanged: {
        if (visible) {
            blackout.requestPaint();
        }
    }

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
            text: qsTr("Сканирование")
            anchors.centerIn: parent
            font.pixelSize: Theme.fontSizeLarge
            color: "#ECF0F1"
        }
    }

    QrFilter {
        id: qrFilter
        objectName: "qrFilter"
        active: true

        onResultChanged: {
            if (result && result.length > 0) {
                pageStack.push(Qt.resolvedUrl("StudentPage.qml"), {
                    "qrCodeData": result.trim(), "studentLogin": studentLogin
                })
                clearResult()
            }
        }
    }

    VideoOutput {
        id: viewer
        objectName: "viewer"
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: bottomMenu.top
        }
        fillMode: VideoOutput.PreserveAspectFit
        source: Camera {
            captureMode: Camera.CaptureVideo
            focus {
                focusMode: CameraFocus.FocusContinuous
                focusPointMode: CameraFocus.FocusPointAuto
            }
        }
        filters: [qrFilter]
    }

    Rectangle {
        id: captureRect
        objectName: "captureRect"
        anchors.centerIn: viewer
        width: Math.min(viewer.width, viewer.height) * 0.7
        height: width
        color: "transparent"

        Component.onCompleted: {
            frame.createObject(captureRect, { "x": 0, "y": 0 });
            frame.createObject(captureRect, { "x": captureRect.width, "y": 0, "rotation": 90 });
            frame.createObject(captureRect, { "x": captureRect.width, "y": captureRect.height, "rotation": 180 });
            frame.createObject(captureRect, { "x": 0, "y": captureRect.height, "rotation": -90 });
        }
    }


    Label {
        text: qsTr("Отсканируйте QR-код на парте")
        anchors.top: captureRect.bottom
        anchors.topMargin: Theme.paddingMedium
        anchors.horizontalCenter: parent.horizontalCenter
        color: "#ECF0F1"
        font.pixelSize: Theme.fontSizeMedium - 2
    }


    Canvas {
        id: blackout
        objectName: "blackout"
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d");
            ctx.fillStyle = Theme.rgba(Theme.overlayBackgroundColor, Theme.opacityHigh);
            ctx.beginPath();
            ctx.fillRect(viewer.x, viewer.y, viewer.width, viewer.height);
            ctx.closePath();
            ctx.fill();
            ctx.clearRect(captureRect.x, captureRect.y, captureRect.width, captureRect.height);
        }
    }


    Rectangle {
        id: bottomMenu
        width: parent.width
        height: 140
        color: "#1F252A"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom

        Rectangle {
            id: circleBackground
            width: 150
            height: 150
            radius: width / 2
            color: "#1F252A"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.top
            anchors.bottomMargin: -height / 1.5
        }

        Rectangle {
            id: qrCircle
            width: 80
            height: 80
            radius: width / 2
            color: "#1F252A"
            border.color: "#3A4A52"
            border.width: 2
            anchors.centerIn: circleBackground

            Image {
                id: qrIcon
                source: "../images/scan-code-qr.png"
                width: 60
                height: 60
                anchors.centerIn: parent
                fillMode: Image.PreserveAspectFit
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    qrFilter.clearResult()
                }
            }
        }
    }

    Button {
        id: testButton
        text: "Тест"
        anchors.bottom: bottomMenu.top
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingLarge
        anchors.bottomMargin: Theme.paddingMedium
        onClicked: {
            var fakeResult = JSON.stringify({ "room": "342", "desk": "42" });
            pageStack.push(Qt.resolvedUrl("StudentPage.qml"), {
                "qrCodeData": fakeResult.trim(), "studentLogin": studentLogin
            });
        }
    }


    Component {
        id: frame

        Item {
            Rectangle {
                id: verticalRect
                objectName: "verticalRect"
                anchors.top: parent.top
                anchors.left: parent.left
                width: captureRect.width / 50
                height: captureRect.height / 10
                color: palette.primaryColor
            }

            Rectangle {
                objectName: "horizontalRect"
                anchors.top: parent.top
                anchors.left: verticalRect.right
                width: captureRect.width / 10 - verticalRect.width
                height: captureRect.height / 50
                color: palette.primaryColor
            }
        }
    }
}
