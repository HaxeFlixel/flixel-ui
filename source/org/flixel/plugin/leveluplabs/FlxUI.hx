package org.flixel.plugin.leveluplabs;
import nme.geom.Point;
import nme.geom.Rectangle;
import haxe.xml.Fast;
import nme.Assets;
import nme.display.BitmapData;
import nme.display.BitmapInt32;
import nme.Lib;
import org.flixel.FlxBasic;
import org.flixel.FlxButton;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxObject;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxText;
import org.flixel.plugin.leveluplabs.IEventGetter;

/**
 * A simple xml-driven user interface
 * 
 * Usage example:
	_ui = new FlxUI(U.xml("save_slot"),this);
	add(_ui);
 * 
 * @author Lars Doucet
 */

class FlxUI extends FlxGroupX, implements IEventGetter
{
	/***EVENT HANDLING***/
	
	public function getEvent(id:String, sender:Dynamic, data:Dynamic):Void {
		//not yet implemented
	}
	
	public function getRequest(id:String, sender:Dynamic, data:Dynamic):Dynamic {
		//not yet implemented
		return null;
	}
		
	/***PUBLIC FUNCTIONS***/
		
	public function new(data:Fast=null,ptr:IEventGetter=null) 
	{
		super();
		_ptr = ptr;
		if(data != null){
			load(data);
		}
	}
	
	/**
	 * Remove all the references and pointers, then destroy everything
	 */
	
	public override function destroy():Void {
		for (key in _group_index.keys()) {
			_group_index.remove(key);
		}_group_index = null;
		for (key in _asset_index.keys()) {
			_asset_index.remove(key);
		}_asset_index = null;
		super.destroy();		
	}
	
	/**
	 * Main setup function - pass in a Fast(xml) object 
	 * to set up your FlxUI
	 * @param	data
	 */
	
	public function load(data:Fast):Void {
		_group_index = new Hash<FlxGroupX>();
		_asset_index = new Hash<FlxBasic>();
		_definition_index = new Hash<Fast>();
		
		if (data != null) {
			
			//First, load all our definitions
			if (data.hasNode.definition) {
				for (def_data in data.nodes.definition) {
					var def_id:String = def_data.att.id;
					_definition_index.set(def_id, def_data);					
				}
			}
			
			//Then, load all our group definitions
			if(data.hasNode.group){
				for (group_data in data.nodes.group) {
					
					//Create FlxGroupX's for each group we define
					var id:String = group_data.att.id;
					var group:FlxGroupX = new FlxGroupX();					
					group.str_id = id;
					_group_index.set(id, group);
					add(group);
					
					#if (cpp || neko)
						group.makeAtlas(str_id, FlxG.width, FlxG.height);
					#end
					
					FlxG.log("Creating group (" + id + ")");
				}
			}
			
			#if debug
				//Useful debugging info, make sure things go in the right group:
				FlxG.log("Member list...");
				for (fb in members) {
					if (Std.is(fb, FlxGroupX)) {
						var g:FlxGroupX = cast(fb, FlxGroupX);
						FlxG.log("-->Group(" + g.str_id + "), length="+g.members.length);						
						for (fbb in g.members) {
							FlxG.log("---->Member(" + fbb + ")");
						}
					}else {
						FlxG.log("-->Thing(" + fb + ")");
					}
				}			
			#end
			
			if (data.x.firstElement() != null) {
				//Load the actual things
				var node:Xml;
				for (node in data.x.elements()) {
					var type:String = node.nodeName;
					type.toLowerCase();
					var obj:Fast = new Fast(node);
					var group_id:String="";
					var group:FlxGroupX = null;		
					var thing_id:String = U.xml_str(obj.x, "id", true);
										
					//If it belongs to a group, get that information ready:
					if (obj.has.group) { 
						group_id = obj.att.group; 
						group = _group_index.get(group_id);
					}
					
					//Make the thing
					var thing:FlxBasic = _loadThing(type,obj);
							
					if (thing != null) {
						if (group != null) {
							group.add(thing);
							//FlxG.log("adding (" + thing_id + "," + type + ") to group(" + group_id + ")");
						}else {
							add(thing);			
							//FlxG.log("adding (" + thing_id + "," + type + ")");
						}		
						
						_loadPosition(obj, thing);	//Position the thing if possible						
						
						if (thing_id != "") {
							_asset_index.set(thing_id, thing);
						}
					}
				}
			}
		}
	}
		
