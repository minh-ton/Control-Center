//
//  ControlCenterView.swift
//  Control Center
//
//  Created by MinhTon on 7/9/20.
//  Copyright © 2020 MinhTon. All rights reserved.
//

import Cocoa
import AudioToolbox
import CoreWLAN
import SpotifyAppleScript
import iTunesAppleScript

/* let systemVersion = ProcessInfo.processInfo.operatingSystemVersion.minorVersion
if systemVersion == 12 || systemVersion == 13 || systemVersion == 14 { */

class ControlCenterView: NSView {
    
    @IBOutlet weak var weatherCityName: NSTextField!
    @IBOutlet weak var weatherTemp: NSTextField!
    @IBOutlet weak var weatherCons: NSTextField!
    @IBOutlet weak var weatherPressure: NSTextField!
    @IBOutlet weak var weatherHumid: NSTextField!
    @IBOutlet weak var weatherIMGView: NSImageView!
    @IBOutlet weak var dndBulb: NSImageView!
    @IBOutlet weak var dndStatus: NSTextField!
    @IBOutlet weak var brightnessSlider: NSSlider!
    @IBOutlet weak var volumeSlider: NSSlider!
    @IBOutlet weak var BluetoothBulb: NSImageView!
    @IBOutlet weak var BluetoothStatus: NSTextField!
    @IBOutlet weak var wifiBulb: NSImageView!
    @IBOutlet weak var wifiStatus: NSTextField!
    @IBOutlet weak var appearanceStatus: NSTextField!
    @IBOutlet weak var appearanceBulb: NSImageView!
    @IBOutlet weak var nightshiftBulb: NSImageView!
    @IBOutlet weak var nightshiftSlider: NSSlider!
    @IBOutlet weak var nightshiftStatus: NSTextField!
    @IBOutlet weak var musicApp: NSImageView!
    @IBOutlet weak var songName: NSTextField!
    @IBOutlet weak var songDescription: NSTextField!
    @IBOutlet weak var pauseButton: NSButton!
    
    
    @IBAction func skipClicked(_ sender: NSButton) {
        let Spotifyurl = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.spotify.client")
        if Spotifyurl == nil {
            return
        } else {
            let spotifyIsRunning = NSRunningApplication.runningApplications(withBundleIdentifier: "com.spotify.client").count
            if spotifyIsRunning > 0 {
                SpotifyAppleScript.playNext()
                songDescription.isHidden = false
                let playingSongName = SpotifyAppleScript.currentTrack.title
                let playingsongArtist = SpotifyAppleScript.currentTrack.artist
                if playingSongName == nil && playingsongArtist == nil {
                    songName.stringValue = "Not Playing"
                    songDescription.isHidden = true
                } else {
                    if playingSongName!.count < 10 {
                        songName.stringValue = "\(String(describing: playingSongName!))"
                    } else {
                        songName.stringValue = "\(String(describing: playingSongName!.prefix(10)))..."
                    }
                    if playingsongArtist!.count < 15 {
                        songDescription.stringValue = "\(String(describing: playingsongArtist!))"
                    } else {
                        songDescription.stringValue = "\(String(describing: playingsongArtist!.prefix(15)))..."
                    }
                }
                if SpotifyAppleScript.currentTrack.artworkUrl == nil {
                    musicApp.image = NSImage(named: "music")
                } else {
                    let playingsongArtwork = NSImage(contentsOf: URL(string: SpotifyAppleScript.currentTrack.artworkUrl!)!)
                    musicApp.image = playingsongArtwork
                }
            } else {
                let systemVersion = ProcessInfo.processInfo.operatingSystemVersion.minorVersion
                var musicIsRunning = 0
                if systemVersion == 12 || systemVersion == 13 || systemVersion == 14 {
                    musicIsRunning = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.iTunes").count
                } else {
                    musicIsRunning = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.Music").count
                }
                if musicIsRunning > 0 {
                    iTunesAppleScript.playNext()
                    songDescription.isHidden = false
                    let playingSongName = iTunesAppleScript.currentTrack.title
                    let playingsongArtist = iTunesAppleScript.currentTrack.artist
                    if playingSongName == nil && playingsongArtist == nil {
                        songName.stringValue = "Not Playing"
                        songDescription.isHidden = true
                    } else {
                        if playingSongName!.count < 10 {
                            songName.stringValue = "\(String(describing: playingSongName!))"
                        } else {
                            songName.stringValue = "\(String(describing: playingSongName!.prefix(10)))..."
                        }
                        if playingsongArtist!.count < 15 {
                            songDescription.stringValue = "\(String(describing: playingsongArtist!))"
                        } else {
                            songDescription.stringValue = "\(String(describing: playingsongArtist!.prefix(15)))..."
                        }
                    }
                    if iTunesAppleScript.currentTrack.artworkUrl == nil {
                        musicApp.image = NSImage(named: "music")
                    } else {
                        let playingsongArtwork = NSImage(contentsOf: URL(string: iTunesAppleScript.currentTrack.artworkUrl!)!)
                        musicApp.image = playingsongArtwork
                    }
                }
            }
        }
    }
    
