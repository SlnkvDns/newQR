import QtQuick 2.0

QtObject {
    id: root


    property string url: "https://rgxmzhkosapntoiwdomg.supabase.co"
    property string key: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJneG16aGtvc2FwbnRvaXdkb21nIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE3MTY3ODYsImV4cCI6MjA2NzI5Mjc4Nn0.ldRtDtg77-fqLk6n7ziXXI3RUEZ8GJm47yagBlzUyQw"


    signal studentsLoaded(var students)
    signal scannedStudentsLoaded(var scannedStudents)
    signal updateFinished(bool success)
    signal errorOccurred(string message)


    function getAllStudents() {
        var xhr = new XMLHttpRequest()
        var requestUrl = url + "/rest/v1/group?select=id,name,status"

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    studentsLoaded(JSON.parse(xhr.responseText))
                } else {
                    errorOccurred("Ошибка получения студентов: " + xhr.statusText)
                }
            }
        }

        xhr.open("GET", requestUrl, true)
        xhr.setRequestHeader("apikey", key)
        xhr.setRequestHeader("Content-Type", "application/json")
        xhr.send()
    }


    function getScannedStudents() {
        var xhr = new XMLHttpRequest()
        var requestUrl = url + "/rest/v1/scanned_data?select=id,room,desk,student_login,check_in_time"

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    scannedStudentsLoaded(JSON.parse(xhr.responseText))
                } else {
                    errorOccurred("Ошибка получения отметившихся: " + xhr.statusText)
                }
            }
        }

        xhr.open("GET", requestUrl, true)
        xhr.setRequestHeader("apikey", key)
        xhr.setRequestHeader("Content-Type", "application/json")
        xhr.send()
    }

    function updateStudentsInfo(changes, delete_students,  callback) {
        if (!changes || changes.length === 0) {
            if (typeof callback === "function") callback(true);
            return;
        }

        updateStudentsStatus(changes, function(groupSuccess) {
            if (!groupSuccess) {
                console.error("Failed to update group table");
                if (typeof callback === "function") callback(false);
                return;
            }

            updateStudentsDesk(changes, delete_students, function(scannedSuccess) {
                if (typeof callback === "function") {
                    callback(groupSuccess && scannedSuccess);
                }
            });
        });
    }


    function updateStudentsStatus(changes,  callback) {
              var xhr = new XMLHttpRequest();
              var apiUrl = url + "/rest/v1/group";

               xhr.onreadystatechange = function() {
                   if (xhr.readyState === XMLHttpRequest.DONE) {
                       if (xhr.status === 200 || xhr.status === 201 || xhr.status === 204) {
                           if (typeof callback === "function") callback(true);
                       } else {
                           console.error("Bulk update error:", xhr.status, xhr.responseText);
                           if (typeof callback === "function") callback(false);
                       }
                   }
               };

               xhr.open("POST", apiUrl, true);
               xhr.setRequestHeader("apikey", key);
               xhr.setRequestHeader("Content-Type", "application/json");
               xhr.setRequestHeader("Prefer", "resolution=merge-duplicates");

               var updates = changes.map(function(change) {
                   return {
                       id: change.id,
                       status: change.status,
                       name: change.name
                   };
               });

               xhr.send(JSON.stringify(updates));
               return;
    }


    function updateStudentsDesk(changes, delete_students,  callback){


        if (delete_students && delete_students.length > 0) {
                var deleteUrl = url + "/rest/v1/scanned_data?id=in.(" + delete_students.join(",") + ")";
                var deleteXhr = new XMLHttpRequest();

                deleteXhr.onreadystatechange = function() {
                    if (deleteXhr.readyState === XMLHttpRequest.DONE) {
                        if (deleteXhr.status === 200 || deleteXhr.status === 204) {
                            console.log("Удалено записей:", delete_students.length);
                        } else {
                            console.error("Delete error:", deleteXhr.status, deleteXhr.responseText);
                            if (typeof callback === "function") callback(false);
                        }
                    }
                };

                deleteXhr.open("DELETE", deleteUrl, true);
                deleteXhr.setRequestHeader("apikey", key);
                deleteXhr.setRequestHeader("Content-Type", "application/json");
                deleteXhr.send();
            }

        var apiUrl = url + "/rest/v1/scanned_data";
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    if (xhr.status === 200 || xhr.status === 201 || xhr.status === 204) {
                        if (typeof callback === "function") callback(true);
                    } else {
                        console.error("Desk update error:", xhr.status + xhr.responseText);
                        if (typeof callback === "function") callback(false);
                    }
                }
            };

        xhr.open("POST", apiUrl, true);
        xhr.setRequestHeader("apikey", key);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.setRequestHeader("Prefer", "resolution=merge-duplicates");
        console.log(Array.isArray(delete_students))
        console.log(JSON.stringify(changes))
        var records = changes.filter(function(item) {
                return delete_students.indexOf(item.id) === -1;
            }).map(function(item) {
                return {
                    id: item.id,
                    room: item.room,
                    desk: item.desk,
                    student_login: item.login,
                    check_in_time: "2025-07-14 12:30:45.123+00"
                };
            });
        if (records.length === 0) {
                if (typeof callback === "function") callback(true);
                return;
            }



        xhr.send(JSON.stringify(records));
        return;

    }
}
