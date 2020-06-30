package flixel.addons.ui;

import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.geom.Point;
import flixel.addons.ui.FlxUI.MaxMinSize;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.ui.interfaces.IFlxUIButton;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import haxe.Json;
import haxe.xml.Printer;
import openfl.Assets;
import openfl.display.BitmapDataChannel;
import openfl.geom.Matrix;
import flixel.system.FlxAssets.FlxGraphicAsset;
import openfl.geom.Rectangle;
#if sys
import sys.FileSystem;
import sys.io.File;
import sys.io.FileOutput;
#end
#if (openfl >= "4.0.0")
import openfl.utils.AssetType;
#end
#if haxe4
import haxe.xml.Access;
#else
import haxe.xml.Fast as Access;
#end

/**
 * Utility functions, inlined where possible
 * @author Lars Doucet
 */
class U
{
	/**
	 * Safety wrapper for reading a string attribute from xml
	 * @param	data the Xml object
	 * @param	att the name of the attribute
	 * @param	lower_case force lower_case or not
	 * @param   what to return if it is ""
	 * @return  the attribute as a string if it exists, otherwise returns ""
	 */
	public static function xml_str(data:Xml, att:String, lower_case:Bool = false, default_str:String = ""):String
	{
		if (data.get(att) != null)
		{
			if (lower_case)
			{
				return data.get(att).toLowerCase();
			}
			else
			{
				return data.get(att);
			}
		}
		return default_str;
	}

	/**
	 * For conveniently getting the very common "name" attribute, with backwards-compatibility for the old "id" attribute if name is not found
	 * @param	data
	 * @return
	 */
	public static function xml_name(data:Xml):String
	{
		var name:String = U.xml_str(data, "name", true, "");
		if (name == "")
		{
			name = U.xml_str(data, "id", true, "");
		}
		return name;
	}

	/**
	 * Safety wrapper for reading a FlxColor attribute from xml
	 * @param	data the Xml object
	 * @param	att a color string in either 0xRRGGBB or 0xAARRGGBB format
	 * @param	cast32Bit if true adds an alpha channel if not detected
	 */
	public static function xml_color(data:Xml, att:String, cast32Bit:Bool = true, defaultColor:Null<FlxColor> = null):Null<FlxColor>
	{
		var col:Null<FlxColor> = null;
		var str:String = U.xml_str(data, att, true);
		if (str != "")
		{
			col = U.parseHex(str, cast32Bit);
		}
		if (col == null && defaultColor != null)
		{
			col = defaultColor;
		}
		return col;
	}

	public static function xml_iArray(data:Xml, att:String):Array<Int>
	{
		var arr = xml_strArray(data, att);
		var ints:Array<Int> = null;
		if (arr != null && arr.length > 0)
		{
			ints = [];
			for (i in 0...arr.length)
			{
				ints[i] = Std.parseInt(arr[i]);
			}
		}
		return ints;
	}

	public static function xml_fArray(data:Xml, att:String):Array<Float>
	{
		var arr = xml_strArray(data, att);
		var fs:Array<Float> = null;
		if (arr != null && arr.length > 0)
		{
			fs = [];
			for (i in 0...arr.length)
			{
				fs[i] = Std.parseFloat(arr[i]);
			}
		}
		return fs;
	}

	public static function xml_strArray(data:Xml, att:String, lowerCase:Bool = true, default_:Array<String> = null):Array<String>
	{
		var str:String = U.xml_str(data, att, lowerCase);
		if (str != "")
		{
			var arr = str.split(",");
			return arr;
		}
		else
		{
			return default_;
		}
		return null;
	}

	public static function xml_colorArray(data:Xml, att:String, cast32Bit:Bool = true):Array<FlxColor>
	{
		var arr = xml_strArray(data, att);
		var cols:Array<FlxColor> = null;
		if (arr != null && arr.length > 0)
		{
			cols = [];
			for (i in 0...arr.length)
			{
				cols[i] = U.parseHex(arr[i], cast32Bit);
			}
		}
		return cols;
	}

	/**
	 * If a string is a number that ends with a % sign, it will return a normalized percent float (0-100% = 0.0-1.0)
	 * @param  str a percentage value, such as "5%" or "236.214%"
	 * @return a normalized float, or NaN if not valid input
	 */
	public static function perc_to_float(str:String):Float
	{
		if (str.lastIndexOf("%") == str.length - 1)
		{
			str = str.substr(0, str.length - 1); // trim the % off
			var r:EReg = ~/([0-9]+)?(\.)?([0-9]*)?/; // make sure it's just numbers & at most 1 decimal
			if (r.match(str))
			{
				var match:{pos:Int, len:Int} = r.matchedPos();
				if (match.pos == 0 && match.len == str.length)
				{
					var perc_float:Float = Std.parseFloat(str);
					perc_float /= 100;
					return perc_float;
				}
			}
		}
		return Math.NaN;
	}

	public static function isStrNum(str:String):Bool
	{
		if (str == null || str == "")
			return false;
		var r:EReg = ~/-?([0-9]+)?(\.)?([0-9]*)?/;
		if (r.match(str))
		{
			var p:{pos:Int, len:Int} = r.matchedPos();
			if (p.pos == 0 && p.len == str.length)
			{
				return true;
			}
		}
		return false;
	}

	public static function isStrInt(str:String):Bool
	{
		var r:EReg = ~/[0-9]+/;
		if (r.match(str))
		{
			var p:{pos:Int, len:Int} = r.matchedPos();
			if (p.pos == 0 && p.len == str.length)
			{
				return true;
			}
		}
		return false;
	}

	public static function isStrFloat(str:String):Bool
	{
		var r:EReg = ~/[0-9]+\.[0-9]+/;
		if (r.match(str))
		{
			var p:{pos:Int, len:Int} = r.matchedPos();
			if (p.pos == 0 && p.len == str.length)
			{
				return true;
			}
		}
		return false;
	}

	/**
	 * Safety wrapper for reading a float attribute from xml
	 * @param	data the Xml object
	 * @param	att the name of the attribute
	 * @param 	default_ what to return if the value doesn't exist
	 * @return  the attribute as a float if it exists, otherwise returns default
	 */
	public static function xml_f(data:Xml, att:String, default_:Float = 0):Float
	{
		if (data.get(att) != null)
		{
			return Std.parseFloat(data.get(att));
		}
		return default_;
	}

	/**
	 * Safety wrapper for reading an int attribute from xml
	 * @param	data the Xml object
	 * @param	att the name of the attribute
	 * @param 	default_ what to return if the value doesn't exist
	 * @return  the attribute as an int if it exists, otherwise returns default
	 */
	public static function xml_i(data:Xml, att:String, default_:Int = 0):Int
	{
		if (data.get(att) != null)
		{
			return Std.parseInt(data.get(att));
		}
		return default_;
	}

	/**
	 * Safety wrapper for reading a point attribute from xml
	 * @param	data the Xml object
	 * @param	att the name of the attribute
	 * @param 	default_ what to return if the value doesn't exist
	 * @return  the attribute as a point if it exists, otherwise returns default
	 */
	public static function xml_pt(data:Xml, att:String, default_:FlxPoint = null):FlxPoint
	{
		if (data.get(att) != null)
		{
			return pointify(data.get(att));
		}
		return default_;
	}

	public static function boolify(str:String):Bool
	{
		str = str.toLowerCase();
		if (str == "true" || str == "1")
		{
			return true;
		}
		return false;
	}

