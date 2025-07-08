import QtQuick 2.6
import Sailfish.Silica 1.0

Page {
    id: registerPage

    property string supabaseUrl: "https://rgxmzhkosapntoiwdomg.supabase.co"
    property string supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJneG16aGtvc2FwbnRvaXdkb21nIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE3MTY3ODYsImV4cCI6MjA2NzI5Mjc4Nn0.ldRtDtg77-fqLk6n7ziXXI3RUEZ8GJm47yagBlzUyQw"
    property bool isTeacher: false

    property string username: ""
    property string password: ""

    Rectangle {
        anchors.fill: parent
        color: "#22333B"
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: mainColumn.implicitHeight

        Column {
            id: mainColumn
            width: parent.width
            spacing: Theme.paddingLarge
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: parent.height * 0.2

            Label {
                text: qsTr("Регистрация")
                font.pixelSize: Theme.fontSizeExtraLarge
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
                color: "#ECF0F1"
            }

            Item { width: 1; height: Theme.paddingSmall * 1.5 }

            // Кнопка выбора типа пользователя
            Rectangle {
                width: parent.width * 0.6
                height: 50
                radius: 25
                color: isTeacher ? "#998EA8C3" : "#991F252A"
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    anchors.centerIn: parent
                    text: isTeacher ? qsTr("Преподаватель") : qsTr("Студент")
                    color: "#ECF0F1"
                    font.pixelSize: Theme.fontSizeMedium
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: isTeacher = !isTeacher
                }
            }

            Item { width: 1; height: Theme.paddingMedium }

            Column {
                width: parent.width
                spacing: Theme.paddingSmall * 0.8
                anchors.horizontalCenter: parent.horizontalCenter

                TextField {
                    id: usernameField
                    width: parent.width * 0.8
                    placeholderText: qsTr("Имя пользователя")
                    color: "#ECF0F1"
                    font.pixelSize: Theme.fontSizeMedium
                    horizontalAlignment: Text.AlignLeft
                    anchors.horizontalCenter: parent.horizontalCenter
                    onTextChanged: username = text
                }

                TextField {
                    id: passwordField
                    width: parent.width * 0.8
                    placeholderText: qsTr("Пароль")
                    echoMode: TextInput.Password
                    color: "#ECF0F1"
                    font.pixelSize: Theme.fontSizeMedium
                    horizontalAlignment: Text.AlignLeft
                    anchors.horizontalCenter: parent.horizontalCenter
                    onTextChanged: password = text
                }
            }

            Item { width: 1; height: Theme.paddingLarge }

            Column {
                width: parent.width
                spacing: 40
                anchors.horizontalCenter: parent.horizontalCenter

                // Кнопка регистрации
                Rectangle {
                    width: parent.width * 0.6
                    height: 64
                    radius: height / 2
                    color: "#998EA8C3"
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        anchors.centerIn: parent
                        text: qsTr("Зарегистрироваться")
                        color: "#ECF0F1"
                        font.pixelSize: Theme.fontSizeLarge
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (username === "" || password === "") {
                                errorLabel.text = qsTr("Пожалуйста, заполните все поля")
                            } else {
                                registerUser()
                            }
                        }
                    }
                }

                Rectangle {
                    width: parent.width * 0.4
                    height: 64
                    radius: height / 2
                    color: "#991F252A"
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        anchors.centerIn: parent
                        text: qsTr("Назад")
                        color: "#BDC3C7"
                        font.pixelSize: Theme.fontSizeMedium
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: pageStack.pop()
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

            BusyIndicator {
                id: busyIndicator
                size: BusyIndicatorSize.Medium
                anchors.horizontalCenter: parent.horizontalCenter
                running: false
            }
        }
    }

    function registerUser() {
        busyIndicator.running = true
        errorLabel.text = ""

        var table = isTeacher ? "lectors" : "students"
        var url = supabaseUrl + "/rest/v1/" + table

        var data = {
            "name": username,
            "password": password
        }

        if (isTeacher) {
            data = {
                "lector_name": username,
                "lector_password": password
            }
        } else {
            data = {
                "student_name": username,
                "student_password": password
            }
        }

        var xhr = new XMLHttpRequest()
        xhr.open("POST", url)
        xhr.setRequestHeader("apikey", supabaseKey)
        xhr.setRequestHeader("Authorization", "Bearer " + supabaseKey)
        xhr.setRequestHeader("Content-Type", "application/json")
        xhr.setRequestHeader("Prefer", "return=minimal")

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                busyIndicator.running = false

                if (xhr.status === 201) {
                    errorLabel.color = "green"
                    errorLabel.text = qsTr("Регистрация успешна!")
                    console.log("User registered:", username)

                    pageStack.replace(Qt.resolvedUrl("LoginPage.qml"))

                } else {
                    errorLabel.color = "red"
                    if (xhr.status === 409) {
                        errorLabel.text = qsTr("Пользователь с таким именем уже существует")
                    } else {
                        errorLabel.text = qsTr("Ошибка регистрации: ") + xhr.status + " - " + xhr.responseText
                    }
                }
            }
        }

        xhr.send(JSON.stringify(data))
    }
}
