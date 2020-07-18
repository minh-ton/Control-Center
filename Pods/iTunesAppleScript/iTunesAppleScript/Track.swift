//
//  CurrentTrack.swift
//  iTunesAppleScript
//
//  Created by Miklós Kristyán on 08/10/17.
//  Copyright © 2017 KM. All rights reserved.
//

import Foundation

open class Track: NSObject {
    
    open var id: String? {
        get { return iTunesAppleScript.executeAppleScriptWithString("get id of current track") }
    }
    
    open var title: String? {
        get { return iTunesAppleScript.executeAppleScriptWithString("get name of current track") }
    }
    
    open var artist: String? {
        get { return iTunesAppleScript.executeAppleScriptWithString("get artist of current track") }
    }
    
    open var albumArtist: String? {
        get { return iTunesAppleScript.executeAppleScriptWithString("get album artist of current track") }
    }
    
    open var artworkUrl: String? {
        get { return iTunesAppleScript.executeAppleScriptWithString("get artwork url of current track") }
    }
    
    open var positionPercentage: Double {
        get {
            let d = duration
            if d == 0.0 { return 0}
            return position/d
        }
        set {
            let d = duration
            if d == 0.0 { return }
            _ = iTunesAppleScript.executeAppleScriptWithString("set player position to \(d * newValue)")
            return
        }
        
    }
    
    open var position: Double {
        get {
            if let pos = iTunesAppleScript.executeAppleScriptWithString("get player position") {
                if let val = Double(pos) {
                    return val
                }
            }
            return 0
        }
    }
    
    open var duration: Double {
        get {
            if let pos = iTunesAppleScript.executeAppleScriptWithString("get duration of current track") {
                if let val = Double(pos) {
                    return val/1000
                }
            }
            return 0
        }
    }
}
