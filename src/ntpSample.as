package
{
	import com.transcendingdigital.time.ntpTimeUtility;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	[SWF(width="640", height="480", backgroundColor="#FFFFFF", frameRate="30")]
	public class ntpSample extends Sprite
	{
		private var resultsText:TextField;
		private var ntpTime:ntpTimeUtility;
		
		public function ntpSample()
		{
			createUI();
		}
		
		private function createUI():void {
			
			var clkBtn:Sprite = new Sprite();
			clkBtn.graphics.lineStyle(1,0x000000,1);
			clkBtn.graphics.beginFill(0x0d9d73,1);
			clkBtn.graphics.drawRoundRect(0,0,150,35,2);
			clkBtn.graphics.endFill();
			clkBtn.buttonMode = true;
			
			var clkTxt:TextField = new TextField();
			var tmpFormat:TextFormat = new TextFormat();
			clkTxt.width = 150;
			tmpFormat.color = 0xFFFFFF;
			tmpFormat.size = 14;
			tmpFormat.align = TextFormatAlign.CENTER;
			tmpFormat.bold = true;
			clkTxt.text = "Do NTP Request";
			clkTxt.setTextFormat(tmpFormat);
			clkTxt.defaultTextFormat = tmpFormat;
			clkTxt.selectable = false;
			clkTxt.mouseEnabled = false;
			clkTxt.y = 8;
			
			clkBtn.addChild(clkTxt);
			clkBtn.addEventListener(MouseEvent.CLICK, handleUIClick);
			addChild(clkBtn);
			clkBtn.x = 640/2 - clkBtn.width/2;
			clkBtn.y = 480/2 - clkBtn.height/2;
			
			// Results area
			var resultsArea:Sprite = new Sprite();
			resultsArea.graphics.lineStyle(1,0x0000000,1);
			resultsArea.graphics.beginFill(0xFFFFFF,1);
			resultsArea.graphics.drawRect(0,0,300,50);
			resultsArea.graphics.endFill();
			resultsArea.buttonMode = true;

			resultsText = new TextField();
			resultsText.width = 300;
			resultsText.selectable = false;
			var resultsFormat:TextFormat = new TextFormat();
			resultsFormat.size = 12;
			resultsText.setTextFormat(resultsFormat);
			resultsText.defaultTextFormat = resultsFormat;
			resultsText.text = "";
			resultsArea.addChild(resultsText);
			
			addChild(resultsArea);
			resultsArea.x = 640/2 - resultsArea.width / 2;
			resultsArea.y = clkBtn.y + clkBtn.height + 10;
		}
		
		private function handleUIClick(e:MouseEvent):void {
			resultsText.text = "Preforming NTP Request...";
			trace("Doing NTP Request: ");
			createNtpTimeUtility();
			ntpTime.initiateUDPTimeRequest();
			
		}
		
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
			resultsText.text = ntpTime.latestNTPTime.toString();
			destroyNtpTimeUtility();
		}
		private function handleNtpTimeError(e:Event):void {
			// Do what you would do here if the time cant be retrieved.
			destroyNtpTimeUtility();
		}
	}
}