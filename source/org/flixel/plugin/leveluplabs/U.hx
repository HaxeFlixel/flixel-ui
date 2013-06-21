package org.flixel.plugin.leveluplabs;
import haxe.xml.Fast;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.geom.Point;
import flash.Lib;
import flash.text.Font;
import openfl.Assets;
import org.flixel.FlxBasic;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxObject;
import org.flixel.FlxSprite;

/**
 * Utility functions, inlined where possible
 * @author Lars Doucet
 */

class U 
{

	public function new() 
	{
		
	}	
	
	/**
	 * Safety wrapper for reading a string attribute from xml
	 * @param	data the Xml object
	 * @param	att the name of the attribute
	 * @param	lower_case force lower_case or not
	 * @return  the attribute as a string if it exists, otherwise returns ""
	 */
	
	public static function xml_str(data:Xml, att:String, lower_case:Bool = false):String {
		if (data.get(att) != null) {
			if (lower_case) {
				return data.get(att).toLowerCase();
			}else{
				return data.get(att);
			}
		}return "";
	} 
	
	/**
	 * If a string is a number that ends with a % sign, it will return a normalized percent float (0-100% = 0.0-1.0)
	 * @param  str a percentage value, such as "5%" or "236.214%"
	 * @return a normalized float, or null if not valid input
	 */
	
	public static function perc_to_float(str:String):{percent:Float,error:Bool}{
		if (str.lastIndexOf("%") == str.length - 1) {
			str = str.substr(0, str.length - 1);	//trim the % off
			var r:EReg = ~/[0-9]+(?:\.[0-9]*)?/;		//make sure it's just numbers & at most 1 decimal
			if (r.match(str)) {
				var match: { pos:Int, len:Int } = r.matchedPos();
				if (match.pos == 0 && match.len == str.length) {
					var perc_float:Float = Std.parseFloat(str);
					perc_float /= 100;
					return { percent:perc_float, error:false };
				}
			}
		}
		return {percent:0,error:true};
	}
	
	public static function arrayContains(arr:Array<Dynamic>, thing:Dynamic):Bool {
		for (i in 0...arr.length) {
			if (arr[i] == thing) {
				return true;
			}
		}
		return false;
	}
	
	public static function isStrNum(str:String):Bool {
		var r:EReg = ~/[0-9]+(?:\.[0-9]*)?/;
			if (r.match(str)) {
			var p: { pos:Int, len:Int } = r.matchedPos();
			if (p.pos == 0 && p.len == str.length) {
				return true;
			}
		}
		return false;
	}
	
	public static function isStrInt(str:String):Bool {
		var r:EReg = ~/[0-9]+/;
			if (r.match(str)) {
			var p: { pos:Int, len:Int } = r.matchedPos();
			if (p.pos == 0 && p.len == str.length) {
				return true;
			}
		}
		return false;
	}
	