	/**
	 * Parses a point expressed as a string to a FlxPoint object.
	 * Must be two numbers separated by a "," or an "x"
	 * This function strips extraneous characters first, ie "(",")"," ","=",":"
	 * @param	str
	 * @return
	 */
	public static function pointify(str:String):FlxPoint
	{
		var pt:FlxPoint = null;
		if (str != null)
		{
			var arr:Array<String> = ["(", ")", " ", "=", ":"]; // remove fancy point formatting crap, reduce to just pt="1,2" or whatever
			for (thing in arr)
			{
				while (str.indexOf(thing) != -1)
				{
					str = StringTools.replace(str, thing, "");
				}
			}
			if (str.indexOf(",") == -1)
			{ // there's no comma
				if (str.indexOf("x") != -1)
				{ // is there an x?
					str = StringTools.replace(str, "x", ","); // replace x with comma
				}
			}
			arr = str.split(",");
			if (arr.length == 2)
			{
				pt = new FlxPoint(Std.parseFloat(arr[0]), Std.parseFloat(arr[1]));
			}
		}
		return pt;
	}

	/**
	 * Pass in two variables as strings, and compare them using proper casting based on a desired type
	 * @param	variable	some variable as a string, say "1.0", "2354", "false", or "happydays"
	 * @param	otherValue	another variable
	 * @param	type		"string","int","float", or "bool"
	 * @param	op			"==","!=","<",">","<=",">="
	 * @return	the value of the comparison
	 */
	public static function compareStringVars(variable:String, otherValue:String, type:String, op:String = "=="):Bool
	{
		switch (type)
		{
			case "string":
				if (op == "==" || op == "=")
				{
					return variable == otherValue;
				}
				if (op == "!==" || op == "!=")
				{
					return variable != otherValue;
				}
			case "int":
				var ia:Int = Std.parseInt(variable);
				var ib:Int = Std.parseInt(otherValue);
				if (op == "==" || op == "=")
				{
					return ia == ib;
				}
				else if (op == "!==" || op == "!=")
				{
					return ia != ib;
				}
				else if (op == "<")
				{
					return ia < ib;
				}
				else if (op == ">")
				{
					return ia > ib;
				}
				else if (op == "<=")
				{
					return ia <= ib;
				}
				else if (op == ">=")
				{
					return ia >= ib;
				}
			case "float":
				var fa:Float = Std.parseFloat(variable);
				var fb:Float = Std.parseFloat(otherValue);
				if (op == "==" || op == "=")
				{
					return fa == fb;
				}
				else if (op == "!==" || op == "!=")
				{
					return fa != fb;
				}
				else if (op == "<")
				{
					return fa < fb;
				}
				else if (op == ">")
				{
					return fa > fb;
				}
				else if (op == "<=")
				{
					return fa <= fb;
				}
				else if (op == ">=")
				{
					return fa >= fb;
				}
			case "bool":
				var ba:Bool = U.boolify(variable);
				var bb:Bool = U.boolify(otherValue);
				if (op == "==" || op == "=")
				{
					return ba == bb;
				}
				else if (op == "!==" || op == "!=")
				{
					return ba != bb;
				}
		}
		return false;
	}

	/**
	 * Safety wrapper for reading a bool attribute from xml
	 * @param	data the Xml object
	 * @param	att the name of the attribute
	 * @param   what to return if the value doesn't exist
	 * @return  true if att is "true" (case-insensitive) or "1", otherwise false
	 */
	public static function xml_bool(data:Xml, att:String, default_:Bool = false):Bool
	{
		if (data.get(att) != null)
		{
			var str:String = data.get(att);
			str = str.toLowerCase();
			if (str == "true" || str == "1")
			{ // only "true" or "1" return TRUE
				return true;
			}
			return false; // any other value returns FALSE
		}
		return default_; // if the attribute does not EXIST, return the DEFAULT VALUE
	}

	public static inline function xml_gfx(data:Xml, att:String, test:Bool = true):String
	{
		var str:String = "";
		if (data.get(att) != null)
		{
			str = data.get(att);
			if (str == "" || str == null)
			{
				str = "";
			}
			else
			{
				str = U.gfx(str);
				if (test)
				{
					try
					{
						if (!Assets.exists(str, AssetType.IMAGE))
						{
							throw("couldn't load bmp \"" + att + "\"");
						}
					}
					catch (msg:String)
					{
						FlxG.log.error("FlxUI: U.xml_gfx() : " + msg);
					}
				}
			}
		}
		return str;
	}

	/**
	 * Center fb2 on fb1's center point
	 * @param	fb1	a FlxObject (does not move)
	 * @param	fb2 a FlxObject (center on fb1)
	 * @param 	centerX center X axis?
	 * @param 	centerY center Y axis?
	 */
	public static inline function center(fb1:FlxObject, fb2:FlxObject, centerX:Bool = true, centerY:Bool = true):Void
	{
		if (centerX)
		{
			fb2.x = fb1.x + ((fb1.width - fb2.width) / 2);
		}
		if (centerY)
		{
			fb2.y = fb1.y + ((fb1.height - fb2.height) / 2);
		}
	}

	public static inline function test_int(i1:Int, test:String, i2:Int):Bool
	{
		return switch (test)
		{
			case "==": i1 == i2;
			case "<": i1 < i2;
			case ">": i1 > i2;
			case "<=": i1 <= i2;
			case ">=": i1 >= i2;
			case "!=": i1 != i2;
			default: false;
		}
	}

	public static inline function test_float(f1:Float, test:String, f2:Int):Bool
	{
		return switch (test)
		{
			case "==": f1 == f2;
			case "<": f1 < f2;
			case ">": f1 > f2;
			case "<=": f1 <= f2;
			case ">=": f1 >= f2;
			case "!=": f1 != f2;
			default: false;
		}
	}

	/**
	 * Return a numeric string with leading zeroes
	 * @param	i any integer
	 * @param	d how many digits
	 * @param	padChar	what to pad with ("0") by default
	 * @return  i's value as a string padded with padChar, exactly d digits in length
	 */
	public static inline function padDigits(i:Int, d:Int, padChar:String = "0"):String
	{
		var f:Float = i;
		var str:String = "";
		var num_digits:Int = 0;
		while (f >= 1)
		{
			f /= 10;
			num_digits++;
		}

		if (i == 0)
		{
			num_digits = 1; // special case
		}

		if (num_digits < d)
		{
			for (temp in 0...(d - num_digits))
			{
				str += padChar;
			}
		}

		return str + Std.string(i);
	}

	public static function conformToBounds(pt:Point, maxMin:MaxMinSize):Point
	{
		if (maxMin != null)
		{
			if (pt.x < maxMin.min_width)
				pt.x = maxMin.min_width;
			if (pt.y < maxMin.min_height)
				pt.y = maxMin.min_height;
			if (pt.x > maxMin.max_width)
				pt.x = maxMin.max_width;
			if (pt.x > maxMin.max_height)
				pt.y = maxMin.max_height;
		}
		return pt;
	}

	/**
	 * Parses hex string to equivalent integer, with safety checks
	 * @param	hex_str string in format 0xRRGGBB or 0xAARRGGBB
	 * @param	cast32Bit add an alpha channel if none is given
	 * @param	safe don't throw errors, just return -1
	 * @param 	default_color what to return if safe is true and it fails
	 * @return integer value
	 */
	public static inline function parseHex(str:String, cast32Bit:Bool = false, safe:Bool = false, default_color:Int = 0x000000):Int
	{
		var return_val = FlxColor.fromString(str);
		if (return_val == null)
		{
			if (!safe)
			{
				throw "U.parseHex() unable to parse hex String " + str;
			}
			else
			{
				return_val = default_color;
			}
		}
		return return_val;
	}

