// SPDX-FileCopyrightText: 2023 Open Mobile Platform LLC <community@omp.ru>
// SPDX-License-Identifier: BSD-3-Clause
import QtQuick 2.6
import QtMultimedia 5.6
import Sailfish.Silica 1.0
import Amber.QrFilter 1.0
import Aurora.Controls 1.0

Page {
    objectName: "recognitionPage"

    onVisibleChanged: {
        if (visible) {
            blackout.requestPaint(); // reload canvas
        }
    }

    AppBar {
        id: pageHeader

        headerText: appWindow.appName

        AppBarSpacer {
        }

        AppBarButton {
            context: qsTr("Create a QR-code")
            icon.source: "image://theme/icon-m-add"
            onClicked: pageStack.push(Qt.resolvedUrl("CreateQRCodePage.qml"))
        }

        AppBarSpacer {
        }

        AppBarButton {
            context: qsTr("About")
            icon.source: "image://theme/icon-m-about"
            onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
        }
    }

    QrFilter {
        id: qrFilter

        objectName: "qrFilter"
        active: true
    }

    VideoOutput {
        id: viewer

        objectName: "viewer"
        anchors {
            top: pageHeader.bottom
            left: parent.left
            right: parent.right
            bottom: shootButton.top
            bottomMargin: Theme.horizontalPageMargin
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
            frame.createObject(captureRect, {
                    "x": 0,
                    "y": 0
                });
            frame.createObject(captureRect, {
                    "x": captureRect.width,
                    "y": 0,
                    "rotation": 90
                });
            frame.createObject(captureRect, {
                    "x": captureRect.width,
                    "y": captureRect.height,
                    "rotation": 180
                });
            frame.createObject(captureRect, {
                    "x": 0,
                    "y": captureRect.height,
                    "rotation": -90
                });
        }
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

    Button {
        id: shootButton

        objectName: "shootButton"
        text: qsTr("Processing")
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: Theme.horizontalPageMargin
        }
        enabled: qrFilter.result.length !== 0

        onClicked: {
            pageStack.push(Qt.resolvedUrl("ProcessingPage.qml"), {
                    "qrCodeData": qrFilter.result
                });
            qrFilter.clearResult();
        }
    }

    Component {
        id: frame

        Item {
            Rectangle {
                id: verticalRect
                objectName: "verticalRect"

                anchors {
                    top: parent.top
                    left: parent.left
                }

                width: captureRect.width / 30
                height: captureRect.height / 6
                color: shootButton.enabled ? palette.primaryColor : Theme.rgba(Theme.secondaryColor, Theme.opacityLow)
            }

            Rectangle {
                objectName: "horizontalRect"

                anchors {
                    top: parent.top
                    left: verticalRect.right
                }

                width: captureRect.width / 6 - verticalRect.width
                height: captureRect.height / 30
                color: shootButton.enabled ? palette.primaryColor : Theme.rgba(Theme.secondaryColor, Theme.opacityLow)
            }
        }
    }
}
