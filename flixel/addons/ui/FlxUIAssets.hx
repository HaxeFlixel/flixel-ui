package flixel.addons.ui;
import flash.display.BitmapData;
import flash.text.Font;
import openfl.Assets;

class FlxUIAssets
{
	//images	
	inline static public var IMG_BUTTON:String = "flixel/flixel-ui/img/button.png";
	inline static public var IMG_BUTTON_THIN:String = "flixel/flixel-ui/img/button_thin.png";
	inline static public var IMG_BUTTON_TOGGLE:String = "flixel/flixel-ui/img/button_toggle.png";

	inline static public var IMG_BUTTON_SIZE:Float = 18;	//each of the above buttons is 18x18
	
	inline static public var IMG_CHECK_MARK:String = "flixel/flixel-ui/img/check_mark.png";
	inline static public var IMG_CHECK_BOX:String = "flixel/flixel-ui/img/check_box.png";
	inline static public var IMG_CHROME:String = "flixel/flixel-ui/img/chrome.png";
	inline static public var IMG_CHROME_FLAT:String = "flixel/flixel-ui/img/chrome_flat.png";
	inline static public var IMG_CHROME_INSET:String = "flixel/flixel-ui/img/chrome_inset.png";
	inline static public var IMG_RADIO:String = "flixel/flixel-ui/img/radio.png";
	inline static public var IMG_RADIO_DOT:String = "flixel/flixel-ui/img/radio_dot.png";
	inline static public var IMG_TAB:String = "flixel/flixel-ui/img/tab.png";
	inline static public var IMG_TAB_BACK:String = "flixel/flixel-ui/img/tab_back.png";
	inline static public var IMG_BOX:String = "flixel/flixel-ui/img/box.png";
	inline static public var IMG_DROPDOWN:String = "flixel/flixel-ui/img/dropdown_mark.png";
	inline static public var IMG_HILIGHT:String = "flixel/flixel-ui/img/hilight.png";
	inline static public var IMG_INVIS:String = "flixel/flixel-ui/img/invis.png";
	
	//slice9 rules
	inline static public var SLICE9_BUTTON:String = "6,6,11,11";
	inline static public var SLICE9_BUTTON_TOGGLE:String = "6,6,11,11";
	inline static public var SLICE9_TAB:String = "6,6,11,11";
		
	// xml (default definitions)
	inline static public var XML_DEFAULTS_ID:String = "flixel/flixel-ui/xml/defaults";
	inline static public var XML_DEFAULT_POPUP_ID:String = "flixel/flixel-ui/xml/default_popup";
	
	static public var index_size:Map<String,Array<Float>>=null;
	
	static public function init():Void
	{
		//
	}
}