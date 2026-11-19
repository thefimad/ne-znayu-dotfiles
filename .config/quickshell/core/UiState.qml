pragma Singleton
import QtQuick

// Shared UI state: which panel is open, DND, unread notification count.
QtObject {
    id: root

    property string panel: ""
    property bool dnd: false
    property int unseen: 0

    function open(name) {
        panel = name;
        if (name === "notifications")
            unseen = 0;
    }

    function toggle(name) {
        if (panel === name)
            panel = "";
        else
            open(name);
    }

    function close() {
        panel = "";
    }
}