	/******UTILITY INLINES**********/
	
	/**
	 * Adds to thing.x and/or thing.y with wrappers depending on type
	 * @param	thing
	 * @param	X
	 * @param	Y
	 */
	
	private static inline function _delta(thing:Dynamic, X:Float=0, Y:Float=0):Void {
		if(Std.is(thing,FlxObject)){
			var obj:FlxObject = cast(thing, FlxObject);
			obj.x += X; obj.y += Y;
		}else if (Std.is(thing, FlxButtonPlusX)) {
			var butt:FlxButtonPlusX = cast(thing, FlxButtonPlusX);
			butt.x += Std.int(X); butt.y += Std.int(Y);
		}else if (Std.is(thing, FlxGroupX)) {
			var group:FlxGroupX = cast(thing, FlxGroupX);
			group.instant_update = true;
			group.x += Std.int(X); group.y += Std.int(Y);
		}
	}
		
	/**
	 * Centers thing in x axis with wrappers depending on type
	 * @param	thing
	 * @param	amt
	 */
		
	private static inline function _center(thing:Dynamic,X:Bool=true,Y:Bool=true):Dynamic{
		var return_thing:Dynamic = thing;
		if(Std.is(thing,FlxObject)){
			var obj:FlxObject = cast(thing, FlxObject);
			if (X) { obj.x = (FlxG.width - obj.width) / 2; }
			if (Y) { obj.y = (FlxG.height - obj.height) / 2;}
			return_thing = obj;
		}else if (Std.is(thing, FlxButtonPlusX)) {
			var butt:FlxButtonPlusX = cast(thing, FlxButtonPlusX);
			if (X) { butt.x = Std.int((FlxG.width - butt.width) / 2); }
			if (Y) { butt.y = Std.int((FlxG.height - butt.height) / 2);}
			return_thing = butt;
		}
		return return_thing;
	}
	
	/***PRIVATE***/
		
	private var _group_index:Hash<FlxGroupX>;
	private var _asset_index:Hash<FlxBasic>;
	private var _definition_index:Hash<Fast>;
	private var _ptr:IEventGetter;	
	
	/************LOADING FUNCTIONS**************/
	
	private function _loadThing(type:String, data:Fast):Dynamic {
		var use_def:String = U.xml_str(data.x, "use_def", true);		
		var definition:Fast = null;
		if (use_def != "") {
			definition = _definition_index.get(use_def);
		}
		switch(type) {
			case "chrome","9slicesprite": return _load9SliceSprite(data, definition);
			case "sprite": return _loadSprite(data,definition);
			case "text": return _loadText(data,definition);
			case "button": return _loadButton(data,definition);
			case "save_slot": return _loadSaveSlot(data, definition);
			default: 
				//If I don't know how to load this thing, I will request it from my pointer:			
				return _ptr.getRequest("ui_get:" + type, this, data);
		}
		return null;
	}
	
	private function _loadSaveSlot(data:Fast,definition:Fast=null):FlxUI_SaveSlot {
		var s:FlxUI_SaveSlot = new FlxUI_SaveSlot(data, definition, this);		
		return s;
	}
	
	private function _loadText(data:Fast,definition:Fast=null):FlxText{
		var the_data:Fast = data;
		if (definition != null) { the_data = definition;}
		
		var text:String = U.xml_str(data.x, "text");
		while (text.indexOf("$N") != -1) {				
			text = StringTools.replace(text,"$N","\n");	
		}
		
		var W:Int = U.xml_i(data.x, "width"); if (W == 0) { W = 100; }
		
		var the_font:String = _loadFontFace(the_data);
		
		var align:String = U.xml_str(the_data.x, "align"); if (align == "") { align = null;}
		var size:Int = U.xml_i(the_data.x, "size"); if (size == 0) { size = 8;}
		var color:Int = _loadColor(the_data);
		var shadow:Int = U.xml_i(the_data.x, "shadow");
				
		var ft:FlxText = new FlxText(0, 0, W, text);
		ft.setFormat(the_font, size, color, align, shadow);
		return ft;
	}
	
