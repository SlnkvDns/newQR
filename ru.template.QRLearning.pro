TARGET = ru.template.QRLearning

CONFIG += qzxing_multimedia\
          qzxing_qml\
          auroraapp\

QT += core quick multimedia qml

PKGCONFIG += \

SOURCES += \
    src/hasher.cpp \
    src/main.cpp \

HEADERS += \
    src/hasher.h

DISTFILES += \
    qml/pages/CheckInPage.qml \
    qml/pages/LectorPage.qml \
    qml/pages/LoginPage.qml \
    qml/pages/QrScannerPage.qml \
    qml/pages/RegisterPage.qml \
    qml/pages/StudentPage.qml \
    rpm/ru.template.QRLearning.spec \

AURORAAPP_ICONS = 86x86 108x108 128x128 172x172

CONFIG += auroraapp_i18n

TRANSLATIONS += \
    translations/ru.template.QRLearning.ts \
    translations/ru.template.QRLearning-ru.ts \

CONFIG += enable_dDEFINES += ENABLE_QZXING_QMLecoder_qr_code

include(QZXing/QZXing.pri)
