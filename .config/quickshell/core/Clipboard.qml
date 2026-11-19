pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// cliphist-backed clipboard history.
QtObject {
    id: root

    property var entries: []
    property bool loading: false

    property Process listProcess: Process {
        command: ["cliphist", "list"]
        onRunningChanged: root.loading = running
        stdout: StdioCollector {
            onStreamFinished: root.parseList(text)
        }
    }

    function reload() {
        if (!listProcess.running)
            listProcess.running = true;
    }

    function parseList(output) {
        var result = [];
        var lines = String(output || "").split("\n");
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i];
            if (!line.length)
                continue;
            var tab = line.indexOf("\t");
            var id = tab > 0 ? line.substring(0, tab) : "";
            var preview = tab > 0 ? line.substring(tab + 1) : line;
            result.push({ id: id, raw: line, preview: preview });
        }
        entries = result;
    }

    function isImage(preview) {
        return String(preview || "").indexOf("[[ binary data") === 0;
    }

    function copy(entry) {
        if (!entry || !entry.id)
            return;

        // cliphist previews images as "[[ binary data 378 KiB png 1920x1080 ]]".
        // Those need an explicit MIME type, otherwise wl-copy marks raw PNG
        // bytes as text and paste targets reject them.
        if (isImage(entry.preview)) {
            var mime = /\bjpe?g\b/.test(entry.preview) ? "image/jpeg" : "image/png";
            var target = "${XDG_RUNTIME_DIR:-/tmp}/cliphist-image" +
                (mime === "image/jpeg" ? ".jpg" : ".png");
            var cmd = "cliphist decode " + entry.id + " > \"" + target + "\" && " +
                "\"$HOME/.local/bin/copy-image\" \"" + target + "\" " + mime;
            Quickshell.execDetached(["bash", "-c", cmd]);
            return;
        }

        Quickshell.execDetached(["bash", "-c", "cliphist decode " + entry.id + " | wl-copy"]);
    }

    function remove(entry) {
        if (!entry)
            return;
        Quickshell.execDetached(["cliphist", "delete-query", entry.raw]);
        Qt.callLater(reload);
    }

    function wipe() {
        Quickshell.execDetached(["cliphist", "wipe"]);
        entries = [];
    }
}