	private function _loadButton(data:Fast,definition:Fast=null):FlxButtonPlusX {
		var src:String = ""; 
		var fb:FlxButtonPlusX = null;
		
		var the_data:Fast = data;
		if (definition != null) { the_data = definition;}
				
		var label:String = U.xml_str(data.x, "label");
		var W:Int = U.xml_i(the_data.x, "width");
		var H:Int = U.xml_i(the_data.x, "height");	
		var vis_str:String = U.xml_str(data.x, "visible", true);
		var isVis:Bool = U.xml_bool(data.x, "visible", true);		
				
		var params:Array<Dynamic> = null;
		if (data.hasNode.param) {
			params = new Array<Dynamic>();
			for (param in data.nodes.param) {
				if(param.has.type && param.has.value){
					var type:String = param.att.type;
					type = type.toLowerCase();
					switch(type) {
						case "string": params.push(new String(param.att.value));
						case "int": params.push(Std.parseInt(param.att.value));
						case "float": params.push(Std.parseFloat(param.att.value));
						case "color", "hex":params.push(U.parseHex(param.att.value, true));
					}
				}
			}
		}		
				
		fb = new FlxButtonPlusX(0, 0, _onClickButton, params, label, W, H);
		fb.visible = isVis;
		
		if (the_data.hasNode.graphic) {
			var up_graphic:String = "";
			var over_graphic:String = "";
			var up_slice9:String = "";
			var over_slice9:String = "";
			var up_rect:String = "";
			var over_rect:String = "";
			for (graphicNode in the_data.nodes.graphic) {
				var graphic_id:String = U.xml_str(graphicNode.x, "id", true);
				var vis:String = U.xml_str(graphicNode.x, "visible");
				var image:String = U.xml_str(graphicNode.x, "image");
				var slice9:String = U.xml_str(graphicNode.x, "slice9");
				var rect:String = U.xml_str(graphicNode.x, "rect");
				switch(graphic_id) {
					case "inactive", "", "normal": 
						fb.showNormal = (vis!="false");
						if (image != "") { 
							up_graphic = image;
						}
						up_slice9 = slice9;
						up_rect = rect;
					case "active", "hilight", "over", "hover": 
						fb.showHilight = (vis!="false");
						if (image != "") { 
							over_graphic = image;
						}
						over_slice9 = slice9;
						over_rect = rect;
					case "border": 
						if(vis == "false"){
							fb.borderColor = 0x00000000;
						}
				}
			}
						
			if (up_graphic != "") {
				if (over_graphic == "") {
					over_graphic = up_graphic;
				}
				
				//The eventual sprites we feed into loadGraphic()
				var up:FlxSprite = null;
				var over:FlxSprite = null;
				
				/*
				//Bitmap content
				var bmp_up:BitmapData = null;
				var bmp_over:BitmapData = null;
				
				if (up_rect != "") {
					if(over_rect == "") {		//if over rectangle not defined, copy up rectangle
						over_rect = up_rect;
					}
					bmp_up = _loadBitmapRect(up_graphic, up_rect);	//load part of a spritesheet
				}else {
					bmp_up = Assets.getBitmapData(U.gfx(up_graphic));				//load the whole thing
				}
				
				if (over_rect != "") {			//same 
					bmp_over = _loadBitmapRect(over_graphic, over_rect);
				}else {
					bmp_over = Assets.getBitmapData(U.gfx(over_graphic));
				}*/
								
				
				if (up_slice9 != ""){			//if over slice9 not defined, copy up slice9
					if(over_slice9 == ""){
						over_slice9 = up_slice9;
					}
					//load the slice9 sprite
					up = new Flx9SliceSprite(0, 0, U.gfx(up_graphic), new Rectangle(0, 0, W, H), up_slice9);
				}else {
					up = U.fs(U.gfx(up_graphic));			//load the thing as-is
				}
				
				if (over_slice9 != "") {		//same
					over = new Flx9SliceSprite(0, 0, U.gfx(over_graphic), new Rectangle(0, 0, W, H), over_slice9);
				}else {
					over = U.fs(U.gfx(over_graphic));
				}
				
				//load the resultant sprites
				fb.loadGraphic(up, over);
			}
		}
		
		if (the_data.hasNode.text) {
			var text_x:Int = U.xml_i(the_data.x, "text_x");
			var text_y:Int = U.xml_i(the_data.x, "text_y");
			for (textNode in the_data.nodes.text) {
				var use_def:String = U.xml_str(textNode.x, "use_def", true);
				var text_def:Fast = textNode;
				if (use_def != "") {
					text_def = _definition_index.get(use_def);
				}			
				
				var text_data:Fast = textNode;
				if (text_def != null) { text_data = text_def; };
				
				var case_id:String = U.xml_str(textNode.x, "id", true);
				var the_font:String = _loadFontFace(text_data);
				var size:Int = U.xml_i(text_data.x, "size"); if (size == 0) { size = 8;}
				var color:Int = _loadColor(text_data);				
				var shadow:Int = U.xml_i(text_data.x, "shadow");
				var dropShadow:Bool = U.xml_bool(text_data.x, "dropShadow");
				var align:String = U.xml_str(text_data.x, "align", true); if (align == "") { align = null;}
				switch(case_id) {
					case "inactive","", "normal": 
						fb.textNormalX.setFormat(the_font, size, color, align, shadow);
						fb.textNormalX.dropShadow = true;
					case "active","hilight", "over", "hover": 
						fb.textHighlightX.setFormat(the_font, size, color, align, shadow);
						fb.textHighlightX.dropShadow = true;
				}				
				
				fb.textHighlight.visible = false;
				fb.textNormal.visible = true;				
				
				fb.textY = Std.int((fb.height - fb.textNormal.frameHeight) / 2) + text_y;
				fb.textX = text_x;
			}
		}
		
		if (the_data.hasNode.color) {
			var arrayActive:Array<BitmapInt32> = new Array<BitmapInt32>();
			var arrayInactive:Array<BitmapInt32> = new Array<BitmapInt32>();
			var borderColor:BitmapInt32 = 0xffffffff;
			for (colorNode in the_data.nodes.color) {
				var color_id:String = U.xml_str(colorNode.x, "id", true);
				var color:BitmapInt32 = cast(_loadColor(colorNode), BitmapInt32);
				switch(color_id) {
					case "inactive","", "normal": 
						arrayInactive.push(color);
					case "active", "hilight", "over", "hover": 
						arrayActive.push(color);
					case "border": 
						borderColor = color;
				}	
			}
			fb.borderColor = Std.int(borderColor);
			fb.updateActiveButtonColors(arrayActive);
			fb.updateInactiveButtonColors(arrayInactive);
		}			
		
		return fb;
	}
	