	/**
	 * Parses an individual hexadecimal string character to the equivalent decimal integer value
	 * @param	hex_char hexadecimal character (1-length string)
	 * @return  decimal value of hex_char
	 */
	public static inline function hexChar2dec(hex_char:String):Int
	{
		return switch (hex_char)
		{
			case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10": Std.parseInt(hex_char);
			case "A", "a": 10;
			case "B", "b": 11;
			case "C", "c": 12;
			case "D", "d": 13;
			case "E", "e": 14;
			case "F", "f": 15;
			default: throw "U.hexChar2dec() illegal char(" + hex_char + ")";
		}
	}

	/**
	 * Parses hex string to equivalent integer
	 * @param	hex_str string in format RRGGBB or AARRGGBB (no "0x")
	 * @return integer value
	 */
	private static inline function hex2dec(hex_str:String):Int
	{
		var length:Int = hex_str.length;
		var place_mult:Int = 1;
		var sum:Int = 0;
		var i:Int = length - 1;
		while (i >= 0)
		{
			var char_hex:String = hex_str.substr(i, 1);
			var char_int:Int = hexChar2dec(char_hex);
			sum += char_int * place_mult;
			place_mult *= 16;
			i--;
		}
		return sum;
	}

	/**
	 * Parses hex pixel value into a 3-length array of [r,g,b] ints
	 * @param	hex
	 * @return
	 */
	public static inline function hex2rgb(hex:Int):Array<Int>
	{
		return [hex >> 16 & 0xFF, // R
			hex >> 8 & 0xFF, // G
			hex & 0xFF]; // B
	}

	public static function applyResize(resize_ratio:Float, resize_ratio_axis:Int, w:Float, h:Float, ?pt:FlxPoint):FlxPoint
	{
		if (pt == null)
		{
			pt = new FlxPoint();
		}
		if (resize_ratio > 0)
		{
			var effective_ratio:Float = (w / h);
			if (Math.abs(effective_ratio - resize_ratio) > 0.0001)
			{
				if (resize_ratio_axis == FlxUISprite.RESIZE_RATIO_Y)
				{
					h = w * (1 / resize_ratio);
				}
				else
				{
					w = h * (1 / resize_ratio);
				}
			}
		}
		var iw:Int = Std.int(w);
		if (iw < 1)
		{
			w = 1;
		}
		var ih:Int = Std.int(h);
		if (ih < 1)
		{
			h = 1;
		}
		pt.set(w, h);
		return pt;
	}

	/**
	 * Returns the hex pixel value of 3 r, g, b ints
	 * @param	r
	 * @param	g
	 * @param	b
	 * @return
	 */
	public static inline function rgb2hex(r:Int, g:Int, b:Int):Int
	{
		return r << 16 | g << 8 | b;
	}

	/**
	 * Returns a color somewhere between the given two.
	 * @param	hex1 A hexadecimal color
	 * @param	hex2 A hexadecimal color
	 * @param	amt 0=100% hex1, 1=100% hex2, 0.5=50% of each
	 * @return
	 */
	public static inline function interpolate(hex1:Int, hex2:Int, amt:Float):Int
	{
		if (amt < 0)
		{
			amt = 0;
		}
		else if (amt > 1)
		{
			amt = 1;
		}

		var a1:Float = 1 - amt;

		var c1r:Int = hex1 >> 16 & 0xFF; // R
		var c1g:Int = hex1 >> 8 & 0xFF; // G
		var c1b:Int = hex1 & 0xFF; // B

		var c2r:Int = hex2 >> 16 & 0xFF; // R
		var c2g:Int = hex2 >> 8 & 0xFF; // G
		var c2b:Int = hex2 & 0xFF; // B

		var c3r:Int = Std.int(c1r * a1 + c2r * amt);
		var c3g:Int = Std.int(c1g * a1 + c2g * amt);
		var c3b:Int = Std.int(c1b * a1 + c2b * amt);

		return rgb2hex(c3r, c3g, c3b);
	}

	/*public static inline function interpolate(hex1:Int, hex2:Int, amt:Float):Int {
		if (amt < 0) { amt = 0; } else if (amt > 1) { amt = 1; }

		var c1:Array = hex2rgb(hex1);
		var c2:Array = hex2rgb(hex2);
		var a1:Float = 1 - amt;
		var a2:Float = amt;

		var c3:Array = [c1[0] * a1 + c2[0] * a2,	//R
						c1[1] * a1 + c2[1] * a2,	//G
						c1[2] * a1 + c2[2] * a2];	//B

		return rgb2hex(c3[0], c3[1], c3[2]);
	}*/
	public static inline function getLocList(xmin:Int, ymin:Int, xmax:Int, ymax:Int):Array<FlxPoint>
	{
		var list:Array<FlxPoint> = new Array<FlxPoint>();
		for (yy in ymin...ymax + 1)
		{
			for (xx in xmin...xmax + 1)
			{
				list.push(FlxPoint.get(xx, yy));
			}
		}
		return list;
	}

	public static inline function disposeXML(thing:Dynamic):Void
	{
		// don't think this works
		/*#if flash
				var the_xml:Xml;
				if ((thing is Xml)) {
					the_xml = cast(thing, Xml);
				}else if ((thing is Access)) {
					the_xml = cast(thing, Access).x;
				}
				thing = null;
				flash.system.System.disposeXML(the_xml);
			#end */
	}

	public static inline function copyAccess(fast:Access):Access
	{
		return new Access(copyXml(fast.x));
	}

	public static inline function copyXml(data:Xml):Xml
	{
		return Xml.parse(data.toString()).firstElement();
	}

	#if sys
	public static function readXml(path:String):Xml
	{
		if (FileSystem.exists(path))
		{
			var content:String = File.getContent(path);
			return Xml.parse(content).firstElement();
		}
		return null;
	}

	public static function readAccess(path:String):Access
	{
		var xml:Xml = readXml(path);
		if (xml != null)
		{
			return new Access(xml);
		}
		return null;
	}

	public static function fixSlash(path:String):String
	{
		var goodSlash:String = slash();
		var badSlash:String = (goodSlash == "/") ? "\\" : "/";
		while (path.indexOf(badSlash) != -1)
		{
			path = StringTools.replace(path, badSlash, goodSlash);
		}
		return path;
	}

	#if flash
	public static function endline():String
	{
		return "\n";
	}
	#else
	public static inline function endline():String
	{
		#if windows
		return "\r\n";
		#else
		return "\n";
		#end
	}
	#end

	public static inline function slash():String
	{
		#if windows
		return "\\";
		#else
		return "/";
		#end
	}

	public static function writeXml(data:Xml, path:String, wrapData:Bool = true, addHeader:Bool = true):Void
	{
		var xml:Xml = data;

		if (FileSystem.exists(path)) // if file exists, delete it so we don't crash
		{
			FileSystem.deleteFile(path);
		}

		var xmlString:String = "";

		var fout:FileOutput = File.write(path, false); // open file for reading
		if (addHeader)
		{
			xmlString = '<?xml version="1.0" encoding="utf-8" ?>\n'; // print the boilerplate header
		}
		if (wrapData)
		{
			xmlString += '<data>\n';
		}

		xmlString += Printer.print(xml);

		if (wrapData)
		{
			xmlString += '</data>';
		}

		fout.writeString(xmlString); // write it out
		fout.close();
	}
	#end

