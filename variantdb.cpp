#include "variantdb.h"
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QDebug>

VariantDB::VariantDB(QObject *parent)
    : QObject(parent), manager(new QNetworkAccessManager(this)) {
    apiKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJneG16aGtvc2FwbnRvaXdkb21nIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE3MTY3ODYsImV4cCI6MjA2NzI5Mjc4Nn0.ldRtDtg77-fqLk6n7ziXXI3RUEZ8GJm47yagBlzUyQw";
    projectUrl = "https://rgxmzhkosapntoiwdomg.supabase.co ";
}

void VariantDB::getUniqueValues(const QString &table, const QString &field, const std::function<void(QStringList)> &callback) {
    if (apiKey.isEmpty() || projectUrl.isEmpty()) {
        qDebug() << "API ключ или URL не установлены";
        if (callback) callback(QStringList());
        return;
    }

    QString baseUrl = projectUrl.trimmed() + "/rest/v1/" + table + "?select=" + field;
    qDebug() << "Request URL:" << baseUrl;

    QUrl qurl(baseUrl);
    QNetworkRequest request(qurl);
    request.setRawHeader("apikey", apiKey.toUtf8());
    request.setRawHeader("Authorization", QString("Bearer %1").arg(apiKey).toUtf8());

    QNetworkReply *reply = manager->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply, field, callback]() {
        QStringList result;
        if (reply->error() == QNetworkReply::NoError) {
            QByteArray response = reply->readAll();
            QJsonDocument doc = QJsonDocument::fromJson(response);
            if (!doc.isNull() && doc.isArray()) {
                QJsonArray arr = doc.array();
                QSet<QString> uniqueValues;
                for (const QJsonValue &val : arr) {
                    QJsonObject obj = val.toObject();
                    if (obj.contains(field)) {
                        uniqueValues.insert(obj.value(field).toString());
                    }
                }
                result = uniqueValues.toList();
                if (callback) callback(result);
            } else {
                qDebug() << "Invalid JSON response or not an array";
                if (callback) callback(QStringList());
            }
        } else {
            qDebug() << "Ошибка запроса:" << reply->errorString();
            qDebug() << "Response:" << reply->readAll();
            if (callback) callback(QStringList());
        }
        reply->deleteLater();
    });
}

void VariantDB::getDesksByRoom(const QString &room, const std::function<void(QStringList)> &callback) {
    if (apiKey.isEmpty() || projectUrl.isEmpty()) {
        qDebug() << "API ключ или URL не установлены";
        if (callback) callback(QStringList());
        return;
    }

    QString baseUrl = projectUrl.trimmed() + "/rest/v1/scanned_data?select=desk&room=eq." + QUrl::toPercentEncoding(room);
    qDebug() << "Request URL:" << baseUrl;

    QUrl qurl(baseUrl);
    QNetworkRequest request(qurl);
    request.setRawHeader("apikey", apiKey.toUtf8());
    request.setRawHeader("Authorization", QString("Bearer %1").arg(apiKey).toUtf8());

    QNetworkReply *reply = manager->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply, callback]() {
        QStringList result;
        if (reply->error() == QNetworkReply::NoError) {
            QByteArray response = reply->readAll();
            QJsonDocument doc = QJsonDocument::fromJson(response);
            if (!doc.isNull() && doc.isArray()) {
                QJsonArray arr = doc.array();
                for (const QJsonValue &val : arr) {
                    QString deskValue = val.toObject().value("desk").toString();
                    bool ok;
                    int deskNum = deskValue.toInt(&ok);
                    if (ok) {
                        int row = deskNum / 10;
                        int seat = deskNum % 10;
                        if (row > 0 && seat > 0) {
                            result << QString("р%1м%2").arg(row).arg(seat);
                        } else {
                            result << QString("р0м%1").arg(deskNum);
                        }
                    } else {
                        result << "р0м" + deskValue;
                    }
                }
                if (callback) callback(result);
            } else {
                qDebug() << "Invalid JSON response or not an array";
                if (callback) callback(QStringList());
            }
        } else {
            qDebug() << "Ошибка запроса:" << reply->errorString();
            qDebug() << "Response:" << reply->readAll();
            if (callback) callback(QStringList());
        }
        reply->deleteLater();
    });
}

