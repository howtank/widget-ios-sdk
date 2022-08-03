# Howtank Widget SDK
To generate the framework, we just need to run command:

```
sh ./make_build.sh
```

To publish the generated framework to Cocoapod and Swift package manager, run the command:
```
sh ./publish_podspec.sh
```


**LATEST_VERSION** = **2.3.0**

# Integration guideline

### Technical overview
- The **Howtank iOS widget** is a library that, once included in your app, display the `Howtank chat`. 
- Before being clicked by the user, it is in a `folded` state, waiting quietly for a user action.
- Once clicked by the user, it switches to the `expanded` state, exchanging chat data with Howtank servers.
- The widget is very lightweight to preserve your application.
- This documentation is explaining how to install the widget into a `Swift` or an `Objective C` app.

### Demo applications:
- **Swift application:** http://cdn.howtank.com/sdk/ios/HowtankWidgetSample-1.0.0.zip
- **Objective-c Application:** https://cdn.howtank.com/sdk/ios/HowtankWidgetObjcCDemo-1.1.0.zip
   
    ##### Steps to run the demo app:
    1. Unzip the file and run the following command (you need to have CocoaPods installed)
        ```bash
          pod install
          cd my-project
        ```
    2. Double-click on ``Howtank Widget Sample.xcworkspace`` to open the demo project in `XCode`
    3. Please read the content of the `ViewController.swift` file. It is fully documented and explain how to set up and run the widget.
    
### Installation:
1. In your project folder, add ``pod ‘HowtankWidgetSwift’, ‘LATEST_VERSION’`` into the ``Podfile``
2. Then run ``Pod install`` command on terminal.

### Quick setup
>**1. Widget initialization**

To get the HowtankWidget up and running, you just need to add the following lines in your `AppDelegate` class:

***Swift***
```
HowtankWidget.shared.configure(hostId: "YOUR_HOST_ID", delegate: nil)
```

***Objective-C***
```
[[HowtankWidget shared] configureWithHostId:"YOUR_HOST_ID" delegate: nil];
```

***Where***
Name | Description | Mandatory?
--- | --- | ---
YOUR_HOST_ID | Your identifier (given by Howtank team) | YES 

</br>
</br>

>**2. Widget initialization**

You might want to display the widget on some controllers and not on some others, or display the widget everywhere in your app. In any case, you need to call the following method within all your `ViewControllers` `viewWillAppear` function:

***Swift***
```
// Howtank Widget specific configuration
HowtankWidget.shared.browse(show: SHOW_WIDGET, pageName: "PAGE_NAME", pageUrl: "PAGE_URL");
```

***Objective-C***
```
// Howtank Widget specific configuration
[[HowtankWidget shared] browseWithShow:SHOW_WIDGET pageName:"PAGE_NAME" pageUrl: “PAGE_URL"];
```
</br>

***Where***
Name | Description | Mandatory?
--- | --- | ---
SHOW_WIDGET | boolean, if the widget should be displayed `true` on this controller or not `false`. By default, the widget is `hidden`. | YES 
PAGE_NAME | String, the name of the current controller (ie. `Product page` or `Product – Apple iPhone`). This information will be read by your community member when taking a chat, so the more precise the better | YES 
PAGE_URL | String, a URL representation of your current page. Most apps use URLs for deeplinking. Again, this url will be clickable by members, so they can have a precise view of what the user is watching. **Examples are:** http://www.mywebsite.com/product/1234 or myapp://product/1234 | YES 

That’s all! The Howtank Widget should appear on the bottom-right end corner of your application. Please note that it might take a few seconds since we query our servers to decide whether or not the widget should be displayed.

![Screenshot](./assets/ic_bubble.png)

</br>
</br>

>**3. Advanced configuration**

Default configuration gets the widget running in a few lines of code. However, you can overload it with the following parameters.
Please note that `configure` should always be called last.

**Example**
Init example:

***Swift***
```
HowtankWidget.shared.verboseMode(true).configure(hostId: "YOUR_HOST_ID", delegate: nil)
```

