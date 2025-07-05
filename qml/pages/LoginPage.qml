import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: loginPage

    property string username: ""
    property string password: ""

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: Theme.paddingLarge

            Label {
                text: "Вход"
                font.pixelSize: Theme.fontSizeExtraLarge
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
            }

            TextField {
                id: usernameField
                label: "Имя пользователя"
                width: parent.width * 0.9
                onTextChanged: username = text
            }

            TextField {
                id: passwordField
                label: "Пароль"
                echoMode: TextInput.Password
                width: parent.width * 0.9
                onTextChanged: password = text
            }

            Button {
                text: "Войти"
                width: parent.width * 0.9
                onClicked: {
                    if (false) {
                        errorLabel.text = "Заполните все поля"
                    } else {
                        errorLabel.text = "Вход выполнен (эмуляция)"
                        console.log("Логин:", username, "Пароль:", password)
                        pageStack.push(Qt.resolvedUrl("QrScannerPage.qml"))
                    }
                }
            }

            Label {
                id: errorLabel
                text: ""
                color: "red"
                font.pixelSize: Theme.fontSizeSmall
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
                wrapMode: Text.Wrap
            }

            Button {
                text: "Регистрация"
                width: parent.width * 0.9
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("RegisterPage.qml"))
                }
            }
        }
    }
}
