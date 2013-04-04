Introduction
===============================================
January 2013

This project is mainly based on Adam Buckley's implementation in Java.
This is to my knowledge the only NTP implementation for the Flash platform, but it requires
adobe AIR. This may be useful for developers who need a good clock reference for cryptography
or other operations.

This is an example project containing an NTP implementation targeted at Adobe AIR.
The sample project can be compiled using Flash Builder, Flash Develop, or Flash CS.

The sample was created with Flash Builder 4.6 and Flash Professional CS 5.5 (Saved as CS4)

The NTP classes require Adobe AIR becuase they use UDP sockets.

Example Usage
--------------------------------------------------
```actionscript3
ntpTime = new ntpTimeUtility();
ntpTime.addEventListener(ntpTimeUtility.NTP_TIME_RECIEVED, handleNTPTime, false, 0, true);
ntpTime.initiateUDPTimeRequest();

private function handleNTPTime(e:Event):void {
  // The time returned from the time server which should be localized
  // to the computers clock is in the ntpTIme.latestNTPTime variable
  trace("main - ntp time utility return: " + ntpTime.latestNTPTime);
} 
```

Air Descriptor File
--------------------------------------------------
You may need to change the air descriptor file, " to target your particular installed SDK.

src/ntpSample-app.xml

All you need to do is change the second node in the xml to target your installed SDK or lower (this determines the AIR runtime version needed when the app is deployed)

```xml
<application xmlns="http://ns.adobe.com/air/application/3.1">
```

Special Thanks
--------------------------------------------------
Thanks to [Leo O'Donnell](https://github.com/leopoldodonnell) for requesting this be posted on Github and help with the intial commits.

License
--------------------------------------------------
The NTPTimeObject.as based on Adam Buckley's Java class may fall under the GNU GPL

The licensing for everything else should be considered BSD or MIT; whichever is more free for your particular locale and application.
Charles Palen
*[Technogumbo](http://www.technogumbo.com)*
*[Transcending Digital LLC](http://www.transcendingdigital.com)*