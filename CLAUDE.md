## Build

    $ xcodebuild -project Cocoa\ CapsBeeper.xcodeproj

## Notes

- Deployment target is macOS 13.0+ (required for SMAppService)
- The Objective-C API is `SMAppService.mainAppService`, not `mainApp` — the latter is the Swift-only name (via `NS_SWIFT_NAME`)
- The app name "Cocoa CapsBeeper" appears in many places: project.pbxproj, Info.plist, InfoPlist.strings, MainMenu.nib, AppController.m, build.yml, and the xcodeproj directory name itself
- Homebrew formula lives in https://github.com/henrik242/homebrew-brew