	private static inline function _loadBitmapRect(source:String,rect_str:String):BitmapData {
		var b1:BitmapData = Assets.getBitmapData(U.gfx(source));
		var r:Rectangle = Flx9SliceSprite.getRectFromString(rect_str);
		var b2:BitmapData = new BitmapData(Std.int(r.width), Std.int(r.height), true, 0x00ffffff);					
		b2.copyPixels(b1, r, new Point(0, 0));
		return b2;
	}
	
	private function _load9SliceSprite(data:Fast,definition:Fast=null):Flx9SliceSprite{
		var src:String = ""; 
		var f9s:Flx9SliceSprite = null;
		
		var the_data:Fast = data;
		if (definition != null) { the_data = definition;}
		
		src = U.xml_gfx(the_data.x, "src");
		
		var rc:Rectangle;
		var slice9:String = "";
		
		var rect_w:Int = U.xml_i(data.x, "width");
		var rect_h:Int = U.xml_i(data.x, "height");
		
		if (rect_w == 0 || rect_h == 0) {
			return null;
		}
		
		var rc:Rectangle = new Rectangle(0, 0, rect_w, rect_h);
		var slice9:String = U.xml_str(the_data.x, "slice9");
		var tile:Bool = U.xml_bool(the_data.x, "tile", false);
		var smooth:Bool = U.xml_bool(the_data.x, "smooth", false);
		
		if (src != "") {
			if(slice9 != ""){
				f9s = new Flx9SliceSprite(0, 0, src, rc, slice9, tile, smooth);
			}else {
				f9s = new Flx9SliceSprite(0, 0, src, rc,"",tile, smooth);
			}
		}
		
		return f9s;
	}
	
