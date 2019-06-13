#include "synchronycontroller.h"

#include <QtConcurrent/QtConcurrentRun>

#include <QVariantList>

#include <QDebug>

static void callback(void *ctx, Command cmd) {
    qDebug() << "received";
    auto obj = reinterpret_cast<SynchronyController*>(ctx);
    obj->handleCommand(cmd);
}

SynchronyController::SynchronyController(QObject *parent) : QObject(parent)
{
    socket2 = nullptr;

    connectToServer("127.0.0.1", 32019);
}

SynchronyController::~SynchronyController() {
    synchro_connection_free(socket2);
}

void SynchronyController::connectToServer(QString ip, quint16 port)
{
    socket2 = synchro_connection_new(qPrintable(ip), port, callback, this);
    QtConcurrent::run(synchro_connection_run, socket2);
}

void SynchronyController::sendCommand(quint8 cmdNum, QVariantList arguments)
{
    // if (socket->state() != QTcpSocket::ConnectedState)
    //     return;

    Command cmd = Command();
    cmd.tag = static_cast<Command::Tag>(cmdNum);

    switch(cmd.tag) {
    case Command::Tag::Pause: {
        cmd.pause.paused = arguments.takeFirst().toBool();
        cmd.pause.percent_pos = arguments.takeFirst().toDouble();
        break;
    }
    case Command::Tag::Seek: {
        cmd.seek.percent_pos = arguments.takeFirst().toDouble();
        cmd.seek.dragged = arguments.takeFirst().toBool();
        break;
    }
    }

    synchro_connection_send(socket2, cmd);
    qDebug() << "send em";
}

void SynchronyController::handleCommand(Command command)
{
    qDebug() << "recieved data";
    switch(command.tag) {
    case Command::Tag::Pause: {
        emit pause(command.pause.paused, command.pause.percent_pos);
        break;
    }
    case Command::Tag::Seek: {
        emit seek(command.seek.percent_pos, command.seek.dragged);
        break;
    }
    case Command::Tag::Invalid: {
        qDebug() << "Invalid command received";
        break;
    }
    }
}