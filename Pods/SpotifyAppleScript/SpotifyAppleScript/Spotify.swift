//
//  Spotify.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 02/09/16.
//  Copyright © 2016 KM. All rights reserved.
//

import Foundation

open class SpotifyAppleScript: NSObject {
    
    // MARK: - Variables
    open static var currentTrack = Track()
    
    open static var playerState: PlayerState {
        get {
            if let state = SpotifyAppleScript.executeAppleScriptWithString("get player state") {
                //print(state)
                if let stateEnum = PlayerState(rawValue: state) {
                    return stateEnum
                }
            }
            return PlayerState.paused
        }
        
        set {
            switch newValue {
            case .paused:
                _ = SpotifyAppleScript.executeAppleScriptWithString("pause")
            case .playing:
                _ = SpotifyAppleScript.executeAppleScriptWithString("play")
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: InternalNotification.key), object: self)
        }
    }
    
    
    // MARK: - Methods
    open static func playNext(_ completionHandler: (()->())? = nil){
        _ = SpotifyAppleScript.executeAppleScriptWithString("play (next track)")
        completionHandler?()
        NotificationCenter.default.post(name: Notification.Name(rawValue: InternalNotification.key), object: self)
        
    }
    
    open static func playPrevious(_ completionHandler: (() -> ())? = nil){
        _ = SpotifyAppleScript.executeAppleScriptWithString("play (previous track)")
        completionHandler?()
        NotificationCenter.default.post(name: Notification.Name(rawValue: InternalNotification.key), object: self)
    }
    
    
    open static func startSpotify(hidden: Bool = true, completionHandler: (() -> ())? = nil){
        let option: StartOptions
        switch hidden {
        case true:
            option = .withoutUI
        case false:
            option = .withUI
        }
        _ = SpotifyAppleScript.startSpotify(option: option)
        completionHandler?()
        NotificationCenter.default.post(name: Notification.Name(rawValue: InternalNotification.key), object: self)
    }
    
    
    open static func activateSpotify(completionHandler: (() -> ())? = nil){
        _ = SpotifyAppleScript.activateSpotify()
        completionHandler?()
        NotificationCenter.default.post(name: Notification.Name(rawValue: InternalNotification.key), object: self)
    }
    
    // MARK: - Helpers
    static func executeAppleScriptWithString(_ command: String) -> String? {
        let myAppleScript = "if application \"Spotify\" is running then tell application \"Spotify\" to \(command)"
        
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
    
    static func startSpotify(option:StartOptions) -> String? {
        let command:String;
        switch option {
        case .withoutUI:
            command = "run"
        case .withUI:
            command = "launch"
        }
        
        let myAppleScript = "if application \"Spotify\" is not running then \(command) application \"Spotify\""
        
        //print(myAppleScript)
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: myAppleScript) {
            return scriptObject.executeAndReturnError(&error).stringValue
        }
        return nil
    }
    
    static func activateSpotify() -> String? {
        
        let myAppleScript = "activate application \"Spotify\""
        
        //print(myAppleScript)
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: myAppleScript) {
            return scriptObject.executeAndReturnError(&error).stringValue
        }
        return nil
    }
    
}
