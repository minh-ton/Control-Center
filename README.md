# [Control-Center Beta](https://github.com/Minh-Ton/Control-Center)

Bring the macOS Big Sur Control Center to macOS 10.12 - 10.15

### Requirements
- macOS 10.12 Sierra or later (not tested on Big Sur)

### How to use: 

- Download the latest release from the [Releases page](https://github.com/Minh-Ton/Control-Center/releases/latest).
- Open the downloaded ```Control Center.dmg``` file, and move the App to the Applications folder.
- Launch ```Control Center.app```
- To change the Weather Location, click the Settings icon near the ```Weather in North Pole``` label.

##### Application is damaged / unidentified developer

Currently, the app is only signed with an Apple Development Certificate. Therefore you might experience `Application is damaged` or `Unidentified Developer`. 
To bypass our friend Gatekeeper, run the following command:
```bash
sudo spctl --master-disable
```
If you still cannot open the app, try with a different command: 
```bash
sudo xattr -d com.apple.quarantine /Applications/Control\ Center.app #Assuming the app is in the Applications folder
```
After running one of those commands, you should be able to open the application.

#### If you want to build from Source Code: 
- Create a new Swift file called "APIKey.swift"
- In APIKey.swift, add a function ```weatherAPIKey```: 
```swift
func weatherAPIKey() -> String {
    return "YOUR_API_KEY_HERE" //Weather API from OpenWeatherMap
}
```
- Build the app and run it normally.

### Known issues
- The GUI is still a little bit slow and sluggish...
- Toggle DND Mode is not working properly, requires 2 clicks to turn DND on/off.
- There are reports of UI Glitches in Light Mode, which creates grey borders around labels.
