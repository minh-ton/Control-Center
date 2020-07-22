## Bring the macOS Big Sur Control Center to macOS 10.12 - 10.15

### Requirements
- macOS 10.12.2 Sierra or later.
- Supports Night Shift (Blue Light Filter)

### How to use: 

- Download the latest release from the [Releases page](https://github.com/Minh-Ton/Control-Center/releases/latest).
- Open the downloaded ```Control Center.dmg``` file, and move the App to the Applications folder.
- Launch ```Control Center.app```

#### Application is damaged / unidentified developer

Currently, the app is only signed with an Apple Development Certificate. Therefore you might experience `Application is damaged` or `Unidentified Developer`. 
To bypass our friend Gatekeeper, run the following command:
```bash
sudo spctl --master-disable
```
If you still cannot open the app, try with a different command: 
```bash
#Assuming the app is in the Applications folder
sudo xattr -d com.apple.quarantine /Applications/Control\ Center.app 
sudo codesign --force --deep --sign - /Applications/Control\ Center.app 
```
After running one of those commands, you should be able to open the application.

#### Build from Source Code: 
**[ Requires Xcode 9.3 or later ]** 
- Create a new Swift file called "APIKey.swift"
- In APIKey.swift, add a function ```weatherAPIKey```: 
```swift
func weatherAPIKey() -> String {
    return "YOUR_API_KEY_HERE" //Weather API from OpenWeatherMap
}
```
- Build the app and run it normally.

### LICENSE
This project is licensed under the MIT License. View LICENSE.md to know more.

