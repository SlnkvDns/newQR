#ifndef HASHER_H
#define HASHER_H

#include <QObject>
#include <QCryptographicHash>

class Hasher : public QObject
{
    Q_OBJECT
public:
    explicit Hasher(QObject *parent = nullptr);

    Q_INVOKABLE QString hashPassword(const QString &password);
};

#endif // HASHER_H
