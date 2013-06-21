package org.flixel.plugin.leveluplabs;
import flash.geom.Point;
import flash.geom.Rectangle;
import haxe.xml.Fast;
import flash.display.BitmapData;
import flash.Lib;
import openfl.Assets;
import org.flixel.FlxBasic;
import org.flixel.FlxButton;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxObject;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxText;
import org.flixel.FlxTilemap;
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

class FlxUI extends FlxGroupX implements IEventGetter
{
	
	//If this is true, the first few frames after initialization ignore all input so you can't auto-click anything
	public var do_safe_input_delay:Bool = true;
	public var safe_input_delay_time:Float = 0.01;
	
	public var failed:Bool = false;
	public var failed_by:Float = 0;
	
	/***EVENT HANDLING***/
	
	public function getEvent(id:String, sender:Dynamic, data:Dynamic):Void {
		//not yet implemented
	}
	
	public function getRequest(id:String, sender:Dynamic, data:Dynamic):Dynamic {
		//not yet implemented
		return null;
	}
		
	/***PUBLIC FUNCTIONS***/
		
	public function new(data:Fast=null,ptr:IEventGetter=null,superIndex_:FlxUI=null) 
	{
		super();
		_ptr = ptr;
		if (superIndex_ != null) {
			setSuperIndex(superIndex_);
		}
		if(data != null){
			load(data);
		}
	}
	
	/**
	 * Set a pointer to another FlxUI for the purposes of indexing
	 * @param	flxUI
	 */
	
	public function setSuperIndex(flxUI:FlxUI):Void {
		_superIndexUI = flxUI;
	}
	
	public override function update():Void {
		if (do_safe_input_delay) {
			_safe_input_delay_elapsed += FlxG.elapsed;
			if (_safe_input_delay_elapsed > safe_input_delay_time) {
				do_safe_input_delay = false;
			}else {
				return;
			}
		}
		super.update();
	}
	
	/**
	 * Removes an asset
	 * @param	key the asset to remove
	 * @param	destroy whether to destroy it
	 * @return	the asset, or null if destroy=true
	 */
	
	public function removeAsset(key:String,destroy:Bool=true):FlxBasic{
		var asset:FlxBasic = getAsset(key, false);
		if (asset != null) {
			replaceInGroup(asset, null, true);
			_asset_index.remove(key);
		}
		if (destroy) {
			asset.destroy();
			asset = null;
		}
		return asset;
	}
	
	/**
	 * Replaces an asset, both in terms of location & group position
	 * @param	key the string id of the original
	 * @param	replace the replacement object
	 * @param 	destroy_old kills the original if true
	 * @return	the old asset, or null if destroy_old=true
	 */
	
	public function replaceAsset(key:String, replace:FlxBasic, center_x:Bool=true, center_y:Bool=true, destroy_old:Bool=true):FlxBasic{
		//get original asset
		var original:FlxBasic = getAsset(key, false);
		
		if(original != null){
			//set replacement in its location
			if (Std.is(original, FlxObject) && Std.is(replace, FlxObject)) {
				var r:FlxObject = cast(replace, FlxObject);
				var o:FlxObject = cast(original, FlxObject);
				if(!center_x){
					r.x = o.x;
				}else {
					r.x = o.x + (o.width-r.width) / 2;
				}
				if (!center_y) {
					r.y = o.y;
				}else {
					r.y = o.y + (o.height - o.height) / 2;
				}
				r = null; o = null;
			}
			
			//switch original for replacement in whatever group it was in
			replaceInGroup(original, replace);
			
			//remove the original asset index key
			_asset_index.remove(key);
			
			//key the replacement to that location
			_asset_index.set(key, replace);
			
			//destroy the original if necessary
			if (destroy_old) {
				original.destroy();
				original = null;
			}
		}
		
		return original;
	}
	
	
	
	/**
	 * Remove all the references and pointers, then destroy everything
	 */
	
	public override function destroy():Void {
		if(_group_index != null){
			for (key in _group_index.keys()) {
				_group_index.remove(key);
			}_group_index = null;
		}
		if(_asset_index != null){
			for (key in _asset_index.keys()) {
				_asset_index.remove(key);
			}_asset_index = null;			
		}
		_superIndexUI = null;
		super.destroy();	
	}
	
	/**
	 * Main setup function - pass in a Fast(xml) object 
	 * to set up your FlxUI
	 * @param	data
	 */
	
