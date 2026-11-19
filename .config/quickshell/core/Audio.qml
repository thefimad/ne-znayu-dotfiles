pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// PipeWire model for the audio panel, OSD and bar.
QtObject {
    id: root

    readonly property var nodes: Pipewire.nodes.values
    readonly property var sinks: nodes.filter(function (n) {
        return n && n.audio && n.isSink && !n.isStream;
    })
    readonly property var sources: nodes.filter(function (n) {
        return n && n.audio && !n.isSink && !n.isStream;
    })
    readonly property var streams: nodes.filter(function (n) {
        return n && n.audio && n.isStream;
    })

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    readonly property bool muted: sink && sink.audio ? sink.audio.muted : false
    readonly property int volume: sink && sink.audio ? Math.round(sink.audio.volume * 100) : 0
    readonly property string sinkLabel: sink ? (sink.description || sink.name) : "NO OUTPUT"
    readonly property string sourceLabel: source ? (source.description || source.name) : "NO INPUT"
    readonly property bool micLive: source && source.audio ? !source.audio.muted : false

    property bool osdVisible: false
    property string osdTitle: ""
    property int osdValue: 0
    property bool osdMuted: false

    property PwObjectTracker tracker: PwObjectTracker {
        objects: root.sinks.concat(root.sources).concat(root.streams)
    }

    property Connections sinkWatch: Connections {
        target: root.sink && root.sink.audio ? root.sink.audio : null
        function onVolumeChanged() { root.showOsd(); }
        function onMutedChanged() { root.showOsd(); }
    }

    property Timer osdTimer: Timer {
        interval: 1600
        onTriggered: root.osdVisible = false
    }

    function showOsd() {
        osdTitle = sinkLabel;
        osdValue = volume;
        osdMuted = muted;
        osdVisible = true;
        osdTimer.restart();
    }

    function setVolume(node, value) {
        if (!node || !node.audio)
            return;
        node.audio.volume = Math.max(0, Math.min(1, value));
    }

    function nudge(node, delta) {
        if (!node || !node.audio)
            return;
        setVolume(node, node.audio.volume + delta / 100);
    }

    function toggleMute(node) {
        if (!node || !node.audio)
            return;
        node.audio.muted = !node.audio.muted;
    }

    function setDefaultSink(node) {
        if (node)
            Quickshell.execDetached(["wpctl", "set-default", String(node.id)]);
    }

    function setDefaultSource(node) {
        if (node)
            Quickshell.execDetached(["wpctl", "set-default", String(node.id)]);
    }

    function label(node) {
        if (!node)
            return "";
        // node.nick is short and human friendly (e.g. "ASUS VG27V"), while the
        // description is long enough to truncate inside the panel.
        return node.nickname || node.description || node.name || "";
    }

    function streamLabel(node) {
        if (!node)
            return "";
        var props = node.properties || {};
        return props["application.name"] || props["media.name"] || props["node.name"] || node.name || "STREAM";
    }
}