	public static function getXML(str:String, folder:String = ""):Dynamic
	{
		var id:String = str;
		if (folder != "")
		{
			id = folder + "/" + id;
		}
		return xml(id);
	}

	public static function json(str:String, extension:String = "json", dir = "assets/json/"):Dynamic
	{
		var json_str:String = Assets.getText(dir + str + "." + extension);
		if (json_str != "" && json_str != null)
		{
			var the_json = Json.parse(json_str);
			return the_json;
		}
		return null;
	}

	public static function field(object:Dynamic, field:String, _default:Dynamic = null):Dynamic
	{
		if (object == null)
			return null;
		if (Reflect.hasField(object, field))
		{
			var thing:Dynamic = Reflect.field(object, field);
			if (thing == null)
			{
				return _default;
			}
			return thing;
		}
		return _default;
	}

	public static function xml(id:String, extension:String = "xml", getAccess:Bool = true, dir = "assets/xml/"):Dynamic
	{
		if (id.indexOf("raw:") == 0 || id.indexOf("RAW:") == 0)
		{
			id = id.substr(4, id.length - 4);
			dir = "";
		}

		var thePath = dir + id + "." + extension;

		var exists = Assets.exists(thePath, AssetType.TEXT);

		if (!exists)
		{
			return null;
		}

		var str:String = Assets.getText(dir + id + "." + extension);
		if (str == null)
		{
			return null;
		}
		var the_xml:Xml = Xml.parse(str);
		if (getAccess)
		{
			var fast:Access = new Access(the_xml.firstElement());
			return fast;
		}
		else
		{
			return the_xml.firstElement();
		}
	}

	/**
	 * This will remove an array structure, but will leave its contents untouched.
	 * This can lead to memory leaks! Only use this when you want an array gone but
	 * you still need the original elements and know what you're doing.
	 * @param	array
	 */
	public static function clearArraySoft(array:Array<Dynamic>):Void
	{
		if (array == null)
			return;
		var i:Int = array.length - 1;
		while (i >= 0)
		{
			array[i] = null;
			array.splice(i, 1);
			i--;
		}
		array = null;
	}

	/**
	 * This will MURDER an array, removing all traces of both it and its contents
	 * @param	array
	 */
	public static function clearArray(array:Array<Dynamic>):Void
	{
		if (array == null)
			return;
		var i:Int = array.length - 1;
		while (i >= 0)
		{
			destroyThing(array[i]);
			array[i] = null;
			array.splice(i, 1);
			i--;
		}
		array = null;
	}

	public static function destroyThing(thing:Dynamic):Void
	{
		if (thing == null)
			return;

		if ((thing is Array))
		{
			clearArray(thing);
		}
		else if ((thing is IFlxDestroyable))
		{
			var idstr:IFlxDestroyable = cast(thing, IFlxDestroyable);
			idstr.destroy();
			idstr = null;
		}
		else if ((thing is FlxBasic))
		{
			var fb:FlxBasic = cast(thing, FlxBasic);
			fb.destroy();
			fb = null;
		}
		thing = null;
	}

	/**
	 * Given something like "verdana" and "bold" returns "assets/fonts/verdanab"
	 * @param	str
	 * @param	style
	 * @return
	 */
	public static inline function fontStr(str:String, style:String = ""):String
	{
		return _font(str, style);
	}

	/**
	 * Given something like "verdana", "bold", ".ttf", returns "assets/fonts/verdanab.ttf"
	 * @param	str
	 * @param	style
	 * @param	extension
	 * @return
	 */
	public static function font(str:String, style:String = "", extension:String = ".ttf"):String
	{
		var ostr = str;
		str = _font(str, style);
		if (str.indexOf(extension) == -1)
		{
			str = str + extension;
		}

		#if (flash || !openfl_legacy)
		str = FontFixer.add(str);
		#end

		var exists = Assets.exists(str, AssetType.FONT);
		if (!exists && extension == ".ttf")
		{
			var alt = font(ostr, style, ".otf");
			if (Assets.exists(alt, AssetType.FONT))
			{
				return alt;
			}
		}

		return str;
	}

	// inline that does the work:
	private static inline function _font(str:String, style:String = ""):String
	{
		style = style.toLowerCase();
		var suffix:String = "";
		switch (style)
		{
			case "normal", "regular", "none", "":
				suffix = "";
			case "bold", "b":
				suffix = "b";
			case "italic", "i":
				suffix = "i";
			case "bold-italic", "bolditalic", "italic-bold", "italicbold", "ibold", "boldi", "ib", "bi", "z":
				suffix = "z";
		}

		if (str.indexOf("assets/fonts/") != 0)
		{
			return "assets/fonts/" + str + suffix;
		}
		return str + suffix;
	}

	public static inline function fsx(data:Dynamic):FlxUISprite
	{
		return new FlxUISprite(0, 0, data);
	}

	public static inline function fs(data:Dynamic):FlxSprite
	{
		return new FlxSprite(0, 0, data);
	}

	/**
	 * Return string with first character uppercase'd
	 * @param	str
	 * @return
	 */
	public static function FU(str:String):String
	{
		return str.substr(0, 1).toUpperCase() + str.substr(1, str.length - 1);
	}

	/**
	 * Return string with first character uppercase'd, rest lowercase'd
	 * @param	str
	 * @return
	 */
	public static function FUL(str:String):String
	{
		return str.substr(0, 1).toUpperCase() + str.substr(1, str.length - 1).toLowerCase();
	}

	public static function getBmp(asset:FlxGraphicAsset):BitmapData
	{
		var str:String = null;
		if ((asset is String))
		{
			str = cast asset;
		}
		else if ((asset is FlxGraphic))
		{
			var fg:FlxGraphic = cast asset;
			str = fg.key;
		}
		else if ((asset is BitmapData))
		{
			var bmp:BitmapData = cast asset;
			return bmp;
		}
		if (FlxG.bitmap.checkCache(str))
		{
			var cg = FlxG.bitmap.get(str);
			if (cg.bitmap != null)
			{
				return cg.bitmap;
			}
		}
		return Assets.getBitmapData(str, false);
	}

	public static function checkHaxedef(str:String):Bool
	{
		str = str.toLowerCase();
		switch (str)
		{
			case "cpp":
				#if cpp
				return true;
				#end
			case "neko":
				#if neko
				return true;
				#end
			case "windows":
				#if windows
				return true;
				#end
			case "mac":
				#if mac
				return true;
				#end
			case "linux":
				#if linux
				return true;
				#end
			case "desktop":
				#if desktop
				return true;
				#end
			case "mobile":
				#if mobile
				return true;
				#end
			case "android":
				#if android
				return true;
				#end
			case "ios":
				#if ios
				return true;
				#end
			case "tvos":
				#if tvos
				return true;
				#end
			case "flash":
				#if flash
				return true;
				#end
			case "html5":
				#if html5
				return true;
				#end
			case "js":
				#if js
				return true;
				#end
			case "web":
				#if web
				return true;
				#end
			case "sys":
				#if sys
				return true;
				#end
			case "demo":
				#if demo
				return true;
				#end
			case "next", "lime_next":
				var val = true;
				#if (lime_legacy || legacy)
				val = false;
				#end
				return val;
			case "legacy", "lime_legacy":
				#if (lime_legacy || legacy)
				return true;
				#end
			case "console_pc", "console-pc":
				#if console_pc
				return true;
				#end
			case "ps4":
				#if ps4
				return true;
				#end
			case "ps3":
				#if ps3
				return true;
				#end
			case "vita":
				#if vita
				return true;
				#end
			case "wiiu":
				#if wiiu
				return true;
				#end
			case "xbox1":
				#if xbox1
				return true;
				#end
		}
		return false;
	}

