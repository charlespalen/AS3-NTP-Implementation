package com.transcendingdigital.time
{
	import flash.utils.ByteArray;

	/**
	 * Adapted for AS3 by Charles Palen Jan, 2013. 
	 * http://www.technogumbo.com
	 * 
	 * This implementation would have not been
	 * possible without the original Java reference by Adam Buckley.
	 * Also used the "NTP Check" free software from Galleon Systems for help with determining
	 * what the requests and responses are supposed to look like in AS3.
	 * http://www.galsys.co.uk/categories/ntp-server-checker.html
	 * 
	 * This code is copyright (c) Adam Buckley 2004
	 *
	 * This program is free software; you can redistribute it and/or modify it 
	 * under the terms of the GNU General Public License as published by the Free 
	 * Software Foundation; either version 2 of the License, or (at your option) 
	 * any later version.  A HTML version of the GNU General Public License can be
	 * seen at http://www.gnu.org/licenses/gpl.html
	 *
	 * This program is distributed in the hope that it will be useful, but WITHOUT 
	 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
	 * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for 
	 * more details.
	 * 
	 * Comments for member variables are taken from RFC2030 by David Mills,
	 * University of Delaware.
	 * 
	 * Number format conversion code in NtpMessage(byte[] array) and toByteArray()
	 * inspired by http://www.pps.jussieu.fr/~jch/enseignement/reseaux/
	 * NTPMessage.java which is copyright (c) 2003 by Juliusz Chroboczek
	 * 
	 * @author Adam Buckley
	 * */
	public class NTPTimeObject
	{
		/**
		 * This is a two-bit code warning of an impending leap second to be
		 * inserted/deleted in the last minute of the current day.  It's values
		 * may be as follows:
		 * 
		 * Value     Meaning
		 * -----     -------
		 * 0         no warning
		 * 1         last minute has 61 seconds
		 * 2         last minute has 59 seconds)
		 * 3         alarm condition (clock not synchronized)
		 */
		public var leapIndicator:uint = 0;
		
		
		/**
		 * This value indicates the NTP/SNTP version number.  The version number
		 * is 3 for Version 3 (IPv4 only) and 4 for Version 4 (IPv4, IPv6 and OSI).
		 * If necessary to distinguish between IPv4, IPv6 and OSI, the
		 * encapsulating context must be inspected.
		 */
		public var version:uint = 3;
		
		
		/**
		 * This value indicates the mode, with values defined as follows:
		 * 
		 * Mode     Meaning
		 * ----     -------
		 * 0        reserved
		 * 1        symmetric active
		 * 2        symmetric passive
		 * 3        client
		 * 4        server
		 * 5        broadcast
		 * 6        reserved for NTP control message
		 * 7        reserved for private use
		 * 
		 * In unicast and anycast modes, the client sets this field to 3 (client)
		 * in the request and the server sets it to 4 (server) in the reply. In
		 * multicast mode, the server sets this field to 5 (broadcast).
		 */ 
		public var mode:uint = 0;
		
		
		/**
		 * This value indicates the stratum level of the local clock, with values
		 * defined as follows:
		 * 
		 * Stratum  Meaning
		 * ----------------------------------------------
		 * 0        unspecified or unavailable
		 * 1        primary reference (e.g., radio clock)
		 * 2-15     secondary reference (via NTP or SNTP)
		 * 16-255   reserved
		 */
		public var stratum:uint = 0;
		
		
		/**
		 * This value indicates the maximum interval between successive messages,
		 * in seconds to the nearest power of two. The values that can appear in
		 * this field presently range from 4 (16 s) to 14 (16284 s); however, most
		 * applications use only the sub-range 6 (64 s) to 10 (1024 s).
		 */
		public var pollInterval:uint = 0;
		
		
		/**
		 * This value indicates the precision of the local clock, in seconds to
		 * the nearest power of two.  The values that normally appear in this field
		 * range from -6 for mains-frequency clocks to -20 for microsecond clocks
		 * found in some workstations.
		 */
		public var precision:uint = 0;
		
		
		/**
		 * This value indicates the total roundtrip delay to the primary reference
		 * source, in seconds.  Note that this variable can take on both positive
		 * and negative values, depending on the relative time and frequency
		 * offsets. The values that normally appear in this field range from
		 * negative values of a few milliseconds to positive values of several
		 * hundred milliseconds.
		 */
		public var rootDelay:Number = 0;
		
		
		/**
		 * This value indicates the nominal error relative to the primary reference
		 * source, in seconds.  The values  that normally appear in this field
		 * range from 0 to several hundred milliseconds.
		 */ 
		public var rootDispersion:Number = 0;
		
		
		/**
		 * This is a 4-byte array identifying the particular reference source.
		 * In the case of NTP Version 3 or Version 4 stratum-0 (unspecified) or
		 * stratum-1 (primary) servers, this is a four-character ASCII string, left
		 * justified and zero padded to 32 bits. In NTP Version 3 secondary
		 * servers, this is the 32-bit IPv4 address of the reference source. In NTP
		 * Version 4 secondary servers, this is the low order 32 bits of the latest
		 * transmit timestamp of the reference source. NTP primary (stratum 1)
		 * servers should set this field to a code identifying the external
		 * reference source according to the following list. If the external
		 * reference is one of those listed, the associated code should be used.
		 * Codes for sources not listed can be contrived as appropriate.
		 * 
		 * Code     External Reference Source
		 * ----     -------------------------
		 * LOCL     uncalibrated local clock used as a primary reference for
		 *          a subnet without external means of synchronization
		 * PPS      atomic clock or other pulse-per-second source
		 *          individually calibrated to national standards
		 * ACTS     NIST dialup modem service
		 * USNO     USNO modem service
		 * PTB      PTB (Germany) modem service
		 * TDF      Allouis (France) Radio 164 kHz
		 * DCF      Mainflingen (Germany) Radio 77.5 kHz
		 * MSF      Rugby (UK) Radio 60 kHz
		 * WWV      Ft. Collins (US) Radio 2.5, 5, 10, 15, 20 MHz
		 * WWVB     Boulder (US) Radio 60 kHz
		 * WWVH     Kaui Hawaii (US) Radio 2.5, 5, 10, 15 MHz
		 * CHU      Ottawa (Canada) Radio 3330, 7335, 14670 kHz
		 * LORC     LORAN-C radionavigation system
		 * OMEG     OMEGA radionavigation system
		 * GPS      Global Positioning Service
		 * GOES     Geostationary Orbit Environment Satellite
		 */
		public var referenceIdentifier:String = "";
		
		
		/**
		 * This is the time at which the local clock was last set or corrected, in
		 * seconds since 00:00 1-Jan-1900.
		 */
		public var referenceTimestamp:Number = 0;
		
		
		/**
		 * This is the time at which the request departed the client for the
		 * server, in seconds since 00:00 1-Jan-1900.
		 */
		public var originateTimestamp:Number = 0;
		
		
		/**
		 * This is the time at which the request arrived at the server, in seconds
		 * since 00:00 1-Jan-1900.
		 */
		public var receiveTimestamp:Number = 0;
		
		
		/**
		 * This is the time at which the reply departed the server for the client,
		 * in seconds since 00:00 1-Jan-1900.
		 */
		public var transmitTimestamp:Number = 0;
		
		private var hasBeenPopulated:Boolean = false;
		
		public function NTPTimeObject()
		{

		}
		
		public function createNTPRequest():ByteArray {

			var p:ByteArray = new ByteArray();
			this.mode = 3;
			// Number of seconds since Jan 1 1900
			var tmpOriginDate:Date = new Date(1900,0,1,0,0,0,0);
			var tmpNowDate:Date = new Date();
			this.transmitTimestamp = (tmpNowDate.valueOf()/1000) + (tmpOriginDate.valueOf() / 1000 * -1);
			
			if(hasBeenPopulated == false) {
				p.writeByte( leapIndicator << 6 | version << 3 | mode );
				p.writeByte(stratum);
				p.writeByte(pollInterval);
				p.writeByte(precision);
				
				// root delay is a signed 16.16-bit FP, in Java an int is 32-bits
				var l:int = int(rootDelay * 65536.0);
				p.writeByte((l >> 24) & 0xFF);
				p.writeByte((l >> 16) & 0xFF);
				p.writeByte((l >> 8) & 0xFF);
				p.writeByte(l & 0xFF);
				
				// root dispersion is an unsigned 16.16-bit FP, in Java there are no
				// unsigned primitive types, so we use a long which is 64-bits 
				var ul:int = int(rootDispersion * 65536.0);
				p.writeByte((ul >> 24) & 0xFF);
				p.writeByte((ul >> 16) & 0xFF);
				p.writeByte((ul >> 8) & 0xFF);
				p.writeByte(ul & 0xFF);
				
				// Reference identifier is all 0's
				p.writeByte(0);
				p.writeByte(0);
				p.writeByte(0);
				p.writeByte(0);
				
				encodeTimestamp(p, 16, referenceTimestamp);
				encodeTimestamp(p, 24, originateTimestamp);
				encodeTimestamp(p, 32, receiveTimestamp);
				encodeTimestamp(p, 40, transmitTimestamp);
			} else {
				throw new Error("You can only create a request before the object is populated");
			}
			
			return p; 
		}
		
		public function populateObjectFromBA(_inputBA:ByteArray):void {
			
			// See the packet format diagram in RFC 2030 for details 
			if(_inputBA.length == 48) {
				leapIndicator = ((_inputBA[0] >> 6) & 0x3);
				version = ((_inputBA[0] >> 3) & 0x7);
				mode = (_inputBA[0] & 0x7);
				stratum = _inputBA[1];
				pollInterval = _inputBA[2];
				precision = _inputBA[3];
				
				rootDelay = ( (_inputBA[4] * 256.0) + _inputBA[5]) +
					(_inputBA[6] / 256.0) +
					(_inputBA[7] / 65536.0);
				
				rootDispersion = (_inputBA[8] * 256.0) + 
					_inputBA[9] +
					(_inputBA[10] / 256.0) +
					(_inputBA[11] / 65536.0);
				
				var smallCopy:ByteArray = new ByteArray();
				_inputBA.position = 12;
				smallCopy.writeByte( _inputBA.readByte() );
				smallCopy.writeByte( _inputBA.readByte() );
				smallCopy.writeByte( _inputBA.readByte() );
				smallCopy.writeByte( _inputBA.readByte() );
				smallCopy.position = 0;
				referenceIdentifier = smallCopy.readUTFBytes(4);
					
				referenceTimestamp = decodeTimestamp(_inputBA, 16);
				originateTimestamp = decodeTimestamp(_inputBA, 24);
				receiveTimestamp = decodeTimestamp(_inputBA, 32);
				transmitTimestamp = decodeTimestamp(_inputBA, 40);
				
				hasBeenPopulated = true;
			}
		}
		
		/**
		 * After things have been populated, this will take
		 * the timeservers return time which is seconds since
		 * Jan 1, 00:00 1900 and convert it into a usable
		 * AS3 Date.
		 * 
		 * Will throw an error if the data hasnt been populated.
		 * 
		 * NOTE: This is just taking the referenceTimestamp and
		 * ignoring all the potentially important data. For
		 * more critical applications that require second accuracy
		 * you may need to do some work here.
		 */
		public function getLocalizedTimeserverDate():Date {
			var returnDate:Date = null;
			
			if(hasBeenPopulated == true) {
				// OK - time is in seconds since 1900 start off AS3 Date object bases
				// everything on the Unix timestamp Jan 1 1970. So using our seed we need to
				// convert from number of seconds since 1900 to 1970
				//var tmpOriginDate:Date = new Date(1900,0,1,0,0,0,0);
				// tmpOriginDate.valueOf will be a negative value because its BEFORE the unix timestamp
				var msSinceUnixTS:Number = (this.referenceTimestamp * 1000) - (2208988800000.0);
				// 
				returnDate = new Date(msSinceUnixTS);
				
			} else {
				throw new Error("You must first populate the data using populateObjectFromBA");
			}
			
			return returnDate;
		}
		
		/**
		 * Will read 8 bytes of a message beginning at <code>pointer</code>
		 * and return it as a double, according to the NTP 64-bit timestamp
		 * format.
		 */
		private function decodeTimestamp(array:ByteArray, pointer:int):Number
		{
			var r:Number = 0.0;
			
			for(var i:int=0; i<8; i++)
			{
				r += array[pointer+i] * Math.pow(2, (3-i)*8);
			}
			
			return r;
		}
		
		/**
		 * Encodes a timestamp according to the position of array
		 * The pointer here is only used for help with the timestamp
		 */
		private function encodeTimestamp(array:ByteArray, pointer:int, timestamp:Number):void
		{
			// Converts a double into a 64-bit fixed point
			for(var i:int=0; i<8; i++)
			{
				// 2^24, 2^16, 2^8, .. 2^-32
				var base:Number = Math.pow(2, (3-i)*8);
				
				// Capture byte value
				array.writeByte(timestamp / base);
				
				// Subtract captured value from remaining total
				timestamp = timestamp - Number(int(array[pointer+i]) * base);
			}
			
			// From RFC 2030: It is advisable to fill the non-significant
			// low order bits of the timestamp with a random, unbiased
			// bitstring, both to avoid systematic roundoff errors and as
			// a means of loop detection and replay detection.
			
			// This isnt correct...it modifies position 7 in the main array because it doesnt
			// account for the offset?
			//array[7] = (byte) (Math.random()*255.0);
			//array.writeByte(Math.random()*255.0);
		}
	}
}