//
//  PreferencesWindow.swift
//  Control Center
//
//  Created by Ford on 7/11/20.
//  Copyright © 2020 fordApps. All rights reserved.
//

import Cocoa
import Sparkle

class PreferencesWindow: NSWindowController, NSWindowDelegate {
    
    @IBOutlet weak var yourCity: NSTextField!
    @IBOutlet weak var saveButton: NSButton!
    
    @IBAction func saveClicked(_ sender: Any) {
        let defaults = UserDefaults.standard
        defaults.setValue(yourCity.stringValue, forKey: "city")
        saveButton.isEnabled = false
    }
    
    @IBAction func checkForUpdates(_ sender: Any) {
        let updater = SUUpdater.shared()
        updater?.checkForUpdates(self)
    }
    
    override var windowNibName : String! {
        return "PreferencesWindow"
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        saveButton.isEnabled = true
        let defaults = UserDefaults.standard
        let city = defaults.string(forKey: "city") ?? DEFAULT_CITY
        yourCity.stringValue = city
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    func windowWillClose(_ notification: Notification) {
        let defaults = UserDefaults.standard
        defaults.setValue(yourCity.stringValue, forKey: "city")
    }
    
}