***Objective-C***
```
[[[HowtankWidget shared] verboseMode:true] configureWithHostId: “YOUR_HOST_ID” delegate: nil];
```


**Verbose mode**
Enable more detailed logs when something went wrong. Only sets this to `true` in debug mode when debugging with the Howtank team.

```
verboseMode(true|false)
```

</br>
</br>

> **4. Adding a delegate**

You can register your class as a `HowtankWidgetDelegate` when calling the configure method:

***Swift***
```
HowtankWidget.shared.configure(hostId: "HOST_ID", andDelegate: self)
```

***Objective-C***
```
[HowtankWidget shared] configureWithHostId:"HOST_ID" delegate:self];
```

The following methods will be called when specific actions occur:


**Widget events**
```
func widgetEvent(event: WidgetEventType, paramaters: [String : Any]?) {
// Called when a specific widget event occurs
}
````
This method is called when a specific event is triggered, usually by the user. The following events may be triggered:
Event name | Description
--- | --- 
**.initialized** | When the widget has been correctly initialized and the chat is active 
**.opened** | Triggered when the user clicks on the chat bubble 
**.disabled** | When the chat bubble has been dragged and released over the deletion area 
**.displayed** | When the widget bubble is displayed. Be aware that this method can be triggered many times! 
**.hidden** | When the widget bubble is hidden
**.unavailable** | When the widget is unavailable. The parameter reasonindicates why
**.linkSelected** | Called when user click on the link in the chat so you can handle the clicked link properly. By default, nothing happen when user clicks on a link.

</br>
</br>

>**5. Conversion tracker integration**

You can track 2 types of goals: `generic` and `purchases`.

  **- Generic goal tracking**
  The following tracker must be called on controllers where the goals you want to track are achieved:

  ***Swift***
```
HowtankWidget.shared.conversion(name: "GOAL_NAME")
```

***Objective-C***
```
[[HowtankWidget shared] conversionWithName:@"GOAL_NAME"]
```

***Where***
Name | Description | Mandatory?
--- | --- | ---
GOAL_NAME | String, the name of the goal you want to track. You can have several goals (e.g. purchase, registration, subscription, etc.). Our platform will automatically generate a report for each goal tracked. | YES 

  **- Purchase**
  This specific tracker allows you to provide more information about purchases:

 ***Swift***
  ```
  let purchaseParameters = PurchaseParameters(newBuyer: IS_NEW_BUYER, purchaseId: "PURCHASE_ID", valueAmount: VALUE_AMOUNT, valueCurrency: VALUE_CURRENCY)
  // Send the purchase conversion tag
  HowtankWidget.shared.conversion(name: "GOAL_NAME", purchaseParameters: purchaseParameters)
  ```

  ***Objective-C***
  ```
  PurchaseParameters* purchaseParameters = [[PurchaseParameters alloc] initWithNewBuyer:IS_NEW_BUYER purchaseId:@"PURCHASE_ID" valueAmount:VALUE_AMOUNT valueCurrency: VALUE_CURRENCY];
  // Send the purchase conversion tag
  [[HowtankWidget shared] conversionWithName:@"GOAL_NAME" purchaseParameters:purchaseParameters];
  ```
</br>

***Where***
Name | Description | Mandatory?
--- | --- | ---
GOAL_NAME | String, the name of the goal you want to track. You can have several goals (e.g. purchase, registration, subscription, etc.). Our platform will automatically generate a report for each goal tracked. | YES
IS_NEW_BUYER | `true`: this is the first purchase of this user `false`: this user is a returning customer | YES
PURCHASE_ID | String, identifier of the purchase in your system | YES
VALUE_AMOUNT | The amount of the purchase (double) | YES
GOAL_NAME | Use any of the provided enum cases (`.euro`, `.dollar`, `.pound` or a custom value with ISO Currency code string (eg. `USD`, `EUR`, `GBP`, etc.) | YES








    

