import QtQuick 2.6

QtObject {
    id: root

    signal dataUpdated()
    signal saveCompleted(bool success)

    property var allStudents: []
    property var scannedStudents: []
    property var mergedAttendance: []
    property bool hasChanges: false
    property bool isLoading: false

    property var supabaseClient: SupabaseClient {
        onStudentsLoaded: {
            root.allStudents = students
            root.checkDataReady()
        }
        onScannedStudentsLoaded: {
            root.scannedStudents = scannedStudents
            root.checkDataReady()

        }
        onUpdateFinished: {
            root.saveCompleted(success)
            if (success) root.updateData()
        }
        onErrorOccurred: console.error(message)
    }

    function updateData() {
            isLoading = true
            allStudents = []
            scannedStudents = []
            supabaseClient.getAllStudents()
            supabaseClient.getScannedStudents()
        }


    function checkDataReady() {
        if (allStudents.length > 0 && scannedStudents.length >= 0) {
            mergeAttendanceData()
            isLoading = false
        }
    }

    function mergeAttendanceData() {
        var merged = []

        for (var i = 0; i < allStudents.length; i++) {
            var student = allStudents[i]

            var scanned = null
            for (var j = 0; j < scannedStudents.length; j++) {

                if (scannedStudents[j].id === student.id) {
                    scanned = scannedStudents[j]

                    break
                }
            }

            merged.push({
                id: student.id,
                name: student.name,
                status: scanned ? "Пр" : student.status,
                room: scanned ? scanned.room : "--",
                desk: scanned ? scanned.desk : "--",
                login: scanned ? scanned.student_login : "--",
                time: scanned ? scanned.check_in_time : "--",
                scanned: !!scanned,
                originalStatus: student.status,
                originalDesk: scanned ? scanned.desk : "--",

            })
        }


        mergedAttendance = merged
        updateChangesFlag()
        dataUpdated()
    }

    function updateChangesFlag() {
        hasChanges = false
        for (var i = 0; i < mergedAttendance.length; i++) {
            if (mergedAttendance[i].status !== mergedAttendance[i].originalStatus || mergedAttendance[i].desk !== mergedAttendance[i].originalDesk) {
                hasChanges = true
                break
            }
        }
    }

    function saveChanges() {
        if (!hasChanges) {
            saveCompleted(true)
            return
        }

        var changes = []
        var delete_students = [];
        for (var i = 0; i < mergedAttendance.length; i++) {
            var student = mergedAttendance[i]
            if (student.status !== student.originalStatus || student.originalDesk !== student.desk) {
                if (student.status === "Не.ув" ||student.status === "Ув")
                {
                    delete_students.push(
                       student.id
                    )
                }

                changes.push({
                    id: student.id,
                    name: student.name,
                    status: student.status,
                    room: student.room,
                    desk: student.desk,
                    login: student.login,
                    time: student.time
                })

            }


        }
        supabaseClient.updateStudentsInfo(changes, delete_students)
    }
}