	public static function copy_shallow_arr(src:Array<Dynamic>):Array<Dynamic>
	{
		if (src == null)
		{
			return null;
		}
		var arr:Array<Dynamic> = new Array<Dynamic>();
		if (src == null)
		{
			return arr;
		}
		for (thing in src)
		{
			arr.push(thing);
		}
		return arr;
	}

	public static function copy_arr_arr_i(src:Array<Array<Int>>):Array<Array<Int>>
	{
		if (src == null)
		{
			return null;
		}
		var arrarr:Array<Array<Int>> = [];
		for (arri in src)
		{
			var temp:Array<Int> = [];
			for (i in arri)
			{
				temp.push(i);
			}
			arrarr.push(temp);
		}
		return arrarr;
	}

	public static function copy_shallow_arr_i(src:Array<Int>):Array<Int>
	{
		if (src == null)
		{
			return null;
		}
		var arr:Array<Int> = new Array<Int>();
		for (thing in src)
		{
			arr.push(thing);
		}
		return arr;
	}

	public static function copy_shallow_arr_str(src:Array<String>):Array<String>
	{
		if (src == null)
		{
			return null;
		}
		var arr:Array<String> = new Array<String>();
		for (thing in src)
		{
			arr.push(thing);
		}
		return arr;
	}

	public static function FU_(str:String):String
	{
		var arr:Array<String> = str.split(" ");
		var str:String = "";
		for (i in 0...arr.length)
		{ // = 0; i < arr.length; i++) {
			str += FU(arr[i]);
			if (i != arr.length - 1)
			{
				str += " ";
			}
		}
		return str;
	}

	public static function xml_blend(x:Xml, att:String):BlendMode
	{
		return blendModeFromString(xml_str(x, att, true, "normal"));
	}

	public static function blendModeFromString(str:String):BlendMode
	{
		str = str.toLowerCase();
		return switch (str)
		{
			case "add": BlendMode.ADD;
			case "alpha": BlendMode.ALPHA;
			case "darken": BlendMode.DARKEN;
			case "difference": BlendMode.DIFFERENCE;
			case "erase": BlendMode.ERASE;
			case "hardlight": BlendMode.HARDLIGHT;
			case "invert": BlendMode.INVERT;
			case "layer": BlendMode.LAYER;
			case "lighten": BlendMode.LIGHTEN;
			case "multiply": BlendMode.MULTIPLY;
			case "normal": BlendMode.NORMAL;
			case "overlay": BlendMode.OVERLAY;
			case "screen": BlendMode.SCREEN;
			case "subtract": BlendMode.SUBTRACT;
			#if flash
			case "shader": BlendMode.SHADER;
			#end
			default: BlendMode.NORMAL;
		}
	}

	/**
	 * This scales an image that contains tiles, being super OCD about it, making sure each tile is
	 * properly scaled and put in the correct position
	 * @param	orig_id asset id
	 * @param	scale the scale factor
	 * @param	origW original width of the tile
	 * @param	origH original height of the tile
	 * @param	W final width of the tile
	 * @param	H final height of the tile
	 * @param	smooth
	 * @return
	 */
	public static function scaleTileBmp(orig_id:String, scale:Float, origW:Int, origH:Int, W:Int = -1, H:Int = -1, smooth:Bool = true):BitmapData
	{
		var orig:BitmapData = Assets.getBitmapData(orig_id, false);
		if (orig == null)
		{
			if (FlxG.bitmap.checkCache(orig_id))
			{
				orig = FlxG.bitmap.get(orig_id).bitmap;
			}
			else
			{
				return null; // indicates failure
			}
		}

		var widthInTiles:Int = Std.int(orig.width / origW);
		var heightInTiles:Int = Std.int(orig.height / origH);

		// if W and H are not provided, infer the correct size
		if (W == -1)
		{
			W = Std.int(origW * scale);
		}
		if (H == -1)
		{
			H = Std.int(origH * scale);
			scale = H / origH;
		}

		if (Math.abs(scale - 1.0) > 0.001)
		{
			var scaled:BitmapData = new BitmapData(Std.int(W * widthInTiles), Std.int(H * heightInTiles), true, 0x00000000);
			var rect:Rectangle = new Rectangle();
			var pt:Point = new Point();
			var matrix:Matrix = new Matrix();
			matrix.scale(scale, scale);
			for (tiley in 0...heightInTiles)
			{
				for (tilex in 0...widthInTiles)
				{
					var tile:BitmapData = new BitmapData(origW, origH, true, 0x00000000);
					rect.setTo(tilex * origW, tiley * origH, origW, origH);
					pt.setTo(0, 0);
					tile.copyPixels(orig, rect, pt);

					var scaleTile:BitmapData = new BitmapData(W, H, true, 0x000000);
					scaleTile.draw(tile, matrix, null, null, null, smooth);
					pt.setTo(tilex * W, tiley * H);
					scaled.copyPixels(scaleTile, scaleTile.rect, pt);
				}
			}
			return scaled;
		}
		else
		{
			return orig.clone();
		}
	}

	/**
	 * This scales an image that contains tiles, being super OCD about it, making sure each tile is
	 * properly scaled and put in the correct position, and returns the new asset key
	 * @param	orig_id asset id
	 * @param	scale the scale factor
	 * @param	OrigW original width of the tile
	 * @param	OrigH original height of the tile
	 * @param	TileW final width of the tile
	 * @param	TileH final height of the tile
	 * @param	Smooth
	 * @return the asset key
	 */
	public static function scaleAndStoreTileset(orig_id:String, scale:Float, OrigW:Int, OrigH:Int, TileW:Int = -1, TileH:Int = -1, Smooth:Bool = true):String
	{
		var assetKey:String = orig_id + "_x" + scale;

		if (FlxG.bitmap.checkCache(assetKey) == false)
		{
			var bmp = scaleTileBmp(orig_id, scale, OrigW, OrigH, TileW, TileH, Smooth);
			FlxG.bitmap.add(bmp, false, assetKey);
		}

		return assetKey;
	}

	/**
	 * For grabbing a resolution-specific version of an image src and dynamically scaling (and caching) it as necessary
	 * @param	src	the asset key of the base image
	 * @param	W	the final scaled width of the new image
	 * @param	H	the final scaled height of the new image
	 * @return	the unique key of the scaled bitmap
	 */
	public static function loadScaledImage(src:String, W:Float, H:Float, smooth:Bool = true):String
	{
		var bmpSrc:String = gfx(src);
		var testBmp:BitmapData = Assets.getBitmapData(bmpSrc, false);

		if (testBmp != null) // if the master asset exists
		{
			if (W < 0)
			{
				W = testBmp.width;
			}
			if (H < 0)
			{
				H = testBmp.height;
			}

			var diff:Float = Math.abs(W - testBmp.width) + Math.abs(H - testBmp.height);

			// if final size != master asset size, we're going to scale it
			if (diff > 0.01)
			{
				var scaleKey:String = bmpSrc + "_" + Std.int(W) + "x" + Std.int(H); // generate a unique scaled asset key

				// if it doesn't exist yet, create it
				if (FlxG.bitmap.get(scaleKey) == null)
				{
					var scaledBmp:BitmapData = new BitmapData(Std.int(W), Std.int(H), true, 0x00000000); // create a unique bitmap and scale it

					var m:Matrix = getMatrix();
					m.identity();
					m.scale(W / testBmp.width, H / testBmp.height);

					scaledBmp.draw(testBmp, m, null, null, null, smooth);

					FlxG.bitmap.add(scaledBmp, true, scaleKey); // store it by the unique key
				}
				return scaleKey; // return the final scaled key
			}
			else
			{
				return bmpSrc; // couldn't scale it, return master asset key
			}
		}
		return null; // failure
	}

