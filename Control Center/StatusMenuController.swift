//
//  StatusMenuController.swift
//  Control Center
//
//  Created by MinhTon on 7/9/20.
//  Copyright © 2020 MinhTon. All rights reserved.
//

import Cocoa
import AudioToolbox
import CoreWLAN
import CoreBluetooth
import IOKit.ps
import IOKit
import SpotifyAppleScript
import iTunesAppleScript

let DEFAULT_CITY = "North Pole"

extension Date {
    func components(_ components: Set<Calendar.Component>) -> DateComponents {
        return Calendar.current.dateComponents(components, from: self)
    }
    
    func component(_ component: Calendar.Component) -> Int {
        return Calendar.current.component(component, from: self)
    }
    
    var era: Int { return component(.era) }
    var year: Int { return component(.year) }
    var month: Int { return component(.month) }
    var day: Int { return component(.day) }
    var hour: Int { return component(.hour) }
    var minute: Int { return component(.minute) }
    var second: Int { return component(.second) }
    var weekday: Int { return component(.weekday) }
    var weekdayOrdinal: Int { return component(.weekdayOrdinal) }
    var quarter: Int { return component(.quarter) }
    var weekOfMonth: Int { return component(.weekOfMonth) }
    var weekOfYear: Int { return component(.weekOfYear) }
    var yearForWeekOfYear: Int { return component(.yearForWeekOfYear) }
    var nanosecond: Int { return component(.nanosecond) }
    var calendar: Calendar? { return components([.calendar]).calendar }
    var timeZone: TimeZone? { return components([.timeZone]).timeZone }
}

