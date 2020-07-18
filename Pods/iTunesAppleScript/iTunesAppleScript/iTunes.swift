//
//  iTunesAppleScript.swift
//  iTunesAppleScript
//
//  Created by Miklós Kristyán on 08/10/17.
//  Copyright © 2017 KM. All rights reserved.
//

import Foundation

var myAppleScript = ""

open class iTunesAppleScript: NSObject {
    
    // MARK: - Variables
    open static var currentTrack = Track()
    
    open static var playerState: PlayerState {
        get {
            if let state = iTunesAppleScript.executeAppleScriptWithString("get player state") {
                
                if let stateEnum = PlayerState(rawValue: state) {
                    return stateEnum
                }
            }
            return PlayerState.paused
        }
        
        set {
            switch newValue {
            case .paused:
                _ = iTunesAppleScript.executeAppleScriptWithString("pause")
            case .playing:
                _ = iTunesAppleScript.executeAppleScriptWithString("play")
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: InternalNotification.key), object: self)
        }
    }
    
    
    // MARK: - Methods
    open static func playNext(_ completionHandler: (()->())? = nil){
        _ = iTunesAppleScript.executeAppleScriptWithString("play (next track)")
        completionHandler?()
        NotificationCenter.default.post(name: Notification.Name(rawValue: InternalNotification.key), object: self)
        
    }
    
    open static func playPrevious(_ completionHandler: (() -> ())? = nil){
        _ = iTunesAppleScript.executeAppleScriptWithString("play (previous track)")
        completionHandler?()
        NotificationCenter.default.post(name: Notification.Name(rawValue: InternalNotification.key), object: self)
    }
    
    
    open static func startiTunes(hidden: Bool = true, completionHandler: (() -> ())? = nil){
        let option: StartOptions
        switch hidden {
        case true:
            option = .withoutUI
        case false:
            option = .withUI
        }
        _ = iTunesAppleScript.startiTunes(option: option)
        completionHandler?()
        NotificationCenter.default.post(name: Notification.Name(rawValue: InternalNotification.key), object: self)
    }
    
    
    open static func activateiTunes(completionHandler: (() -> ())? = nil){
        _ = iTunesAppleScript.activateiTunes()
        completionHandler?()
        NotificationCenter.default.post(name: Notification.Name(rawValue: InternalNotification.key), object: self)
    }
    
    // MARK: - Helpers
    static func executeAppleScriptWithString(_ command: String) -> String? {
        let systemVersion = ProcessInfo.processInfo.operatingSystemVersion.minorVersion
        if systemVersion == 12 || systemVersion == 13 || systemVersion == 14 {
            myAppleScript = "if application \"iTunes\" is running then tell application \"iTunes\" to \(command)"
        } else {
            myAppleScript = "if application \"Music\" is running then tell application \"Music\" to \(command)"
        }
        
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: myAppleScript) {
            return scriptObject.executeAndReturnError(&error).stringValue
        }
        return nil
    }
    
    
    enum StartOptions {
        case withUI
        case withoutUI
    }
    
    static func startiTunes(option:StartOptions) -> String? {
        let command:String;
        switch option {
        case .withoutUI:
            command = "run"
        case .withUI:
            command = "launch"
        }
        
        let systemVersion = ProcessInfo.processInfo.operatingSystemVersion.minorVersion
        if systemVersion == 12 || systemVersion == 13 || systemVersion == 14 {
            myAppleScript = "if application \"iTunes\" is not running then \(command) application \"iTunes\""
        } else {
            myAppleScript = "if application \"Music\" is not running then \(command) application \"Music\""
        }
        
        //print(myAppleScript)
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: myAppleScript) {
            return scriptObject.executeAndReturnError(&error).stringValue
        }
        return nil
    }
    
    static func activateiTunes() -> String? {
        
        let myAppleScript = "activate application \"iTunes\""
        
        //print(myAppleScript)
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: myAppleScript) {
            return scriptObject.executeAndReturnError(&error).stringValue
        }
        return nil
    }
    
}
