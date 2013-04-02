Jan 2013
Charles Palen
Technogumbo http://www.technogumbo.com
Transcending Digital LLC http://www.transcendingdigital.com

This project is mainly based on Adam Buckley's implementation in Java.
This is to my knowledge the only NTP implementation for the Flash platform, but it requires
adobe AIR. This may be useful for developers who need a good clock reference for cryptography
or other operations.

This is an example project containing an NTP implementation targeted at Adobe AIR.
The sample project can be compiled using Flash Builder, Flash Develop, or Flash CS.

The sample was created with Flash Builder 4.6 and Flash Professional CS 5.5 (Saved as CS4)

The NTP classes require Adobe AIR becuase they use UDP sockets.

EXAMPLE USAGE:
ntpTime = new ntpTimeUtility();
ntpTime.addEventListener(ntpTimeUtility.NTP_TIME_RECIEVED, handleNTPTime, false, 0, true);
ntpTime.initiateUDPTimeRequest();

private function handleNTPTime(e:Event):void {
  // The time returned from the time server which should be localized
  // to the computers clock is in the ntpTIme.latestNTPTime variable
  trace("main - ntp time utility return: " + ntpTime.latestNTPTime);
} 