    @IBAction func playpauseClicked(_ sender: NSButton) {
        let Spotifyurl = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.spotify.client")
        if Spotifyurl == nil {
            return
        } else {
            let spotifyIsRunning = NSRunningApplication.runningApplications(withBundleIdentifier: "com.spotify.client").count
            if spotifyIsRunning > 0 {
                switch SpotifyAppleScript.playerState {
                case .paused:
                    SpotifyAppleScript.playerState = .playing
                    pauseButton.image = NSImage(named: "NSTouchBarPauseTemplate")
                case .playing:
                    SpotifyAppleScript.playerState = .paused
                    pauseButton.image = NSImage(named: "NSTouchBarPlayTemplate")
                }
                songDescription.isHidden = false
                let playingSongName = SpotifyAppleScript.currentTrack.title
                let playingsongArtist = SpotifyAppleScript.currentTrack.artist
                if playingSongName == nil && playingsongArtist == nil {
                    songName.stringValue = "Not Playing"
                    songDescription.isHidden = true
                } else {
                    if playingSongName!.count < 10 {
                        songName.stringValue = "\(String(describing: playingSongName!))"
                    } else {
                        songName.stringValue = "\(String(describing: playingSongName!.prefix(10)))..."
                    }
                    if playingsongArtist!.count < 15 {
                        songDescription.stringValue = "\(String(describing: playingsongArtist!))"
                    } else {
                        songDescription.stringValue = "\(String(describing: playingsongArtist!.prefix(15)))..."
                    }
                }
                if SpotifyAppleScript.currentTrack.artworkUrl == nil {
                    musicApp.image = NSImage(named: "music")
                } else {
                    let playingsongArtwork = NSImage(contentsOf: URL(string: SpotifyAppleScript.currentTrack.artworkUrl!)!)
                    musicApp.image = playingsongArtwork
                }
            } else {
                let systemVersion = ProcessInfo.processInfo.operatingSystemVersion.minorVersion
                var musicIsRunning = 0
                if systemVersion == 12 || systemVersion == 13 || systemVersion == 14 {
                    musicIsRunning = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.iTunes").count
                } else {
                    musicIsRunning = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.Music").count
                }
                if musicIsRunning > 0 {
                    switch iTunesAppleScript.playerState {
                    case .paused:
                        iTunesAppleScript.playerState = .playing
                        pauseButton.image = NSImage(named: "NSTouchBarPauseTemplate")
                    case .playing:
                        iTunesAppleScript.playerState = .paused
                        pauseButton.image = NSImage(named: "NSTouchBarPlayTemplate")
                    }
                    songDescription.isHidden = false
                    let playingSongName = iTunesAppleScript.currentTrack.title
                    let playingsongArtist = iTunesAppleScript.currentTrack.artist
                    if playingSongName == nil && playingsongArtist == nil {
                        songName.stringValue = "Not Playing"
                        songDescription.isHidden = true
                    } else {
                        if playingSongName!.count < 10 {
                            songName.stringValue = "\(String(describing: playingSongName!))"
                        } else {
                            songName.stringValue = "\(String(describing: playingSongName!.prefix(10)))..."
                        }
                        if playingsongArtist!.count < 15 {
                            songDescription.stringValue = "\(String(describing: playingsongArtist!))"
                        } else {
                            songDescription.stringValue = "\(String(describing: playingsongArtist!.prefix(15)))..."
                        }
                    }
                    if iTunesAppleScript.currentTrack.artworkUrl == nil {
                        musicApp.image = NSImage(named: "music")
                    } else {
                        let playingsongArtwork = NSImage(contentsOf: URL(string: iTunesAppleScript.currentTrack.artworkUrl!)!)
                        musicApp.image = playingsongArtwork
                    }
                }
            }
        }
    }
    
