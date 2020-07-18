# Spotify
A Spotify wrapper class for controlling Spotify on macOS.

This wrapper class was originally created for [SpotMenu](https://github.com/kmikiy/SpotMenu).

## Installation

To integrate Spotify into your Xcode project using CocoaPods, specify it in your `Podfile`:

```sh
platform :osx, '10.10'
use_frameworks!

target '<Your Target Name>' do
    pod 'Spotify', '~> 0.1'
end
```

Then, run the following command:

```sh
$ pod install
```
## Usage example

```swift
import Spotify


// Get current artist
if let artist = Spotify.currentTrack.artist {
    print(artist)
}

// Get current track title
if let title = Spotify.currentTrack.title {
    print(title)
}

// Play next song
Spotify.playNext()
```

For a real-world example checkout [SpotMenu](https://github.com/kmikiy/SpotMenu)