	private function _loadSprite(data:Fast,definition:Fast=null):FlxSpriteX{
		var src:String = ""; 
		var fs:FlxSpriteX = null;
		
		var the_data:Fast = data;
		if (definition != null) { the_data = definition;}
		
		src = U.xml_gfx(the_data.x, "src");
		
		if(src != ""){
			fs = new FlxSpriteX(0, 0, src);		
		}else {
			var W:Int = U.xml_i(the_data.x, "width");
			var H:Int = U.xml_i(the_data.x, "height");
			var C:Int = U.parseHex(U.xml_str(the_data.x, "color"),true);
			fs = new FlxSpriteX(0, 0);
			fs.makeGraphic(W, H, C);
		}
		
		return fs;
	}
		
	private function _loadPosition(data:Fast, thing:Dynamic):Void {
		var X:Float = U.xml_f(data.x, "x");				//position offset from 0,0
		var Y:Float = U.xml_f(data.x, "y");
		var ctrX:Bool = U.xml_bool(data.x, "center_x");	//if true, centers on the screen
		var ctrY:Bool = U.xml_bool(data.x, "center_y");
		
		var center_on:String = U.xml_str(data.x, "center_on");
		var center_on_x:String = U.xml_str(data.x, "center_on_x");
		var center_on_y:String = U.xml_str(data.x, "center_on_y");
		
		//First, try to center the object on the screen:
		if (ctrX || ctrY) {
			_center(thing,ctrX,ctrY);
		}
				
		//Then, try to center it on another object:
		if (center_on != "") {
			var other:FlxBasic = _asset_index.get(center_on);
			if (other != null && Std.is(other, FlxBasic)) {
				U.center(cast(other, FlxObject), cast(thing, FlxObject));
			}
		}else {
			if (center_on_x != "") {
				var other:FlxBasic = _asset_index.get(center_on);
				if (other != null && Std.is(other, FlxBasic)) {
					U.center(cast(other, FlxObject), cast(thing, FlxObject), true, false);
				}
			}
			if (center_on_y != "") {
				var other:FlxBasic = _asset_index.get(center_on);
				if (other != null && Std.is(other, FlxBasic)) {
					U.center(cast(other, FlxObject), cast(thing, FlxObject), false, true);
				}
			}
		}
		
		//Then, add its offset to wherever it wound up:
		_delta(thing, X, Y);
	}	
	
	private function _loadColor(data:Fast,_default:Int=0xffffffff):Int {
		var colorStr:String = U.xml_str(data.x, "color");
		if (colorStr == "" && data.x.nodeName == "color") { 
			colorStr = U.xml_str(data.x, "value"); 
		}
		var color:Int = _default;		
		if (colorStr != "") { color = U.parseHex(colorStr, true); }		
		return color;
	}
	
	private function _loadFontFace(data:Fast):String{
		var fontFace:String = U.xml_str(data.x, "font"); 
		var fontStyle:String = U.xml_str(data.x, "style");
		var the_font:String = null;
		if (fontFace != "") { the_font = U.font(fontFace, fontStyle); }
		return the_font;
	}
	
	private function _onClickButton(params:Dynamic = null):Void {
		FlxG.log("FlxUI._onClickButton(" + params + ")");
		if (_ptr != null) {
			_ptr.getEvent("click_button", this, params);
		}
	}

	
}