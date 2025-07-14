#ifndef VARIANTDB_H
#define VARIANTDB_H

#include <QObject>
#include <QNetworkAccessManager>
#include <functional>

class VariantDB : public QObject
{
    Q_OBJECT
public:
    explicit VariantDB(QObject *parent = nullptr);

    Q_INVOKABLE void getUniqueValues(const QString &table, const QString &field, const std::function<void(QStringList)> &callback = nullptr);
    Q_INVOKABLE void getDesksByRoom(const QString &room, const std::function<void(QStringList)> &callback = nullptr);

    Q_INVOKABLE void loadUniqueValues(const QString &table, const QString &field);
    Q_INVOKABLE void loadDesksByRoom(const QString &room);

signals:
    void uniqueValuesLoaded(const QStringList &values);
    void desksByRoomLoaded(const QStringList &desks);

private:
    QString apiKey;
    QString projectUrl;
    QNetworkAccessManager *manager;
};

#endif // VARIANTDB_H
