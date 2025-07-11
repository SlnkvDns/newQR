#include "hasher.h"

Hasher::Hasher(QObject *parent) : QObject(parent) {}

QString Hasher::hashPassword(const QString &password)
{
    QByteArray hash = QCryptographicHash::hash(password.toUtf8(), QCryptographicHash::Sha256);
    return QString(hash.toHex());
}
