package flixel.addons.ui;
import flixel.util.FlxColorUtil;
/**
 * ...
 * @author Lars A. Doucet
 */
class SwatchData {

	public var name : String;
	public var hilight : Int;
	public var midtone : Int;
	public var shadowMid : Int;
	public var shadowDark : Int;
	
	public function new(Name:String, Hilight:Int=0xffffffff, Midtone:Int=0xff888888, ShadowMid:Int=0xff000000, ShadowDark:Int = 0xff000000) 
	{
		name = Name;
		hilight = Hilight;
		midtone = Midtone;
		shadowMid = ShadowMid;
		shadowDark = ShadowDark;
	}

	public function copy() : SwatchData 
	{
		return new SwatchData(name, hilight, midtone, shadowMid, shadowDark);
	}

	public function toString() : String 
	{
		return "(" + name + "," + FlxColorUtil.ARGBtoHexString(hilight) + "," + FlxColorUtil.ARGBtoHexString(midtone) + "," + FlxColorUtil.ARGBtoHexString(shadowMid) + "," + FlxColorUtil.ARGBtoHexString(shadowDark) + ")";
	}

}

