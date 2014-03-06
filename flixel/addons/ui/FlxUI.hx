package flixel.addons.ui;

import flash.display.BitmapData;
import flash.errors.Error;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.addons.ui.FlxUI.MaxMinSize;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.interfaces.IEventGetter;
import flixel.addons.ui.interfaces.IFireTongue;
import flixel.addons.ui.interfaces.IFlxUIButton;
import flixel.addons.ui.interfaces.IFlxUIState;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.interfaces.ILabeled;
import flixel.addons.ui.interfaces.IResizable;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxPoint;
import flixel.util.FlxStringUtil;
import haxe.xml.Fast;
import openfl.Assets;

/**
 * A simple xml-driven user interface
 * 
 * Usage example:
 *	_ui = new FlxUI(U.xml("save_slot"),this);
 *	add(_ui);
 * 
 * @author Lars Doucet
 */
class FlxUI extends FlxUIGroup implements IEventGetter
{	
	
	//If this is true, the first few frames after initialization ignore all input so you can't auto-click anything
	public var do_safe_input_delay:Bool = true;
	public var safe_input_delay_time:Float = 0.01;
	
	public var failed:Bool = false;
	public var failed_by:Float = 0;
	
	public var tongue(get, set):IFireTongue;
	public function get_tongue():IFireTongue { return _ptr_tongue; }
	public function set_tongue(t:IFireTongue):IFireTongue 
	{
		_ptr_tongue = t;
		_tongueSet(members, t);
		return _ptr_tongue;
	}
	
	public var focus(default, set):IFlxUIWidget;	//set focused object
	public function set_focus(widget:IFlxUIWidget):IFlxUIWidget {
		if (focus != null) {
			onFocusLost(focus);
		}
		focus = widget;
		if (focus != null) {
			onFocus(focus);
		}
		return widget;
	}
	
	//Set this 
	public var getTextFallback:String->String->Bool->String = null;
	
	private var _ptr_tongue:IFireTongue;
	private var _data:Fast;
	
	/**
	 * Make sure to recursively propogate the tongue pointer down to all my members
	 */
	private function _tongueSet(list:Array<FlxSprite>, tongue:IFireTongue):Void 
	{		
		for (fs in list) {
			if (Std.is(fs, FlxUIGroup)) {
				var g:FlxUIGroup = cast(fs, FlxUIGroup);
				_tongueSet(g.members, tongue);
			}else if (Std.is(fs, FlxUI)) {
				var fu:FlxUI = cast(fs, FlxUI);
				fu.tongue = tongue;
			}
		}
	}
	
	/***EVENT HANDLING***/
	
	/**
	 * Broadcasts an event to the current FlxUIState/FlxUISubState
	 * @param	name	string identifier of the event -- each IFlxUIWidget has a set of string constants
	 * @param	sender	the IFlxUIWidget that sent this event
	 * @param	data	non-array data (boolean for a checkbox, string for a radiogroup, etc)
	 * @param	?params	(optional) user-specified array of arbitrary data
	 */
	
	public static function event(name:String, sender:IFlxUIWidget, data:Dynamic, ?params:Array<Dynamic>):Void {
		var currState:IEventGetter = getLeafUIState();
		
		if (currState != null) {
			currState.getEvent(name, sender, data, params);
		}else {
			FlxG.log.notice("could not call getEvent() for FlxUI event \""+name+"\" because current state is not a FlxUIState.\nSolution: state should extend FlxUIState, implement IEventGetter. Otherwise, set broadcastToFlxUI=false for your IFlxUIWidget to supress the events.");
		}
	}
	
	/**
	 * Static-level function used to force giving a certain widget focus (useful for e.g. enforcing overlap logic)
	 * @param	b
	 * @param	thing
	 */
	public static function forceFocus(b:Bool, thing:IFlxUIWidget):Void 
	{
		var currState:IFlxUIState = getLeafUIState();
		if (currState != null) {
			currState.forceFocus(b, thing);				//this will try to drill down to currState._ui.onForceFocus()
		}
	}
	
	/**
	 * Drill down to the current state or sub-state, and ensure it is an IFlxUIState (FlxUIState or FlxUISubState)
	 * @return
	 */
	
	private static function getLeafUIState():IFlxUIState{
		var state:FlxState = FlxG.state;
		if (state != null) 
		{
			while (state.subState != null) 
			{
				state = state.subState;
			}
		}
		if (Std.is(state, IFlxUIState)) 
		{
			return cast state;
		}
		return null;
	}
	
	/**
	 * Broadcasts an event to the current FlxUIState/FlxUISubState, and expects data in return
	 * @param	name	string identifier of the event -- each IFlxUIWidget has a set of string constants
	 * @param	sender	the IFlxUIWidget that sent this event
	 * @param	data	non-array data (boolean for a checkbox, string for a radiogroup, etc)
	 * @param	?params	(optional) user-specified array of arbitrary data
	 * @return	some sort of arbitrary data from the recipient
	 */
	
	public static function request(name:String, sender:IFlxUIWidget, data:Dynamic, ?params:Array<Dynamic>):Dynamic {
		var currState:IEventGetter = getLeafUIState();
		if (currState != null) {
			return currState.getRequest(name, sender, data, params);
		}else {
			FlxG.log.error("Warning, FlxUI event not handled, IFlxUIWidgets need to exist within an IFlxUIState");
		}
		return null;
	}
	
	public function callEvent(id:String, sender:IFlxUIWidget, data:Dynamic, ?params:Array<Dynamic>):Void {
		getEvent(id, sender, data, params);
	}
	
	public function getEvent(id:String, sender:IFlxUIWidget, data:Dynamic, ?params:Array<Dynamic>):Void {
		if (_ptr != null) {
			_ptr.getEvent(id, sender, data, params);
		}
	}
	
	public function getRequest(id:String, sender:IFlxUIWidget, data:Dynamic, ?params:Array<Dynamic>):Dynamic {
		if (_ptr != null) {
			return _ptr.getRequest(id, sender, data, params);
		}
		return null;
	}
		
	/***PUBLIC FUNCTIONS***/
		
	public function new(data:Fast=null,ptr:IEventGetter=null,superIndex_:FlxUI=null,tongue_:IFireTongue=null) 
	{
		super();
		_ptr_tongue = tongue_;	//set the localization data structure, if any.
								//we set this directly b/c no children have been created yet
								//when children FlxUI elements are added, this pointer is passed down
								//on destroy(), it is recurvisely removed from all of them
		_ptr = ptr;
		if (superIndex_ != null) {
			setSuperIndex(superIndex_);
		}
		if(data != null){
			load(data);
		}
	}
	
	public function onFocus(widget:IFlxUIWidget):Void {
		if (Std.is(widget, FlxUIDropDownMenu)) {
			//when drop down menu has focus, every other button needs to skip updating
			for (asset in members){
				setWidgetSuppression(asset,widget);
			}
		}
	}
	
	private function setWidgetSuppression(asset:FlxSprite,butNotThisOne:IFlxUIWidget,suppressed:Bool=true):Void {
		if (Std.is(asset, IFlxUIButton)) {
			var skip:Bool = false;
			if (Std.is(asset, FlxUIDropDownMenu)) {
				var ddasset:FlxUIDropDownMenu = cast asset;
				if (ddasset == butNotThisOne) {
					skip = true;
				}
			}
			if(!skip){
				var ibtn:IFlxUIButton = cast asset;
				ibtn.skipButtonUpdate = suppressed;			//skip button updates until further notice
			}
		}else if (Std.is(asset, FlxUIGroup)) {
			var g:FlxUIGroup = cast asset;
			for (groupAsset in g.members) {
				setWidgetSuppression(groupAsset,butNotThisOne,suppressed);
			}
		}
	}
	
	/**
	 * This causes FlxUI to respond to a specific widget losing focus
	 * @param	widget
	 */
	
