import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: registerPage

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
                text: "Регистрация"
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
                text: "Зарегистрироваться"
                width: parent.width * 0.9
                onClicked: {
                    if (username === "" || password === "") {
                        errorLabel.text = "Пожалуйста, заполните все поля"
                    } else {
                        errorLabel.text = "Регистрация выполнена (эмуляция)"
                        console.log("Регистрация:", username, password)
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
                text: "Назад ко входу"
                width: parent.width * 0.9
                onClicked: pageStack.pop()
            }
        }
    }
}