	public static function loadImageScaleToHeight(src:String, Height:Float, Smooth:Bool = true, checkFlxBitmap:Bool = false):String
	{
		var bmpSrc:String = gfx(src);
		var testBmp:BitmapData = null;

		if (!checkFlxBitmap)
		{
			testBmp = Assets.getBitmapData(bmpSrc, false);
		}
		else
		{
			var flximg = FlxG.bitmap.get(bmpSrc);
			testBmp = flximg != null ? flximg.bitmap : null;
		}

		var ratio:Float = (testBmp != null) ? Height / testBmp.height : 1.0;
		return loadMonoScaledImage(bmpSrc, ratio, Smooth, checkFlxBitmap);
	}

	/**
	 * For grabbing a version of an image src and dynamically scaling (and caching) it as necessary
	 * @param	src	the asset key of the base image
	 * @param	Scale	the scale factor of the new image
	 * @param	smooth	whether to apply smoothing or not
	 * @param	checkFlxBitmap	whether to use the FlxG.bitmap.get cache instead of Assets.getBitmapData
	 * @return	the unique key of the scaled bitmap
	 */
	public static function loadMonoScaledImage(src:String, Scale:Float, smooth:Bool = true, checkFlxBitmap:Bool = false, fixAlphaChannel:Bool = false):String
	{
		var bmpSrc:String = gfx(src);

		var testBmp:BitmapData = null;

		if (!checkFlxBitmap)
		{
			testBmp = Assets.getBitmapData(bmpSrc, false);
			if (testBmp == null)
			{
				testBmp = Assets.getBitmapData(bmpSrc, true);
			}
		}
		else
		{
			var flximg = FlxG.bitmap.get(bmpSrc);
			testBmp = flximg != null ? flximg.bitmap : null;
		}

		if (testBmp != null) // if the master asset exists
		{
			if (Scale <= 0)
			{
				throw "Error! Scale must be positive & > 0! (Scale was = " + Scale + ")";
			}

			// if final size != master asset size, we're going to scale it
			if (Math.abs(Scale - 1.00) > 0.001)
			{
				var scaleKey:String = bmpSrc + "_ScaleX" + Scale; // generate a unique scaled asset key

				// if it doesn't exist yet, create it
				if (FlxG.bitmap.get(scaleKey) == null)
				{
					var scaledBmp:BitmapData = new BitmapData(Std.int(testBmp.width * Scale), Std.int(testBmp.height * Scale), true,
						0x00000000); // create a unique bitmap and scale it

					var m:Matrix = getMatrix();
					m.identity();
					m.scale(Scale, Scale);
					scaledBmp.draw(testBmp, m, null, null, null, smooth);

					if (fixAlphaChannel)
					{
						// Create a black canvas
						var black = new BitmapData(scaledBmp.width, scaledBmp.height, true, 0xFF000000);
						// Copy the image onto it
						black.copyPixels(scaledBmp, scaledBmp.rect, new Point(), null, null, true);
						// Copy the alpha channel onto it
						black.copyChannel(scaledBmp, scaledBmp.rect, new Point(0, 0), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);

						var temp = scaledBmp;
						scaledBmp = black;
						temp.dispose();
					}

					FlxG.bitmap.add(scaledBmp, true, scaleKey); // store it by the unique key
				}

				return scaleKey; // return the final scaled key
			}
			else
			{
				FlxG.bitmap.add(testBmp, false, bmpSrc);
				return bmpSrc; // couldn't scale it, return master asset key
			}
		}

		return null; // failure
	}

	public static function gfx(id:String, dir1:String = "", dir2:String = "", dir3:String = "", dir4:String = "", suppressError:Bool = false):String
	{
		if (id != null)
		{
			id = id.toLowerCase();
		}

		var prefix:String = "";

		if (dir1 != "")
		{
			prefix = dir1 + "/";
			if (dir2 != "")
			{
				prefix += dir2 + "/";
				if (dir3 != "")
				{
					prefix += dir3 + "/";
					if (dir4 != "")
					{
						prefix += dir4 + "/";
					}
				}
			}
		}

		if (prefix != "")
		{
			id = prefix + id;
		}

		if (id.indexOf("raw:") != 0)
		{
			id = StringTools.replace(id, "-", "_"); // .replace("-", "_");
		}

		return get_gfx(id);

		// TODO: make mod-compatible

		/*var c:Class = null;
			try {

				if (Main.MOD_IS_ACTIVE && Main.MOD_DATA != null) {
					c = Main.MOD_DATA.getGfx(id);
					if(c != null){
						return c;
					}
				}

				c = Main.embed_graphics[id];

			}catch (e:Error) {
				if(!suppressError){
					Main.handleError(e, "U.gfx(" + id + ")");
				}
			}

			return c; */
	}

	public static function bmpToArrayIntLayer(color_index:Int, bd:BitmapData):Array<Int>
	{
		// Walk image and export pixel values
		var p:Int;
		var arr:Array<Int> = [];
		var w:Int = bd.width;
		var h:Int = bd.height;
		for (r in 0...h)
		{
			for (c in 0...w)
			{
				// Decide if this pixel/tile is solid (1) or not (0)
				p = bd.getPixel(c, r);

				if (p == color_index) // it matches our color
					p = 1; // solid tile
				else
				{ // some other color, ignore it
					p = 0;
				}

				// Write the result to the string
				arr.push(p);
			}
		}
		return arr;
	}

	/**
	 * Converts a PNG file to a comma-separated string.
	 * pixels that match color_index are flagged
	 * others are ignored
	 * must be a PERFECT MATCH
	 *
	 * @param   color_index   The matching color index
	 *
	 * @return	A comma-separated string containing the level data in a FlxTilemap-friendly format.
	 */
	public static function bmpToCSVLayer(color_index:Int, bd:BitmapData):String
	{
		// Walk image and export pixel values
		var p:Int;
		var csv:String = "";
		var w:Int = bd.width;
		var h:Int = bd.height;
		for (r in 0...h)
		{
			for (c in 0...w)
			{
				// Decide if this pixel/tile is solid (1) or not (0)
				p = bd.getPixel(c, r);

				if (p == color_index) // it matches our color
					p = 1; // solid tile
				else
				{ // some other color, ignore it
					p = 0;
				}

				// Write the result to the string
				if (c == 0)
				{
					if (r == 0)
						csv += p;
					else
					{
						csv += "\n" + p;
					}
				}
				else
				{
					csv += ", " + p;
				}
			}
		}
		return csv;
	}

	public static function get_gfx(str:String):String
	{
		var return_str:String = "";

		var suffix = "";

		// If it ends with ".jpg" treat that as the suffix, otherwise treat the suffix as ".png"
		if (str.indexOf(".jpg") != -1)
		{
			suffix = ".jpg";
		}
		else
		{
			suffix = ".png";
		}

		if (str != null && str.length > 4 && str.indexOf(suffix) != -1)
		{
			str = str.substr(0, str.length - 4); // strip off the suffix if it exists
		}
		if (str.indexOf("raw:") == 0 || str.indexOf("RAW:") == 0)
		{
			str = str.substr(4, str.length - 4);
			return_str = str + suffix;
		}
		if (str != null && str.indexOf("assets/gfx/") == 0)
		{
			return_str = str + suffix;
		}

		if (return_str == "")
		{
			return_str = "assets/gfx/" + str + suffix;
		}

		if (return_str.indexOf(".stitch.txt" + suffix) != -1)
		{
			return_str = StringTools.replace(return_str, ".stitch.txt" + suffix, ".stitch.txt");
		}

		return return_str;
	}