	public function load(data:Fast):Void {
		
		_group_index = new Map<String,FlxGroupX>();
		_asset_index = new Map<String,FlxBasic>();
		_definition_index = new Map<String,Fast>();
		_mode_index = new Map<String,Fast>();

		
		if (data != null) {
			
			//First, load all our definitions
			if (data.hasNode.definition) {
				for (def_data in data.nodes.definition) {
					var def_id:String = def_data.att.id;
					_definition_index.set(def_id, def_data);					
				}
			}
		
			
			//Next, load all our modes
			if (data.hasNode.mode) {
				for (mode_data in data.nodes.mode) {
					var mode_id:String = mode_data.att.id;
					_mode_index.set(mode_id, mode_data);
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
					
					// TODO - CREATE ATLAS COMMENTED FOR CPP TARGET.
					/*#if (cpp || neko)
						group.makeAtlas(str_id, FlxG.width, FlxG.height);
					#end*/
					
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
				for (node in data.x.elements()) 
				{
					var type:String = node.nodeName;
					type.toLowerCase();
					var obj:Fast = new Fast(node);
					var group_id:String="";
					var group:FlxGroupX = null;		
									
					var thing_id:String = U.xml_str(obj.x, "id", true);
										
					//If it belongs to a group, get that information ready:
					if (obj.has.group) { 
						group_id = obj.att.group; 
						group = getGroup(group_id);
					}
					
					//Make the thing
					var thing:FlxBasic = _loadThing(type,obj);
					
					if (thing != null) {

						if (group != null) {
							group.add(thing);
						}else {
							add(thing);			
						}		
						
						_loadPosition(obj, thing);	//Position the thing if possible						
						
						if (thing_id != "") {
							_asset_index.set(thing_id, thing);
						}
					}
				}
			}
			
			//if (_post_load != null) {
			if (data.x.firstElement() != null) {
				//Load the actual things
				var node:Xml;
				for (node in data.x.elements()) 
				{
				//for (data in _post_load) {
					_postLoadThing(node.nodeName.toLowerCase(), new Fast(node));					
				}
				//U.clearArraySoft(_post_load);
				//_post_load = null;
			}
			
			if (_failure_checks != null) {
				for (data in _failure_checks) {					
					if (_checkFailure(data)) {
						failed = true;
						break;
					}
				}
				U.clearArraySoft(_failure_checks);
				_failure_checks = null;
			}
		}
		
	}
	
	/**
	 * Set a mode for this UI. This lets you show/hide stuff basically. 
	 * @param	mode_id The mode you want, say, "empty" or "play" for a save slot
	 * @param	target_id UI element to target - "" for the UI itself, otherwise the id of an element that is itself a FlxUI
	 */
	
	public function setMode(mode_id:String,target_id:String=""):Void {
		var mode:Fast = getMode(mode_id);
		var id:String = "";
		var thing:FlxBasic;
		if(target_id == ""){			
			if (mode != null) {
				if (mode.hasNode.show) {
					for (show_node in mode.nodes.show) {
						id = show_node.att.id;
						thing = getAsset(id);
						if (thing != null) {
							thing.visible = true;
						}
					}
				}
				if (mode.hasNode.hide) {
					for (hide_node in mode.nodes.hide) {
						id = hide_node.att.id;
						thing = getAsset(id);
						if (thing != null) {
							thing.visible = false;
						}
					}
				}
			}
		}else {
			var target:FlxBasic = getAsset(target_id);
			if (target != null && Std.is(target, FlxUI)) {
				var targetUI:FlxUI = cast(target, FlxUI);
				targetUI.setMode(mode_id, "");
			}
		}
	}
	
	/******UTILITY FUNCTIONS**********/
	
	public function getGroup(key:String, recursive:Bool=true):FlxGroupX{
		var group:FlxGroupX = _group_index.get(key);
		if (group == null && recursive && _superIndexUI != null) {
			return _superIndexUI.getGroup(key, recursive);
		}
		return group;
	}
	
	public function getFlxText(key:String, recursive:Bool = true):FlxText {
		var asset:FlxBasic = getAsset(key, recursive);
		if (asset != null) {
			if (Std.is(asset, FlxText)) {
				return cast(asset, FlxText);
			}
		}
		return null;
	}
	
	public function getAsset(key:String, recursive:Bool=true):FlxBasic{
		var asset:FlxBasic = _asset_index.get(key);
		if (asset == null && recursive && _superIndexUI != null) {
			return _superIndexUI.getAsset(key, recursive);
		}
		return asset;
	}
	
	public function getMode(key:String, recursive:Bool = true):Fast {
		var mode:Fast = _mode_index.get(key);
		if (mode == null && recursive && _superIndexUI != null) {
			return _superIndexUI.getMode(key, recursive);
		}
		return mode;
	}
	
	public function getDefinition(key:String,recursive:Bool=true):Fast{
		var definition:Fast = _definition_index.get(key);
		if (definition == null && recursive && _superIndexUI != null) {
			return _superIndexUI.getDefinition(key, recursive);
		}
		return definition;
	}
	
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
		
	private var _group_index:Map<String,FlxGroupX>;
	private var _asset_index:Map<String,FlxBasic>;
	private var _definition_index:Map<String,Fast>;
	private var _mode_index:Map<String,Fast>;
	private var _ptr:IEventGetter;	

	private var _superIndexUI:FlxUI;
	private var _safe_input_delay_elapsed:Float = 0.0;
	
	//private var _post_load:Array<Fast>;// Map<String,Fast>;
	private var _failure_checks:Array<Fast>;
	
	/**
	 * Replace an object in whatever group it is in
	 * @param	original the original object
	 * @param	replace	the replacement object
	 * @param	splice if replace is null, whether to splice the entry
	 */

	 
	private function replaceInGroup(original:FlxBasic,replace:FlxBasic,splice:Bool=false){
		//Slow, unoptimized, searches through everything
		if(_group_index != null){
			for (key in _group_index.keys()) {
				var group:FlxGroupX = _group_index.get(key);
				if (group.members != null) {
					var i:Int = 0;
					for (member in group.members) {
						if (member == original) {
							group.members[i] = replace;
							if (replace == null) {
								if (splice) {
									group.members.splice(i, 1);
									i--;
								}
							}
							return;
						}
						i++;
					}
				}
			}
		}
		
		//if we get here, it's not in any group, it's just in our global member list
		if (this.members != null) {
			var i:Int = 0;
			for (member in this.members) {				
				if (member == original) {
					members[i] = replace;
					if (replace == null) {
						if (splice) {
							members.splice(i, 1);
							i--;
						}
					}
					return;
				}
				i++;
			}
		}
	}
	
	/************LOADING FUNCTIONS**************/
	
	private function _loadThing(type:String, data:Fast):Dynamic {
		var use_def:String = U.xml_str(data.x, "use_def", true);		
		var definition:Fast = null;
		if (use_def != "") {
			definition = getDefinition(use_def);
		}
		switch(type) {
			case "chrome", "9slicesprite": return _load9SliceSprite(data, definition);
			case "tile_test": return _loadTileTest(data, definition);
			case "sprite": return _loadSprite(data,definition);
			case "text": return _loadText(data,definition);
			case "button": return _loadButton(data, definition);
			case "button_toggle": return _loadButtonToggle(data, definition);
			case "tab_menu": return _loadTabMenu(data, definition);
			case "checkbox": return _loadCheckBox(data, definition);
			case "radio_group": return _loadRadioGroup(data, definition);
			case "layout", "ui": return _loadLayout(data, definition);
			case "failure": if (_failure_checks == null) { _failure_checks = new Array<Fast>(); }
							_failure_checks.push(data);
							return null;
			default: 
				//If I don't know how to load this thing, I will request it from my pointer:			
				var dataObject = { data:data, definition:definition };
				var result = _ptr.getRequest("ui_get:" + type, this, dataObject);
				return result;
		}
		return null;
	}
	
	private function _checkFailure(data:Fast):Bool{
		var target:String = U.xml_str(data.x, "target", true);
		var property:String = U.xml_str(data.x, "property", true);
		var compare:String = U.xml_str(data.x, "compare", true);
		var value:String = U.xml_str(data.x, "value", true);
		
		var thing:FlxBasic = getAsset(target);
		
		if (thing == null) {
			return false;
		}
		
		var fo:FlxObject = null;
		
		if (Std.is(thing, FlxObject) == false) {
			return false;
		}else {
			fo = cast thing;
		}
		
		var prop_f:Float = 0;
		var val_f:Float = 0;
				
		var p: { percent:Float, error:Bool } = U.perc_to_float(value);
		
		if (p.error) {
			if (U.isStrNum(value)) {
				val_f = Std.parseFloat(value);
			}else {
				return false;
			}
		}
		
		switch(property) {
			case "w", "width": prop_f = fo.width; 
							   if (!p.error) { val_f = p.percent * thisWidth(); }
							   
			case "h", "height": prop_f = fo.height; 
							   if (!p.error) { val_f = p.percent * thisHeight();}
		}
		
		switch(compare) {
			case "<": if (prop_f < val_f) {
						failed_by = val_f - prop_f;
						return true;
					  }
			case ">": if (prop_f > val_f) {
						failed_by = prop_f - val_f;
						return true;
					  }
			case "=", "==": if (prop_f == val_f) {
						failed_by = Math.abs(prop_f - val_f);
						return true;
					  }
			case "<=": if (prop_f <= val_f) {
						failed_by = val_f - prop_f;
						return true;
					  }
			case ">=": if (prop_f >= val_f) {
						failed_by = prop_f - val_f;
						return true;
					  }
		}
		
		return false;
	}
	
	private function _postLoadThing(type:String, data:Fast):Void{
		var id:String = U.xml_str(data.x, "id", true);
		var fb:FlxBasic = getAsset(id);
		if (fb == null) {
			return;
		}
		
		if (id == "options") {
			trace("BOINK");
		}
		
		var use_def:String = U.xml_str(data.x, "use_def", true);		
		var definition:Fast = null;
		if (use_def != "") {
			definition = getDefinition(use_def);
		}		
		
		if (Std.is(fb, IResizable)) {
			var wh: { width:Float, height:Float } = calcMinSize(data);				
			var fo_r:IResizable = cast fb;
			if(wh.width != 0 && wh.height != 0){
				fo_r.resize(wh.width, wh.height);
			}
		}				
		
		var fbx:Float=0;
		var fby:Float=0;
				
		if (Std.is(fb, FlxObject)) {
			var fo:FlxObject = cast fb;
			fbx = fo.x; fby = fo.y;
		}else if (Std.is(fb, FlxGroupX)) {
			var fg:FlxGroupX = cast fb;
			fbx = fg.x; fby = fg.y;
		}else if (Std.is(fb, FlxButtonPlusX)) {
			var fp:FlxButtonPlusX = cast fb;
			fbx = fp.x; fby = fp.y;
		}
		
		//_delta(fb, -fbx, -fby);			//reset position to 0,0
		//_loadPosition(data,fb);				//reposition
	}
	
	private function _loadTileTest(data:Fast, definition:Fast = null):FlxTileTest {
		var the_data:Fast = data;
		if (definition != null) { the_data = definition; }
		
		var tiles_w:Int = U.xml_i(data.x, "tiles_w", 2);
		var tiles_h:Int = U.xml_i(data.x, "tiles_h", 2);
		var w:Float = U.xml_f(data.x, "width");
		var h:Float = U.xml_f(data.x, "height");
		
		var wh:{width:Float, height:Float} = calcMinSize(data,w,h);
		
		var tileWidth:Int = Std.int(wh.width/tiles_w);
		var tileHeight:Int = Std.int(wh.height/tiles_h);
		
		if (tileWidth < tileHeight) { tileHeight = tileWidth; }
		else if (tileHeight < tileWidth) { tileWidth = tileHeight; }
		
		if (tileWidth < 2) { tileWidth = 2; }
		if (tileHeight < 2) { tileHeight = 2; }
		
		var ftt:FlxTileTest = new FlxTileTest(0, 0, tileWidth, tileHeight, tiles_w, tiles_h);
		return ftt;
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
	
	private function _loadRadioGroup(data:Fast, definition:Fast = null):FlxRadioGroup {
		var frg:FlxRadioGroup = null;
		
		var default_data:Fast = data;
		if (definition != null) { default_data = definition; }
		
		var dot_src:String = U.xml_str(default_data.x, "dot_src", true);
		var radio_src:String = U.xml_str(default_data.x, "radio_src", true);
		var radio_over_src:String = U.xml_str(default_data.x, "radio_over_src", true);
		
		var labels:Array<String> = new Array<String>();
		var ids:Array<String> = new Array<String>();
		
		for (radioNode in data.nodes.radio) {
			var id:String = U.xml_str(radioNode.x, "id", true);
			var label:String = U.xml_str(radioNode.x, "label");
			ids.push(id);
			labels.push(label);
		}
		
		var y_space:Float = U.xml_f(data.x, "y_space", 25);
		
		var params:Array<Dynamic> = getParams(data);
		
		var up_sprite:FlxSprite = U.fs(U.gfx(radio_src));		
		
		var over_sprite:FlxSprite;
		if (radio_over_src != "") {
			over_sprite = U.fs(U.gfx(radio_over_src));
		}else {
			over_sprite = up_sprite;
		}
		
		var dot_sprite:FlxSprite;
		if (dot_src != "") {
			dot_sprite = U.fs(U.gfx(dot_src));
		}else {
			dot_sprite = new FlxSprite(0, 0);
			dot_sprite.makeGraphic(4, 4, 0x000000); //4x4 black square by default
		}
		
		frg = new FlxRadioGroup(0, 0, ids, labels, _onClickRadioGroup, y_space);
						
		if (up_sprite != null) {
			frg.loadGraphics(up_sprite, dot_sprite, over_sprite);
		}
		
		var text_x:Int = U.xml_i(default_data.x, "text_x");
		var text_y:Int = U.xml_i(default_data.x, "text_y");		
		
		for (fo in frg.members) {
			if (Std.is(fo, FlxCheckBox)){
				var fc:FlxCheckBox = cast(fo, FlxCheckBox);
				formatButtonText(default_data, fc);
				fc.textX = fc.textX + text_x;				
				fc.textY = fc.textY + text_y;	
			}
		}
						
		return frg;
	}
	
	private function _loadCheckBox(data:Fast, definition:Fast = null):FlxCheckBox {
		var src:String = "";
		var fc:FlxCheckBox = null;
		
		var default_data:Fast = data;
		if (definition != null) { default_data = definition; }
		
		var label:String = U.xml_str(data.x, "label");
		var W:Int = U.xml_i(default_data.x, "width", 100);
		var H:Int = U.xml_i(default_data.x, "height", 32);
		var check_src:String = U.xml_str(default_data.x, "check_src", true);
		var box_src:String = U.xml_str(default_data.x, "box_src", true);
		var box_over_src:String = U.xml_str(default_data.x, "box_over_src", true);
		
		var params:Array<Dynamic> = getParams(data);
		
		var up_sprite:FlxSprite = U.fs(U.gfx(box_src));		
		
		var over_sprite:FlxSprite;
		if (box_over_src != "") {
			over_sprite = U.fs(U.gfx(box_over_src));
		}else {
			over_sprite = up_sprite;
		}
		
		fc = new FlxCheckBox(0, 0, _onClickCheckBox, params, label, W, H);
						
		if (up_sprite != null) {
			fc.loadGraphic(up_sprite, over_sprite);
		}
		
		var check_sprite:FlxSprite = U.fs(U.gfx(check_src));
		fc.loadCheckGraphic(check_sprite);
		
		formatButtonText(default_data, fc);
		var text_x:Int = U.xml_i(default_data.x, "text_x");
		var text_y:Int = U.xml_i(default_data.x, "text_y");		
		
		fc.textX = fc.textX + text_x;				
		fc.textY = fc.textY + text_y;		
						
		return fc;
	}
	
	private function _loadLayout(data:Fast, definition:Fast = null):FlxUI{
		var default_data:Fast = data;
		if (definition != null) { default_data = definition;}
				
		var id:String = U.xml_str(data.x, "id", true);
		var _ui:FlxUI = new FlxUI(data, this, this);
		_ui.str_id = id;
		
		return _ui;
	}
	
	private function _loadTabMenu(data:Fast, definition:Fast = null):FlxTabMenu{
		var default_data:Fast = data;
		if (definition != null) { default_data = definition;}
		
		var back_def_str:String = U.xml_str(default_data.x, "back_def");
		var back_def:Fast = getDefinition(back_def_str);
		if (back_def == null) {
			back_def = default_data;
		}
		
		var back:Flx9SliceSprite = _load9SliceSprite(data, back_def);
		
		var tab_def:Fast = null;
			
		if (default_data.hasNode.tab) {
			var tab_def_str:String = U.xml_str(default_data.node.tab.x, "use_def");
			if (tab_def_str != "") {
				tab_def = getDefinition(tab_def_str);
			}else {
				tab_def = default_data.node.tab;
			}
		}
		
		var list_tabs:Array<FlxButtonToggle> = new Array<FlxButtonToggle>();
		
		var id:String = "";
		
		if (data.hasNode.tab) {
			for (tab_node in data.nodes.tab) {
				id = U.xml_str(tab_node.x, "id", true);
				var label:String = U.xml_str(tab_node.x, "label");
				var tab:FlxButtonToggle = _loadButtonToggle(tab_node, tab_def);
				list_tabs.push(tab);
			}			
		}
		
		var fg:FlxTabMenu = new FlxTabMenu(back,list_tabs);		
		
		if (data.hasNode.group) {
			for (group_node in data.nodes.group) {
				id = U.xml_str(group_node.x, "id", true);
				var _ui:FlxUI = new FlxUI(group_node, fg, this);
				_ui.str_id = id;
				fg.addGroup(_ui);				
			}
		}		
		
		fg.showTabInt(0);
		
		return fg;
	}
	
	private function _loadButtonToggle(data:Fast, definition:Fast = null):FlxButtonToggle {
	
		var default_data:Fast = data;
		if (definition != null) { default_data = definition;}
		
		var label:String = U.xml_str(data.x, "label");		
		var W:Int = U.xml_i(default_data.x, "width");
		var H:Int = U.xml_i(default_data.x, "height");	
		var id:String = U.xml_str(data.x, "id",true);
		var params:Array<Dynamic> = getParams(data);
		if (id != "") { 
			if (params == null) { 
				params = []; 
			}
			params.push(id);
		}
		
		var btn_def_normal:Fast = null;
		var btn_def_toggle:Fast = null;
		if (default_data.hasNode.normal) {
			btn_def_normal = default_data.node.normal;			
		}
		if (default_data.hasNode.toggle) {
			btn_def_toggle = default_data.node.toggle;
		}
		if (btn_def_toggle == null) { btn_def_toggle = btn_def_normal; }
		if (btn_def_normal == null) { throw "ERROR! FlxUI._loadButtonToggle() - no definition specified for normal button state!"; }
		
		var btn_normal:FlxButtonPlusX = _loadButton(data, btn_def_normal,false);
		var btn_toggle:FlxButtonPlusX = _loadButton(data, btn_def_toggle,false);
		
		var fbt:FlxButtonToggle = new FlxButtonToggle(0, 0, _onClickButtonToggle, params, btn_normal, btn_toggle, id);
		
		return fbt;
	}
	
	private function _loadButton(data:Fast,definition:Fast=null,setCallback:Bool=true):FlxButtonPlusX {
		var src:String = ""; 
		var fb:FlxButtonPlusX = null;
		
		
		var default_data:Fast = data;
		if (definition != null) { default_data = definition;}
				
		var label:String = U.xml_str(data.x, "label");
		var W:Int = U.xml_i(default_data.x, "width");
		var H:Int = U.xml_i(default_data.x, "height");	
		var vis_str:String = U.xml_str(data.x, "visible", true);
		var isVis:Bool = U.xml_bool(data.x, "visible", true);		
		
		
		var params:Array<Dynamic> = getParams(data);
		
		if(setCallback){
			fb = new FlxButtonPlusX(0, 0, _onClickButton, params, label, W, H);
		}else {
			fb = new FlxButtonPlusX(0, 0, null, null, label, W, H);
		}
		fb.visible = isVis;
				
		formatButtonText(default_data, fb);
				
		var text_x:Int = 0;
		var text_y:Int = 0;
		if (data.x.get("text_x") != null) {
			text_x = U.xml_i(data.x, "text_x");			
		}else {
			text_x = U.xml_i(default_data.x, "text_x");
		}
			
		if (data.x.get("text_y") != null) {
			text_y = U.xml_i(data.x, "text_y");			
		}else {
			text_y = U.xml_i(default_data.x, "text_y");
		}
			
			
		fb.textY = Std.int((fb.height - fb.textNormal.frameHeight) / 2) + text_y;
		fb.textX = text_x;
				
		if (default_data.hasNode.graphic) {
			var up_graphic:String = "";
			var over_graphic:String = "";
			var up_slice9:String = "";
			var over_slice9:String = "";
			var up_rect:String = "";
			var over_rect:String = "";
			for (graphicNode in default_data.nodes.graphic) {
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
		
		if (default_data.hasNode.color) {
			#if flash
				var arrayActive:Array<Int> = new Array<Int>();
				var arrayInactive:Array<Int> = new Array<Int>();
			#else
				var arrayActive:Array<Int> = new Array<Int>();
				var arrayInactive:Array<Int> = new Array<Int>();
			#end
			var borderColor:Int = 0xffffffff;
			for (colorNode in default_data.nodes.color) {
				var color_id:String = U.xml_str(colorNode.x, "id", true);
				var color:Int = cast(_loadColor(colorNode), Int);
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
		/*
		*/
		
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
		
		var min_size: { width:Float, height:Float }= calcMinSize(data);
		
		src = U.xml_gfx(the_data.x, "src");
				
		var rc:Rectangle;
		var slice9:String = "";
		var rect_w:Int = U.xml_i(data.x, "width");
		var rect_h:Int = U.xml_i(data.x, "height");
		
		if (rect_w < min_size.width) { rect_w = cast min_size.width; }
		if (rect_h < min_size.height) { rect_h = cast min_size.height; }
		
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
	
	private function thisWidth():Int {
		//if (_ptr == null || Std.is(_ptr, FlxUI) == false) {
			return FlxG.width;
		/*}
		var ptrUI:FlxUI = cast _ptr;
		return Std.int(ptrUI.width);*/
	}
	
	private function thisHeight():Int {
		//if (_ptr == null || Std.is(_ptr, FlxUI) == false) {
			return FlxG.height;
		/*}
		var ptrUI:FlxUI = cast _ptr;
		return Std.int(ptrUI.height);*/
	}
		
	private function _getAnchorPos(thing:FlxBasic, axis:String, str:String):Float {
		switch(str) {
			case "": return 0;
			case "left": return 0;
			case "right": return thisWidth();
			case "top", "up": return 0;
			case "bottom", "down": return thisHeight();
			default:
				var perc: { percent:Float, error:Bool } = U.perc_to_float(str);
				if (!perc.error) {
					if (axis == "x") {
						return perc.percent * thisWidth();
					}else if (axis == "y") {
						return perc.percent * thisHeight();
					}
				}else {
					var r:EReg = ~/[\w]+\.[\w]+/;
					var property:String = "";
					if (r.match(str)) {
						var p: { pos:Int, len:Int }= r.matchedPos();
						if (p.pos == 0 && p.len == str.length) {
							var arr:Array<String> = str.split(".");
							str = arr[0];
							property = arr[1];
						}
					}
					
					var otherb:FlxBasic = getAsset(str);
					var other:FlxObject;
					var otherx:Float;
					var othery:Float;
					var otherw:Float;
					var otherh:Float;
					if (Std.is(otherb, FlxObject)) {
						other = cast otherb;
						otherx = other.x;		othery = other.y;
						otherw = other.width;	otherh = other.height;
					}else if (Std.is(otherb, FlxButtonPlusX)) {
						var fbx:FlxButtonPlusX = cast otherb;
						otherx = fbx.x;		othery = fbx.y;
						otherw = fbx.width; otherh = fbx.height;
					}else if (Std.is(otherb, FlxGroupX)) {
						var fgx:FlxGroupX = cast otherb;
						otherx = fgx.x;		othery = fgx.y;
						otherw = fgx.width; otherh = fgx.height;
					}else {
						return 0;
					}
					
					if (thing != null) {
						if (axis == "x") { 
							switch(property) {
								case "left": return otherx;
								case "right": return otherx + otherw;
								case "center": return otherx + otherw / 2;
								default:return otherx; 
							}
						}
						else if (axis == "y") { 
							switch(property) {
								case "top": return othery;
								case "bottom": return othery + otherh;
								case "center": return othery + otherh / 2;
								default:return othery;
							}
						}
					}
				}
		}
		return 0;
	}
	
	private function calcMinSize(data:Fast,width:Dynamic=null,height:Dynamic=null):{width:Float,height:Float}{
		var min_w:Float = 0;
		var min_h:Float = 0;
		var temp_w:Float = 0;
		var temp_h:Float = 0;
		if (data.hasNode.min_size) {
			for(minNode in data.nodes.min_size){
				var min_w_str:String = U.xml_str(minNode.x, "width");
				var min_h_str:String = U.xml_str(minNode.x, "height");
				temp_w = _getMinSize("w", min_w_str, data);
				temp_h = _getMinSize("h", min_h_str, data);			
				if (temp_w > min_w) {
					min_w = temp_w;
				}
				if (temp_h > min_h) {
					min_h = temp_h;
				}
			}
		}
		if (width != null){
			if (width >= min_w) { min_w = width; }			
		}
		if (height != null) {
			if (height >= min_h) { min_h = height; }
		}
		return { width:min_w, height:min_h };
	}
	
	private function _getMinSize(target:String, str:String,data:Fast=null):Float {
		var result: { percent:Float, error:Bool } = U.perc_to_float(str);
		var percf:Float = result.percent;
		if(!result.error){
			switch(target) {
				case "w", "width":	return thisWidth() * percf;
					
				case "h", "height": return thisHeight() * percf;
			}
		}else {
			if (str.indexOf("stretch:") == 0) {
				str = StringTools.replace(str, "stretch:", "");
				var arr:Array<String> = str.split(",");
				var stretch_0:Float = _getStretch(0, target, arr[0],data);
				var stretch_1:Float = _getStretch(1, target, arr[1], data);
				if(stretch_0 != -1 && stretch_1 != -1){
					return stretch_1 - stretch_0;
				}else {
					return -1;
				}
			}else if(U.isStrNum(str)){
				return Std.parseFloat(str);
			}
		}
		return 0;
	}
	
	private function _addPostLoad(fast:Fast):Void {
		/*if (_post_load == null) { 
			_post_load = new Array<Fast>();
		}
		if(!U.arrayContains(_post_load,fast)){
			_post_load.push(fast);
		}*/
	}
	
	private function _getStretch(index:Int,target:String, str:String,data:Fast=null):Float {
		var flxb:FlxBasic = getAsset(str);		
		var other:FlxObject = null;
		if (Std.is(flxb, FlxObject)) {
			other = cast flxb;
		}
		if (other == null) {			
			switch(str) {
				case "top", "up": return 0;
				case "bottom", "down": return thisHeight();
				case "left": return 0;
				case "right": return thisWidth();
				default:
					if (U.isStrNum(str)) {
						return Std.parseFloat(str);
					}else {
						//_addPostLoad(data);
						return -1;
					}
			}
		}else {
			switch(target) {
				case "w", "width": 
					if (index == 0) { return other.x + other.width; }
					if (index == 1) { return other.x;}
				case "h", "height":
					if (index == 0) { return other.y + other.height; }
					if (index == 1) { return other.y;}
			}
		}
		return 0;
	}
	
	private function _loadPosition(data:Fast, thing:Dynamic):Void {
		var X:Float = U.xml_f(data.x, "x");				//position offset from 0,0
		var Y:Float = U.xml_f(data.x, "y");
		var ctrX:Bool = U.xml_bool(data.x, "center_x");	//if true, centers on the screen
		var ctrY:Bool = U.xml_bool(data.x, "center_y");
				
		var center_on:String = U.xml_str(data.x, "center_on");
		var center_on_x:String = U.xml_str(data.x, "center_on_x");
		var center_on_y:String = U.xml_str(data.x, "center_on_y");
		
		var anchor_x_str:String = "";
		var anchor_y_str:String = "";
		var anchor_x:Float = 0;
		var anchor_y:Float = 0;
		var anchor_x_flush:String = "";
		var anchor_y_flush:String = "";
		
		if (data.hasNode.anchor) {
			anchor_x_str = U.xml_str(data.node.anchor.x, "x");
			anchor_y_str = U.xml_str(data.node.anchor.x, "y");
			anchor_x = _getAnchorPos(thing, "x", anchor_x_str);
			anchor_y = _getAnchorPos(thing, "y", anchor_y_str);
			anchor_x_flush = U.xml_str(data.node.anchor.x,"x-flush",true);
			anchor_y_flush = U.xml_str(data.node.anchor.x, "y-flush", true);						
		}
				
		//Flush it to the anchored coordinate
		if (anchor_x_str != "" || anchor_y_str != "") {
			switch(anchor_x_flush) {
				case "left":	//do-nothing		 					//flush left side to anchor
				case "right":	anchor_x = anchor_x - thing.width;	 	//flush right side to anchor
				case "center":  anchor_x = anchor_x - thing.width / 2;	//center on anchor point
			}
			switch(anchor_y_flush) {
				case "up", "top": //do-nothing
				case "down", "bottom": anchor_y = anchor_y - thing.height;
				case "center": anchor_y = anchor_y - thing.height / 2;
			}
			
			_delta(thing, anchor_x, anchor_y);
		}
		
		//Try to center the object on the screen:
		if (ctrX || ctrY) {
			_center(thing,ctrX,ctrY);
		}
				
		//Then, try to center it on another object:
		if (center_on != "") {
			var other:FlxBasic = getAsset(center_on);
			if (other != null && Std.is(other, FlxBasic)) {
				U.center(cast(other, FlxObject), cast(thing, FlxObject));
			}
		}else {
			if (center_on_x != "") {
				var other:FlxBasic = getAsset(center_on);
				if (other != null && Std.is(other, FlxBasic)) {
					U.center(cast(other, FlxObject), cast(thing, FlxObject), true, false);
				}
			}
			if (center_on_y != "") {
				var other:FlxBasic = getAsset(center_on);
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
	
	private function _onClickRadioGroup(params:Dynamic = null):Void {
		FlxG.log("FlxUI._onClickRadioGroup(" + params + ")");
		if (_ptr != null) {
			_ptr.getEvent("click_radio_group", this, params);
		}	
	}
	
	private function _onClickCheckBox(params:Dynamic = null):Void {
		FlxG.log("FlxUI._onClickCheckBox(" + params + ")");
		if (_ptr != null) {
			_ptr.getEvent("click_checkbox", this, params);
		}		
	}
	
	private function _onClickButton(params:Dynamic = null):Void {
		FlxG.log("FlxUI._onClickButton(" + params + ")");
		if (_ptr != null) {
			_ptr.getEvent("click_button", this, params);
		}
	}
	
	private function _onClickButtonToggle(params:Dynamic = null):Void {
		FlxG.log("FlxUI._onClickButtonToggle(" + params + ")");
		if (_ptr != null) {
			_ptr.getEvent("click_button_toggle", this, params);
		}
	}
	
	/**********UTILITY FUNCTIONS************/
	
	/**
	 * Parses params out of xml and loads them in the correct type
	 * @param	data
	 */
	
	private static inline function getParams(data:Fast):Array<Dynamic>{
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
		return params;
	}	
	
	private function formatButtonText(data:Fast, fb:FlxButtonPlusX):Void {
		if (data != null && data.hasNode.text) {
			for (textNode in data.nodes.text) {
				var use_def:String = U.xml_str(textNode.x, "use_def", true);
				var text_def:Fast = textNode;
				if (use_def != "") {
					text_def = getDefinition(use_def);
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
				
				var fbt:FlxTextX = fb.textNormalX;
				var fbth:FlxTextX = fb.textHighlightX;
				
				switch(case_id) {
					case "inactive", "", "normal": 
						fbt.setFormat(the_font, size, color, align, shadow);
						fbt.dropShadow = true;
					case "active", "hilight", "over", "hover": 
						fbth.setFormat(the_font, size, color, align, shadow);
						fbth.dropShadow = true;
				}
								
				fb.textHighlight.visible = false;
				fb.textNormal.visible = true;
			}
		}
	}
}