class StatusMenuController: NSObject, NSMenuDelegate, WeatherAPIDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var CCMenu: NSMenu!
    @IBOutlet weak var controlCenterView: ControlCenterView!
    @IBOutlet weak var brightnessSlider: NSSlider!
    @IBOutlet weak var volumeSlider: NSSlider!
    @IBOutlet weak var wifiStatus: NSTextField!
    @IBOutlet weak var wifiBulb: NSImageView!
    @IBOutlet weak var bluetoothStatus: NSTextField!
    @IBOutlet weak var bluetoothBulb: NSImageView!
    @IBOutlet weak var dndStatus: NSTextField!
    @IBOutlet weak var dndLayer: NSImageView!
    @IBOutlet weak var appearanceStatus: NSTextField!
    @IBOutlet weak var appearanceSwitchButton: NSButton!
    @IBOutlet weak var nightshiftBulb: NSImageView!
    @IBOutlet weak var nightshiftSlider: NSSlider!
    @IBOutlet weak var songName: NSTextField!
    @IBOutlet weak var songDescription: NSTextField!
    @IBOutlet weak var musicApp: NSImageView!
    @IBOutlet weak var pauseButton: NSButton!
    
    var controlCenterMenuItem: NSMenuItem!
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    var weatherAPI: WeatherAPI!
    var preferencesWindow: PreferencesWindow!
    var wifiDetailsView: WiFiDetailsView!
    
    override func awakeFromNib() {
        controlCenterView.window?.isOpaque = true
        controlCenterView.window?.backgroundColor = NSColor.clear
        
        let menuicon = NSImage(named: "controlcenter")
        menuicon?.isTemplate = true
        statusItem.image = menuicon
        statusItem.menu = CCMenu
        controlCenterMenuItem = CCMenu.item(withTitle: "ControlCenter")
        controlCenterMenuItem.view = controlCenterView
        preferencesWindow = PreferencesWindow()
        wifiDetailsView = WiFiDetailsView(frame: controlCenterView.frame)
        wifiDetailsView.backButton.target = self
        wifiDetailsView.backButton.action = #selector(returnFromWiFiClicked(_:))
        
        // Insert code here to initialize your application
        weatherAPI = WeatherAPI(delegate: self)
        updateInfomation()
        updateAll()
    }
    
    @IBAction func preferencesClicked(_ sender: Any) {
        preferencesWindow.showWindow(self)
    }
    
    @IBAction func wifiDetailsClicked(_ sender: NSButton) {
        controlCenterMenuItem.view = wifiDetailsView
        controlCenterView.isHidden = true
        wifiDetailsView.isHidden = false
    }

    @objc func returnFromWiFiClicked(_ sender: NSButton) {
        controlCenterMenuItem.view = controlCenterView
        controlCenterView.isHidden = false
        wifiDetailsView.isHidden = true
    }

    func updateAll() {
        updateBrightnessSlider()
        updateVolumeSlider()
        updateWifiNetworkString()
        updateBluetoothString()
        updateDNDStatus()
        updateAppearanceString()
        updateNightShift()
        checkSpotifyPlaying()
        checkMusicPlaying()
        updateWeather()
    }
    
    var timer = Timer()
    private func updateInfomation() {
        timer = Timer.scheduledTimer(timeInterval: 15.0, target: self, selector:#selector(self.updateWifiNetworkString) , userInfo: nil, repeats: true)
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector:#selector(self.updateDNDStatus) , userInfo: nil, repeats: true)
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(self.updateBrightnessSlider) , userInfo: nil, repeats: true)
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(self.updateVolumeSlider) , userInfo: nil, repeats: true)
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector:#selector(self.updateBluetoothString) , userInfo: nil, repeats: true)
        timer = Timer.scheduledTimer(timeInterval: 8.0, target: self, selector:#selector(self.updateAppearanceString) , userInfo: nil, repeats: true)
        timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector:#selector(self.updateNightShift) , userInfo: nil, repeats: true)
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector:#selector(self.checkSpotifyPlaying) , userInfo: nil, repeats: true)
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector:#selector(self.checkMusicPlaying) , userInfo: nil, repeats: true)
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector:#selector(self.updateWeather) , userInfo: nil, repeats: true)
    }
    
    @objc func updateNightShift() {
        let nightlightpath = Bundle.main.path(forResource: "nightlight", ofType:nil)!
        let nightshiftstate = shell("\"\(nightlightpath)\" status")
        if nightshiftstate.contains("off") {
            nightshiftBulb.image = NSImage(named: "bulb_off")
        } else if nightshiftstate.contains("on") {
            nightshiftBulb.image = NSImage(named: "bulb_on")
        }
        let nightshiftwarmth = shell("\"\(nightlightpath)\" temp")
        nightshiftSlider.doubleValue = (nightshiftwarmth as NSString).doubleValue
    }
    
    @objc func updateAppearanceString() {
        let currentAppearance = getCurrentAppearance()
        if currentAppearance == true {
            appearanceStatus.stringValue = "Dark"
        } else {
            appearanceStatus.stringValue = "Light"
        }
    }
    
    func getCurrentAppearance() -> Bool {
        return UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark"
    }
    
    @objc func checkMusicPlaying() {
        let systemVersion = ProcessInfo.processInfo.operatingSystemVersion.minorVersion
        var musicIsRunning = 0
        if systemVersion == 12 || systemVersion == 13 || systemVersion == 14 {
            musicIsRunning = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.iTunes").count
        } else {
            musicIsRunning = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.Music").count
        }
        if musicIsRunning > 0 {
            let playerstate = iTunesAppleScript.playerState
            if playerstate.rawValue == "kPSP" {
                pauseButton.image = NSImage(named: "NSTouchBarPauseTemplate")
            } else {
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
        } else {
            return
        }
    }
    
    @objc func checkSpotifyPlaying() {
        let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.spotify.client")
        if url == nil {
            return
        } else {
            let spotifyIsRunning = NSRunningApplication.runningApplications(withBundleIdentifier: "com.spotify.client").count
            if spotifyIsRunning > 0 {
                let playerstate = SpotifyAppleScript.playerState
                if playerstate.rawValue == "kPSP" {
                    pauseButton.image = NSImage(named: "NSTouchBarPauseTemplate")
                } else {
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
                return
            }
        }
    }

    @objc func updateBluetoothString() {
        /* blueutilpath=$1
         echo $("$blueutilpath" --recent 1) | sed 's/^.*name/name/' | cut -c7- | tr -d '"' | awk -F',' '{print $1}' */
        
        let blueutilpath = Bundle.main.path(forResource: "blueutil", ofType:nil)!
        let bluetoothstate = shell("\"\(blueutilpath)\" --power")
        if bluetoothstate.contains("0") {
            bluetoothStatus.stringValue = "Off"
            bluetoothBulb.image = NSImage(named: "bulb_off")
        } else if bluetoothstate.contains("1") {
            bluetoothStatus.stringValue = "On"
            bluetoothBulb.image = NSImage(named: "bulb_on")
        }
    }
    
    @objc func updateBrightnessSlider() {
        let brightness = getDisplayBrightness()
        brightnessSlider.isContinuous = true
        brightnessSlider.doubleValue = Double(brightness)*100
    }
    
    @objc func updateVolumeSlider() {
        let volume = getSystemVolume()
        volumeSlider.isContinuous = true
        volumeSlider.doubleValue = Double(volume)*100
    }
    
    @objc func updateDNDStatus() {
        let dndshellpath = Bundle.main.path(forResource: "do-not-disturb", ofType:nil)!
        let status = shell("\"\(dndshellpath)\" status")
        if status.contains("off") {
            dndLayer.image = NSImage(named: "bulb_off")
            dndStatus.stringValue = "Off"
        } else {
            dndLayer.image = NSImage(named: "bulb_on")
            dndStatus.stringValue = "On"
        }
    }
    
    @objc func updateWifiNetworkString() {
        var ssid: String {
            return CWWiFiClient.shared().interface(withName: nil)?.ssid() ?? ""
        }
        let networkstatus = shell("/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport -s")
        if networkstatus == "" {
            wifiStatus.stringValue = "Off"
            wifiBulb.image = NSImage(named: "bulb_off")
        } else {
            if ssid == "" {
                wifiStatus.stringValue = "On"
                wifiBulb.image = NSImage(named: "bulb_on")
            } else {
                wifiStatus.stringValue = ssid
                wifiBulb.image = NSImage(named: "bulb_on")
            }
        }
    }
    
    func weatherDidUpdate(_ weather: Weather) {
        NSLog(weather.description)
    }
    
    @objc func updateWeather() {
        let defaults = UserDefaults.standard
        let city = defaults.string(forKey: "city") ?? DEFAULT_CITY
        weatherAPI.fetchWeather(city) { weather in
            self.controlCenterView.update(weather)
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
    
    func getSystemVolume() -> Float32 {
        
        var defaultOutputDeviceID = AudioDeviceID(0)
        var defaultOutputDeviceIDSize = UInt32(MemoryLayout.size(ofValue: defaultOutputDeviceID))
        
        var getDefaultOutputDevicePropertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
        
        AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &getDefaultOutputDevicePropertyAddress, 0, nil, &defaultOutputDeviceIDSize, &defaultOutputDeviceID)
        
        var volume = Float32(0.0)
        var volumeSize = UInt32(MemoryLayout.size(ofValue: volume))
        
        var volumePropertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwareServiceDeviceProperty_VirtualMasterVolume,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMaster)
        
        AudioObjectGetPropertyData(defaultOutputDeviceID, &volumePropertyAddress, 0, nil, &volumeSize, &volume)
        
        return volume
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
