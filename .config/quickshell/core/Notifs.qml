pragma Singleton
import QtQuick
import Quickshell.Services.Notifications

// NotificationServer replacing dunst + popup/history state.
QtObject {
    id: root

    property var popups: []
    property var history: []
    property int nextKey: 1

    property NotificationServer server: NotificationServer {
        keepOnReload: true
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true
        actionsSupported: true
        actionIconsSupported: true

        onNotification: function (notification) {
            root.push(notification);
        }
    }

    property Timer cleanup: Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: root.expirePopups()
    }

    function push(notification) {
        var item = {
            key: root.nextKey++,
            app: notification.appName || "",
            summary: notification.summary || "",
            body: notification.body || "",
            urgency: notification.urgency,
            when: Date.now(),
            timeout: notification.urgency === NotificationUrgency.Critical ? 12000 : 6000,
            raw: notification
        };

        history = [item].concat(history).slice(0, 50);

        if (UiState.dnd) {
            notification.dismiss();
            return;
        }

        UiState.unseen++;
        notification.tracked = true;
        popups = [item].concat(popups).slice(0, 4);
    }

    function expirePopups() {
        var now = Date.now();
        var keep = [];
        for (var i = 0; i < popups.length; i++) {
            var item = popups[i];
            if (now - item.when > item.timeout) {
                if (item.raw && item.raw.tracked)
                    item.raw.dismiss();
            } else {
                keep.push(item);
            }
        }
        popups = keep;
    }

    function dismiss(item) {
        popups = popups.filter(function (entry) { return entry.key !== item.key; });
        if (item.raw && item.raw.tracked)
            item.raw.dismiss();
    }

    function removeHistory(item) {
        history = history.filter(function (entry) { return entry.key !== item.key; });
    }

    function clearHistory() {
        history = [];
    }

    function setDnd(value) {
        UiState.dnd = value;
        if (value) {
            for (var i = 0; i < popups.length; i++) {
                if (popups[i].raw && popups[i].raw.tracked)
                    popups[i].raw.dismiss();
            }
            popups = [];
        }
    }
}