	public static inline function sfx(str:String):String
	{
		var extension:String = "";
		#if flash
		extension = ".mp3";
		#else
		extension = ".ogg";
		#end
		if (str.indexOf("RAW:") == 0)
		{
			str = str.substr(4, str.length - 4);
			return str + extension;
		}
		return "assets/sfx/" + str + extension;
	}

	/**
	 * Converts a comma and hyphen list string of numbers to an int array
	 * @param	str input, ex: "1,2,3", "2-4", "1,2,3,5-10"
	 * @return int array, ex: [1,2,3], [2,3,4], [1,2,3,5,6,7,8,9,10]
	 */
	public static inline function intStr_to_arr(str:String):Array<Int>
	{
		var arr:Array<String> = str.split(",");
		var str_arr:Array<Int> = new Array<Int>();
		for (s in arr)
		{
			if (s.indexOf("-") == -1)
			{ // if it's just a number, "5" push it: [5]
				str_arr.push(Std.parseInt(s));
			}
			else
			{ // if it's a range, say, "5-10", push all: [5,6,7,8,9,10]
				var range:Array<String> = str.split("-");
				var lo:Int = -1;
				var hi:Int = -1;
				if (range != null && range.length == 2)
				{
					lo = Std.parseInt(range[0]);
					hi = Std.parseInt(range[1]) + 1; // +1 so it's inclusive
					if (lo >= 0 && hi > lo)
					{
						for (i in lo...hi)
						{
							str_arr.push(i);
						}
					}
				}
			}
		}
		return str_arr;
	}

	/**
	 * Converts a comma and hyphen list string of numbers to a String array
	 * @param	str input, ex: "1,2,3", "2-4", "1,2,3,5-10"
	 * @return int array, ex: [1,2,3], [2,3,4], [1,2,3,5,6,7,8,9,10]
	 */
	public static inline function intStr_to_arrStr(str:String):Array<String>
	{
		var arr:Array<String> = str.split(",");
		var str_arr:Array<String> = new Array<String>();
		for (s in arr)
		{
			if (s.indexOf("-") == -1)
			{ // if it's just a number, "5" push it: [5]
				str_arr.push(Std.string(Std.parseInt(s))); // validation -- force it to be an int
			}
			else
			{ // if it's a range, say, "5-10", push all: [5,6,7,8,9,10]
				var range:Array<String> = str.split("-");
				var lo:Int = -1;
				var hi:Int = -1;
				if (range != null && range.length == 2)
				{
					lo = Std.parseInt(range[0]);
					hi = Std.parseInt(range[1]) + 1; // +1 so it's inclusive
					if (lo >= 0 && hi > lo)
					{
						for (i in lo...hi)
						{
							str_arr.push(Std.string(i));
						}
					}
				}
			}
		}
		return str_arr;
	}

	public static inline function dirStr(XX:Int, YY:Int):String
	{
		var str:String = "";
		if (XX == 0)
		{
			if (YY == -1)
			{
				str = "N";
			}
			else if (YY == 1)
			{
				str = "S";
			}
			else if (YY == 0)
			{
				str = "NONE";
			}
		}
		else if (XX == 1)
		{
			if (YY == -1)
			{
				str = "NE";
			}
			else if (YY == 1)
			{
				str = "SE";
			}
			else if (YY == 0)
			{
				str = "E";
			}
		}
		else if (XX == -1)
		{
			if (YY == -1)
			{
				str = "NW";
			}
			else if (YY == 1)
			{
				str = "SW";
			}
			else if (YY == 0)
			{
				str = "W";
			}
		}
		else
		{
			str = "NONE";
		}
		return str;
	}

	public static inline function obj_direction(a:FlxObject, b:FlxObject):FlxPoint
	{
		var dx:Float = a.x - b.x;
		var dy:Float = a.y - b.y;

		var ipt = FlxPoint.get(Std.int(dx / Math.abs(dx)), Std.int(dy / Math.abs(dy)));
		return ipt;
	}

	public static inline function circle_test(x1:Float, y1:Float, r1:Float, x2:Float, y2:Float, r2:Float):Bool
	{
		var dx:Float = x1 - x2;
		var dy:Float = y1 - y2;
		var d2:Float = (dx * dx) + (dy * dy);
		var dr2:Float = (r1 * r1) + (r2 * r2);
		return d2 <= dr2;
	}

	public static inline function point_circle_test(x:Float, y:Float, cx:Float, cy:Float, r:Float):Bool
	{
		var dx:Float = x - cx;
		var dy:Float = y - cy;
		var d2:Float = (dx * dx) + (dy * dy);
		return d2 <= (r * r);
	}

	public static inline function aabb_test_mult(a:FlxObject, b:FlxObject, multA:Float = 1, multB:Float = 1):Bool
	{
		var extra:Float = a.width * multA;
		var diff:Float = (extra - a.width) / 2;

		var ax1:Float = a.x - diff;
		var ax2:Float = a.x + a.width + diff;

		extra = a.height * multA;
		diff = (extra - a.height) / 2;

		var ay1:Float = a.y - diff;
		var ay2:Float = a.y + a.height + diff;

		extra = b.width * multB;
		diff = (extra - b.width) / 2;

		var bx1:Float = b.x - diff;
		var bx2:Float = b.x + b.width + diff;

		extra = b.height * multB;
		diff = (extra - b.height) / 2;

		var by1:Float = b.y - diff;
		var by2:Float = b.y + b.height + diff;

		return Math.abs(bx2 + bx1 - (ax2 + ax1)) <= (bx2 - bx1 + ax2 - ax1)
			&& Math.abs(by2 + by1 - (ay2 + ay1)) <= (by2 - by1 + ay2 - ay1);
	}

	public static inline function aabb_test(a:FlxObject, b:FlxObject):Bool
	{
		var ax1:Float = a.x;
		var ax2:Float = a.x + a.width;

		var ay1:Float = a.y;
		var ay2:Float = a.y + a.height;

		var bx1:Float = b.x;
		var bx2:Float = b.x + b.width;

		var by1:Float = b.y;
		var by2:Float = b.y + b.height;

		return Math.abs(bx2 + bx1 - (ax2 + ax1)) <= (bx2 - bx1 + ax2 - ax1)
			&& Math.abs(by2 + by1 - (ay2 + ay1)) <= (by2 - by1 + ay2 - ay1);
	}

	/**
	 * Get the dimensions of a bit string
	 */
	public static inline function bitStringDimensions(str:String):Point
	{
		var pt:Point = new Point(0, 0);
		var arr:Array<String> = str.split("\n");
		if (arr != null && arr.length > 1)
		{
			pt.y = arr.length;
			if (arr[0] != null && arr[0].length > 1)
			{
				pt.x = arr[0].length;
			}
		}
		return pt;
	}

