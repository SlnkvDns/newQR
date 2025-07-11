import QtQuick 2.6
import Sailfish.Silica 1.0

Page {
    id: registerPage

    property string supabaseUrl: "https://bunlbfktdfdtxuciapbo.supabase.co"
    property string supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ1bmxiZmt0ZGZkdHh1Y2lhcGJvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIyMTc0ODEsImV4cCI6MjA2Nzc5MzQ4MX0.TVfvRGNd0O5Qrzbwu2gnxYNCO0XZgdnPoj7fw88KTPs"
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
                    id: emailField
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
        var email = emailField.text;
        var password = passwordField.text;
        var role = isTeacher ? "teacher" : "student";

        // Показываем индикатор загрузки
        busyIndicator.running = true;
        errorLabel.text = "";

        // Шаг 1: Регистрация пользователя в Supabase Auth
        var authUrl = supabaseUrl + "/auth/v1/signup";
        var authXhr = new XMLHttpRequest();
        authXhr.open("POST", authUrl);
        authXhr.setRequestHeader("apikey", supabaseKey);
        authXhr.setRequestHeader("Content-Type", "application/json");

        var authData = {
            "email": email,
            "password": password,
            "options": {
                "data": {
                    "role": role
                }
            }
        };

        authXhr.onreadystatechange = function() {
            if (authXhr.readyState === XMLHttpRequest.DONE) {
                if (authXhr.status === 200) {
                    var authResponse = JSON.parse(authXhr.responseText);

                    // Шаг 2: Добавление в соответствующую таблицу
                    addUserToRoleTable(email, role);

                } else {
                    busyIndicator.running = false;
                    try {
                        var errorResponse = JSON.parse(authXhr.responseText);
                        errorLabel.text = errorResponse.error_description || qsTr("Ошибка регистрации");
                    } catch (e) {
                        errorLabel.text = qsTr("Ошибка сервера: ") + authXhr.status;
                    }
                }
            }
        };
        authXhr.send(JSON.stringify(authData));
    }

    function addUserToRoleTable(email, role) {
        var table = role === "teacher" ? "teachers" : "students";
        var idField = role === "teacher" ? "teacher_id" : "student_id";
        console.log("Table:", table)
        console.log("ID Field:", idField)

        var url = supabaseUrl + "/rest/v1/" + table;
        console.log("URL:", url)

        var xhr = new XMLHttpRequest();
        xhr.open("POST", url);
        xhr.setRequestHeader("apikey", supabaseKey);
        xhr.setRequestHeader("Authorization", "Bearer " + supabaseKey);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.setRequestHeader("Prefer", "return=minimal");

        var data = {
            "email": email,
        };

        console.log("Request data:", JSON.stringify(data))

        // Добавляем обработчики для всех состояний
        xhr.onreadystatechange = function() {
            console.log("ReadyState changed:", xhr.readyState)

            if (xhr.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
                console.log("Headers received")
            }
            else if (xhr.readyState === XMLHttpRequest.LOADING) {
                console.log("Loading response")
            }
            else if (xhr.readyState === XMLHttpRequest.DONE) {
                console.log("Request DONE, status:", xhr.status)
                busyIndicator.running = false;

                if (xhr.status === 201) {
                    console.log("Success! Response:", xhr.responseText)
                    pageStack.pop();
                } else {
                    console.log("Error! Response:", xhr.responseText)
                    try {
                        var errorResponse = JSON.parse(xhr.responseText);
                        errorLabel.text = qsTr("Ошибка при создании профиля: ") +
                                         (errorResponse.message || xhr.status);
                        deleteUser(userId);
                    } catch (e) {
                        errorLabel.text = qsTr("Ошибка сервера: ") + xhr.status;
                    }
                }
            }
        };

        // Добавляем обработчики ошибок
        xhr.onerror = function() {
            console.log("Network error occurred")
            busyIndicator.running = false;
            errorLabel.text = qsTr("Сетевая ошибка");
        };

        xhr.ontimeout = function() {
            console.log("Request timed out")
            busyIndicator.running = false;
            errorLabel.text = qsTr("Таймаут запроса");
        };

        console.log("Sending request...")
        xhr.send(JSON.stringify(data));
        console.log("Request sent")
    }

    function deleteUser(userId) {
        var url = supabaseUrl + "/auth/v1/admin/users/" + userId;
        var xhr = new XMLHttpRequest();
        xhr.open("DELETE", url);
        xhr.setRequestHeader("apikey", supabaseKey);
        xhr.setRequestHeader("Authorization", "Bearer " + supabaseKey);
        xhr.send();
    }
}
