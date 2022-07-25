# HowtankWidgetSwift
Start with ***iOS***. Enter the following command into the terminal:

```jsx
xcodebuild archive \
-scheme HowtankWidgetSwift \
-configuration Release \
-destination 'generic/platform=iOS' \
-archivePath './build/HowtankWidgetSwift.framework-iphoneos.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
```

Next, target ***Simulator***. Make an archive by adding this command to your terminal:

```jsx
xcodebuild archive \
-scheme HowtankWidgetSwift \
-configuration Release \
-destination 'generic/platform=iOS Simulator' \
-archivePath './build/HowtankWidgetSwift.framework-iphonesimulator.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
```

Now, make the binary framework, ***XCFramework***. Add the following command to the terminal:

```
xcodebuild -create-xcframework \
-framework './build/HowtankWidgetSwift.framework-iphonesimulator.xcarchive/Products/Library/Frameworks/HowtankWidgetSwift.framework' \
-framework './build/HowtankWidgetSwift.framework-iphoneos.xcarchive/Products/Library/Frameworks/HowtankWidgetSwift.framework' \
-output './build/HowtankWidgetSwift.xcframework'

```
