﻿import QtQuick 2.10
import QtQuick.Controls 2.3
import "../synchrostyle"

import Synchro.Core 1.0

Item {
    property alias state:oscPanel.state

    id: container
    anchors.fill: parent
    clip: true


    Connections {
        target: videoObject

        onIsPausedChanged: {
        if (videoObject.isPaused)
            playPauseIcon.state = ""
        else
            playPauseIcon.state = "playing"
        }

        onPercentPosChanged: seekSlider.value = videoObject.percentPos

        onTimePosStringChanged: videoTimeLabel.timePosString = videoObject.timePosString

        onDurationStringChanged: videoTimeLabel.durationString = videoObject.durationString
    }

    Rectangle {
        id: shadow
        anchors.bottomMargin: oscPanel.height+1+oscPanel.anchors.bottomMargin
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        height: 5
        opacity: 0.7
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: "black" }
        }

        states: State {
            name: "seekbarexpanded"
            when: seekSlider.state != ""
            PropertyChanges {
                target: shadow
                anchors.bottomMargin: oscPanel.height+3
            }
        }

        transitions: Transition {
            reversible: true
            from: ""
            to: "seekbarexpanded"
            NumberAnimation {
                target: shadow
                properties: "anchors.bottomMargin"
                duration: 75
                easing.type: Easing.InOutQuad
            }
        }
    }
    Seekbar {
        id: seekSlider
        transformOrigin: Item.Bottom
        anchors.bottomMargin: oscPanel.height-bottomPadding+oscPanel.anchors.bottomMargin
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        implicitWidth: 99999999
        z: 1
        onSeek: videoObject.seek(value, dragged, true)
    }

    Item {
        id: oscPanel
        height: 48
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        SynchroBackground {
            sourceItem: videoObject
            sourceRect: Qt.rect(parent.x, parent.y, parent.width, parent.height)
        }

        states: [
            State {
                name: "hidden"
                PropertyChanges {
                    target: oscPanel
                    anchors.bottomMargin: -height-shadow.height*2
                    enabled: false
                }
            },
            State {
                name: "seek"
                PropertyChanges {
                    target: oscPanel
                    anchors.bottomMargin: seekSlider.height-(height+shadow.height*2)
                    enabled: false
                }
            }
        ]

        transitions: [
            Transition {
                to: "seek"
                NumberAnimation {
                    target: oscPanel
                    properties: "anchors.bottomMargin"
                    duration: 125
                    easing.type: Easing.InQuad
                }
            },
            Transition {
                from: "seek"
                NumberAnimation {
                    target: oscPanel
                    properties: "anchors.bottomMargin"
                    duration: 125
                    easing.type: Easing.outQuad
                }
            },
            Transition {
                to: ""
                NumberAnimation {
                    target: oscPanel
                    properties: "anchors.bottomMargin"
                    duration: 250
                    easing.type: Easing.OutQuart
                }
            },
            Transition {
                to: "hidden"
                NumberAnimation {
                    target: oscPanel
                    properties: "anchors.bottomMargin"
                    duration: 250
                    easing.type: Easing.InQuart
                }
            }
        ]

        Label {
            id: videoTimeLabel
            property string timePosString;
            property string durationString;

            text: timePosString + "/" + durationString
            anchors.leftMargin: 10
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            id: controlsWrapper
            height: oscPanel.height-12
            anchors.rightMargin: 0
            anchors.fill: parent

            AbstractButton {
                id: backButton
                width: 22
                height: 22
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: -40
                anchors.verticalCenter: parent.verticalCenter
                onPressed: videoObject.back();

                Image {
                    id: backIcon
                    width: parent.width
                    height: parent.height
                    source: "qrc:/resources/music_beginning_button.png"
                    fillMode: Image.PreserveAspectFit
                }
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    cursorShape: Qt.PointingHandCursor
                }
            }

            AbstractButton {
                id: playPauseButton
                width: 36
                height: 36
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                onPressed: videoObject.pause(!videoObject.isPaused)
                AnimatedSprite {
                    id: playPauseIcon
                    width: parent.height
                    height: parent.width
                    source: "qrc:/resources/play-pause.png"
                    frameWidth: 36
                    frameHeight: 36
                    frameCount: 16
                    frameDuration: 16
                    running: false
                    currentFrame: 15
                    reverse: true
                    onCurrentFrameChanged: if (currentFrame == 15) running = false
                    onStateChanged: {
                        running = false
                        reverse = !reverse
                        currentFrame = 15-currentFrame
                        running = true
                    }

                    states: State {
                        name: "playing"
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }

            AbstractButton {
                id: forwardButton
                width: 22
                height: 22
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: 40
                anchors.verticalCenter: parent.verticalCenter
                onPressed: videoObject.forward();

                Image {
                    id: forwardIcon
                    width: parent.width
                    height: parent.height
                    source: "qrc:/resources/music_end_button.png"
                    fillMode: Image.PreserveAspectFit
                }
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    cursorShape: Qt.PointingHandCursor
                }
            }

            AbstractButton {
                id: volumeButton
                width: 22
                height: 22
                anchors.rightMargin: 10
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                onPressed: videoObject.muted = !videoObject.muted

                Image {
                    id: volumeIcon
                    width: parent.width
                    height: parent.height
                    source: "qrc:/resources/music_volume_up.png"
                    fillMode: Image.PreserveAspectFit
                    horizontalAlignment: Image.AlignLeft

                    states: [
                        State {
                            name: "low"
                            PropertyChanges {
                                target: volumeIcon
                                source: "qrc:/resources/music_volume_down.png"
                            }
                        },
                        State {
                            name: "mute"
                            PropertyChanges {
                                target: volumeIcon
                                source: "qrc:/resources/music_mute.png"
                            }
                        }
                    ]
                }

                MouseArea {
                    id: volumeIconMouseArea
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onContainsMouseChanged: {
                        volumeOsc.showOsc();
                    }
                }
            }
        }
    }

    VolumeOsc {
        id: volumeOsc

        onVolumeChanged: changeIcon()

        function changeIcon()
        {
            if (videoObject.muted || value < 1)
                volumeIcon.state = "mute"
            else if (value > 50)
                volumeIcon.state = ""
            else
                volumeIcon.state = "low"
        }
    }
}