void VariantDB::loadUniqueValues(const QString &table, const QString &field)
{
    if (apiKey.isEmpty() || projectUrl.isEmpty()) {
        qDebug() << "API ключ или URL не установлены";
        emit uniqueValuesLoaded(QStringList());
        return;
    }

    QString baseUrl = projectUrl.trimmed() + "/rest/v1/" + table + "?select=" + field;
    qDebug() << "Request URL:" << baseUrl;

    QUrl qurl(baseUrl);
    QNetworkRequest request(qurl);
    request.setRawHeader("apikey", apiKey.toUtf8());
    request.setRawHeader("Authorization", QString("Bearer %1").arg(apiKey).toUtf8());

    QNetworkReply *reply = manager->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply, field]() {
        QStringList result;
        if (reply->error() == QNetworkReply::NoError) {
            QByteArray response = reply->readAll();
            QJsonDocument doc = QJsonDocument::fromJson(response);
            if (!doc.isNull() && doc.isArray()) {
                QJsonArray arr = doc.array();
                QSet<QString> uniqueValues;
                for (const QJsonValue &val : arr) {
                    QJsonObject obj = val.toObject();
                    if (obj.contains(field)) {
                        uniqueValues.insert(obj.value(field).toString());
                    }
                }
                result = uniqueValues.toList();
            } else {
                qDebug() << "Invalid JSON response or not an array";
            }
        } else {
            qDebug() << "Ошибка запроса:" << reply->errorString();
            qDebug() << "Response:" << reply->readAll();
        }
        emit uniqueValuesLoaded(result);
        reply->deleteLater();
    });
}

void VariantDB::loadDesksByRoom(const QString &room)
{
    if (apiKey.isEmpty() || projectUrl.isEmpty()) {
        qDebug() << "API ключ или URL не установлены";
        emit desksByRoomLoaded(QStringList());
        return;
    }

    QString baseUrl = projectUrl.trimmed() + "/rest/v1/scanned_data?select=desk&room=eq." + QUrl::toPercentEncoding(room);
    qDebug() << "Request URL:" << baseUrl;

    QUrl qurl(baseUrl);
    QNetworkRequest request(qurl);
    request.setRawHeader("apikey", apiKey.toUtf8());
    request.setRawHeader("Authorization", QString("Bearer %1").arg(apiKey).toUtf8());

    QNetworkReply *reply = manager->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        QStringList result;
        if (reply->error() == QNetworkReply::NoError) {
            QByteArray response = reply->readAll();
            QJsonDocument doc = QJsonDocument::fromJson(response);
            if (!doc.isNull() && doc.isArray()) {
                QJsonArray arr = doc.array();
                for (const QJsonValue &val : arr) {
                    QString deskValue = val.toObject().value("desk").toString();
                    bool ok;
                    int deskNum = deskValue.toInt(&ok);
                    if (ok) {
                        int row = deskNum / 10;
                        int seat = deskNum % 10;
                        if (row > 0 && seat > 0) {
                            result << QString("р%1м%2").arg(row).arg(seat);
                        } else {
                            result << QString("р0м%1").arg(deskNum);
                        }
                    } else {
                        result << "р0м" + deskValue;
                    }
                }
            } else {
                qDebug() << "Invalid JSON response or not an array";
            }
        } else {
            qDebug() << "Ошибка запроса:" << reply->errorString();
            qDebug() << "Response:" << reply->readAll();
        }
        emit desksByRoomLoaded(result);
        reply->deleteLater();
    });
}
