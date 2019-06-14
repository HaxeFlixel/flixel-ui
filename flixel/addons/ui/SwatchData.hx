package flixel.addons.ui;

import flixel.util.FlxArrayUtil;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

/**
 * ...
 * @author Lars A. Doucet
 */
class SwatchData implements IFlxDestroyable
{
	public var name:String;
	public var colors:Array<FlxColor>;

	// The "main four" are now getter/setters so you can have an underlying colors array with arbitrary # of colors
	public var hilight(get, set):FlxColor;
	public var midtone(get, set):FlxColor;
	public var shadowMid(get, set):FlxColor;
	public var shadowDark(get, set):FlxColor;

	public function setColor(i:Int, Value:FlxColor):FlxColor
	{
		if (colors == null)
		{
			colors = [];
		}
		colors[i] = Value;
		return Value;
	}

	public function getColor(i:Int):FlxColor
	{
		if (colors.length >= i)
		{
			return colors[i];
		}
		return 0xff000000;
	}

	/**GETTERs/SETTERS**/
	private function get_hilight():FlxColor
	{
		return getColor(0);
	}

	private function set_hilight(Value:FlxColor):FlxColor
	{
		if (colors == null)
		{
			colors = [];
		}
		colors[0] = Value;
		return Value;
	}

	private function get_midtone():FlxColor
	{
		return getColor(1);
	}

	private function set_midtone(Value:FlxColor):FlxColor
	{
		if (colors == null)
		{
			colors = [];
		}
		colors[1] = Value;
		return Value;
	}

	private function get_shadowMid():FlxColor
	{
		return getColor(2);
	}

	private function set_shadowMid(Value:FlxColor):FlxColor
	{
		if (colors == null)
		{
			colors = [];
		}
		colors[2] = Value;
		return Value;
	}

	private function get_shadowDark():FlxColor
	{
		return getColor(3);
	}

	private function set_shadowDark(Value:FlxColor):FlxColor
	{
		if (colors == null)
		{
			colors = [];
		}
		colors[3] = Value;
		return Value;
	}

	public function destroy():Void
	{
		FlxArrayUtil.clearArray(colors);
		colors = null;
	}

	public function new(Name:String, ?Colors:Array<FlxColor>)
	{
		if (Colors == null)
		{
			Colors = [0xffffffff, 0xff888888, 0xff444444, 0xff000000];
		}
		name = Name;
		colors = Colors;
	}

	public function copy():SwatchData
	{
		var colorsCopy:Array<FlxColor> = colors != null ? colors.copy() : null;
		return new SwatchData(name, colorsCopy);
	}

	public function toString():String
	{
		var str:String = "(";
		var i:Int = 0;
		if (colors != null)
		{
			for (colorInt in colors)
			{
				str += colorInt.toWebString();
				if (i != colors.length - 1)
				{
					str += ",";
				}
				i++;
			}
		}
		else
		{
			str += "null";
		}
		str += ",name=" + name + ")";
		return str;
	}

	// Get the total raw difference in colors from another color swatch

	public function getRawDifference(?other:SwatchData, ?otherColors:Array<FlxColor>, ?IgnoreInvisible:Bool = false):Int
	{
		var listA:Array<FlxColor> = colors;
		if (colors != null)
		{
			listA = colors;
		}
		else
		{
			listA = [];
		}

		var listB:Array<FlxColor> = null;
		if (other != null)
		{
			listB = other.colors;
		}
		else
		{
			if (otherColors != null)
			{
				listB = otherColors;
			}
			else
			{
				listB = [];
			}
		}

		var bigList:Array<FlxColor>;
		var smallList:Array<FlxColor>;

		if (listA.length < listB.length)
		{
			bigList = listB;
			smallList = listA;
		}
		else
		{
			bigList = listA;
			smallList = listB;
		}

		var totalDiff:Int = 0;
		for (i in 0...smallList.length)
		{
			var ignore:Bool = false;
			if (IgnoreInvisible && (bigList[i] == 0x00000000 || smallList[i] == 0x00000000))
			{
				if (listA[i] == 0x00000000)
				{
					ignore = true;
				}
			}
			if (!ignore)
			{
				totalDiff += getRGBdelta(bigList[i], smallList[i]); // get raw RGB delta
			}
		}

		var lengthDiff:Int = bigList.length - smallList.length;
		if (lengthDiff != 0)
		{
			totalDiff += ((3 * 0xFF) * lengthDiff);
		}

		return totalDiff;
	}

	public function doColorsEqual(?other:SwatchData, ?otherColors:Array<FlxColor>):Bool
	{
		var otherArray:Array<FlxColor> = null;
		if (other != null)
		{
			otherArray = other.colors;
		}
		else
		{
			if (otherColors != null)
			{
				otherArray = otherColors;
			}
		}

		if (otherArray == null)
		{
			return colors == null;
		}
		else if (colors == null)
		{
			return otherArray == null;
		}

		if (otherArray.length != colors.length)
		{
			return false;
		}
		for (i in 0...colors.length)
		{
			if (colors[i] != otherArray[i])
			{
				return false;
			}
		}
		return true;
	}

	private function getRGBdelta(a:Int, b:Int):Int
	{
		var ra:Int = a >> 16 & 0xFF;
		var ga:Int = a >> 8 & 0xFF;
		var ba:Int = a & 0xFF;

		var rb:Int = b >> 16 & 0xFF;
		var gb:Int = b >> 8 & 0xFF;
		var bb:Int = b & 0xFF;

		return Std.int(Math.abs(ra - rb) + Math.abs(ga - gb) + Math.abs(ba - bb));
	}
}
