﻿#ifndef VIDEOOBJECT_H
#define VIDEOOBJECT_H

#include <QtQuick/QQuickFramebufferObject>

#include <mpv/client.h>
#include <mpv/render_gl.h>
#include <mpv/qthelper.hpp>

class VideoObject : public QQuickFramebufferObject
{
    Q_OBJECT

    Q_PROPERTY(qreal currentVideoPos READ getCurrentVideoPos WRITE setCurrentVideoPos)
    Q_PROPERTY(qreal currentVideoLength READ getCurrentVideoLength)
    Q_PROPERTY(bool paused READ getPaused WRITE setPaused NOTIFY pausedChanged)
    Q_PROPERTY(bool muted READ getMuted WRITE setMuted NOTIFY mutedChanged)


public:
    VideoObject();
    virtual ~VideoObject();
    virtual Renderer *createRenderer() const;

    void setMpvRenderContext(mpv_render_context *value);

    qreal getCurrentVideoLength() const;

    qreal getCurrentVideoPos() const;
    void setCurrentVideoPos(const qreal &value);

    bool *getIsResizing();

    bool getPaused() const;
    void setPaused(bool value);

    bool getMuted() const;
    void setMuted(bool value);

signals:
    void updateGui();

    void pausedChanged();
    void mutedChanged();

public slots:
    void seek(const qreal newPos);

    void pause();

    void mute();

    void command(const QVariant &args);

    void setProperty(const QString name, const QVariant &v);

    QVariant getProperty(const QString name);

    void setOption(const QString name, const QVariant &v);

    void resized();

private:
    mpv_handle *mpvHandler;
    mpv_render_context *mpvRenderContext;

    QTimer *guiUpdateTimer;
    qreal currentVideoPos;
    qreal currentVideoLength;

    QTimer *resizingTimer;
    bool isResizing;

    bool paused;
    bool muted;
};

#endif // VIDEOOBJECT_H