    @IBAction func switchAppearanceToggled(_ sender: NSButton) {
        switchAppearance()
        let currentAppearance = getCurrentAppearance()
        if currentAppearance == true {
            appearanceStatus.stringValue = "Dark"
        } else {
            appearanceStatus.stringValue = "Light"
        }
    }
    
    @IBAction func nightshiftToggled(_ sender: NSButton) {
        let nightlightpath = Bundle.main.path(forResource: "nightlight", ofType:nil)!
        let nightshiftstate = shell("\"\(nightlightpath)\" status")
        if nightshiftstate.contains("off") {
            _ = shell("\"\(nightlightpath)\" on")
            nightshiftBulb.image = NSImage(named: "bulb_on")
            nightshiftStatus.stringValue = "Turned on!"
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.nightshiftStatus.stringValue = "Night Shift"
            }
        } else if nightshiftstate.contains("on") {
            _ = shell("\"\(nightlightpath)\" off")
            nightshiftBulb.image = NSImage(named: "bulb_off")
            nightshiftStatus.stringValue = "Turned off!"
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.nightshiftStatus.stringValue = "Night Shift"
            }
        }
    }
    
    @IBAction func nightshiftWarmedChanged(_ sender: NSSlider) {
        let warmth = Int(nightshiftSlider!.doubleValue)
        let nightlightpath = Bundle.main.path(forResource: "nightlight", ofType:nil)!
        _ = shell("\"\(nightlightpath)\" temp \(warmth)")
    }
    
    
    @IBAction func sleepDisplayToggled(_ sender: NSButton) {
        sleepDisplay()
    }
    
    @IBAction func bluetoothClicked(_ sender: NSButton) {
        toggleBluetooth()
    }
    
    @IBAction func brightnessChanged(_ sender: NSSlider) {
        let brightness = Float(brightnessSlider!.doubleValue) / 100
        brightnessSlider.isContinuous = true
        setBrightnessLevel(level: brightness)
    }
    
    @IBAction func volumeChanged(_ sender: NSSlider) {
        let volumelevel = Float32(volumeSlider!.doubleValue) / 100
        volumeSlider.isContinuous = true
        setVolumeLevel(level: volumelevel)
    }
    
    @IBAction func dndStateChanged(_ sender: NSButton) {
        updateDNDStatus()
    }
    
    @IBAction func wifiToggled(_ sender: NSButton) {
        let networkstatus = shell("/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport -s")
        if networkstatus == "" {
            _ = shell("networksetup -setairportpower en0 on")
            wifiStatus.stringValue = "On"
            wifiBulb.image = NSImage(named: "bulb_on")
        } else {
            _ = shell("networksetup -setairportpower en0 off")
            wifiStatus.stringValue = "Off"
            wifiBulb.image = NSImage(named: "bulb_off")
        }
    }
    
    func switchAppearance() {
        _ = shell("osascript -e 'tell app \"System Events\" to tell appearance preferences to set dark mode to not dark mode'")
    }
    
    func getCurrentAppearance() -> Bool {
        return UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark"
    }
    
    func sleepDisplay() {
        _ = shell("pmset displaysleepnow")
    }
    
    func toggleBluetooth() {
        let blueutilpath = Bundle.main.path(forResource: "blueutil", ofType:nil)!
        let bluetoothstate = shell("\"\(blueutilpath)\" --power")
        if bluetoothstate.contains("0") {
            _ = shell("\"\(blueutilpath)\" --power 1")
            BluetoothBulb.image = NSImage(named: "bulb_on")
            BluetoothStatus.stringValue = "On"
        } else if bluetoothstate.contains("1") {
            _ = shell("\"\(blueutilpath)\" --power 0")
            BluetoothBulb.image = NSImage(named: "bulb_off")
            BluetoothStatus.stringValue = "Off"
        }
    }
    
    func update(_ weather: Weather) {
        // do UI updates on the main thread
        let formatter = MeasurementFormatter()
        let Temperature = Measurement(value: 0, unit: UnitTemperature.celsius)
        let tempUnit = formatter.string(from: Temperature).last
        let currentTempRound = weather.currentTemp.rounded()
        
        DispatchQueue.main.async {
            self.weatherCityName.stringValue = "Weather in \(weather.city)"
            self.weatherTemp.stringValue = "Temperature: \(currentTempRound)˚\(tempUnit!)"
            self.weatherCons.stringValue = "\(weather.conditions)"
            self.weatherPressure.stringValue = "Pressure: \(weather.pressure) hpa"
            self.weatherHumid.stringValue = "Humidity: \(weather.humidity)%"
            self.weatherIMGView.image = NSImage(named: weather.icon)
        }
    }
    
    func updateDNDStatus() {
        let dndshellpath = Bundle.main.path(forResource: "do-not-disturb", ofType:nil)!
        let status = shell("\"\(dndshellpath)\" status")
        if status.contains("off") {
            enableDND()
            dndBulb.image = NSImage(named: "bulb_on")
            dndStatus.stringValue = "On"
        } else {
            disableDND()
            dndBulb.image = NSImage(named: "bulb_off")
            dndStatus.stringValue = "Off"
        }
    }
    
    func enableDND() {
        let dndshellpath = Bundle.main.path(forResource: "do-not-disturb", ofType:nil)!
        _ = shell("\"\(dndshellpath)\" on")
    }
    
    func disableDND() {
        let dndshellpath = Bundle.main.path(forResource: "do-not-disturb", ofType:nil)!
        _ = shell("\"\(dndshellpath)\" off")
    }
    
    func setBrightnessLevel(level: Float) {
        var iterator: io_iterator_t = 0
        if IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching("IODisplayConnect"), &iterator) == kIOReturnSuccess {
            var service: io_object_t = 1
            while service != 0 {
                service = IOIteratorNext(iterator)
                IODisplaySetFloatParameter(service, 0, kIODisplayBrightnessKey as CFString, level)
                IOObjectRelease(service)
            }
        }
    }
    
    func getDisplayBrightness() -> Float {
        
        var brightness: Float = 1.0
        var service: io_object_t = 1
        var iterator: io_iterator_t = 0
        let result: kern_return_t = IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching("IODisplayConnect"), &iterator)
        
        if result == kIOReturnSuccess {
            
            while service != 0 {
                service = IOIteratorNext(iterator)
                IODisplayGetFloatParameter(service, 0, kIODisplayBrightnessKey as CFString, &brightness)
                IOObjectRelease(service)
            }
        }
        return brightness
    }
    
    func setVolumeLevel(level: Float32) {
        var defaultOutputDeviceID = AudioDeviceID(0)
        var defaultOutputDeviceIDSize = UInt32(MemoryLayout.size(ofValue: defaultOutputDeviceID))
        
        var getDefaultOutputDevicePropertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
        
        AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &getDefaultOutputDevicePropertyAddress, 0, nil, &defaultOutputDeviceIDSize, &defaultOutputDeviceID)
        
        var volume = Float32(level) // 0.0 ... 1.0
        let volumeSize = UInt32(MemoryLayout.size(ofValue: volume))
        
        var volumePropertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwareServiceDeviceProperty_VirtualMasterVolume,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMaster)
        
        AudioObjectSetPropertyData(defaultOutputDeviceID, &volumePropertyAddress, 0, nil, volumeSize, &volume)
    }
    
    func shell(_ command: String) -> String {
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
