pragma Singleton
import QtQuick
import Quickshell.Services.Mpris

// Current MPRIS player. A 1s tick keeps bindings fresh for services that only
// emit coarse position/state updates.
QtObject {
    id: root

    property int tick: 0

    readonly property var players: Mpris.players.values
    readonly property var player: {
        tick;
        for (var i = 0; i < players.length; i++) {
            if (players[i].isPlaying)
                return players[i];
        }
        return players.length > 0 ? players[0] : null;
    }

    readonly property bool active: player !== null
    readonly property bool playing: player ? player.isPlaying : false
    readonly property string title: player && player.trackTitle ? player.trackTitle : ""
    readonly property string artist: player && player.trackArtist ? player.trackArtist : ""
    readonly property string identity: player && player.identity ? player.identity : ""
    readonly property real position: player ? player.position : 0
    readonly property real length: player ? player.length : 0

    property Timer ticker: Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.tick++;
    }

    function toggle() {
        if (player && player.canTogglePlaying)
            player.togglePlaying();
    }

    function next() {
        if (player && player.canGoNext)
            player.next();
    }

    function previous() {
        if (player && player.canGoPrevious)
            player.previous();
    }

    function format(seconds) {
        if (!seconds || seconds < 0)
            return "0:00";
        var total = Math.floor(seconds);
        var m = Math.floor(total / 60);
        var s = total % 60;
        return m + ":" + (s < 10 ? "0" : "") + s;
    }
}
