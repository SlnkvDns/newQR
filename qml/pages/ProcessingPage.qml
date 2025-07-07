// SPDX-FileCopyrightText: 2023 Open Mobile Platform LLC <community@omp.ru>
// SPDX-License-Identifier: BSD-3-Clause
import QtQuick 2.6
import QtMultimedia 5.6
import Sailfish.Silica 1.0
import Aurora.Controls 1.0

Page {
    id: processingPage
    property string qrCodeData: ""

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
                text: qsTr("QR Code Content")
            }

            Label {
                width: parent.width - 2*Theme.horizontalPageMargin
                x: Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                text: qsTr("Raw data:")
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
            }

            TextArea {
                width: parent.width
                readOnly: true
                text: qrCodeData
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.Wrap
            }

            SectionHeader {
                text: qsTr("Formatted JSON")
                visible: jsonFormatted.visible
            }

            TextArea {
                id: jsonFormatted
                width: parent.width
                readOnly: true
                visible: isJsonValid(qrCodeData)
                text: formatJson(qrCodeData)
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.Wrap
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Back to Scan")
                onClicked: pageStack.pop()
            }
        }
    }

    function isJsonValid(jsonString) {
        try {
            JSON.parse(jsonString);
            return true;
        } catch(e) {
            return false;
        }
    }

    function formatJson(jsonString) {
        try {
            var jsonObj = JSON.parse(jsonString);
            return JSON.stringify(jsonObj, null, 4);
        } catch(e) {
            return jsonString;
        }
    }
}