	public static function isStrFloat(str:String):Bool {
		var r:EReg = ~/[0-9]+\.[0-9]+/;
			if (r.match(str)) {
			var p: { pos:Int, len:Int } = r.matchedPos();
			if (p.pos == 0 && p.len == str.length) {
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
	 * @return  the attribute as a float if it exists, otherwise returns 0
	 */
	
	public static function xml_f(data:Xml, att:String, default_:Float=0):Float{
		if (data.get(att) != null) {
			return Std.parseFloat(data.get(att));
		}return default_;
	}
	
	/**
	 * Safety wrapper for reading an int attribute from xml
	 * @param	data the Xml object
	 * @param	att the name of the attribute
	 * @param 	default_ what to return if the value doesn't exist
	 * @return  the attribute as an int if it exists, otherwise returns 0
	 */
	
	public static function xml_i(data:Xml, att:String, default_:Int=0):Int {
		if (data.get(att) != null) {
			return Std.parseInt(data.get(att));
		}return default_;
	}
	
	/**
	 * Safety wrapper for reading a bool attribute from xml
	 * @param	data the Xml object
	 * @param	att the name of the attribute
	 * @param   what to return if the value doesn't exist
	 * @return  true if att is "true" (case-insensitive) or "1", otherwise false
	 */
	
	public static function xml_bool(data:Xml, att:String, default_:Bool=false):Bool {
		if (data.get(att) != null) {
			var str:String = data.get(att);
			str = str.toLowerCase();
			if (str == "true") return true;
			if (str == "1") return true;
			return false;
		}return default_;
	}
	
	public static inline function xml_gfx(data:Xml, att:String, test:Bool=true):String {
		var str:String = "";				
		if (data.get(att) != null) { 
			str = U.gfx(data.get(att)); 	
			if (test) {
				try{
					var testbmp:BitmapData = Assets.getBitmapData(str);
					if (testbmp == null) {
						throw ("couldn't load bmp \""+att+"\"");
					}
					testbmp = null;					
				}catch (msg:String) {
					trace("***ERROR*** U.xml_gfx() : " + msg);
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
	
	public static inline function center(fb1:FlxObject,fb2:FlxObject,centerX:Bool=true,centerY:Bool=true):Void {
		if(centerX){fb2.x = fb1.x + ((fb1.width - fb2.width) / 2);}
		if(centerY){fb2.y = fb1.y + ((fb1.height - fb2.height) / 2);}
	}	
	
	/*public static inline function groupGetFirstDeadOfType(_group:FlxGroup, type:String):Entity{
		for (fb in _group.members) {
			if (fb.alive == false) {
				if (Std.is(fb, Entity)) {
					var e:Entity = cast(fb, Entity);
					if (e.type == type || type=="*") {
						return e;
					}
				}
			}
		}return null;
	}*/
	
	
	/**
	 * Simple rand function - return an integer in this range
	 * @param	min	smallest possible value
	 * @param	max largest possible value
	 * @return
	 */
	
	public static inline function iRandRange(min:Int, max:Int):Int {
		/*var n:Float = Math.random();
		var range:Float = cast(max - min, Float);
		var i:Int = (n * range) + min;
		return i;*/
		
		//rand = random(0 <= r < 1)
		//range = 1+(max-min)
		//result = floor(rand * range) + min
		
		return Std.int(Math.random() * cast(1+max-min, Float)) + min;
	}

	public static inline function test_int(i1:Int, test:String, i2:Int):Bool {
		var bool:Bool = false;
		switch(test) {
			case "==": bool = i1 == i2;
			case "<": bool = i1 < i2;
			case ">": bool = i1 > i2;
			case "<=": bool = i1 <= i2;
			case ">=": bool = i1 >= i2;
			case "!=": bool = i1 != i2;
		}
		return bool;
	}
	
	public static inline function test_float(f1:Float, test:String, f2:Int):Bool {
		var bool:Bool = false;
		switch(test) {
			case "==": bool = f1 == f2;
			case "<": bool = f1 < f2;
			case ">": bool = f1 > f2;
			case "<=": bool = f1 <= f2;
			case ">=": bool = f1 >= f2;
			case "!=": bool = f1 != f2;
		}
		return bool;
	}
	
	/*public static inline function countRoomEntities(content:Dynamic,list_things:Array<String>,literal:Bool=false):Array<Int>{
		var count_things:Array<Int> = new Array<Int>();
		var i:Int = 0;
		for (i in 0...list_things.length) {
			count_things.push(0);
		}
		
		var rows:Array<String> = content.split("\n");
		var iy:Int = 0;
		var ix:Int = 0;
		var type:String;
		var best_type:String="";
		for (row in rows) {
			var length:Int = row.length;
			for (ix in 0...length) {
				var char:String = row.charAt(ix);			
				
				i = 0; for (str in list_things) {
					if (literal && str == char) {
						count_things[i]++;
					}else if (str == getSpawnCharType(char)) {
						count_things[i]++;
					}
					i++;
				}
			}
			iy++;
		}		
		return count_things;
	}*/
	
	/**
	 * Return a numeric string with leading zeroes
	 * @param	i any integer
	 * @param	d how many digits
	 * @return  i's value as a string padded with zeroes, exactly d digits in length
	 */
	
	public static inline function padDigits(i:Int, d:Int):String {
		var f:Float = cast(i, Float);
		var str:String = "";
		var num_digits:Int = 0;
		while (f >= 1) {
			f /= 10;
			num_digits++;
		}
		
		if (i == 0) {
			num_digits = 1; //special case
		}
		
		if(num_digits < d){		
			for (temp in 0...(d-num_digits)) {
				str += "0";
			}
		}
		
		return str + Std.string(i);
	}
	
	/**
	 * Parses hex string to equivalent integer, with safety checks
	 * @param	hex_str string in format 0xRRGGBB or 0xAARRGGBB
	 * @return integer value
	 */
	
	public static inline function parseHex(str:String,cast32Bit:Bool=false):Int {
		if (str.indexOf("0x") != 0) {	//if it doesn't start with "0x"
			throw "U.parseHex() string(" + str + ") does not start with \"0x\"!";
		}
		if (str.length != 8 && str.length != 10) {
			throw "U.parseHex() string(" + str + ") must be 8(0xRRGGBB) or 10(0xAARRGGBB) characters long!";
		}
		str = str.substr(2, str.length - 2);		//chop off the "0x"
		if (cast32Bit && str.length == 6) {			//add an alpha channel if none is given and we're casting
			str = "FF" + str;
		}
		return hex2dec(str);
		
	}
	
	/**
	 * Parses an individual hexadecimal string character to the equivalent decimal integer value
	 * @param	hex_char hexadecimal character (1-length string)
	 * @return  decimal value of hex_char
	 */
	
	public static inline function hexChar2dec(hex_char:String):Int {
		var val:Int = -1;
		switch(hex_char) {
			case "0","1","2","3","4","5","6","7","8","9","10":val = Std.parseInt(hex_char);
			case "A","a": val = 10;
			case "B", "b": val = 11; 
			case "C", "c": val = 12; 
			case "D", "d": val = 13; 
			case "E", "e": val = 14; 
			case "F", "f": val = 15; 
		}
		if(val == -1){
			throw "U.hexChar2dec() illegal char(" + hex_char + ")";
		}
		return val;
	}
	
	/**
	 * Parses hex string to equivalent integer
	 * @param	hex_str string in format RRGGBB or AARRGGBB (no "0x")
	 * @return integer value
	 */
	
	private static inline function hex2dec(hex_str:String):Int {
		var length:Int = hex_str.length;
		var place_mult:Int = 1;		
		var sum:Int = 0;
		var i:Int = length - 1; while (i >= 0) {
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
	
	public static inline function hex2rgb(hex:Int):Array<Int> { 
		return 	[hex >> 16 & 0xFF, 	//R
				 hex >> 8 & 0xFF, 	//G
				 hex & 0xFF];		//B
	} 
	
	/**
	 * Returns the hex pixel value of 3 r, g, b ints
	 * @param	r
	 * @param	g
	 * @param	b
	 * @return
	 */
	
	public static inline function rgb2hex(r:Int, g:Int, b:Int):Int {
		return r << 16 | g << 8 | b;
	}
	
	/**
	 * Returns a color somewhere between the given two. 
	 * @param	hex1 A hexadecimal color
	 * @param	hex2 A hexadecimal color
	 * @param	amt 0=100% hex1, 1=100% hex2, 0.5=50% of each
	 * @return
	 */
	
	public static inline function interpolate(hex1:Int, hex2:Int, amt:Float):Int {
		if (amt < 0) { amt = 0; } else if (amt > 1) { amt = 1; }
		
		var a1:Float = 1 - amt;
		
		var c1r:Int = hex1 >> 16 & 0xFF; 	//R
		var c1g:Int = hex1 >> 8 & 0xFF; 	//G
		var c1b:Int = hex1 & 0xFF;			//B
		
		var c2r:Int = hex2 >> 16 & 0xFF; 	//R
		var c2g:Int = hex2 >> 8 & 0xFF; 	//G
		var c2b:Int = hex2 & 0xFF;			//B
				
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
	
	
	public static inline function getLocList(xmin:Int, ymin:Int, xmax:Int, ymax:Int):Array<IntPt> {
		var list:Array<IntPt> = new Array<IntPt>();
		for (yy in ymin...ymax + 1) {
			for (xx in xmin...xmax + 1) {
				list.push(new IntPt(xx, yy));
			}
		}return list;
	}
		
	public static inline function shuffleArray(a:Array<Dynamic>):Array<Dynamic>{		
		var i:Int = a.length - 1; while (i > 0) {
			var n:Int = U.iRandRange(0, i);
			var t:Dynamic = a[n];
			a[n] = a[i];
			a[i] = t;
		}
		return a;
	}
	
	public static inline function disposeXML(thing:Dynamic):Void {
		//don't think this works
		/*#if flash
			var the_xml:Xml;
			if (Std.is(thing, Xml)) {
				the_xml = cast(thing, Xml);
			}else if (Std.is(thing, Fast)) {
				the_xml = cast(thing, Fast).x;
			}
			thing = null;
			flash.system.System.disposeXML(the_xml);
		#end*/
	}
		
	public static inline function copyFast(fast:Fast):Fast {
		return new Fast(copyXml(fast.x));
	}
	
	public static inline function copyXml(data:Xml):Xml {
		return Xml.parse(data.toString()).firstElement();
	}
	
	public static function getXML(str:String, folder:String=""):Dynamic {
		var id:String = str;
		if (folder != "") {
			id = folder + "/" + id;
		}
		return xml(id);
	}
	
	public static function xml(str:String, extension:String = "xml",getFast:Bool=true):Dynamic{
		var str:String = Assets.getText("assets/xml/"+str+"."+extension);
		var the_xml:Xml = Xml.parse(str);
		if(getFast){
			var fast:Fast = new Fast(the_xml.firstElement());
			return fast;
		}else{
			return the_xml.firstElement();
		}
	}
	
	/**
	 * This will remove an array structure, but will leave its contents untouched.
	 * This can lead to memory leaks! Only use this when you want an array gone but
	 * you still need the original elements and know what you're doing.
	 * @param	array
	 */
	
	public static function clearArraySoft(array:Array<Dynamic>):Void {
		if (array == null) return;
		var i:Int = array.length - 1; while (i >= 0) {
			array[i] = null;
			array.splice(i, 1);
			i--;
		}array = null;
	}
	
	/**
	 * This will MURDER an array, removing all traces of both it and its contents
	 * @param	array
	 */
	
	public static function clearArray(array:Array<Dynamic>):Void {
		if (array == null) return;
		var i:Int = array.length - 1; while (i >= 0) {
			destroyThing(array[i]);
			array[i] = null;
			array.splice(i, 1);
			i--;
		}array = null;
	}
	
	public static function destroyThing(thing:Dynamic):Void {
		if (thing == null) return;
		
		
		if (Std.is(thing,Array)){
			clearArray(thing);
		}else if (Std.is(thing,IDestroyable)) {
			var idstr:IDestroyable = cast(thing, IDestroyable);
			idstr.destroy();
			idstr = null;
		}else if (Std.is(thing,FlxBasic)) {
			var fb:FlxBasic = cast(thing, FlxBasic);
			fb.destroy();
			fb = null;
		}		
		thing = null;
	}
		
	public static inline function fontStr(str:String, style:String=""):String {
		return _font(str, style);
	}	
	
	public static inline function font(str:String, style:String=""):String {
		return _font(str,style) + ".ttf";
		//return Assets.getFont("assets/fonts/" + str + suffix + ".ttf");
	}
	
		//inline that does the work:
		private static inline function _font(str:String, style:String=""):String {
			style = style.toLowerCase();
			var suffix:String = "";
			switch(style) {
				case "normal", "regular", "none", "":suffix = "";
				case "bold", "b":suffix = "b";
				case "italic", "i": suffix = "i";
				case "bold-italic", "bolditalic", "italic-bold", "italicbold", "ibold", "boldi", "z":suffix = "z";
			}
			return "assets/fonts/" + str + suffix;
		}
	
	public static inline function fsx(data:Dynamic):FlxSpriteX {
		return new FlxSpriteX(0, 0, data);
	}
	
	public static inline function fs(data:Dynamic):FlxSprite {
		return new FlxSprite(0, 0, data);
	}
	
	public static function FU(str:String):String {
		return str.substr(0, 1).toUpperCase() + str.substr(1, str.length - 1);
	}
		
	public static function copy_shallow_arr(src:Array<Dynamic>):Array<Dynamic> {
		var arr:Array<Dynamic> = new Array<Dynamic>();
		var thing:Dynamic;
		if (src == null){ 
			return arr;
		}
		for (thing in src) {
			arr.push(thing);
		}
		return arr;
	}
	
	public static inline function copy_shallow_arr_i(src:Array<Int>):Array<Int> {
		var arr:Array<Int> = new Array<Int>();
		var thing:Int;
		for (thing in src) {
			arr.push(thing);
		}
		return arr;
	}
	
	public static inline function copy_shallow_arr_str(src:Array<String>):Array<String> {
		var arr:Array<String> = new Array<String>();
		var thing:String;
		for (thing in src) {
			arr.push(thing);
		}
		return arr;
	}
		
	public static function FU_(str:String):String {
		var arr:Array<String> = str.split(" ");
		var str:String="";
		for (i in 0...arr.length){//= 0; i < arr.length; i++) {
			str += FU(arr[i]);
			if (i != arr.length - 1) {
				str += " ";
			}
		}
		return str;
	}
	
	public static function blendModeFromString(str:String):BlendMode
	{
		str = str.toLowerCase();
		switch(str)
		{
			case "add"		 : 	return BlendMode.ADD;
			case "alpha" 	 :	return BlendMode.ALPHA;
			case "darken" 	 : 	return BlendMode.DARKEN;
			case "difference":  return BlendMode.DIFFERENCE;
			case "erase" 	 :  return BlendMode.ERASE;
			case "hardlight" : 	return BlendMode.HARDLIGHT;
			case "invert" 	 : 	return BlendMode.INVERT;
			case "layer" 	 : 	return BlendMode.LAYER;
			case "lighten" 	 : 	return BlendMode.LIGHTEN;
			case "multiply"  : 	return BlendMode.MULTIPLY;
			case "normal" 	 : 	return BlendMode.NORMAL;
			case "overlay" 	 : 	return BlendMode.OVERLAY;
			case "screen" 	 : 	return BlendMode.SCREEN;
			case "subtract"  : 	return BlendMode.SUBTRACT;			
			#if flash
				case "shader" 	 : 	return BlendMode.SHADER;
			#end
		}
		return BlendMode.NORMAL;
	}
	
	public static function gfx(id:String, dir1:String = "", dir2:String = "", dir3:String = "", dir4:String = "",suppressError:Bool=false):String{
		if (id != null) {
			id = id.toLowerCase();
		}
					
		var prefix:String = "";
		
		if (dir1 != "") {
			prefix = dir1 + "/";
			if (dir2 != "") {
				prefix += dir2 + "/";
				if (dir3 != "") {
					prefix += dir3 + "/";
					if (dir4 != "") {
						prefix += dir4 + "/";
					}
				}
			}
		}
		
		if (prefix != "") {
			id = prefix + id;
		}
		
		id = StringTools.replace(id, "-", "_");// .replace("-", "_");
		
		return get_gfx(id);		
		
		//TODO: make mod-compatible
		
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
		
		return c;*/
	}
	
	public static inline function get_gfx(str:String):String{
		return "assets/gfx/" + str + ".png";
	}
	
	public static inline function sfx(str:String):String {
		return "assets/sfx/" + str + ".mp3";
	}
	
	/**
	 * Converts a comma and hyphen list string of numbers to an int array
	 * @param	str input, ex: "1,2,3", "2-4", "1,2,3,5-10"
	 * @return int array, ex: [1,2,3], [2,3,4], [1,2,3,5,6,7,8,9,10]
	 */
	
	public static inline function intStr_to_arr(str:String):Array<Int> {
		var arr:Array<String> = str.split(",");
		var str_arr:Array<Int> = new Array<Int>();
		for (s in arr) {
			if(s.indexOf("-") == -1){			//if it's just a number, "5" push it: [5]
				str_arr.push(Std.parseInt(s));
			}else {		//if it's a range, say, "5-10", push all: [5,6,7,8,9,10]
				var range:Array<String> = str.split("-");
				var lo:Int = -1;
				var hi:Int = -1;
				if(range != null && range.length == 2){
					lo = Std.parseInt(range[0]);
					hi = Std.parseInt(range[1]) + 1;	//+1 so it's inclusive
					if(lo >= 0 && hi > lo){
						for (i in lo...hi) {
							str_arr.push(i);
						}
					}
				}				
			}
		}			
		return str_arr;
	}
	
	public static inline function dirStr(XX:Int, YY:Int):String {
		var str:String = "";
		if (XX == 0) {
			if (YY == -1) { str="N"; }
			else if (YY == 1)  { str="S"; }
			else if (YY == 0)  { str="NONE"; }
		}else if (XX == 1) {
			if (YY == -1) { str="NE"; }
			else if (YY == 1)  { str="SE"; }
			else if (YY == 0)  { str="E"; }
		}else if (XX == -1) {
			if (YY == -1) { str="NW"; }
			else if (YY == 1)  { str="SW"; } 
			else if (YY == 0)  { str="W"; }
		}else {
			str = "NONE";
		}return str;
	}
	
	public static inline function obj_direction(a:FlxObject, b:FlxObject):IntPt {
		var ax:Float = a.x + (a.width / 2);
		var ay:Float = a.y + (a.height / 2);
		
		var bx:Float = b.x + (b.width / 2);
		var by:Float = b.y + (b.height / 2);
		
		var dx:Float = a.x - b.x;
		var dy:Float = a.y - b.y;
		
		var ipt:IntPt = new IntPt(Std.int(dx / Math.abs(dx)), Std.int(dy / Math.abs(dy)));
		return ipt;
	}

	public static inline function circle_test(x1:Float, y1:Float, r1:Float, x2:Float, y2:Float, r2:Float):Bool {
		var dx:Float = x1 - x2;
		var dy:Float = y1 - y2;
		var d2:Float = (dx * dx) + (dy * dy);
		var dr2:Float = (r1 * r1) + (r2 * r2);
		return d2 <= dr2;		
	}
	
	public static inline function point_circle_test(x:Float, y:Float, cx:Float, cy:Float, r:Float):Bool {
		var dx:Float = x - cx;
		var dy:Float = y - cy;
		var d2:Float = (dx * dx) + (dy * dy);
		return d2 <= (r * r);		
	}
	
	public static inline function aabb_test_mult(a:FlxObject,b:FlxObject,multA:Float=1,multB:Float=1):Bool{
		var extra:Float = a.width * multA; var diff:Float = (extra - a.width)/2;
		
		var ax1:Float = a.x - diff;		
		var ax2:Float = a.x + a.width + diff;
		
		extra = a.height * multA; diff = (extra - a.height) / 2;
		
		var ay1:Float = a.y - diff;		
		var ay2:Float = a.y + a.height + diff;
		
		extra = b.width * multB; diff = (extra - b.width) / 2;
		
		var bx1:Float = b.x - diff;
		var bx2:Float = b.x + b.width + diff;
		
		extra = b.height * multB; diff = (extra - b.height) / 2;
		
		var by1:Float = b.y - diff;
		var by2:Float = b.y + b.height + diff;		

		return Math.abs(bx2 + bx1 - (ax2 + ax1)) <= (bx2 - bx1 + ax2 - ax1) &&
		Math.abs(by2 + by1 - (ay2 + ay1)) <= (by2 - by1 + ay2 - ay1);
	}		
	
	public static inline function aabb_test(a:FlxObject,b:FlxObject):Bool{
		
		var ax1:Float = a.x;		
		var ax2:Float = a.x + a.width;
		
		var ay1:Float = a.y;		
		var ay2:Float = a.y + a.height;
		
		var bx1:Float = b.x;
		var bx2:Float = b.x + b.width;
		
		var by1:Float = b.y;
		var by2:Float = b.y + b.height;		
		
		return Math.abs(bx2 + bx1 - (ax2 + ax1)) <= (bx2 - bx1 + ax2 - ax1) &&
		Math.abs(by2 + by1 - (ay2 + ay1)) <= (by2 - by1 + ay2 - ay1);
	}
		
	public static inline function rand(n:Float, n2:Float):Float {
		var min:Float = n;
		var max:Float = n2;
		if (n > n2) { min = n2; max = n;}
		var diff:Float	= max - min;
		return (Math.random() * diff)+min;			
	}
	
	/**
	 * Get the dimensions of a bit string
	 * @param	str
	 * @return
	 */
	
	public static inline function bitStringDimensions(str:String):Point {
		var pt:Point = new Point(0, 0);
		var arr:Array<String> = str.split("\n");
		if (arr != null && arr.length > 1) {
			pt.y = arr.length;
			if (arr[0] != null && arr[0].length > 1) {
				pt.x = arr[0].length;
			}
		}
		return pt;
	}
	
	/**
	 * Splits a binary string with endlines into a big long int array
	 * @param	str
	 * @return
	 */
	
	public static inline function splitBitString(str:String):Array<Int> {
		var final:Array<Int> = new Array<Int>();
		var arr:Array<String> = str.split("\n");
		var i:Int = 0; while (i < arr.length) {
			var len:Int = arr[i].length;
			var j:Int = 0; while (j < len) {
				var char:String = arr[i].charAt(j);
				var num:Int = Std.parseInt(char);
				final.push(num);
				j++;
			}
			i++;
		}
		return final;
	}
	
	public static function getShortTextFromFlxKeyText(str:String):String {
			var s:String = str.toUpperCase();
			switch(str) {
				case "ESC": 
				case "ESCAPE": s = "EC"; 
				case "MINUS": s = "-"; 
				case "PLUS": s = "+"; 
				case "EQUALS": s = "="; 				
				case "DELETE": s = "DE"; 
				case "BACKSPACE": s = "BK"; 
				case "LBRACKET": s = "["; 
				case "RBRACKET": s = "]"; 
				case "BACKSLASH": s = "\\"; 
				case "SEMICOLON": s = ";"; 
				case "QUOTE": s = "\""; 
				case "ENTER": s = "EN"; 
				case "SHIFT": s = "SH"; 
				case "COMMA": s = ","; 
				case "PERIOD": s = "."; 
				case "SLASH": s = "/"; 
				case "CONTROL": s = "CT"; 
				case "ALT": s = "AT"; 
				case "SPACE": s = "SP"; 
				case "UP": s = "UP"; 
				case "DOWN": s = "DN"; 
				case "LEFT": s = "LT"; 
				case "RIGHT": s = "RT"; 
				case "ZERO": s = "0"; 
				case "ONE": s = "1"; 
				case "TWO": s = "2"; 
				case "THREE": s = "3"; 
				case "FOUR": s = "4"; 
				case "FIVE": s = "5"; 
				case "SIX": s = "6"; 
				case "SEVEN": s = "7"; 
				case "EIGHT": s = "8"; 
				case "NINE": s = "9"; 
				case "TEN": s = "10"; 
				case "ACCENT": s = "`"; 
				case "TAB": s = "TB"; 
				case "CAPSLOCK": s = "CP"; 
				case "PAUSEBREAK": s = "PB"; 
				case "HOME": s = "HM"; 
				case "INSERT": s = "IN"; 
				case "PAGEUP": s = "PU"; 
				case "PAGEDOWN": s = "PD"; 
				case "END": s = "ED"; 
				case "NUMLOCK": s = "NM"; 
				case "SCROLLLOCK": s = "SC"; 
				case "NUM0": s = "N0"; 
				case "NUM1": s = "N1"; 
				case "NUM2": s = "N2";  
				case "NUM3": s = "N3";  
				case "NUM4": s = "N4";  
				case "NUM5": s = "N5";  
				case "NUM6": s = "N6";  
				case "NUM7": s = "N7";  
				case "NUM8": s = "N8";  
				case "NUM9": s = "N9";  
				case "NUMDIV": s = "N/"; 
				case "NUMMULT": s = "N*"; 
				case "NUMPLUS": s = "N+"; 
				case "NUMMINUS": s = "N-"; 
				case "NUMDEC": s = "N."; 
				case "NULL": s = " "; 
				default: s = str; 
			}
			return s;
		}
		
		public static function getFlxKeyTextFromShortText(str:String):String {
			var s:String = str.toUpperCase();
			switch(str) {
				case "EC": s = "ESCAPE"; 
				case "-": s = "MINUS"; 
				case "=": s = "EQUALS"; 
				case "+": s = "PLUS"; 
				case "DE": s = "DELETE"; 
				case "BK": s = "BACKSPACE"; 
				case "[": s = "LBRACKET"; 
				case "]": s = "RBRACKET"; 
				case "\\": s = "BACKSLASH"; 
				case "CP": s = "CAPSLOCK"; 
				case ";": s = "SEMICOLON"; 
				case "\"": s = "QUOTE"; 
				case "EN": s = "ENTER"; 
				case "SH": s = "SHIFT"; 
				case ",": s = "COMMA"; 
				case ".": s = "PERIOD"; 
				case "/": s = "SLASH"; 
				case "CT": s = "CONTROL"; 
				case "AT": s = "ALT"; 
				case "SP": s = "SPACE"; 
				case "UP": s = "UP"; 
				case "DN": s = "DOWN"; 
				case "LT": s = "LEFT"; 
				case "RT": s = "RIGHT"; 
				case "0": s = "ZERO"; 
				case "1": s = "ONE"; 
				case "2": s = "TWO"; 
				case "3": s = "THREE"; 
				case "4": s = "FOUR"; 
				case "5": s = "FIVE"; 
				case "6": s = "SIX"; 
				case "7": s = "SEVEN"; 
				case "8": s = "EIGHT"; 
				case "9": s = "NINE"; 
				case "10": s = "TEN"; 
				case "`": s = "ACCENT"; 
				case "TB": s = "TAB"; 
				case "PB": s = "PAUSEBREAK"; 
				case "HM": s = "HOME"; 
				case "IN": s = "INSERT"; 
				case "PU": s = "PAGEUP"; 
				case "PD": s = "PAGEDOWN"; 
				case "ED": s = "END"; 
				case "NM": s = "NUMLOCK"; 
				case "SC": s = "SCROLLLOCK"; 
				case "N0": s = "NUM0"; 
				case "N1": s = "NUM1"; 
				case "N2": s = "NUM2"; 
				case "N3": s = "NUM3"; 
				case "N4": s = "NUM4"; 
				case "N5": s = "NUM5"; 
				case "N6": s = "NUM6"; 
				case "N7": s = "NUM7"; 
				case "N8": s = "NUM8"; 
				case "N9": s = "NUM9"; 
				case "N.": s = "NUMDEC"; 
				case "N/": s = "NUMDIV"; 
				case "N+": s = "NUMPLUS"; 
				case "N-": s = "NUMMINUS"; 
				case "*": s = "NUMMULT"; 
				case "": s = " "; 
				default: s = str; 
			}
			return s;
		}
		
}