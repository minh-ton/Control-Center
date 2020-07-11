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
    
    @IBOutlet weak var ControlCenterView: ControlCenterView!
    
    @IBOutlet weak var timelabel: NSTextField!
    @IBOutlet weak var daylabel: NSTextField!
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
    
    var controlCenterMenuItem: NSMenuItem!
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    var weatherAPI: WeatherAPI!
    var preferencesWindow: PreferencesWindow!

    override func awakeFromNib() {
        ControlCenterView.window?.isOpaque = true
        ControlCenterView.window?.backgroundColor = NSColor.clear
        
        let menuicon = NSImage(named: "controlcenter")
        
        menuicon?.isTemplate = true // best for dark mode
        statusItem.image = menuicon
        statusItem.menu = CCMenu
        controlCenterMenuItem = CCMenu.item(withTitle: "ControlCenter")
        controlCenterMenuItem.view = ControlCenterView
        preferencesWindow = PreferencesWindow()
        
        // Insert code here to initialize your application
        weatherAPI = WeatherAPI(delegate: self)
        
        updateTime()
        updateInfomation()
        updateBrightnessSlider()
        updateVolumeSlider()
        updateWifiNetworkString()
        updateBluetoothString()
        updateDNDStatus()
        checkAppearanceCompat()
        updateAppearanceString()
    }
    
    @IBAction func preferencesClicked(_ sender: Any) {
        preferencesWindow.showWindow(nil)
    }
    
    
    func checkAppearanceCompat() {
        let systemVersion = ProcessInfo.processInfo.operatingSystemVersion.minorVersion
        if systemVersion == 12 || systemVersion == 13 {
            appearanceSwitchButton.isEnabled = false
            appearanceStatus.stringValue = "Not Available"
        }
    }
    
    var timer = Timer()
    private func updateInfomation() {
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector:#selector(self.updateTime) , userInfo: nil, repeats: true)
        timer = Timer.scheduledTimer(timeInterval: 15.0, target: self, selector:#selector(self.updateWifiNetworkString) , userInfo: nil, repeats: true)
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector:#selector(self.updateDNDStatus) , userInfo: nil, repeats: true)
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(self.updateBrightnessSlider) , userInfo: nil, repeats: true)
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(self.updateVolumeSlider) , userInfo: nil, repeats: true)
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector:#selector(self.updateBluetoothString) , userInfo: nil, repeats: true)
        timer = Timer.scheduledTimer(timeInterval: 8.0, target: self, selector:#selector(self.updateAppearanceString) , userInfo: nil, repeats: true)
    }
    
    @objc func updateAppearanceString() {
        let currentAppearance = getCurrentAppearance()
        if currentAppearance.contains("true") {
            appearanceStatus.stringValue = "Dark"
        } else {
            appearanceStatus.stringValue = "Light"
        }
    }
    
    func getCurrentAppearance() -> String {
        return shell("osascript -e 'tell application \"System Events\" to return dark mode of appearance preferences'")
    }
    
    @objc func updateBluetoothString() {
        /* Shell Script:
         
         blueutilpath=$1
         echo $("$blueutilpath" --recent 1) | sed 's/^.*name/name/' | cut -c7- | tr -d '"' | awk -F',' '{print $1}'
         
         */
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
        let dndPlist = UserDefaults(suiteName: "com.apple.notificationcenterui")
        let status = dndPlist!.bool(forKey: "doNotDisturb")
        if status == false {
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
                updateWeather()
            }
        }
    }
    
    @objc func updateTime() {
        let date = Date()
        let (hour, minute) = (date.hour, date.minute)
        let (day, month, year) = (date.day, date.month, date.year)
        self.timelabel.stringValue = "\(hour):\(minute)"
        self.daylabel.stringValue = "\(day)/\(month)/\(year)"
    }
    
    func weatherDidUpdate(_ weather: Weather) {
      NSLog(weather.description)
    }
    
    func updateWeather() {
        let defaults = UserDefaults.standard
        let city = defaults.string(forKey: "city") ?? DEFAULT_CITY
        weatherAPI.fetchWeather(city) { weather in
            self.ControlCenterView.update(weather)
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
    
    func getBatteryPowerSource() -> String {
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let powerSource = IOPSGetProvidingPowerSourceType(snapshot).takeRetainedValue()
        return powerSource as String
    }
    
    func getBatteryPercentage() -> Int {
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as Array
        for source in sources {
            if let description = IOPSGetPowerSourceDescription(snapshot, source).takeUnretainedValue() as? [String: Any] {
                if description["Type"] as? String == kIOPSInternalBatteryType {
                    return description[kIOPSCurrentCapacityKey] as? Int ?? 0
                }
            }
        }
        return 0
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
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
}
