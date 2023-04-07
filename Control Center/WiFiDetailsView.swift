//
//  WiFiDetailsView.swift
//  Control Center
//
//  Created by Matthew Benedict on 2023/04/06.
//  Copyright © 2023 fordApps. All rights reserved.
//

import Foundation
import Cocoa
import CoreWLAN

class WiFiDetailsView : NSView {
    var backButton: NSButton!
    var networkButtons: [(wifi: NSButton, ssid: NSButton)] = []

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {
        backButton = NSButton(frame: NSRect(x: 0, y: frame.height - 20, width: 50, height: 20))
        backButton.title = "Back"
        self.addSubview(backButton)

        let max = Int(frame.height) - 45
        let currentSSID = WiFiDetailsView.getCurrentSSID()
        let ssidList = WiFiDetailsView.getSSIDList()
        for i in 0 ..< ssidList.count {
            let wifi = NSButton(frame: NSRect(x: 0, y: max - 25 * i, width: 25, height: 25))
            wifi.image = NSImage(named: ssidList[i] == currentSSID ? "bulb_on" : "bulb_off")
            self.addSubview(wifi)

            let ssid = NSButton(frame: NSRect(x: 25, y: max - 25 * i, width: 320, height: 25))
            ssid.title = ssidList[i]
            ssid.target = self
            ssid.action = #selector(connectToNetwork(_:))
            self.addSubview(ssid)

            networkButtons.append((wifi: wifi, ssid: ssid))
        }
    }

    @objc func connectToNetwork(_ sender: NSButton) {
        let ssid = sender.title
        if ssid != WiFiDetailsView.getCurrentSSID() {
            _ = WiFiDetailsView.shell("networksetup -setairportnetwork en0 \"\(ssid)\"")
        }

        for tuple in networkButtons {
            tuple.wifi.image = NSImage(named: tuple.ssid.title == ssid ? "bulb_on" : "bulb_off")
        }
    }

    static func getCurrentSSID() -> String {
        CWWiFiClient.shared().interface(withName: nil)?.ssid() ?? ""
    }

    static func getSSIDList() -> [String] {
        let components = WiFiDetailsView.shell("vars=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport -s);SAVEIFS=$IFS;IFS=$'\n';vars=($vars);len=${#vars[@]};for ((i = 1; i < $len; i++ )); do IFS=: ssida=(${vars[$i]}); ssid=${ssida[0]%???}; echo $(echo $ssid | xargs); done;IFS=$SAVEIFS").components(separatedBy: "\n")
        return Array(Set<String>(components).subtracting([""])).sorted()
    }

    static func shell(_ command: String) -> String {
        let task = Process()
        let pipe = Pipe()

        task.standardOutput = pipe
        task.arguments = ["-c", command]
        task.launchPath = "/bin/bash"
        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!

        return output
    }
}
