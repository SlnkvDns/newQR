import QtQuick 2.6
import Sailfish.Silica 1.0

Item {
    id: attendanceRow
    width: parent.width
    height:  seatField.height+ Theme.paddingMedium

    property int studentId: 0
    property string studentName: ""
    property string roomNumber: ""
    property string deskNumber: ""
    property string attendanceStatus: ""
    property bool isAttend: true
    property bool editMode: false
    property bool showPopup: false

    signal statusChanged(string newStatus)
    signal seatChanged(string newDesk)

    Row {
        width: parent.width - 2*Theme.horizontalPageMargin
        x: Theme.horizontalPageMargin
        spacing: Theme.paddingMedium
        anchors.verticalCenter: parent.verticalCenter

        Item {
            width: parent.width * 0.6
            height: nameLabel.height

            Label {
                id: nameLabel
                width: parent.width
                text: studentName
                truncationMode: TruncationMode.Fade
                maximumLineCount: 1
                color: isAttend ? Theme.highlightColor : "white"
                font.bold: isAttend
            }


            MouseArea {
                anchors.fill: parent
                onClicked: showPopup = !showPopup
            }
        }

        MouseArea {
            id: statusBox
            width: parent.width * 0.2
            height: statusLabel.height
            property var statusOptions: ["Пр", "Ув", "Не.ув"]
            property int currentStatusIndex: statusOptions.indexOf(attendanceStatus)

            Rectangle {
                id: statusBg
                anchors.fill: parent
                radius: Theme.paddingSmall
                color: getStatusColor(attendanceStatus)

                function getStatusColor(status) {
                    switch(status) {
                        case "Пр": return Theme.rgba(Theme.highlightColor, 0.4);
                        case "Ув": return Theme.rgba("#FFA000", 0.4);
                        case "Не.ув": return Theme.rgba("#F44336", 0.4);
                        default: return "transparent";
                    }
                }

                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
            }

            Label {
                id: statusLabel
                anchors.centerIn: parent
                text: attendanceStatus
                font.bold: true
                color: getStatusTextColor(attendanceStatus)

                function getStatusTextColor(status) {
                    switch(status) {
                        case "Пр": return Theme.highlightColor;
                        case "Ув": return "#FFA000";
                        case "Не.ув": return "#F44336";
                        default: return Theme.primaryColor;
                    }
                }
            }

            onClicked: {
                currentStatusIndex = (currentStatusIndex + 1) % statusOptions.length
                var newStatus = statusOptions[currentStatusIndex]
                statusChanged(newStatus)
                statusBg.color = statusBg.getStatusColor(newStatus)
                statusLabel.color = statusLabel.getStatusTextColor(newStatus)
                statusLabel.text = newStatus
            }
        }


        Item {
            id: seatField
            width: parent.width * 0.2
            height: Math.max(seatLabel.height, seatInput.height)

            Label {
                id: seatLabel
                anchors.fill: parent
                visible: !editMode
                text: deskNumber !== "--" ? deskNumber : "--"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                truncationMode: TruncationMode.Fade
                color: "white"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (isAttend)
                            editMode = true
                    }
                }
            }

            TextField {
                id: seatInput
                anchors.fill: parent
                visible: editMode
                text: deskNumber !== "--" ? deskNumber : ""
                placeholderText: "--"
                horizontalAlignment: Text.AlignHCenter
                labelVisible: false
                color: "black"

                EnterKey.enabled: text.length > 0
                onActiveFocusChanged: {
                               if (!activeFocus && editMode) {
                                   var newDesk = text.trim() === "" ? "--" : text.trim();
                                   console.log(newDesk)
                                   deskNumber = newDesk;
                                   seatChanged(newDesk);
                                   editMode = false;
                               }
                           }
            }
        }
    }
    Rectangle {
        id: namePopup
        visible: showPopup
        width: popupLabel.width * 1.1
        height: nameLabel.height
        color: "white"
        border.color: "black"
        radius: Theme.paddingSmall


        Label {
            id: popupLabel
            text: studentName
            color: "black"
            horizontalAlignment: Text.AlignHCenter
        }
    }


    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: Theme.secondaryColor
        opacity: 0.2
    }
}
