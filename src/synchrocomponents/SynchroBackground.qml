import QtQuick 2.9
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import "../synchrostyle"

Item {
    anchors.fill: parent
    property alias sourceRect:effectSource.sourceRect
    property alias sourceItem:effectSource.sourceItem
    property alias radius:tint.radius
    property alias tintOpacity:tint.opacity



    ShaderEffectSource {
        id: effectSource
        width: parent.width
        height: parent.height
        anchors.margins: -64
    }

    FastBlur {
        id: blur
        anchors.fill: effectSource
        source: effectSource
        radius: 64
    }

    Rectangle {
        id: tint
        anchors.fill: parent
        color: "#000000"
        opacity: 0.66
        border.width: 0
    }
}
