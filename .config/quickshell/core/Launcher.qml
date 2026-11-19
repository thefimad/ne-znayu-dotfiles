pragma Singleton
import QtQuick
import Quickshell

// Desktop entries for the launcher.
QtObject {
    id: root

    readonly property var entries: {
        var all = DesktopEntries.applications.values || [];
        var result = [];
        for (var i = 0; i < all.length; i++) {
            var entry = all[i];
            if (entry && !entry.noDisplay)
                result.push(entry);
        }
        result.sort(function (a, b) {
            return String(a.name).localeCompare(String(b.name));
        });
        return result;
    }

    function search(query) {
        var needle = String(query || "").toLowerCase().trim();
        var result = [];
        for (var i = 0; i < entries.length && result.length < 40; i++) {
            var entry = entries[i];
            var haystack = (entry.name + " " + (entry.genericName || "") + " " + (entry.comment || "") + " " + (entry.keywords || "")).toLowerCase();
            if (needle.length === 0 || haystack.indexOf(needle) !== -1)
                result.push(entry);
        }
        return result;
    }

    function launch(entry) {
        if (!entry)
            return;
        entry.execute();
    }
}
