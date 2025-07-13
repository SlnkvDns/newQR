import QtQuick 2.6
import Sailfish.Silica 1.0

Page {
    id: loginPage

    property string supabaseUrl: "https://rgxmzhkosapntoiwdomg.supabase.co"
    property string supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJneG16aGtvc2FwbnRvaXdkb21nIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE3MTY3ODYsImV4cCI6MjA2NzI5Mjc4Nn0.ldRtDtg77-fqLk6n7ziXXI3RUEZ8GJm47yagBlzUyQw"

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
            anchors.topMargin: parent.height * 0.3


            Rectangle {
                width: 220
                height: 220
                radius: width / 2
                color: "#1F252A"
                opacity: 0.15
                anchors.horizontalCenter: parent.horizontalCenter
                border.color: "#BDC3C7"
                border.width: 2

                Image {
                    width: 150
                    height: 150
                    anchors.centerIn: parent
                    source: "../images/education.png"
                    fillMode: Image.PreserveAspectFit
                }
            }

            Item { width: 1; height: Theme.paddingLarge * 1.5 }

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
                }

                TextSwitch {
                    id: teacherSwitch
                    text: qsTr("Войти как преподаватель")
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            Item { width: 1; height: Theme.paddingLarge }


            Column {
                width: parent.width
                spacing: 40
                anchors.horizontalCenter: parent.horizontalCenter


                Rectangle {
                    width: parent.width * 0.4
                    height: 64
                    radius: height / 2
                    color: "#998EA8C3"
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        anchors.centerIn: parent
                        text: qsTr("Войти")
                        color: "#ECF0F1"
                        font.pixelSize: Theme.fontSizeLarge
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (usernameField.text === "" || passwordField.text === "") {
                                errorLabel.text = qsTr("Заполните все поля")
                            } else {
                                errorLabel.text = ""
                                loginUser()
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
                        text: qsTr("Регистрация")
                        color: "#BDC3C7"
                        font.pixelSize: Theme.fontSizeMedium
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: pageStack.push(Qt.resolvedUrl("RegisterPage.qml"))
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
        }
    }

    function loginUser() {
        var table = teacherSwitch.checked ? "lectors" : "students"
        var nameColumn = teacherSwitch.checked ? "lector_login" : "student_login"
        var passwordColumn = teacherSwitch.checked ? "lector_password" : "student_password"

        var url = supabaseUrl + "/rest/v1/" + table +
                  "?" + nameColumn + "=eq." + encodeURIComponent(usernameField.text) +
                  "&" + passwordColumn + "=eq." + encodeURIComponent(passwordField.text) +
                  "&select=*"

        var xhr = new XMLHttpRequest()
        xhr.open("GET", url)
        xhr.setRequestHeader("apikey", supabaseKey)
        xhr.setRequestHeader("Authorization", "Bearer " + supabaseKey)

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var response = JSON.parse(xhr.responseText)
                    if (response.length > 0) {
                        var user = response[0]
                        console.log("User logged in:", user)
                        if (teacherSwitch.checked) {
                            pageStack.push(Qt.resolvedUrl("LectorPage.qml"))
                        } else {
                            pageStack.push(Qt.resolvedUrl("QrScannerPage.qml"), {
                                "studentLogin": usernameField.text
                            })
                        }
                    } else {
                        errorLabel.text = qsTr("Неверные учетные данные")
                    }
                } else {
                    errorLabel.text = qsTr("Ошибка сервера: ") + xhr.status
                }
            }
        }
        xhr.send()
    }
}

