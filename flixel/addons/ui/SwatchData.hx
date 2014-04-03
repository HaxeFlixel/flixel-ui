package flixel.addons.ui;
import flixel.interfaces.IFlxDestroyable;
import flixel.util.FlxColorUtil;
/**
 * ...
 * @author Lars A. Doucet
 */
class SwatchData implements IFlxDestroyable{

	public var name:String;
	public var colors:Array<Int>;
	
	//The "main four" are now getter/setters so you can have an underlying colors array with arbitrary # of colors
	public var hilight(get, set):Int;
	public var midtone(get, set):Int;
	public var shadowMid(get, set):Int;
	public var shadowDark(get, set):Int;
	
	public function setColor(i:Int, Value:Int):Int {
		if (colors == null) { colors = [];}
		colors[i] = Value;
		return Value;
	}
	
	public function getColor(i:Int):Int {
		if (colors.length >= i) {
			return colors[i];
		}
		return 0xff000000;
	}
	
	/**GETTERs/SETTERS**/

	private function get_hilight():Int {
		return getColor(0);
	}
	private function set_hilight(Value:Int):Int {
		if (colors == null) { colors = [];}
		colors[0] = Value;
		return Value;
	}
	
	private function get_midtone():Int {
		return getColor(1);
	}
	private function set_midtone(Value:Int):Int {
		if (colors == null) { colors = [];}
		colors[1] = Value;
		return Value;
	}
	
	private function get_shadowMid():Int {
		return getColor(2);
	}
	private function set_shadowMid(Value:Int):Int {
		if (colors == null) { colors = [];}
		colors[2] = Value;
		return Value;
	}
	
	private function get_shadowDark():Int {
		return getColor(3);
	}
	private function set_shadowDark(Value:Int):Int {
		if (colors == null) { colors = [];}
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
	
	public function new(Name:String, ?Colors:Array<Int>)
	{
		if (Colors == null) {
			Colors = [0xffffffff, 0xff888888, 0xff444444, 0xff000000];
		}
		name = Name;
		colors = Colors;
	}

	public function copy():SwatchData 
	{
		var colorsCopy:Array<Int> = colors != null ? colors.copy() : null;
		return new SwatchData(name, colorsCopy);
	}

	public function toString():String 
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
	
	public function getRawDifference(?other:SwatchData, ?otherColors:Array<Int>):Int {
		var listA:Array<Int> = colors;
		if (colors != null) {
			listA = colors;
		}else {
			listA = [];
		}
		
		var listB:Array<Int> = null;
		if (other != null) {
			listB = other.colors;
		}else {
			if (otherColors != null) {
				listB = otherColors;
			}else{
				listB = [];
			}
		}
		
		var bigList:Array<Int>;
		var smallList:Array<Int>;
		
		if (listA.length < listB.length) {
			bigList = listB;
			smallList = listA;
		}else {
			bigList = listA;
			smallList = listB;
		}
		
		var totalDiff:Int = 0;
		var i:Int = 0;
		for (i in 0...smallList.length) {
			totalDiff += getRGBdelta(bigList[i], smallList[i]);				//get raw RGB delta
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