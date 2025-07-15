import QtQuick 2.0
import Sailfish.Silica 1.0

ApplicationWindow {
    property color customBackground: "#22333B"
    Rectangle {
        anchors.fill: parent
        color: customBackground
        z: -1
    }
    objectName: "applicationWindow"
    initialPage: Qt.resolvedUrl("pages/LectorPage.qml")
    cover: Qt.resolvedUrl("cover/DefaultCoverPage.qml")
    allowedOrientations: defaultAllowedOrientations
}
