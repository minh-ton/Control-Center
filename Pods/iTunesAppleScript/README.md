# iTunesAppleScript
An iTunes wrapper class for controlling iTunes on macOS.

This wrapper class was originally created for [SpotMenu](https://github.com/kmikiy/SpotMenu).

## Installation

To integrate iTunesAppleScript into your Xcode project using CocoaPods, specify it in your `Podfile`:

```sh
platform :osx, '10.10'
use_frameworks!

target '<Your Target Name>' do
    pod 'iTunesAppleScript', '~> 0.3'
end
```

Then, run the following command:

```sh
$ pod install
```
## Usage example

```swift
import iTunesAppleScript


// Get current artist
if let artist = iTunesAppleScript.currentTrack.artist {
    print(artist)
}

// Get current track title
if let title = iTunesAppleScript.currentTrack.title {
    print(title)
}

// Play next song
iTunesAppleScript.playNext()
```

