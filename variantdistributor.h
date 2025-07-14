#ifndef VARIANTDISTRIBUTOR_H
#define VARIANTDISTRIBUTOR_H

#include <QObject>
#include <QStringList>
#include <QVariantMap>
#include <QString>

class VariantDistributor : public QObject
{
    Q_OBJECT
public:
    explicit VariantDistributor(QObject *parent = nullptr);

    Q_INVOKABLE QVariantMap distributeVariants(const QStringList &positions, int variantsCount);
};

#endif // VARIANTDISTRIBUTOR_H
