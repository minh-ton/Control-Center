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

class ControlCenterView: NSView {

    @IBOutlet weak var weatherCityName: NSTextField!
    @IBOutlet weak var weatherTemp: NSTextField!
    @IBOutlet weak var weatherCons: NSTextField!
    @IBOutlet weak var weatherPressure: NSTextField!
    @IBOutlet weak var weatherHumid: NSTextField!
    @IBOutlet weak var weatherIMGView: NSImageView!
    @IBOutlet weak var dndBulb: NSImageView!
    @IBOutlet weak var dndStatus: NSTextField!
    @IBOutlet weak var flushDNSCacheLabel: NSTextField!
    @IBOutlet weak var brightnessSlider: NSSlider!
    @IBOutlet weak var volumeSlider: NSSlider!
    @IBOutlet weak var flushDNDCacheBulb: NSImageView!
    @IBOutlet weak var BluetoothBulb: NSImageView!
    @IBOutlet weak var BluetoothStatus: NSTextField!
    @IBOutlet weak var wifiBulb: NSImageView!
    @IBOutlet weak var wifiStatus: NSTextField!
    @IBOutlet weak var appearanceStatus: NSTextField!
    @IBOutlet weak var appearanceBulb: NSImageView!
    
    @IBAction func switchAppearanceToggled(_ sender: Any) {
        switchAppearance()
        let currentAppearance = getCurrentAppearance()
        if currentAppearance.contains("true") {
            appearanceStatus.stringValue = "Dark"
        } else {
            appearanceStatus.stringValue = "Light"
        }
    }
    
    @IBAction func sleepDisplayToggled(_ sender: Any) {
        sleepDisplay()
    }
    
    @IBAction func bluetoothClicked(_ sender: Any) {
        toggleBluetooth()
    }
    
    @IBAction func flushedDNDCache(_ sender: Any) {
        _ = shell("dscacheutil -flushcache")
        flushDNSCacheLabel.stringValue = "Done Flushing!"
        let seconds = 10.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.flushDNSCacheLabel.stringValue = "Flush DNS Cache"
        }
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
    
    @IBAction func dndStateChanged(_ sender: Any) {
        updateDNDStatus()
    }
    
    @IBAction func wifiToggled(_ sender: Any) {
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
    
    func getCurrentAppearance() -> String {
        return shell("osascript -e 'tell application \"System Events\" to return dark mode of appearance preferences'")
    }
    
    func sleepDisplay() {
        let maclightpath = Bundle.main.path(forResource: "maclight", ofType:nil)!
        _ = shell("\"\(maclightpath)\" --ds")
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
            self.weatherTemp.stringValue = "Temp: \(currentTempRound)˚\(tempUnit!)"
            self.weatherCons.stringValue = "Cond: \(weather.conditions)"
            self.weatherPressure.stringValue = "Pr: \(weather.pressure) hpa"
            self.weatherHumid.stringValue = "Hum: \(weather.humidity)%"
            self.weatherIMGView.image = NSImage(named: weather.icon)
        }
    }
    
    func updateDNDStatus() {
        let dndPlist = UserDefaults(suiteName: "com.apple.notificationcenterui")
        let status = dndPlist!.bool(forKey: "doNotDisturb")
        if status == false {
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
        CFPreferencesSetValue("dndStart" as CFString, CGFloat(0) as CFPropertyList, "com.apple.notificationcenterui" as CFString, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost)
        CFPreferencesSetValue("dndEnd" as CFString, CGFloat(1440) as CFPropertyList, "com.apple.notificationcenterui" as CFString, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost)
        CFPreferencesSetValue("doNotDisturb" as CFString, true as CFPropertyList, "com.apple.notificationcenterui" as CFString, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost)
        CFPreferencesSynchronize("com.apple.notificationcenterui" as CFString, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost)
        DistributedNotificationCenter.default().postNotificationName(NSNotification.Name(rawValue: "com.apple.notificationcenterui.dndprefs_changed"), object: nil, userInfo: nil, deliverImmediately: true)
    }
    
    func disableDND() {
        CFPreferencesSetValue("dndStart" as CFString, nil, "com.apple.notificationcenterui" as CFString, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost)
        CFPreferencesSetValue("dndEnd" as CFString, nil, "com.apple.notificationcenterui" as CFString, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost)
        CFPreferencesSetValue("doNotDisturb" as CFString, false as CFPropertyList, "com.apple.notificationcenterui" as CFString, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost)
        CFPreferencesSynchronize("com.apple.notificationcenterui" as CFString, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost)
        DistributedNotificationCenter.default().postNotificationName(NSNotification.Name(rawValue: "com.apple.notificationcenterui.dndprefs_changed"), object: nil, userInfo: nil, deliverImmediately: true)
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
