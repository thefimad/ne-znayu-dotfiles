pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Keybind cheatsheet data. Regenerates when keybinds.lua is saved.
QtObject {
    id: root

    readonly property string sourcePath: Quickshell.env("HOME") + "/.config/hypr/modules/keybinds.lua"
    readonly property string jsonPath: Quickshell.env("HOME") + "/.cache/quickshell/keybinds.json"
    readonly property string generator: Quickshell.env("HOME") + "/.local/bin/hypr-binds-gen"

    property var binds: []
    property int generated: 0
    property int count: 0

    property FileView sourceView: FileView {
        path: root.sourcePath
        watchChanges: true
        printErrors: false
        onFileChanged: root.regenerate()
    }

    property FileView jsonView: FileView {
        path: root.jsonPath
        watchChanges: true
        printErrors: false
        onTextChanged: root.parse()
        onLoaded: root.parse()
    }

    property Process generatorProcess: Process {
        command: [root.generator]
        onExited: root.jsonView.reload()
    }

    Component.onCompleted: {
        parse();
        regenerate();
    }

    function regenerate() {
        if (!generatorProcess.running)
            generatorProcess.running = true;
    }

    function parse() {
        try {
            var data = JSON.parse(jsonView.text());
            binds = data.binds || [];
            generated = data.generated || 0;
            count = data.count || binds.length;
        } catch (error) {
            binds = [];
            generated = 0;
            count = 0;
        }
    }
}
