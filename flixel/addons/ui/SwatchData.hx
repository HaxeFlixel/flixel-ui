package flixel.addons.ui;
import flixel.interfaces.IFlxDestroyable;
import flixel.util.FlxColorUtil;
/**
 * ...
 * @author Lars A. Doucet
 */
class SwatchData implements IFlxDestroyable{

	public var name : String;
	public var colors:Array<Int>;
	
	//The "main four" are now getter/setters so you can have an underlying colors array with arbitrary # of colors
	public var hilight(get, set):Int;
	public var midtone(get, set):Int;
	public var shadowMid(get, set):Int;
	public var shadowDark(get, set):Int;
	
	/**GETTERs/SETTERS**/
	
	public function get_hilight():Int {
		if (colors.length >= 1) {
			return colors[0];
		}
		return 0xff000000;
	}
	public function set_hilight(Value:Int):Int {
		colors[0] = Value;
		return Value;
	}
	
	public function get_midtone():Int {
		if (colors.length >= 2) {
			return colors[1];
		}
		return 0xff000000;
	}
	public function set_midtone(Value:Int):Int {
		colors[1] = Value;
		return Value;
	}
	
	public function get_shadowMid():Int {
		if (colors.length >= 3) {
			return colors[2];
		}
		return 0xff000000;
	}
	public function set_shadowMid(Value:Int):Int {
		colors[2] = Value;
		return Value;
	}
	
	public function get_shadowDark():Int {
		if (colors.length >= 4) {
			return colors[3];
		}
		return 0xff000000;
	}
	public function set_shadowDark(Value:Int):Int {
		colors[3] = Value;
		return Value;
	}
	
	public function destroy():Void {
		if(colors != null){
			while (colors.length > 1) {
				colors.pop();
			}
			colors = null;
		}
	}
	
	public function new(Name:String, Colors:Array<Int> = null)
	{
		if (Colors == null) {
			Colors = [0xffffffff, 0xff888888, 0xff444444, 0xff000000];
		}
		name = Name;
		colors = Colors;
	}

	public function copy() : SwatchData 
	{
		var colorsCopy:Array<Int> = colors != null ? colors.copy() : null;
		return new SwatchData(name, colorsCopy);
	}

	public function toString() : String 
	{
		var str:String = "(" + name + ",";
		var i:Int = 0;
		if(colors != null){
			for (colorInt in colors) {
				str += FlxColorUtil.ARGBtoHexString(colorInt);
				if (i != colors.length - 1) {
					str += ",";
				}
				i++;
			}
		}else {
			str += "null";
		}
		str += ")";
		return str;
	}

	//Get the total raw difference in colors from another color swatch
	
	public function getRawDifference(?other:SwatchData,?otherColors:Array<Int>):Int {
		var bigList:Array<Int> = colors;
		if (colors != null) {
			bigList = colors;
		}else {
			bigList = [];
		}
		
		var smallList:Array<Int> = null;
		if (other != null) {
			smallList = other.colors;
		}else {
			if (otherColors != null) {
				smallList = otherColors;
			}else{
				smallList = [];
			}
		}
		
		if (bigList.length < smallList.length) {
			var temp = bigList;
			smallList = bigList;
			bigList = temp;
			temp = null;
		}
		
		var totalDiff:Int = 0;
		var i:Int = 0;
		for (i in 0...smallList.length) {
			totalDiff += getRGBdelta(bigList[i], smallList[i]);
		}
		
		var lengthDiff:Int = bigList.length - smallList.length;
		if(lengthDiff != 0){
			totalDiff += ((3 * 0xFF) * lengthDiff);
		}
		return totalDiff;
	}
	
	public function doColorsEqual(?other:SwatchData,?otherColors:Array<Int>):Bool {
		var otherArray:Array<Int> = null;
		if (other != null) {
			otherArray = other.colors;
		}else {
			if (otherColors != null) {
				otherArray = otherColors;
			}
		}
		
		if (otherArray == null) {
			return colors == null;
		}else if (colors == null) {
			return otherArray == null;
		}
		
		if (otherArray.length != colors.length) {
			return false;
		}
		for (i in 0...colors.length) {
			if (colors[i] != otherArray[i]) {
				return false;
			}
		}
		return true;
	}
	
	private function getRGBdelta(a:Int, b:Int):Int {
		var ra:Int = a >> 16 & 0xFF;
		var ga:Int = a >> 8 & 0xFF;
		var ba:Int = a & 0xFF;
		var rb:Int = b >> 16 & 0xFF;
		var gb:Int = b >> 8 & 0xFF;
		var bb:Int = b & 0xFF;
		var diff:Int = 0;
		var delta:Int = 0;
		
		diff = ra - rb; if (diff < 0) { diff *= -1; };
		delta += diff;
		
		diff = ga - gb; if (diff < 0) { diff *= -1; };
		delta += diff;
		
		diff = ba - bb; if (diff < 0) { diff *= -1; };
		delta += diff;
		
		return delta;
	}
}

