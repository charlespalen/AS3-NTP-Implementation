package com.transcendingdigital.time
{
	import com.transcendingdigital.time.NTPTimeObject;
	
	import flash.events.DNSResolverEvent;
	import flash.events.DatagramSocketDataEvent;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.net.DatagramSocket;
	import flash.net.dns.AAAARecord;
	import flash.net.dns.ARecord;
	import flash.net.dns.DNSResolver;
	import flash.net.dns.MXRecord;
	import flash.net.dns.PTRRecord;
	import flash.net.dns.SRVRecord;
	import flash.sampler.startSampling;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	/**
	 * This is designed for AIR.
	 * We can make a udp request to whatever due to the
	 * elevated permissions.
	 * 
	 * The class is intended for checking the system clock vs
	 * a remote timeserver for just warning users or having
	 * an accurate time for seeding cryptography...etc
	 * 
	 * The key areas of this solution are based on Adam Buckleys
	 * work in Java.  It was used as a reference for the NTPTimeObject
	 * class.
	 * 
	 * Example Usage:
	  
	    private var ntpTime:ntpTimeUtility;
		 
		private function createNtpTimeUtility():void {
			if(ntpTime == null) {
				ntpTime = new ntpTimeUtility();
				ntpTime.addEventListener(ntpTimeUtility.NTP_TIME_RECIEVED, handleNTPTime, false, 0, true);
				ntpTime.addEventListener(ntpTimeUtility.NTP_TIMEOUT, handleNtpTimeError, false, 0, true);
			} else {
				destroyNtpTimeUtility(true);
			}
		}
		private function destroyNtpTimeUtility(_OptionalCallback:Boolean = false):void {
			if(ntpTime != null) {
				ntpTime.removeEventListener(ntpTimeUtility.NTP_TIME_RECIEVED, handleNTPTime);
				ntpTime.removeEventListener(ntpTimeUtility.NTP_TIMEOUT, handleNtpTimeError);
				ntpTime.destroyInternals();
				ntpTime = null;
				if(_OptionalCallback == true) {
					createNtpTimeUtility();
				}
			}
		}
	  private function handleNTPTime(e:Event):void {
	  		// The time returned from the time server which should be localized
			// to the computers clock is in the ntpTIme.latestNTPTime variable
	 		trace("main - ntp time utility return: " + ntpTime.latestNTPTime);
	 		destroyNtpTimeUtility();
	   }
	 	private function handleNtpTimeError(e:Event):void {
		    // Do what you would do here if the time cant be retrieved.
			destroyNtpTimeUtility();
		}
	 */
	public class ntpTimeUtility extends EventDispatcher
	{
		public static var NTP_TIME_RECIEVED:String = "com.transcendingdigital.time.ntpTimeUtility.NTP_TIME_RECIEVED";
		public static var NTP_TIMEOUT:String = "com.transcendingdigital.time.ntpTimeUtility.NTP_TIMEOUT";
		
		public var latestNTPTime:Date = null;
		
		private var port:int = 123; // NTP guys monopolized on a cool port
		private var timeServers:Vector.<String> = new <String>[
			"nist1-ny.ustiming.org",
			"nist1-nj.ustiming.org",
			"nist1-nj2.ustiming.org",
			"nist2-nj2.ustiming.org",
			"nist1-pa.ustiming.org",
			"time-d.nist.gov",
			"nist1.aol-va.symmetricom.com"
		];
		private var currentTSIndex:int = 0;
		private var networkTimeout:Timer;
		
		private var datagramSocket:DatagramSocket;
		private var dnsResolve:DNSResolver;
		
		public function ntpTimeUtility(target:IEventDispatcher=null)
		{
			super(target);
			
			createUDPSocket();
		}
		public function initiateUDPTimeRequest():void {
			currentTSIndex = 0;
			
			tryNextTimeServer();
		}
		
		private function tryNextTimeServer():void {
			
			// First do a DNS query to get the IP
			if(currentTSIndex < timeServers.length) {
				doDNSResolve( timeServers[ currentTSIndex ] );
			} else {
				dispatchEvent(new Event(ntpTimeUtility.NTP_TIMEOUT, false, true));
			}

		}
		
		private function doTimeRequestUsingIP(_IPV4Add:String):void {

			if(datagramSocket != null) {
				try {
					var ntpReq:ByteArray = formNTPRequest();
					datagramSocket.send(ntpReq,0,0,_IPV4Add,port );
					createTimeoutTimer();
				} catch(e:Error) {
					dispatchEvent(new Event(ntpTimeUtility.NTP_TIMEOUT, false, true));
				}
			}

		}
		
		private function createUDPSocket():void {
			if(datagramSocket == null) {
				datagramSocket = new DatagramSocket(); 
				datagramSocket.addEventListener( DatagramSocketDataEvent.DATA, handleIncomingUDPMessage, false, 0, true ); 
				//Bind the socket to the next available port
				datagramSocket.bind(); 
				//Listen for incoming datagrams 
				datagramSocket.receive(); 
			} else {
				destroyUDPSocket(true);
			}
		}
		private function destroyUDPSocket(_OptionalCallback:Boolean = false):void {
			if(datagramSocket != null) {
				try {
					if(datagramSocket.bound) {
						datagramSocket.close();
					}
				} catch(e:Error) {
					trace("ntpTimeUtility - error closing udp socket: " + e.message);
				}
				datagramSocket.removeEventListener( DatagramSocketDataEvent.DATA, handleIncomingUDPMessage ); 
				datagramSocket = null;
				
				if(_OptionalCallback == true) {
					createUDPSocket();
				}
			}
		}
		/**
		 * This is a non great way to do this. We can get data back out of order
		 * wrong data, not all the data. It may need optimization.
		 */
		private function handleIncomingUDPMessage(e:DatagramSocketDataEvent):void {
			var incomingBA:ByteArray = e.data;
			//var resetBACopy:ByteArray = new ByteArray();
			//resetBACopy.writeBytes(incomingBA,0,incomingBA.length);
			
			destroyTimeoutTimer();
			
			//trace("Got incoming udp data len: " + resetBACopy.length + " content: " + incomingBA.readUTFBytes(incomingBA.length) + " position: " + resetBACopy.position);
			if(incomingBA.length == 48) {
				//trace("--------------------------");
				//resetBACopy.position = 0;
				/*
				for(var i:int = 0; i < incomingBA.length; i++) {
					trace("data: " + uint( incomingBA[i] ) );
					trace("unsignedByte: " + resetBACopy.readUnsignedByte() );
				}
				*/
				//var reqString:String = incomingBA.readUTFBytes(incomingBA.length);
				try {
					var timeObj:NTPTimeObject = new NTPTimeObject();
					timeObj.populateObjectFromBA(incomingBA);
					latestNTPTime = timeObj.getLocalizedTimeserverDate();
					
					// Reset the guts internally just in case the user wants to 
					// do another 
					currentTSIndex = 0;
					dispatchEvent(new Event(ntpTimeUtility.NTP_TIME_RECIEVED));
				} catch(e:Error) {
					// We may have just gotten bad data
					// Try the next one
					currentTSIndex += 1;
					tryNextTimeServer();
				}
				/*
				trace("---------------");
				trace("leapIndicator: " + timeObj.leapIndicator);
				trace("version: " + timeObj.version);
				trace("mode: " + timeObj.mode);
				trace("stratum: " + timeObj.stratum);
				trace("poll Interval: " + timeObj.pollInterval);
				trace("precision: " + timeObj.precision);
				trace("root delay: " + timeObj.rootDelay);
				trace("root dispersion: " + timeObj.rootDispersion);
				trace("referenceIdentifier: " + timeObj.referenceIdentifier);
				trace("referenceTimestamp: " + timeObj.referenceTimestamp);
				trace("originateTimestamp: " + timeObj.originateTimestamp);
				trace("recieveTimestamp: " + timeObj.receiveTimestamp);
				trace("transmitTimestamp: " + timeObj.transmitTimestamp);
				trace("parsedDate: " + timeObj.getLocalizedTimeserverDate() );
				*/
			}
		}
		private function formNTPRequest():ByteArray {
			var request:ByteArray = new ByteArray();
			
			var tmpTime:NTPTimeObject = new NTPTimeObject();
			request = tmpTime.createNTPRequest();
			
			return request;
		}
		
		private function doDNSResolve(_host:String):void {
			if(dnsResolve == null) {
				dnsResolve = new DNSResolver();
				dnsResolve.addEventListener(DNSResolverEvent.LOOKUP, handleDNSLookup, false, 0, true);
				dnsResolve.addEventListener(ErrorEvent.ERROR, handleDNSError,false, 0, true);
				dnsResolve.lookup(_host,ARecord);
			} else {
				destroyDNSResolve(_host, true);
			}
		}
		private function destroyDNSResolve(_host:String = "", _optionalCallback:Boolean = false):void {
			if(dnsResolve != null) {
				dnsResolve.removeEventListener(DNSResolverEvent.LOOKUP, handleDNSLookup);
				dnsResolve.removeEventListener(ErrorEvent.ERROR, handleDNSError);
				dnsResolve = null;
				if(_optionalCallback == true) {
					doDNSResolve(_host);
				}
			}
		}
		private function handleDNSLookup(e:DNSResolverEvent):void {
			
			destroyDNSResolve();
			var ipV4Record:String = "";
			
			for each( var record:* in e.resourceRecords )
			{
				if( record is ARecord ) {
					trace( record.name + " : " + record.address );
					ipV4Record = record.address;
				}
				if( record is AAAARecord ) trace( record.name + " : " + record.address );
				if( record is MXRecord ) trace( record.name + " : " + record.exchange + ", " + record.preference );
				if( record is PTRRecord ) trace( record.name + " : " + record.ptrdName );
				if( record is SRVRecord ) trace( record.name + " : " + record.target + ", " + record.port +
					", " + record.priority + ", " + record.weight );
			}    
			
			if(ipV4Record != "") {
				doTimeRequestUsingIP( ipV4Record );
			} else {
				currentTSIndex += 1;
				tryNextTimeServer();
			}
		}
		private function handleDNSError(e:ErrorEvent):void {
			trace("ntpTimeUtility dns lookup error: " + e);
			destroyDNSResolve();
			
			currentTSIndex += 1;
			tryNextTimeServer();
		}
		private function createTimeoutTimer():void {
			if(networkTimeout == null) {
				// hmm..how many ms before a timeout?
				// 10 seconds. Even simulating with less than
				// a dial up these udp requests are fast..even at
				// 500b/sec they are almost instant
				// Typical dial up 56k modem is ideal 5kb/sec but more like 3kb/sec
				networkTimeout = new Timer(10000);
				networkTimeout.addEventListener(TimerEvent.TIMER, handleNetworkTimeout, false, 0, true);
				networkTimeout.start();
			} else {
				destroyTimeoutTimer(true);
			}
		}
		private function destroyTimeoutTimer(_optionalCallback:Boolean = false):void {
			if(networkTimeout != null) {
				networkTimeout.stop();
				networkTimeout.removeEventListener(TimerEvent.TIMER, handleNetworkTimeout);
				networkTimeout = null;
				if(_optionalCallback == true) {
					createTimeoutTimer();
				}
			}
		}
		private function handleNetworkTimeout(e:TimerEvent):void {
			destroyTimeoutTimer();
			
			currentTSIndex += 1;
			tryNextTimeServer();
		}
		public function destroyInternals():void {
			destroyTimeoutTimer();
			destroyUDPSocket();
			destroyDNSResolve();
		}
	}
}