	public function onFocusLost(widget:IFlxUIWidget):Void {
		if (Std.is(widget, FlxUIDropDownMenu)) {
			//Right now, all this does is toggle button updating on and off for 
			
			//when drop down menu loses focus, every other button can resume updating
			for (asset in members) {
				setWidgetSuppression(asset, null, false);	//allow button updates again
			}
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
	
	public function removeAsset(key:String, destroy:Bool=true):IFlxUIWidget{
		var asset = getAsset(key, false);
		if (asset != null) {
			replaceInGroup(cast asset, null, true);
			_asset_index.remove(key);
		}
		if (destroy) {
			asset.destroy();
			asset = null;
		}
		return asset;
	}
	
	/**
	 * Adds an asset to this UI, and optionally puts it in a group
	 * @param	asset	the IFlxUIWidget asset you want to add
	 * @param	key		unique key for this asset. If it already exists, this fails.
	 * @param	group_id string id of group inside this FlxUI you want to add it to.
	 * @param	recursive whether to recursively search through sub-ui's
	 */
	
	public function addAsset(asset:IFlxUIWidget, key:String, group_id:String = "", recursive:Bool=false):Bool{
		if (_asset_index.exists(key)) {
			return false;
		}

		var g:FlxUIGroup = getGroup(group_id,recursive);
		if (g != null) {
			g.add(cast asset);
		}else {
			add(cast asset);
		}
		
		_asset_index.set(key, asset);
		
		/*if (Std.is(asset, FlxUIDropDownMenu)) {
			var dd:FlxUIDropDownMenu = cast asset;
			dd.setUIControlCallback(_onClickDropDown_control);
		}*/
		return true;
	}
	
	/**
	 * Replaces an asset, both in terms of location & group position
	 * @param	key the string id of the original
	 * @param	replace the replacement object
	 * @param 	destroy_old kills the original if true
	 * @return	the old asset, or null if destroy_old=true
	 */
	
	public function replaceAsset(key:String, replace:IFlxUIWidget, center_x:Bool=true, center_y:Bool=true, destroy_old:Bool=true):IFlxUIWidget{
		//get original asset
		var original = getAsset(key, false);
		
		if(original != null){
			//set replacement in its location
			if (!center_x) {
				replace.x = original.x;
			}else {
				replace.x = original.x + (original.width - replace.width) / 2;
			}
			if (!center_y) {
				replace.y = original.y;
			}else {
				replace.y = original.y + (original.height - replace.width) / 2;
			}
			
			//switch original for replacement in whatever group it was in
			replaceInGroup(cast original, cast replace);
			
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
		if (_definition_index != null) {
			for (key in _definition_index.keys()) {
				_definition_index.remove(key);
			}_definition_index = null;
		}
		_superIndexUI = null;
		_ptr_tongue = null;
		super.destroy();
	}
	
	/**
	 * Main setup function - pass in a Fast(xml) object 
	 * to set up your FlxUI
	 * @param	data
	 */
	
	public function load(data:Fast):Void {
		
		_group_index = new Map<String,FlxUIGroup>();
		_asset_index = new Map<String,IFlxUIWidget>();
		_definition_index = new Map<String,Fast>();
		_mode_index = new Map<String,Fast>();
		
		
		if (data != null) {
			
			_data = data;
			
			
			//See if there's anything to include
			if (data.hasNode.include) {
				for (inc_data in data.nodes.include) {
					var inc_id:String = inc_data.att.id;
					var inc_xml:Fast = U.xml(inc_id);
					if(inc_xml != null){
						for (def_data in inc_xml.nodes.definition) {
							//add a prefix to avoid collisions:
							var def_id:String = "include:"+def_data.att.id;
							_definition_index.set(def_id, def_data);
							
							//DON'T recursively search for further includes. 
							//Search 1 level deep only!
							//Ignore everything else in the include file
						}
					}
				}
			}
			
			
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
					var mode_data2:Fast = applyNodeConditionals(mode_data);
					var mode_id:String = mode_data.att.id;
					//mode_data
					_mode_index.set(mode_id, mode_data2);
				}
			}
		
			//Then, load all our group definitions
			if(data.hasNode.group){
				for (group_data in data.nodes.group) {
					
					//Create FlxUIGroup's for each group we define
					var id:String = group_data.att.id;
					var group:FlxUIGroup = new FlxUIGroup();
					group.id = id;
					_group_index.set(id, group);
					add(group);
					
					FlxG.log.add("Creating group (" + id + ")");
				}
			}
			
			
			#if debug
				//Useful debugging info, make sure things go in the right group:
				FlxG.log.add("Member list...");
				for (fb in members) {
					if(fb != null){
						if (Std.is(fb, FlxUIGroup)) {
							var g:FlxUIGroup = cast(fb, FlxUIGroup);
							FlxG.log.add("-->Group(" + g.id + "), length="+g.members.length);
							for (fbb in g.members) {
								FlxG.log.add("---->Member(" + fbb + ")");
							}
						}else {
							FlxG.log.add("-->Thing(" + fb + ")");
						}
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
					var group:FlxUIGroup = null;
					
					var thing_id:String = U.xml_str(obj.x, "id", true);
					
					//If it belongs to a group, get that information ready:
					if (obj.has.group) { 
						group_id = obj.att.group; 
						group = getGroup(group_id);
					}
					
					
					//Make the thing
					var thing = _loadThing(type, obj);
					
					if (thing != null) {
						if (group != null) {
							group.add(cast thing);
						}else {
							add(cast thing);
						}
						
						_loadPosition(obj, thing);	//Position the thing if possible
						
						if (thing_id != null && thing_id != "") {
							_asset_index.set(thing_id, thing);
						}
					}
				}
			}
			
			_postLoad(data);
			
		}else {
			_onFinishLoad();
		}	
		
		
	}
	
	private function _postLoad(data:Fast):Void {
		
		if (data.x.firstElement() != null) {
			//Load the actual things
			var node:Xml;
			for (node in data.x.elements()) 
			{
				_postLoadThing(node.nodeName.toLowerCase(), new Fast(node));
			}
		}
		
		if (data.hasNode.mode) {
			for (mode_node in data.nodes.mode) {
				var is_default:Bool = U.xml_bool(mode_node.x, "is_default");
				if (is_default) {
					var mode_id:String = U.xml_str(mode_node.x, "id", true);
					setMode(mode_id);
					break;
				}
			}
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
		
		_onFinishLoad();
	}
	
	public var currMode(get, set):String;
	public function get_currMode():String { return _curr_mode; }
	public function set_currMode(m:String):String { setMode(m); return _curr_mode;}
	
	/**
	 * Set a mode for this UI. This lets you show/hide stuff basically. 
	 * @param	mode_id The mode you want, say, "empty" or "play" for a save slot
	 * @param	target_id UI element to target - "" for the UI itself, otherwise the id of an element that is itself a FlxUI
	 */
	
	public function setMode(mode_id:String,target_id:String=""):Void {
		if (_curr_mode == mode_id)
		{
			return;					//no sense in setting the same mode twice!
		}
		var mode:Fast = getMode(mode_id);
		_curr_mode = mode_id;
		var id:String = "";
		var thing;
		if(target_id == ""){
			if (mode != null) {
				
				var xml:Xml;
				for (node in mode.elements) {
					
					var node2:Fast = applyNodeConditionals(node);	//check for conditionals
					xml = node2.x;
					
					var nodeName:String = xml.nodeName;
					
					switch(nodeName) {
						case "show":
							showThing(U.xml_str(xml, "id", true),true);
						case "hide":
							showThing(U.xml_str(xml, "id", true), false);
						case "align":
							_alignThing(node2);
						case "change":
							_changeThing(node2);
						case "position":
							id = U.xml_str(xml, "id", true);
							thing = getAsset(id);
							if(thing != null){
								_loadPosition(node2, thing);
							}
					}
				}
			}
		}else {
			var target = getAsset(target_id);
			if (target != null && Std.is(target, FlxUI)) {
				var targetUI:FlxUI = cast(target, FlxUI);
				targetUI.setMode(mode_id, "");
			}
		}
	}
	
	private function showThing(id:String, b:Bool = true):Void{
		if (id.indexOf(",") != -1) {
			var ids:Array<String> = id.split(",");			//if commas, it's a list
			for(each_id in ids){
				var thing = getAsset(each_id);
				if (thing != null) {
					thing.visible = b;
				}
			}
		}else {
			if(id != "*"){
				var thing = getAsset(id);					//else, it's just one asset
				if (thing != null) { 
					thing.visible = b;
				}
			}else {											//if it's a "*", do this for ALL assets
				for (asset_id in _asset_index.keys()) {		
					if(asset_id != "*"){					//assets can't be named "*", smartass!
						showThing(asset_id, b);				//recurse
					}
				}
			}
		}
	}
	
	/******UTILITY FUNCTIONS**********/
	
	public function getGroup(key:String, recursive:Bool=true):FlxUIGroup{
		var group:FlxUIGroup = _group_index.get(key);
		if (group == null && recursive && _superIndexUI != null) {
			return _superIndexUI.getGroup(key, recursive);
		}
		return group;
	}
	
	public function getFlxText(key:String, recursive:Bool = true):FlxText {
		var asset = getAsset(key, recursive);
		if (asset != null) {
			if (Std.is(asset, FlxText)) {
				return cast(asset, FlxText);
			}
		}
		return null;
	}
	
	public function hasAsset(key:String, recursive:Bool = true):Bool {
		if (_asset_index.exists(key)) {
			return true;
		}
		if (recursive && _superIndexUI != null) {
			return _superIndexUI.hasAsset(key, recursive);
		}
		return false;
	}
	
	public function getAsset(key:String, recursive:Bool=true):IFlxUIWidget{
		var asset:IFlxUIWidget = _asset_index.get(key);
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
			definition = _superIndexUI.getDefinition(key, recursive);			
		}
		if (definition == null) {	//still null? check the globals:
			if (key.indexOf("include:") == -1) {	
				//check if this definition exists with the prefix "include:"
				//but stop short of recursively churning on "include:include:etc"
				definition = getDefinition("include:" + key, recursive);
			}
		}
		return definition;
	}
	
	/**
	 * Adds to thing.x and/or thing.y with wrappers depending on type
	 * @param	thing
	 * @param	X
	 * @param	Y
	 */
	
	private static inline function _delta(thing:IFlxUIWidget, X:Float=0, Y:Float=0):Void {				
		thing.x += X;
		thing.y += Y;
	}
		
	/**
	 * Centers thing in x axis with wrappers depending on type
	 * @param	thing
	 * @param	amt
	 */
		
	private static inline function _center(thing:IFlxUIWidget,X:Bool=true,Y:Bool=true):IFlxUIWidget{
		if (X) { thing.x = (FlxG.width - thing.width) / 2; }
		if (Y) { thing.y = (FlxG.height - thing.height) / 2;}
		return thing;
	}
	
	/***PRIVATE***/
	
	private var _group_index:Map<String,FlxUIGroup>;
	private var _asset_index:Map<String,IFlxUIWidget>;
	private var _definition_index:Map<String,Fast>;
	private var _mode_index:Map<String,Fast>;
	
	private var _curr_mode:String = "";
	
	private var _ptr:IEventGetter;

	private var _superIndexUI:FlxUI;
	private var _safe_input_delay_elapsed:Float = 0.0;
	
	private var _failure_checks:Array<Fast>;
	
	/**
	 * Replace an object in whatever group it is in
	 * @param	original the original object
	 * @param	replace	the replacement object
	 * @param	splice if replace is null, whether to splice the entry
	 */
	 
	private function replaceInGroup(original:FlxSprite,replace:FlxSprite,splice:Bool=false){
		//Slow, unoptimized, searches through everything
		
		if(_group_index != null){
			for (key in _group_index.keys()) {
				var group:FlxUIGroup = _group_index.get(key);
				if (group.members != null) {
					var i:Int = 0;
					for (member in group.members) {
						if(member != null){
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
		}
		
		//if we get here, it's not in any group, it's just in our global member list
		if (this.members != null) {
			var i:Int = 0;
			for (member in this.members) {
				if(member != null){
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
				}
				i++;
			}
		}
	}
	
	/************LOADING FUNCTIONS**************/
	
	private function applyNodeConditionals(info:Fast):Fast{
		if (info.hasNode.locale || info.hasNode.haxedef) {
			info = U.copyFast(info);
			
			if(info.hasNode.locale){
				info = applyNodeChanges(info, "locale");
			}
			
			if (info.hasNode.haxedef) {
				info = applyNodeChanges(info, "haxedef");
			}
		}
		return info;
	}
	
	/**
	 * Make any necessary changes to data/definition xml objects (such as for locale or haxedef settings)
	 * @param	data		Fast xml data
	 * @param	nodeName	name of the node, "locale", or "haxedef"
	 */
	
	private function applyNodeChanges(data:Fast,nodeName:String):Fast {
		//Make any necessary UI adjustments based on locale
		
		var nodeValue:String = "";
		
		//If nodeName="locale", set nodeValue once and only match current locale
		if (nodeName == "locale") {
			if (_ptr_tongue == null) {
				return data;
			}
			nodeValue = _ptr_tongue.locale.toLowerCase();	//match current locale only
		}
		
		//Else if nodeName="haxedef", check each valid haxedef inside the loop itself
		var haxedef:Bool = false;
		if (nodeName == "haxedef") {
			haxedef = true;
		}
		
		for (cNode in data.nodes.resolve(nodeName)) {
			var cid:String = U.xml_str(cNode.x, "id", true);
			
			if(haxedef){
				nodeValue = "";
				if (U.checkHaxedef(cid)) {
					nodeValue = cid;
				}
			}
			
			if (cid == nodeValue) {
				if (cNode.hasNode.change) {
					for (change in cNode.nodes.change) {
						var xml:Xml;
						for (att in change.x.attributes()) {
							var value:String = change.x.get(att);
							data.x.set(att, value);
						}
					}
				}
			}
		}
		
		return data;
	}
	
	private function _loadThing(type:String, data:Fast):IFlxUIWidget{
		var use_def:String = U.xml_str(data.x, "use_def", true);
		var definition:Fast = null;
		if (use_def != "") {
			definition = getDefinition(use_def);
		}
		
		var info:Fast = consolidateData(data, definition);
		info = applyNodeConditionals(info);
		
		switch(type) {
			case "region": return _loadRegion(info);
			case "chrome", "nineslicesprite", "nine_slice_sprite", "nineslice", "nine_slice": return _load9SliceSprite(info);
			case "tile_test": return _loadTileTest(info);
			case "line": return _loadLine(info);
			case "sprite": return _loadSprite(info);
			case "text": return _loadText(info);								//if input has events
			case "numeric_stepper": return _loadNumericStepper(info);			//has events, params
			case "button": return _loadButton(info);							//has events, params
			case "button_toggle": return _loadButton(info,true,true);			//has events, params
			
			case "tab_menu": return _loadTabMenu(info);							//has events, params?
			
			case "dropdown_menu", "dropdown",
			     "pulldown", "pulldown_menu": return _loadDropDownMenu(info);	//has events, params?
			
			case "checkbox": return _loadCheckBox(info);						//has events, params
			case "radio_group": return _loadRadioGroup(info);					//has events, params
			case "layout", "ui": return _loadLayout(info);
			case "failure": if (_failure_checks == null) { _failure_checks = new Array<Fast>(); }
							_failure_checks.push(data);
							return null;
			case "align": 	_alignThing(data);
							return null;
			case "mode", "include", "group", "load_if":			//ignore these, they are handled elsewhere
							return null;
			
			default: 
				//If I don't know how to load this thing, I will request it from my pointer:
				var result = _ptr.getRequest("ui_get:" + type, this, info);
				return result;
		}
		return null;
	}
	
	//Handy helpers for making x/y/w/h loading dynamic:
	private inline function _loadX(data:Fast, default_:Float = 0):Float {
		return _loadWidth(data, default_, "x");
	}
	
	private inline function _loadY(data:Fast, default_:Float = 0):Float {
		return _loadHeight(data, default_, "y");
	}
	
	private function _loadWidth(data:Fast,default_:Float=10,str:String="width"):Float {
		var ws:String = U.xml_str(data.x, str, true, Std.string(default_));
		return _getDataSize("w", ws, default_);
	}
	
	private function _loadHeight(data:Fast,default_:Float=10,str:String="height"):Float {
		var hs:String = U.xml_str(data.x, str, true, Std.string(default_));
		return _getDataSize("h", hs, default_);
	}
	
	private function _loadCompass(data:Fast,str:String="resize_point"):FlxPoint {
		var cs:String = U.xml_str(data.x, str, true, "nw");
		var fp:FlxPoint = FlxPoint.get();
		switch(cs) {
			case "nw", "ul": fp.x = 0;   fp.y = 0;
			case "n", "u":   fp.x = 0.5; fp.y = 0;
			case "ne", "ur": fp.x = 1;   fp.y = 0;
			case "e", "r":   fp.x = 1;   fp.y = 0.5;
			case "se", "lr": fp.x = 1;   fp.y = 1;
			case "s":        fp.x = 0.5; fp.y = 1;
			case "sw", "ll": fp.x = 0;   fp.y = 1;
			case "w":        fp.x = 0.5; fp.y = 0;	
			case "m","c","mid","center":fp.x = 0.5; fp.y = 0.5;	 
		}
		return fp;
	}
	
	private function _changeThing(data:Fast):Void {
		var id:String = U.xml_str(data.x, "id", true);
		var thing = getAsset(id);
		if (thing == null) {
			return;
		}
				
		var new_width:Float = -1;
		var new_height:Float = -1;
		
		var context:String = "";
		var code:String = "";
		
		for (attribute in data.x.attributes()) {
			switch(attribute) {
				case "text": if (Std.is(thing, FlxUIText)) {
								var text = U.xml_str(data.x, "text");
								context = U.xml_str(data.x, "context", true, "ui");
								var t:FlxUIText = cast thing;
								code = U.xml_str(data.x, "code", true, "");
								t.text = getText(text, context, true, code);
							 }
				case "label": var label = U.xml_str(data.x, "label");
							  context = U.xml_str(data.x, "context", true, "ui");
							  code = U.xml_str(data.x, "code", true, "");
							  label = getText(label, context, true, code);
							  if (Std.is(thing, ILabeled)) {
								  var b:ILabeled = cast thing;
								  b.get_label().text = label;
							  }
				case "width": new_width = _loadWidth(data);
				case "height": new_height = _loadHeight(data);
			}
		}
		if (Std.is(thing, IResizable)) {
			var ir:IResizable = cast thing;
			if (new_width != -1 || new_height != -1) {
				if (new_width == -1) { new_width = ir.width; }
				if (new_height == -1) { new_height = ir.height; }
				ir.resize(new_width, new_height);
			}
		}
	}
	
	
	
	private function _alignThing(data:Fast):Void {
		var datastr:String = data.x.toString();
		if (data.hasNode.objects) {
			for (objectNode in data.nodes.objects) {
				var objects:Array<String> = U.xml_str(objectNode.x, "value", true, "").split(",");
			
				var axis:String = U.xml_str(data.x, "axis", true);
				var spacing:Float = U.xml_f(data.x, "spacing", -1);
				var resize:Bool = U.xml_bool(data.x, "resize");
				
				var bounds:FlxPoint = FlxPoint.get(-1,-1);
				
				if (axis != "horizontal" && axis != "vertical") {
					throw new Error("FlxUI._alignThing(): axis must be \"horizontal\" or \"vertical\"!");
					return;
				}
				
				if (data.hasNode.bounds) {
					var bound_range:Float = -1;
					
					var reg:String = U.xml_str(data.node.bounds.x, "left");
					
					if (axis == "horizontal") {
						bounds.x = _getDataSize("w", U.xml_str(data.node.bounds.x, "left"), -1);
						bounds.y = _getDataSize("w", U.xml_str(data.node.bounds.x, "right"), -1);
					}else if (axis == "vertical") {
						bounds.x = _getDataSize("h", U.xml_str(data.node.bounds.x, "top"), -1);
						bounds.y = _getDataSize("h", U.xml_str(data.node.bounds.x, "bottom"), -1);
					}
				
					if (bounds.x != -1 && bounds.y != -1) {
						if(bounds.y <= bounds.x){
							//throw new Error("FlxUI._alignThing(): bounds max must be > bounds min!");
							return;
						}
					}else {
						//throw new Error("FlxUI._alignThing(): missing bound!");
						return;
					}
					
					_doAlign(objects, axis, spacing, resize, bounds);
					
					if(data.hasNode.anchor || data.has.x || data.has.y){
						for (object in objects) {
							var thing:IFlxUIWidget = getAsset(object);
							_loadPosition(data,thing);
						}
					}
				
				}else {
					throw new Error("FlxUI._alignThing(): <bounds> node not found!");
					return;
				}
			}
		}else {
			throw new Error("FlxUI._alignThing(): <objects> node not found!");
			return;
		}
	}
	
	private function _doAlign(objects:Array<String>, axis:String, spacing:Float, resize:Bool, bounds:FlxPoint):Void {
		var total_spacing:Float = 0;
		var total_size:Float = 0;
		
		var bound_range:Float = bounds.y - bounds.x;
		
		var spaces:Float = objects.length-1;
		var space_size:Float = 0;
		var object_size:Float = 0;
		
		var size_prop:String = "width";
		var pos_prop:String = "x";
		if (axis == "vertical") { 
			size_prop = "height"; 
			pos_prop = "y"; 
		}
		
		//calculate total size of everything
		for (id in objects) {
			var widget:IFlxUIWidget = getAsset(id);
			
			var theval:Float = 0;
			
			switch(size_prop) {
				case "width": theval = widget.width;
				case "height": theval = widget.height;
			}
			
			total_size += theval;
		}
		
		if (resize == false) {	//not resizing, so space evenly
			total_spacing = bound_range - total_size;
			space_size = total_spacing / spaces;
		}else {					//resizing, calculate space and then get remaining size
			space_size = spacing;
			total_spacing = spacing * spaces;
			object_size = (bound_range - total_spacing) / objects.length;	//target object size
		}
		
		object_size = Std.int(object_size);
		space_size = Std.int(space_size);
		
		var i:Int = 0;
		var last_pos:Float = bounds.x;
		for (id in objects) {
			var widget:IFlxUIWidget = getAsset(id);
			var pos:Float = last_pos;
			if (!resize) {
				switch(size_prop) {
					case "width": object_size = widget.width;
					case "height": object_size = widget.height;
				}
			}else {
				//if we are resizing, resize it to the target size now
				if (Std.is(widget, IResizable)) {
					var widgetr:IResizable = cast widget;
					if(axis == "vertical"){
						widgetr.resize(widgetr.width, object_size);
					}else if (axis == "horizontal") {
						widgetr.resize(object_size, widgetr.height);
					}
				}
			}
			last_pos = pos + object_size + space_size;
			
			switch(pos_prop) {
				case "x": widget.x = pos;
				case "y": widget.y = pos;
			}
			
			i++;
		}
	}
	
	private function _checkFailure(data:Fast):Bool{
		var target:String = U.xml_str(data.x, "target", true);
		var property:String = U.xml_str(data.x, "property", true);
		var compare:String = U.xml_str(data.x, "compare", true);
		var value:String = U.xml_str(data.x, "value", true);
		
		var thing:IFlxUIWidget = getAsset(target);
		
		if (thing == null) {
			return false;
		}
				
		var prop_f:Float = 0;
		var val_f:Float = 0;
				
		var p:Float = U.perc_to_float(value);
		
		switch(property) {
			case "w", "width": prop_f = thing.width; 
			case "h", "height": prop_f = thing.height; 
		}
				
		if (Math.isNaN(p)) {
			if (U.isStrNum(value)) {
				val_f = Std.parseFloat(value);
			}else {
				return false;
			}
		}else {
			switch(property) {
				case "w", "width": val_f = p * thisWidth(); 
				case "h", "height": val_f = p * thisHeight();
			}
		}
				
		var return_val:Bool = false;
		
		switch(compare) {
			case "<": if (prop_f < val_f) {
						failed_by = val_f - prop_f;
						return_val = true;
					  }
			case ">": if (prop_f > val_f) {
						failed_by = prop_f - val_f;
						return_val = true;
					  }
			case "=", "==": if (prop_f == val_f) {
						failed_by = Math.abs(prop_f - val_f);
						return_val = true;
					  }
			case "<=": if (prop_f <= val_f) {
						failed_by = val_f - prop_f;
						return_val = true;
					  }
			case ">=": if (prop_f >= val_f) {
						failed_by = prop_f - val_f;
						return_val = true;
					  }
		}
	
		return return_val;
	}
	
	private function _resizeThing(fo_r:IResizable, bounds:{ min_width:Float, min_height:Float,
														 max_width:Float, max_height:Float}):Void {
		var do_resize:Bool = false;
		var ww:Float = fo_r.width;
		var hh:Float = fo_r.height;
		
		if (ww < bounds.min_width) {
			do_resize = true; 
			ww = bounds.min_width;
		}else if (ww > bounds.max_width) {
			do_resize = true;
			ww = bounds.max_width;
		}
		
		if (hh < bounds.min_height) {
			do_resize = true;
			hh = bounds.min_height;
		}else if (hh > bounds.max_height) {
			do_resize = true;
			hh = bounds.max_height;
		}
		
		if (do_resize) {
			fo_r.resize(ww,hh);
		}
	}
	
	private function _postLoadThing(type:String, data:Fast):Void {
		
		var id:String = U.xml_str(data.x, "id", true);
		var thing:IFlxUIWidget = getAsset(id);
		
		if (type == "align") {
			_alignThing(data);
		}
		
		if (thing == null) {
			return;
		}
		
		var use_def:String = U.xml_str(data.x, "use_def", true);
		var definition:Fast = null;
		if (use_def != "") {
			definition = getDefinition(use_def);
		}
		
		if (Std.is(thing, IResizable)) {
			var bounds: { min_width:Float, min_height:Float, 
			              max_width:Float, max_height:Float } = calcMaxMinSize(data);
			
			if(bounds != null){
				_resizeThing(cast(thing, IResizable), bounds);
			}
		}
		
		_delta(thing, -thing.x, -thing.y);	//reset position to 0,0
		_loadPosition(data, thing);			//reposition
	}
	
	private function _loadTileTest(data:Fast):FlxUITileTest {
		
		var tiles_w:Int = U.xml_i(data.x, "tiles_w", 2);
		var tiles_h:Int = U.xml_i(data.x, "tiles_h", 2);
		var w:Float = _loadWidth(data);
		var h:Float = _loadHeight(data);
		
		var bounds: { min_width:Float, min_height:Float, 
			          max_width:Float, max_height:Float } = calcMaxMinSize(data);
		
		if (w < bounds.min_width) { w = bounds.min_width; }
		if (h < bounds.min_height) { h = bounds.min_height; }
		
		var tileWidth:Int = Std.int(w/tiles_w);
		var tileHeight:Int = Std.int(h/tiles_h);
		
		if (tileWidth < tileHeight) { tileHeight = tileWidth; }
		else if (tileHeight < tileWidth) { tileWidth = tileHeight; }
		
		var totalw:Float = tileWidth * tiles_w;
		var totalh:Float = tileHeight * tiles_h;
		
		if (totalw > bounds.max_width) { tileWidth = Std.int(bounds.max_width / tiles_w); }
		if (totalh > bounds.max_height) { tileHeight = Std.int(bounds.max_height / tiles_h); }
		
		if (tileWidth < tileHeight) { tileHeight = tileWidth; }
		else if (tileHeight < tileWidth) { tileWidth = tileHeight; }
		
		if (tileWidth < 2) { tileWidth = 2; }
		if (tileHeight < 2) { tileHeight = 2; }
		
		var ftt:FlxUITileTest = new FlxUITileTest(0, 0, tileWidth, tileHeight, tiles_w, tiles_h);
		return ftt;
	}
	
	private function _loadText(data:Fast):IFlxUIWidget{
		
		var text:String = U.xml_str(data.x, "text");
		var context:String = U.xml_str(data.x, "context", true, "ui");
		var code:String = U.xml_str(data.x, "code", true, "");
		text = getText(text,context, true, code);
		
		var W:Int = Std.int(_loadWidth(data, 100));
		
		var the_font:String = _loadFontFace(data);
		
		var input:Bool = U.xml_bool(data.x, "input");
		
		var align:String = U.xml_str(data.x, "align"); if (align == "") { align = null;}
		var size:Int = U.xml_i(data.x, "size"); if (size == 0) { size = 8;}
		var color:Int = _loadColor(data);
		
		var border:Array<Dynamic> = _loadBorder(data);
		
		var ft:IFlxUIWidget;
		if(input == false){
			var ftu:FlxUIText = new FlxUIText(0, 0, W, text, size);
			ftu.setFormat(the_font, size, color, align);
			ftu.borderStyle = border[0];
			ftu.borderColor = border[1];
			ftu.borderSize = border[2];
			ftu.borderQuality = border[3];

			ftu.drawFrame();
			ft = ftu;
		}else {
			var fti:FlxUIInputText = new FlxUIInputText(0, 0, W, text);
			fti.setFormat(the_font, size, color, align);
			fti.borderStyle = border[0];
			fti.borderColor = border[1];
			fti.borderSize = border[2];
			fti.borderQuality = border[3];
			fti.drawFrame();
			ft = fti;
		}
		return ft;
	}
	
	public static function consolidateData(data:Fast, definition:Fast):Fast {
		if (data == null && definition != null) {
			return definition;		//no data? Return the definition;
		}
		if (definition == null) {
			return data;			//no definition? Return the original data
		}else {			
			//If there's data and a definition, try to consolidate them
			//Start with the definition data, copy in the local changes
			
			var new_data:Xml = U.copyXml(definition.x);	//Get copy of definition Xml
			
			for (att in data.x.attributes()) {			//Loop over each attribute in local data
				var val:String = data.att.resolve(att);
				new_data.set(att, val);			//Copy it in
			}
			
			//Make sure the id is the object's id, not the definition's
			new_data.nodeName = data.name;
			if(data.has.id){
				new_data.set("id", data.att.id);
			}else {
				new_data.set("id", "");
			}
			
			//TODO: copy in nodes from local to definition
						
			for (element in data.x.elements()) {		//Loop over each node in local data
				var nodeName = element.nodeName;		
				new_data.insertChild(U.copyXml(element), 0);	//Add the node
				//new_data.x.addChild(U.copyXml(element));	//Add the node				
			}
			return new Fast(new_data);
		}
		return data;
	}
	
	private function _loadRadioGroup(data:Fast):FlxUIRadioGroup {
		var frg:FlxUIRadioGroup = null;
				
		var dot_src:String = U.xml_str(data.x, "dot_src", true);
		var radio_src:String = U.xml_str(data.x, "radio_src", true);
		
		var labels:Array<String> = new Array<String>();
		var ids:Array<String> = new Array<String>();
		
		var W:Int = cast _loadWidth(data, 11, "radio_width");
		var H:Int = cast _loadHeight(data, 11, "radio_height");
		
		var labelW:Int = cast _loadWidth(data, 100, "label_width");
		
		for (radioNode in data.nodes.radio) {
			var id:String = U.xml_str(radioNode.x, "id", true);
			var label:String = U.xml_str(radioNode.x, "label");
			
			var context:String = U.xml_str(radioNode.x, "context", true, "ui");
			var code:String = U.xml_str(radioNode.x, "code", true, "");
			label = getText(label,context,true,code);
		
			ids.push(id);
			labels.push(label);
		}
		
		var y_space:Float = U.xml_f(data.x, "y_space", 25);
		
		var params:Array<Dynamic> = getParams(data);
		
		var radio_asset:String = null;
		if (radio_src != "") {
			radio_asset = U.gfx(radio_src);
		}
		
		var dot_asset:Dynamic=null;
		if (dot_src != "") {
			dot_asset = U.gfx(dot_src);
		}
		
		//if radio_src or dot_src are == "", then leave radio_asset/dot_asset == null, 
		//and FlxUIRadioGroup will default to defaults defined in FlxUIAssets 
		
		frg = new FlxUIRadioGroup(0, 0, ids, labels, null, y_space, W, H, labelW);
		frg.params = params;
		
		if (radio_asset != "" && radio_asset != null) {
			frg.loadGraphics(radio_asset,dot_asset);
		}
		
		var text_x:Int = U.xml_i(data.x, "text_x");
		var text_y:Int = U.xml_i(data.x, "text_y");
		
		for (fo in frg.members) {
			if(fo != null){
				if (Std.is(fo, FlxUICheckBox)){
					var fc:FlxUICheckBox = cast(fo, FlxUICheckBox);
					formatButtonText(data, fc);
					fc.textX = text_x;
					fc.textY = text_y;
				}
			}
		}
		
		return frg;
	}
	
	private function _loadCheckBox(data:Fast):FlxUICheckBox {
		var src:String = "";
		var fc:FlxUICheckBox = null;
		
		var label:String = U.xml_str(data.x, "label");
		var context:String = U.xml_str(data.x, "context", true, "ui");
		var code:String = U.xml_str(data.x, "code", true, "");
		
		label = getText(label,context,true,code);
		
		var labelW:Int = cast _loadWidth(data, 100, "label_width");
		
		var check_src:String = U.xml_str(data.x, "check_src", true);
		var box_src:String = U.xml_str(data.x, "box_src", true);
		
		var params:Array<Dynamic> = getParams(data);
		
		var box_asset:String = null; 
		var check_asset:String = null;  
		
		if(box_src != ""){
			box_asset = U.gfx(box_src);
		}
		if(check_src != ""){
			check_asset = U.gfx(check_src);
		}
		
		fc = new FlxUICheckBox(0, 0, box_asset, check_asset, label, labelW, params);
		formatButtonText(data, fc);
		
		var text_x:Int = U.xml_i(data.x, "text_x");
		var text_y:Int = U.xml_i(data.x, "text_y");
		
		fc.textX = text_x;
		fc.textY = text_y;
		
		fc.text = label;
		
		return fc;
	}
	
	
	private function _loadDropDownMenu(data:Fast):FlxUIDropDownMenu{
		
		/*
		 *   <dropdown label="Something">
		 *      <data id="thing_1" label="Thing 1"/>
		 *      <data id="thing_2" label="Thing 2"/>
		 *      <data id="1_fish" label="One Fish"/>
		 *      <data id="2_fish" label="Two Fish"/>
		 *      <data id="0xff0000_fish" label="Red Fish"/>
		 *      <data id="0x0000ff_fish" label="Blue Fish"/>
		 *   </dropdown>
		 * 
		 *   <dropdown label="Whatever" back_def="dd_back" panel_def="dd_panel" button_def="dd_button">
		 *      <asset id="a" def="thing_a"/>
		 *      <asset id="b" def="thing_b"/>
		 *      <asset id="c" def="thing_c"/>
		 *   </dropdown> 
		 * 
		 *   <dropdown label="Whatever" back_def="dd_back" panel_def="dd_panel" button_def="dd_button">
		 *      <data id="blah" label="Blah"/>
		 *      <data id="blah2" label="Blah2"/>
		 *      <data id="blah3" label="Blah3"/>
		 *   </dropdown>
		 */
		
		var fud:FlxUIDropDownMenu = null;
		
		var label:String = U.xml_str(data.x, "label");
		var context:String = U.xml_str(data.x, "context", true, "ui");
		var code:String = U.xml_str(data.x, "code", true, "");
		label = getText(label,context,true,code);
		
		var back_def:String = U.xml_str(data.x, "back_def", true);
		var panel_def:String = U.xml_str(data.x, "panel_def", true);
		var button_def:String = U.xml_str(data.x, "button_def", true);
		var label_def:String = U.xml_str(data.x, "label_def", true);
		
		var back_asset:FlxSprite = null;
		var panel_asset:FlxUI9SliceSprite = null;
		var button_asset:FlxUISpriteButton = null;
		var label_asset:FlxUIText = null;
				
		if (back_def != "") {
			back_asset = _loadSprite(getDefinition(back_def));
		}
		
		if (panel_def != "") {
			panel_asset = _load9SliceSprite(getDefinition(panel_def));
		}
		
		if (button_def != "") {
			try{
				button_asset = cast _loadButton(getDefinition(button_def), false, false);
			}catch (e:Error) {
				FlxG.log.add("couldn't loadButton with definition \"" + button_def + "\"");
				button_asset = null;
			}
		}
		
		if (label_def != "") {
			try{
				label_asset = cast _loadText(getDefinition(label_def));
			}catch (e:Error) {
				FlxG.log.add("couldn't loadText with definition \"" + label_def + "\"");
				label_asset = null;
			}
			if (label_asset != null && label != "") {
				label_asset.text = label;
			}
		}
		
		var asset_list:Array<FlxUIButton> = null;
		var data_list:Array<StrIdLabel> = null;
		
		if (data.hasNode.data) {
			for (dataNode in data.nodes.data) {
				if (data_list == null) { 
					data_list = new Array<StrIdLabel>();
				}
				var idl:StrIdLabel = new StrIdLabel(U.xml_str(dataNode.x, "id", true), U.xml_str(dataNode.x, "label"));
				data_list.push(idl);
			}
		}else if (data.hasNode.asset) {
			for (assetNode in data.nodes.asset) {
				if (asset_list == null) {
					asset_list = new Array<FlxUIButton>();
				}
				var def_id:String = U.xml_str(assetNode.x, "def", true);
				var id:String = U.xml_str(assetNode.x, "id", true);
				var asset:FlxUIButton = null;
				
				try{
					asset = cast _loadButton(getDefinition(def_id), false);
				}catch (e:Error) {
					FlxG.log.add("couldn't loadButton with definition \"" + def_id + "\"");
				}
				
				if (asset != null) {
					asset.id = id;
					if (asset_list == null) {
						asset_list = new Array<FlxUIButton>();
					}
					asset_list.push(asset);
				}
			}
		}
		
		var header = new FlxUIDropDownHeader(120, back_asset, label_asset, button_asset);
		fud = new FlxUIDropDownMenu(0, 0, data_list, null, header, panel_asset, asset_list);// , _onClickDropDown_control);
		
		return fud;
	}
	
	private function _loadTest(data:Fast):Bool {
		if (data.hasNode.load_if) {
			for (node in data.nodes.load_if) {
				var aspect_ratio:Float = U.xml_f(node.x, "aspect_ratio", -1);
				if (aspect_ratio != -1) {
					var tolerance:Float = U.xml_f(node.x, "tolerance", 0.1);
					var screen_ratio:Float = cast(FlxG.width, Float) / cast(FlxG.height, Float);
					var diff:Float = Math.abs(screen_ratio - aspect_ratio);
					if (diff > tolerance) {
						return false;
					}
				}
				
				var haxeDef:String = U.xml_str(node.x, "haxedef", true, "");
				var haxeVal:Bool = U.xml_bool(node.x, "value", true);
				
				if (haxeDef != "") {
					var defValue:Bool = false;
					switch(haxeDef) {
						case "3ds": 
							#if NINTENDO_3DS
								defValue = true;
							#end			
						case "wiiu":
							#if NINTENDO_WIIU
								defValue = true;
							#end
						case "vita":
							#if PS_VITA
								defValue = true;
							#end
						case "ps4":
							#if PS_4
								defValue = true;
							#end							
					}
					return defValue == haxeVal;
				}
			}
		}
		return true;
	}
	
	private function _loadLayout(data:Fast):FlxUI {
		
		if(_loadTest(data)){
		
			var id:String = U.xml_str(data.x, "id", true);
			var _ui:FlxUI = new FlxUI(data, this, this,_ptr_tongue);
			_ui.id = id;
		
			return _ui;
		}
		
		return null;
	}
	
	private function _loadTabMenu(data:Fast):FlxUITabMenu{
		
		var back_def_str:String = U.xml_str(data.x, "back_def");
		var back_def:Fast = getDefinition(back_def_str);
		if (back_def == null) {
			back_def = data;
		}
	
		back_def = consolidateData(back_def, data);
		var back:FlxUI9SliceSprite = _load9SliceSprite(back_def, "tab_menu");
		
		var tab_def:Fast = null;
		
		var stretch_tabs:Bool = U.xml_bool(data.x, "stretch_tabs",false);
		
		var tab_def_str:String = "";
		
		if (data.hasNode.tab) {
			for(tabNode in data.nodes.tab){
				var temp = U.xml_str(tabNode.x, "use_def");
				if (temp != "") { 
					tab_def_str = temp;
				}
			}
			if (tab_def_str != "") {
				tab_def = getDefinition(tab_def_str);
			}else {
				tab_def = data.node.tab;
			}
		}
		
		var list_tabs:Array<FlxUIButton> = new Array<FlxUIButton>();
		
		var id:String = "";
		
		if (data.hasNode.tab) {
			for (tab_node in data.nodes.tab) {
				id = U.xml_str(tab_node.x, "id", true);
				
				if(id != ""){
					var label:String = U.xml_str(tab_node.x, "label");
					var context:String = U.xml_str(tab_node.x, "context", true, "ui");
					var code:String = U.xml_str(tab_node.x, "code", true, "");
					label = getText(label,context,true,code);
			
					label = getText(label,context,true,code);
			
					var tab_info:Fast = consolidateData(tab_node, tab_def);
					var tab:FlxUIButton = cast _loadButton(tab_info, true, true, "tab_menu");
					tab.id = id;
					list_tabs.push(tab);
				}
			}
		}
		
		if (list_tabs.length > 0) {
			if (tab_def == null || !tab_def.hasNode.text) {
				for (t in list_tabs) {
					t.label.color = 0xFFFFFF;
					t.label.setBorderStyle(FlxText.BORDER_OUTLINE);
				}
			}
			
			if (tab_def == null || !tab_def.has.width) {	//no tab definition!
				stretch_tabs = true;
				//make sure to stretch the default tab graphics
			}
		}
		
		var fg:FlxUITabMenu = new FlxUITabMenu(back,list_tabs,stretch_tabs);
		
		if (data.hasNode.group) {
			for (group_node in data.nodes.group) {
				id = U.xml_str(group_node.x, "id", true);
				var _ui:FlxUI = new FlxUI(group_node, fg, this, _ptr_tongue);
				if(list_tabs != null && list_tabs.length > 0){
					_ui.y += list_tabs[0].height;
				}
				_ui.id = id;
				fg.addGroup(_ui);
			}
		}
		
		//fg.selected_tab = 0;
		
		return fg;
	}
	
	private function _loadNumericStepper(data:Fast, setCallback:Bool = true):IFlxUIWidget {
		
		/*
		 * <numeric_stepper step="1" value="0" min="1" max="2" decimals="1">
		 * 		<text/>
		 * 		<plus/>
		 * 		<minus/>
		 * 		<params/>
		 * </numeric_stepper>
		 * 
		 */
		
		var stepSize:Float = U.xml_f(data.x, "step", 1);
		var defaultValue:Float = U.xml_f(data.x, "value", 0);
		var min:Float = U.xml_f(data.x, "min", 0);
		var max:Float = U.xml_f(data.x, "max", 10);
		var decimals:Int = U.xml_i(data.x, "decimals", 0);
		
		var theText:FlxText = null;
		var buttPlus:FlxUITypedButton<FlxSprite> = null;
		var buttMinus:FlxUITypedButton<FlxSprite> = null;
		var bkg:FlxUISprite = null;
		
		if (data.hasNode.text) {
			theText = cast _loadText(data.node.text);
		}
		if (data.hasNode.plus) {
			buttPlus = cast _loadButton(data.node.plus);
		}
		if (data.hasNode.minus) {
			buttMinus = cast _loadButton(data.node.minus);
		}
		
		var ns:FlxUINumericStepper = new FlxUINumericStepper(0, 0, stepSize, defaultValue, min, max, decimals, FlxUINumericStepper.STACK_HORIZONTAL, theText, buttPlus, buttMinus);
		
		if (setCallback) {
			var params:Array<Dynamic> = getParams(data);
			ns.params = params;
		}
		
		return ns;
	}
	
	private function _loadButton(data:Fast, setCallback:Bool = true, isToggle:Bool = false, load_code:String=""):IFlxUIWidget{
		var src:String = ""; 
		var fb:Dynamic = null;
		
		var resize_ratio:Float = U.xml_f(data.x, "resize_ratio", -1);
		var resize_point:FlxPoint = _loadCompass(data, "resize_point");
		var isVis:Bool = U.xml_bool(data.x, "visible", true);
		
		var label:String = U.xml_str(data.x, "label");
		
		var sprite:FlxUISprite = null;
		
		//TODO:
			//currently you can only have a text label OR a sprite icon
			//once this issue: (https://github.com/HaxeFlixel/flixel/issues/614) is resolved
			//we can have both, but for now we enforce one or the other
		if (label == "") {
			if (data.hasNode.sprite) {
				sprite = cast _loadThing("sprite",data.node.sprite);
			}
		}
		
		var context:String = U.xml_str(data.x, "context", true, "ui");
		var code:String = U.xml_str(data.x, "code", true, "");
		
		label = getText(label,context,true,code);
		
		var W:Int = Std.int(_loadWidth(data, 0, "width"));
		var H:Int = Std.int(_loadHeight(data, 0, "height"));
		
		var params:Array<Dynamic> = getParams(data);
		
		if(sprite == null){
			fb = new FlxUIButton(0, 0, label);
		}else {
			fb = new FlxUISpriteButton(0, 0, sprite);
		}
		fb.resize_ratio = resize_ratio;
		fb.resize_point = resize_point;
		
		if (setCallback) {
			fb.params = params;
		}
		
		/***Begin graphics loading block***/
		
		if (data.hasNode.graphic) {
			
			var blank:Bool = U.xml_bool(data.node.graphic.x, "blank");
			
			if (blank) {
				//load blank
				#if neko
					fb.loadGraphicSlice9(["", "", ""], W, H, null, FlxUI9SliceSprite.TILE_NONE, resize_ratio, false, 0, 0, null);
				#else
					fb.loadGraphicSlice9(["", "", ""], W, H, null, FlxUI9SliceSprite.TILE_NONE, resize_ratio);
				#end
	
			}else{
			
				var graphic_ids:Array<String>=null;
				var slice9_ids:Array<Array<Int>>=null;
				var frames:Array<Int>=null;
				
				if (isToggle) {
					graphic_ids = ["", "", "", "", "", ""];
					slice9_ids= [null, null, null, null, null, null];
				}else {				
					graphic_ids = ["", "", ""];
					slice9_ids = [null, null, null];
				}
				
				//dimensions of source 9slice image (optional)
				var src_w:Int = U.xml_i(data.node.graphic.x, "src_w", 0);
				var src_h:Int = U.xml_i(data.node.graphic.x, "src_h", 0);
				var tile:Int = _loadTileRule(data.node.graphic);
				
				//custom frame indeces array (optional)
				var frame_str:String = U.xml_str(data.node.graphic.x, "frames",true);
				if (frame_str != "") {
					frames = new Array<Int>();
					var arr = frame_str.split(",");
					for (numstr in arr) {
						frames.push(Std.parseInt(numstr));
					}
				}
				
				for (graphicNode in data.nodes.graphic) {
					var graphic_id:String = U.xml_str(graphicNode.x, "id", true);
					var image:String = U.xml_str(graphicNode.x, "image");
					var slice9:Array<Int> = FlxStringUtil.toIntArray(U.xml_str(graphicNode.x, "slice9"));
					tile = _loadTileRule(graphicNode);
					
					var toggleState:Bool = U.xml_bool(graphicNode.x, "toggle");
					toggleState = toggleState && isToggle;
					
					switch(graphic_id) {
						case "inactive", "", "normal", "up": 
							if (image != "") { 
								if(!toggleState){
									graphic_ids[0] = U.gfx(image); 
								}else {
									graphic_ids[3] = U.gfx(image);
								}
							}
							slice9_ids[0] = slice9;
						case "active", "highlight", "hilight", "over", "hover": 
							if (image != "") { 
								if(!toggleState){
									graphic_ids[1] = U.gfx(image); 
								}else {
									graphic_ids[4] = U.gfx(image);
								}
							}
							slice9_ids[1] = slice9;
						case "down", "pressed", "pushed":
							if (image != "") { 
								if(!toggleState){
									graphic_ids[2] = U.gfx(image); 
								}else {
									graphic_ids[5] = U.gfx(image);
								}
							}
							slice9_ids[2] = slice9;
						case "all":
							if (image != "") { 
								graphic_ids = [U.gfx(image)];
							}
							slice9_ids = [slice9];
							if (src_w == 0 || src_h == 0) {		//infer these from looking at the src
								var temp:BitmapData = Assets.getBitmapData(graphic_ids[0]);
								src_w = temp.width;
								if (isToggle) {
									src_h = Std.int(temp.height / 6);
								}else {
									src_h = Std.int(temp.height / 3);
								}
							}
					}
	
					if (graphic_ids[0] != "") {
						if (graphic_ids.length >= 3) {
							if (graphic_ids[1] == "") {		//"over" is undefined, grab "up"
								graphic_ids[1] = graphic_ids[0];
							}
							if (graphic_ids[2] == "") {		//"down" is undefined, grab "over"
								graphic_ids[2] = graphic_ids[1];
							}
							if (graphic_ids.length >= 6) {	//toggle states
								if (graphic_ids[3] == "") {	//"up" undefined, grab "up" (untoggled)
									graphic_ids[3] = graphic_ids[0];
								}
								if (graphic_ids[4] == "") {	//"over" grabs "over"
									graphic_ids[4] = graphic_ids[1];
								}
								if (graphic_ids[5] == "") {	//"down" grabs "down"
									graphic_ids[5] = graphic_ids[2];
								}
							}
						}
					}
				}
				
				//load 9-slice
				fb.loadGraphicSlice9(graphic_ids, W, H, slice9_ids, tile, resize_ratio, isToggle, src_w, src_h, frames);
			}
		}else {			
			if (load_code == "tab_menu"){
				//load default tab menu graphics
				var graphic_ids:Array<String> = [FlxUIAssets.IMG_TAB_BACK, FlxUIAssets.IMG_TAB_BACK, FlxUIAssets.IMG_TAB_BACK, FlxUIAssets.IMG_TAB, FlxUIAssets.IMG_TAB, FlxUIAssets.IMG_TAB];
				var slice9_tab:Array<Int> = FlxStringUtil.toIntArray(FlxUIAssets.SLICE9_TAB);
				var slice9_ids:Array<Array<Int>> = [slice9_tab, slice9_tab, slice9_tab, slice9_tab, slice9_tab, slice9_tab];
				fb.loadGraphicSlice9(graphic_ids, W, H, slice9_ids, FlxUI9SliceSprite.TILE_NONE, resize_ratio, isToggle);
			}else{
				//load default graphics
				if(W > 0 && H > 0){
					fb.loadGraphicSlice9(null, W, H, null, FlxUI9SliceSprite.TILE_NONE, resize_ratio, isToggle);
				}
			}
		}
		
		/***End graphics loading block***/
		
		if (sprite == null) {
			if (data != null && data.hasNode.text) {
				formatButtonText(data, fb);
			}else {
				if (load_code == "tab_menu") {
					fb.up_color = 0xffffff;
					fb.down_color = 0xffffff;
					fb.over_color = 0xffffff;
					fb.up_toggle_color = 0xffffff;
					fb.down_toggle_color = 0xffffff;
					fb.over_toggle_color = 0xffffff;
				}
				else {
					// Center sprite icon 
					fb.autoCenterLabel();
				}
			}
		}
		
		var text_x:Int = 0;
		var text_y:Int = 0;
		if (data.x.get("text_x") != null) {
			text_x = U.xml_i(data.x, "text_x");
		}else if (data.x.get("label_x") != null) {
			text_x = U.xml_i(data.x, "label_x");
		}
		if (data.x.get("text_y") != null) {
			text_y = U.xml_i(data.x, "text_y");
		}else if (data.x.get("label_y") != null) {
			text_y = U.xml_i(data.x, "label_y");
		}
		
		//label offset has already been 'centered,' this adjust from there:
		fb.label.offset.x -= text_x;
		fb.label.offset.y -= text_y;
		
		fb.visible = isVis;
		
		return fb;
	}
	
	private static inline function _loadBitmapRect(source:String,rect_str:String):BitmapData {
		var b1:BitmapData = Assets.getBitmapData(U.gfx(source));
		var r:Rectangle = FlxUI9SliceSprite.getRectFromString(rect_str);
		var b2:BitmapData = new BitmapData(Std.int(r.width), Std.int(r.height), true, 0x00ffffff);					
		b2.copyPixels(b1, r, new Point(0, 0));
		return b2;
	}
	
	private function _loadRegion(data:Fast):FlxUIRegion {
		var w:Int = Std.int(_loadWidth(data));
		var h:Int = Std.int(_loadHeight(data));
		return new FlxUIRegion(0, 0, w, h);
	}
	
	private function _load9SliceSprite(data:Fast,load_code:String=""):FlxUI9SliceSprite{
		var src:String = ""; 
		var f9s:FlxUI9SliceSprite = null;
				
		var resize_ratio:Float = U.xml_f(data.x, "resize_ratio", -1);
		var resize_point:FlxPoint = _loadCompass(data, "resize_point");
		
		var bounds: { min_width:Float, min_height:Float, 
			          max_width:Float, max_height:Float } = calcMaxMinSize(data);
		
		src = U.xml_gfx(data.x, "src");
		if (src == "") { src = null; }
		
		if(src == null){
			if (load_code == "tab_menu") {
				src = FlxUIAssets.IMG_CHROME_FLAT;
			}
		}
		
		var rc:Rectangle;
		var rect_w:Int = Std.int(_loadWidth(data));
		var rect_h:Int = Std.int(_loadHeight(data));
				
		if(bounds != null){
			if (rect_w < bounds.min_width) { rect_w = Std.int(bounds.min_width); }
			else if (rect_w > bounds.max_width) { rect_w = cast bounds.max_width; }
			
			if (rect_h < bounds.min_height) { rect_h = Std.int(bounds.min_height); }
			else if (rect_h > bounds.max_height) { rect_h = Std.int(bounds.max_height); }
		}
		if (rect_w == 0 || rect_h == 0) {
			return null;
		}
		
		var rc:Rectangle = new Rectangle(0, 0, rect_w, rect_h);
		var slice9:Array<Int> = FlxStringUtil.toIntArray(U.xml_str(data.x, "slice9"));
		
		var smooth:Bool = U.xml_bool(data.x, "smooth", false);
		
		var tile:Int = _loadTileRule(data);
				
		f9s = new FlxUI9SliceSprite(0, 0, src, rc, slice9, tile, smooth,"",resize_ratio,resize_point);
		
		return f9s;
	}
	
	private inline function _loadTileRule(data:Fast):Int {
		var tileStr:String = U.xml_str(data.x, "tile", true,"");
		var tile:Int = FlxUI9SliceSprite.TILE_NONE;
		switch(tileStr) {
			case "true", "both", "all", "hv", "vh": tile = FlxUI9SliceSprite.TILE_BOTH;
			case "h", "horizontal": tile = FlxUI9SliceSprite.TILE_H;
			case "v", "vertical": tile = FlxUI9SliceSprite.TILE_V;
		}
		return tile;
	}
	
	private function _loadLine(data:Fast):FlxUISprite {
		var src:String = ""; 
		var fs:FlxUISprite = null;
		
		var axis:String = U.xml_str(data.x, "axis", true, "horizontal");
		var thickness:Int = U.xml_i(data.x, "thickness", 1);
		
		var bounds: { min_width:Float, min_height:Float, 
					  max_width:Float, max_height:Float } = calcMaxMinSize(data);
		
		if (bounds == null) {
			bounds = { min_width:Math.NEGATIVE_INFINITY, min_height:Math.NEGATIVE_INFINITY, max_width:Math.POSITIVE_INFINITY, max_height:Math.POSITIVE_INFINITY };
		}
		switch(axis) {
				case "h", "horz", "horizontal":	bounds.max_height = thickness; bounds.min_height = thickness;
				case "v", "vert", "vertical":	bounds.max_width = thickness; bounds.min_width = thickness;
		}
		
		var W:Int = Std.int(_loadWidth(data));
		var H:Int = Std.int(_loadHeight(data));
		
		if(bounds != null){
			if (W < bounds.min_width) { W = Std.int(bounds.min_width); }
			else if (W > bounds.max_width) { W = Std.int(bounds.max_width); }
			if (H < bounds.min_height) { H = Std.int(bounds.max_height); }
			else if (H > bounds.max_height) { H = Std.int(bounds.max_height);}
		}

		var cstr:String = U.xml_str(data.x, "color", true, "0xff000000");
		var C:Int = 0;
		if (cstr != "") {
			C = U.parseHex(cstr, true);
		}
		fs = new FlxUISprite(0, 0);
		fs.makeGraphic(W, H, C);
		
		return fs;
	}
	
	private function _loadSprite(data:Fast):FlxUISprite{
		var src:String = ""; 
		var fs:FlxUISprite = null;
		
		src = U.xml_gfx(data.x, "src");
		
		var bounds: { min_width:Float, min_height:Float, 
					  max_width:Float, max_height:Float } = calcMaxMinSize(data);
		
		if(src != ""){
			fs = new FlxUISprite(0, 0, src);
		}else {
			var W:Int = Std.int(_loadWidth(data));
			var H:Int = Std.int(_loadHeight(data));
			
			if(bounds != null){
				if (W < bounds.min_width) { W = Std.int(bounds.min_width); }
				else if (W > bounds.max_width) { W = Std.int(bounds.max_width); }
				if (H < bounds.min_height) { H = Std.int(bounds.max_height); }
				else if (H > bounds.max_height) { H = Std.int(bounds.max_height);}
			}

			var cstr:String = U.xml_str(data.x, "color");
			var C:Int = 0;
			if (cstr != "") {
				C = U.parseHex(cstr, true);
			}
			fs = new FlxUISprite(0, 0);
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
		
	private function _getAnchorPos(thing:IFlxUIWidget, axis:String, str:String):Float {
		switch(str) {
			case "": return 0;
			case "left": return 0;
			case "right": return thisWidth();
			case "center":
						 if (axis == "x") { return thisWidth() / 2; }
					else if (axis == "y") { return thisHeight() / 2; }
			case "top", "up": return 0;
			case "bottom", "down": return thisHeight();
			default:
				var perc:Float = U.perc_to_float(str);
				if (!Math.isNaN(perc)) {			//it's a percentage
					if (axis == "x") {
						return perc * thisWidth();
					}else if (axis == "y") {
						return perc * thisHeight();
					}
				}else {
					var r:EReg = ~/[\w]+\.[\w]+/;
					var property:String = "";
					
					if (r.match(str)) {
						var wh:String = "";
						if (axis == "x") { wh = "w"; }
						if (axis == "y") { wh = "h"; }
						var assetValue:Float = _getStretch(1, wh, str);
						return assetValue;
					}

					/*if (r.match(str)) {
						
						var p: { pos:Int, len:Int }= r.matchedPos();
						if (p.pos == 0 && p.len == str.length) {
							var arr:Array<String> = str.split(".");
							str = arr[0];
							property = arr[1];
						}
					}
					
					var other:IFlxUIWidget = getAsset(str);
										
					if (thing != null && other != null) {
						if (axis == "x") { 
							switch(property) {
								case "left": return other.x;
								case "right": return other.x + other.width;
								case "center": return other.x + other.width / 2;
								default:return other.x; 
							}
						}
						else if (axis == "y") { 
							switch(property) {
								case "top": return other.y;
								case "bottom": return other.y + other.height;
								case "center": return other.y + other.height / 2;
								default:return other.y;
							}
						}
					}*/
				}
		}
		return 0;
	}
	
	private function calcMaxMinSize(data:Fast, width:Dynamic = null, height:Dynamic = null):MaxMinSize {
		var min_w:Float = 0;
		var min_h:Float = 0;
		var max_w:Float = Math.POSITIVE_INFINITY;
		var max_h:Float = Math.POSITIVE_INFINITY;
		var temp_min_w:Float = 0;
		var temp_min_h:Float = 0;
		var temp_max_w:Float = Math.POSITIVE_INFINITY;
		var temp_max_h:Float = Math.POSITIVE_INFINITY;
		
		if (data.hasNode.exact_size) {
			for (exactNode in data.nodes.exact_size) {
				var exact_w_str:String = U.xml_str(exactNode.x, "width");
				var exact_h_str:String = U.xml_str(exactNode.x, "height");
				min_w = _getDataSize("w", exact_w_str, 0);
				min_h = _getDataSize("h", exact_h_str, 0);
				max_w = min_w;
				max_h = min_h;
			}
		}else if (data.hasNode.min_size) {
			for(minNode in data.nodes.min_size){
				var min_w_str:String = U.xml_str(minNode.x, "width");
				var min_h_str:String = U.xml_str(minNode.x, "height");
				temp_min_w = _getDataSize("w", min_w_str, 0);
				temp_min_h = _getDataSize("h", min_h_str, 0);
				if (temp_min_w > min_w) {
					min_w = temp_min_w;
				}
				if (temp_min_h > min_h) {
					min_h = temp_min_h;
				}
			}
		}else if (data.hasNode.max_size) {
			for(maxNode in data.nodes.max_size){
				var max_w_str:String = U.xml_str(maxNode.x, "width");
				var max_h_str:String = U.xml_str(maxNode.x, "height");
				temp_max_w = _getDataSize("w", max_w_str, Math.POSITIVE_INFINITY);
				temp_max_h = _getDataSize("h", max_h_str, Math.POSITIVE_INFINITY);
				if (temp_max_w < max_w) {
					max_w = temp_max_w;
				}
				if (temp_max_h < max_h) {
					max_h = temp_max_h;
				}
			}
		}else {
			return null;
		}
		
		if (width != null){
			if (width > min_w) { min_w = width; }
			if (width < max_w) { max_w = width; }
		}
		if (height != null) {
			if (height > min_h) { min_h = height; }
			if (height < max_h) { max_h = height; }
		}
		
		//don't go below 0 folks:
		
		if (max_w <= 0) { max_w = Math.POSITIVE_INFINITY; }
		if (max_h <= 0) { max_h = Math.POSITIVE_INFINITY; }
		
		return { min_width:min_w, min_height:min_h, max_width:max_w, max_height:max_h };
	}
	
	private function _getDataSize(target:String, str:String, default_:Float = 0):Float {		
		
		if (U.isStrNum(str)) {								//Most likely: is it just a number?
			return Std.parseFloat(str);						//If so, parse and return
		}
		
		var percf:Float = U.perc_to_float(str);			//Next likely: is it a %?
		if(!Math.isNaN(percf)){				
			switch(target) {
				case "w", "width":	return thisWidth() * percf;		//return % of screen size
				case "h", "height": return thisHeight() * percf;
			}
		}else {												//Next likely: is it a stretch command?
			if (str.indexOf("stretch:") == 0) {				
				str = StringTools.replace(str, "stretch:", "");
				var arr:Array<String> = str.split(",");
				var stretch_0:Float = _getStretch(0, target, arr[0]);
				var stretch_1:Float = _getStretch(1, target, arr[1]);
				if(stretch_0 != -1 && stretch_1 != -1){
					return stretch_1 - stretch_0;
				}else {
					return default_;
				}
			}else if (str.indexOf("asset:") == 0) {			//Next likely: is it an asset property?
				str = StringTools.replace(str, "asset:", "");
				var assetValue:Float = _getStretch(1, target, str);
				return assetValue;				
			}else {											//Next: is it a formula?
				var r:EReg = ~/[\w]+\.[\w]+/;
				if (r.match(str)) {
					var assetValue:Float = _getStretch(1, target, str);
					return assetValue;
				}
			}
		}
		
		return default_;
	}
	
	/**
	 * Give me a string like "thing.right+10" and I'll return ["+",10]
	 * Only accepts one operator and operand at max!
	 * The operand MUST be a number.
	 * @param	string of format: <value><operator><operand>
	 * @return [<value>:String,<operator>:String,<operand>:Float]
	 */
	
	private function _getOperation(str:String):Array<Dynamic> {
		var list:Array<String> = ["+", "-", "*", "/", "^"];
		var temp:Array<String> = null;
		
		for (operator in list) {
			if (str.indexOf(operator) != -1) {		//return on the FIRST valid operator match found
				temp = str.split(operator);			
				if (temp != null && temp.length == 2) {		//if I find exactly one operator/operand
					var f:Float = Std.parseFloat(temp[1]);	//try to read the operand as a number
					if (f == 0 && temp[1] != "0") {
						return null;	//improperly formatted, invalid operand, bail out
					}else{
						return [temp[0], operator, f];	//proper operand and operator
					}
				}
			}
		}
		
		return null;
	}
	
	private function _doOperation(value:Float, operator:String, operand:Float):Float {
		switch(operator) {
			case "+": return value + operand;
			case "-": return value - operand;
			case "/": return value / operand;
			case "*": return value * operand;
			case "^": return Math.pow(value, operand);
		}
		return value;
	}
	
	private function _getStretch(index:Int, target:String, str:String):Float {
		var arr:Array<Dynamic> = null;
		var prop:String = "";
		var operator:String = "";
		var operand:Float = 0;
		
		arr = _getOperation(str);
		if (arr != null) {
			str = cast arr[0];
			operator = cast arr[1];
			operand = cast arr[2];
		}
		
		if (str.indexOf(".") != -1) {
			arr = str.split(".");
			str = arr[0];
			prop = arr[1];			
		}
		
		var other:IFlxUIWidget = getAsset(str);
				
		var return_val:Float = 0;
		
		if (other == null) {			
			switch(str) {
				case "top", "up": return_val = 0;
				case "bottom", "down": return_val = thisHeight();
				case "left": return_val = 0;
				case "right": return_val = thisWidth();				
				default:
					if (U.isStrNum(str)) {
						return_val = Std.parseFloat(str);
					}else {
						return_val = -1;
					}
			}
		}else {
			switch(target) {
				case "w", "width": 
					if(prop == ""){
						if (index == 0) { return_val = other.x + other.width; }
						if (index == 1) { return_val = other.x; }
					}else {
						switch(prop) {
							case "top", "up", "y": return_val = other.y;
							case "bottom", "down": return_val = other.y +other.height;
							case "right": return_val = other.x + other.width;
							case "left","x": return_val = other.x;
							case "center": return_val = other.x + (other.width / 2);
							case "width": return_val = other.width;
							case "height": return_val = other.height;
						}
					}
				case "h", "height":
					if(prop == ""){
						if (index == 0) { return_val = other.y + other.height; }
						if (index == 1) { return_val = other.y; }
					}else {
						switch(prop){
							case "top", "up", "y": return_val = other.y;
							case "bottom", "down": return_val = other.y +other.height;
							case "right": return_val = other.x + other.width;
							case "left","x": return_val = other.x;
							case "center": return_val = other.y + (other.height / 2);
							case "height": return_val = other.height;
							case "width": return_val = other.width;
						}
					}
			}
		}
		
		if (return_val != -1 && operator != "") {
			return_val = _doOperation(return_val, operator, operand);
		}
		
		return return_val;
	}
		
	private function _loadPosition(data:Fast, thing:IFlxUIWidget):Void {
		var X:Float = _loadX(data);			//position offset from 0,0
		var Y:Float = _loadY(data);
			
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
			anchor_x_flush = U.xml_str(data.node.anchor.x, "x-flush",true);
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
			
			if(anchor_x_str != ""){
				thing.x = anchor_x;
			}
			if(anchor_y_str != ""){
				thing.y = anchor_y;
			}
			//_delta(thing, anchor_x, anchor_y);
		}
		
		//Try to center the object on the screen:
		if (ctrX || ctrY) {
			_center(thing,ctrX,ctrY);
		}
				
		//Then, try to center it on another object:
		if (center_on != "") {
			var other = getAsset(center_on);
			if (other != null) {
				U.center(cast(other, FlxObject), cast(thing, FlxObject));
			}
		}else {
			if (center_on_x != "") {
				var other = getAsset(center_on);
				if (other != null) {
					U.center(cast(other, FlxObject), cast(thing, FlxObject), true, false);
				}
			}
			if (center_on_y != "") {
				var other = getAsset(center_on);
				if (other != null) {
					U.center(cast(other, FlxObject), cast(thing, FlxObject), false, true);
				}
			}
		}
		
		//Then, add its offset to wherever it wound up:
		_delta(thing, X, Y);
	}	
	
	private function _loadBorder(data:Fast):Array<Dynamic>
	{
		var border_str:String = U.xml_str(data.x, "border");
		var border_style:Int = FlxText.BORDER_NONE;
		var border_color:Int = _loadColor(data, "border_color", 0);
		var border_size:Int = U.xml_i(data.x, "border_size", 1);
		var border_quality:Float = U.xml_f(data.x, "border_quality", 0);
		
		switch(border_str) {
			case "shadow": border_style = FlxText.BORDER_SHADOW;
			case "outline": border_style = FlxText.BORDER_OUTLINE;
			case "outline_fast": border_style = FlxText.BORDER_OUTLINE_FAST;
			case "":
				//no "border" value, check for shortcuts:
				//try "outline"
				border_str = U.xml_str(data.x, "shadow", true, "");
				if (border_str != "") {
					border_style = FlxText.BORDER_SHADOW;
					border_color = U.parseHex(border_str, false, true);
				}else{
					border_str = U.xml_str(data.x, "outline", true, "");
					if (border_str != "") {
						border_style = FlxText.BORDER_OUTLINE;
						border_color = U.parseHex(border_str, false, true);
					}else{
						border_str = U.xml_str(data.x, "outline_fast");
						if (border_str != "") {
							border_style = FlxText.BORDER_OUTLINE_FAST;
							border_color = U.parseHex(border_str, false, true);
						}
					}
				}	
		}	
		
		return [border_style, border_color, border_size, border_quality];
	}
	
	private function _loadColor(data:Fast,colorName:String="color",_default:Int=0xffffffff):Int {
		var colorStr:String = U.xml_str(data.x, colorName);
		if (colorStr == "" && data.x.nodeName == colorName) { 
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
	
	private function _onFinishLoad():Void {
		if (_ptr != null) {
			_ptr.getEvent("finish_load", this, null);
		}
	}
	
	/*
	private function _onClickDropDown_control(isActive:Bool, dropdown:FlxUIDropDownMenu):Void {
		if (isActive) {
			focus = dropdown;
		}else {
			focus = null;
		}
	}*/
	
	/**********UTILITY FUNCTIONS************/
	
	public function getText(flag:String, context:String = "data", safe:Bool = true, code:String=""):String {
		var str:String = "";
		if(_ptr_tongue != null){
			str = _ptr_tongue.get(flag, context, safe);
			return formatFromCode(str, code);
		}else if(getTextFallback != null){
			str = getTextFallback(flag, context, safe);
			return formatFromCode(str, code);
		}
		
		return flag;
	}
	
	private function formatFromCode(str:String, code:String):String {
		switch(code) {
			case "u": return str.toUpperCase();		//uppercase
			case "l": return str.toLowerCase();		//lowercase
			case "fu": return U.FU(str);			//first letter uppercase
			case "fu_": return U.FU_(str);			//first letter in each word uppercase
		}
		return str;
	}
	
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
			
	private function formatButtonText(data:Fast, button:Dynamic):Void {
		if (data != null && data.hasNode.text) {
			var textNode = data.node.text;
			var use_def:String = U.xml_str(textNode.x, "use_def", true);
			var text_def:Fast = null;
			
			if (use_def != "") {
				text_def = getDefinition(use_def);
			}
			
			var info:Fast = consolidateData(textNode, text_def);
			
			var case_id:String = U.xml_str(info.x, "id", true);
			var the_font:String = _loadFontFace(info);
			var size:Int = U.xml_i(info.x, "size"); if (size == 0) { size = 8;}
			var color:Int = _loadColor(info);
			
			var border:Array<Dynamic> = _loadBorder(info);
			
			var align:String = U.xml_str(info.x, "align", true); if (align == "") { align = null;}
			
			var the_label:FlxText=null;
			var fb:FlxUIButton = null;
			var cb:FlxUICheckBox = null;
			
			if (Std.is(button, FlxUIButton)) {
				fb = cast button;
				if (align == "" || align == null) {
					align = "center";
				}
			}else if (Std.is(button, FlxUICheckBox)) {
				var cb:FlxUICheckBox = cast button;
				fb = cb.button;
				align = "left";			//force this for check boxes
			}
			
			the_label = fb.label;
			fb.up_color = color;
			fb.down_color = 0;
			fb.over_color = 0;
			
			if (the_label != null) {
				the_label.setFormat(the_font, size, color, align);
				
				the_label.borderStyle = border[0];
				the_label.borderColor = border[1];
				the_label.borderSize = border[2];
				the_label.borderQuality = border[3];
				
				if (Std.is(the_label, FlxUIText)) {
					var ftu:FlxUIText = cast the_label;
					ftu.drawFrame();
				}
				
				fb.autoCenterLabel();
			}	
			
			for (textColorNode in info.nodes.color) {
				var color:Int = _loadColor(textColorNode);
				var state_id:String = U.xml_str(textColorNode.x, "id", true);
				var toggle:Bool = U.xml_bool(textColorNode.x, "toggle");
				switch(state_id) {
					case "up", "inactive", "", "normal": 
						if (!toggle) {
							fb.up_color = color; 
						}else {
							fb.up_toggle_color = color;
						}
					case "active", "hilight", "over", "hover": 
						if(!toggle){
							fb.over_color = color; 
						}else {
							fb.over_toggle_color = color;
						}
					case "down", "pressed", "pushed": 
						if(!toggle){
							fb.down_color = color; 
						}else {
							fb.down_toggle_color = color;
						}
				}
			}
			
			if (fb.over_color == 0) {			//if no over color, match up color
				fb.over_color = fb.up_color;
			}
			if (fb.down_color == 0) {			//if no down color, match over color
				fb.down_color = fb.over_color;
			}
			
			//if toggles are undefined, match them to the normal versions
			if (fb.up_toggle_color == 0) {
				fb.up_toggle_color = fb.up_color;
			}
			if (fb.over_toggle_color == 0) {
				fb.over_toggle_color = fb.over_color;
			}
			if (fb.down_toggle_color == 0) {
				fb.down_toggle_color = fb.down_color;
			}
		}
	}
}

typedef UIEventCallback = String->IFlxUIWidget->Dynamic->Array<Dynamic>->Void;

typedef NamedBool = {
	name:String,
	value:Bool
}

typedef NamedInt = {
	name:String,
	value:Int
}

typedef NamedFloat = {
	name:String,
	value:Float
}

typedef NamedString = {
	name:String,
	value:String
}

typedef MaxMinSize = {
	min_width:Float,
	min_height:Float,
	max_width:Float,
	max_height:Float
}