	/**
	 * Splits a binary string with endlines into a big long int array
	 */
	public static inline function splitBitString(str:String):Array<Int>
	{
		var result:Array<Int> = new Array<Int>();
		var arr:Array<String> = str.split("\n");
		var i:Int = 0;
		while (i < arr.length)
		{
			var len:Int = arr[i].length;
			var j:Int = 0;
			while (j < len)
			{
				var char:String = arr[i].charAt(j);
				var num:Int = Std.parseInt(char);
				result.push(num);
				j++;
			}
			i++;
		}
		return result;
	}

	public static function getShortTextFromFlxKeyText(str:String):String
	{
		str = str.toUpperCase();
		return switch (str)
		{
			case "ESCAPE" | "ESC": "EC";
			case "MINUS": "-";
			case "PLUS": "+";
			case "EQUALS": "=";
			case "DELETE": "DE";
			case "BACKSPACE": "BK";
			case "LBRACKET": "[";
			case "RBRACKET": "]";
			case "BACKSLASH": "\\";
			case "SEMICOLON": ";";
			case "QUOTE": "\"";
			case "ENTER": "EN";
			case "SHIFT": "SH";
			case "COMMA": ",";
			case "PERIOD": ".";
			case "SLASH": "/";
			case "CONTROL": "CT";
			case "ALT": "AT";
			case "SPACE": "SP";
			case "UP": "UP";
			case "DOWN": "DN";
			case "LEFT": "LT";
			case "RIGHT": "RT";
			case "ZERO": "0";
			case "ONE": "1";
			case "TWO": "2";
			case "THREE": "3";
			case "FOUR": "4";
			case "FIVE": "5";
			case "SIX": "6";
			case "SEVEN": "7";
			case "EIGHT": "8";
			case "NINE": "9";
			case "TEN": "10";
			case "ACCENT": "`";
			case "TAB": "TB";
			case "CAPSLOCK": "CP";
			case "PAUSEBREAK": "PB";
			case "HOME": "HM";
			case "INSERT": "IN";
			case "PAGEUP": "PU";
			case "PAGEDOWN": "PD";
			case "END": "ED";
			case "NUMLOCK": "NM";
			case "SCROLLLOCK": "SC";
			case "NUM0": "N0";
			case "NUM1": "N1";
			case "NUM2": "N2";
			case "NUM3": "N3";
			case "NUM4": "N4";
			case "NUM5": "N5";
			case "NUM6": "N6";
			case "NUM7": "N7";
			case "NUM8": "N8";
			case "NUM9": "N9";
			case "NUMDIV": "N/";
			case "NUMMULT": "N*";
			case "NUMPLUS": "N+";
			case "NUMMINUS": "N-";
			case "NUMDEC": "N.";
			case "NULL": " ";
			default: str;
		}
	}

	public static function getFlxKeyTextFromShortText(str:String):String
	{
		str = str.toUpperCase();
		return switch (str)
		{
			case "EC": "ESCAPE";
			case "-": "MINUS";
			case "=": "EQUALS";
			case "+": "PLUS";
			case "DE": "DELETE";
			case "BK": "BACKSPACE";
			case "[": "LBRACKET";
			case "]": "RBRACKET";
			case "\\": "BACKSLASH";
			case "CP": "CAPSLOCK";
			case ";": "SEMICOLON";
			case "\"": "QUOTE";
			case "EN": "ENTER";
			case "SH": "SHIFT";
			case ",": "COMMA";
			case ".": "PERIOD";
			case "/": "SLASH";
			case "CT": "CONTROL";
			case "AT": "ALT";
			case "SP": "SPACE";
			case "UP": "UP";
			case "DN": "DOWN";
			case "LT": "LEFT";
			case "RT": "RIGHT";
			case "0": "ZERO";
			case "1": "ONE";
			case "2": "TWO";
			case "3": "THREE";
			case "4": "FOUR";
			case "5": "FIVE";
			case "6": "SIX";
			case "7": "SEVEN";
			case "8": "EIGHT";
			case "9": "NINE";
			case "10": "TEN";
			case "`": "ACCENT";
			case "TB": "TAB";
			case "PB": "PAUSEBREAK";
			case "HM": "HOME";
			case "IN": "INSERT";
			case "PU": "PAGEUP";
			case "PD": "PAGEDOWN";
			case "ED": "END";
			case "NM": "NUMLOCK";
			case "SC": "SCROLLLOCK";
			case "N0": "NUM0";
			case "N1": "NUM1";
			case "N2": "NUM2";
			case "N3": "NUM3";
			case "N4": "NUM4";
			case "N5": "NUM5";
			case "N6": "NUM6";
			case "N7": "NUM7";
			case "N8": "NUM8";
			case "N9": "NUM9";
			case "N.": "NUMDEC";
			case "N/": "NUMDIV";
			case "N+": "NUMPLUS";
			case "N-": "NUMMINUS";
			case "*": "NUMMULT";
			case "": " ";
			default: str;
		}
	}

	public static function formatXml(_xml:Xml):String
	{
		var s:String = _xml.toString();

		var r:EReg = ~/>[^`<]*</g;
		s = r.replace(s, ">___SPLITHERE___<"); // inserts identifier between tags.

		r = ~/___SPLITHERE___/g;
		var split:Array<String> = r.split(s); // splits into tags using the identifier.

		// Now assembles each tag sepparated by newLines and identented according to child depth.
		s = "";
		var childDepht:Int = 0;
		var whiteSpace = '\t';

		for (str in split)
		{
			for (i in 0...childDepht)
			{
				s += whiteSpace;
			}

			if (str.charAt(0) == '<' && str.charAt(1) == '/') // If its a closing bracket
			{
				childDepht--;
				s = s.substr(0, s.length - whiteSpace.length);
			}
			else if (str.charAt(str.length - 1) == '>' && str.charAt(str.length - 2) != '/' && str.charAt(str.length - 2) != '-') // if its an open bracket.
			{
				childDepht++;
			}

			s += str + "\n"; // Concatenates the tag in the output with a newline at the end.
		}

		return s;
	}

	public static function strCase(str:String, code:String):String
	{
		return switch (code)
		{
			case "u": str.toUpperCase(); // uppercase
			case "l": str.toLowerCase(); // lowercase
			case "fu": U.FU(str); // first letter uppercase
			case "fu_": U.FU_(str); // first letter in each word uppercase
			default: str;
		}
		return str;
	}

	public static function unparentXML(f:Access):Access
	{
		if (f.x.parent != null)
		{
			f.x.parent.removeChild(f.x);
		}
		return f;
	}

	/** @since 2.1.0 */
	public static function setButtonLabel(btn:IFlxUIButton, str:String):Void
	{
		if (btn == null)
			return;

		if ((btn is FlxUIButton))
		{
			// if it's a FlxUIButton, just apply the text and stop
			cast(btn, FlxUIButton).label.text = str;
		}
		else if ((btn is FlxUISpriteButton))
		{
			// if it's a FlxUISpriteButton, and the label is a group,
			// search for the first text field, apply the text, and stop
			var fuisb:FlxUISpriteButton = cast btn;
			if (fuisb.label == null)
				return;
			if ((fuisb.label is FlxSpriteGroup))
			{
				var g:FlxSpriteGroup = cast fuisb.label;
				if (g.members == null)
					return;
				for (sprite in g.members)
				{
					if (sprite == null)
						continue;
					if ((sprite is FlxText))
					{
						cast(sprite, FlxText).text = str;
						return;
					}
				}
			}
		}
	}

	public static function getMatrix():Matrix
	{
		if (_matrix == null)
		{
			_matrix = new Matrix();
		}
		return _matrix;
	}

	private static var _matrix:Matrix = null;
}
