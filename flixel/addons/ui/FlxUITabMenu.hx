package flixel.addons.ui;

import flash.geom.Rectangle;
import flixel.addons.ui.interfaces.IEventGetter;
import flixel.addons.ui.interfaces.IFlxUIClickable;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.interfaces.IResizable;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxPoint;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;

/**
 * @author Lars Doucet
 */
class FlxUITabMenu extends FlxUIGroup implements IResizable implements IFlxUIClickable implements IEventGetter
{

	public static inline var CLICK_EVENT:String = "tab_menu_click";
	
	public static inline var STACK_FRONT:String = "front";		//button goes in front of backing
	public static inline var STACK_BACK:String = "back";		//buton goes behind backing
	
	/**To make IEventGetter happy**/
	public function getEvent(name:String, sender:IFlxUIWidget, data:Dynamic, ?params:Array<Dynamic>):Void {
		//donothing
	}
	
	public function getRequest(name:String, sender:IFlxUIWidget, data:Dynamic, ?params:Array<Dynamic>):Dynamic {
		//donothing
		return null;
	}
	
	/**For IFlxUIClickable**/
	
	public var skipButtonUpdate(default, set):Bool;
	private function set_skipButtonUpdate(b:Bool):Bool {
		skipButtonUpdate = b;
		var tab:FlxUIButton;
		for (tab in _tabs) {
			tab.skipButtonUpdate = b;
		}
		var group:FlxUIGroup;
		for (group in _tab_groups) {
			var sprite:FlxSprite;
			for (sprite in group.members) {
				if (Std.is(sprite, IFlxUIClickable)) {
					var widget:IFlxUIClickable = cast sprite;
					widget.skipButtonUpdate = b;
				}
			}
		}
		return b;
	}
	
	/**For IResizable**/
	
	private override function get_width():Float {
		return _back.width;
	}
	
	private override function get_height():Float {
		var fbt = getFirstTab();
		if (fbt != null) {
			return (_back.y + _back.height) - fbt.y;
		}
		return _back.height;
	}
	
	public function resize(W:Float, H:Float):Void {
		var ir:IResizable;
		if (Std.is(_back, IResizable)) {
			ir = cast _back;
			var fbt = getFirstTab();
			if(fbt != null){
				ir.resize(W, H-fbt.get_height());
			}else {
				ir.resize(W, H);
			}
		}
		distributeTabs();
	}
	
	public var selected_tab(get, set):Int;
	private function get_selected_tab():Int { return _selected_tab; }
	private function set_selected_tab(i:Int):Int { 
		showTabInt(i);			//this modifies _selected_tab/_selected_tab_id
		return _selected_tab; 
	}
	
	public var selected_tab_id(get, set):String;
	private function get_selected_tab_id():String { return _selected_tab_id; }
	private function set_selected_tab_id(str:String):String {
		showTabId(str);			//this modifies _selected_tab/_selected_tab_id
		return _selected_tab_id;
	}
	
	/***PUBLIC***/
	
	public function new(?back_:FlxSprite,?tabs_:Array<FlxUIButton>,?tab_ids_and_labels_:Array<{id:String,label:String}>,?tab_offset:FlxPoint,?stretch_tabs:Bool=false,?tab_spacing:Null<Float>=null,?tab_stacking:Array<String>=null) 
	{
		super();
		
		if (back_ == null) {
			//default, make this:
			back_ = new FlxUI9SliceSprite(0, 0, FlxUIAssets.IMG_CHROME_FLAT, new Rectangle(0, 0, 200, 200));
		}
		
		_back = back_;
		add(_back);
		
		if (tabs_ == null) {
			if (tab_ids_and_labels_ != null) {
				tabs_ = new Array<FlxUIButton>();
			
				//load default graphic data if only tab_ids_and_labels are provided
				for (tdata in tab_ids_and_labels_) {
					//set label and id
					var fb:FlxUIButton = new FlxUIButton(0, 0, tdata.label);
					
					//default style:
					fb.up_color = 0xffffff;
					fb.down_color = 0xffffff;
					fb.over_color = 0xffffff;
					fb.up_toggle_color = 0xffffff;
					fb.down_toggle_color = 0xffffff;
					fb.over_toggle_color = 0xffffff;
					
					fb.label.color = 0xFFFFFF;
					fb.label.setBorderStyle(FlxText.BORDER_OUTLINE);
					
					fb.id = tdata.id;
					
					//load default graphics
					var graphic_ids:Array<String> = [FlxUIAssets.IMG_TAB_BACK, FlxUIAssets.IMG_TAB_BACK, FlxUIAssets.IMG_TAB_BACK, FlxUIAssets.IMG_TAB, FlxUIAssets.IMG_TAB, FlxUIAssets.IMG_TAB];
					var slice9tab:Array<Int> = FlxStringUtil.toIntArray(FlxUIAssets.SLICE9_TAB);
					var slice9_ids:Array<Array<Int>> = [slice9tab, slice9tab, slice9tab, slice9tab, slice9tab, slice9tab];
					fb.loadGraphicSlice9(graphic_ids, 0, 0, slice9_ids, FlxUI9SliceSprite.TILE_NONE, -1, true);
					tabs_.push(fb);
				}
			}
		}
		
		_tabs = tabs_;
		_stretch_tabs = stretch_tabs;
		_tab_spacing = tab_spacing;
		_tab_stacking = tab_stacking;
		if (_tab_stacking == null) {
			_tab_stacking = [STACK_FRONT, STACK_BACK];
		}
		_tab_offset = tab_offset;
		
		var i:Int = 0;
		var tab:FlxUIButton;
		for (tab in _tabs) {
			add(tab);
			tab.onUp.callback = _onTabEvent.bind(tab.id);
			i++;
		}
		
		distributeTabs();
		
		_tab_groups = new Array<FlxUIGroup>();
	}
	
	public override function destroy():Void {
		super.destroy();
		U.clearArray(_tab_groups);
		U.clearArray(_tabs);
		_back = null;
		_tabs = null;
		_tab_groups = null;
	}
	
	public function getTab(?id:String, ?index:Null<Int>):FlxUIButton{
		if (id != null) {
			for (tab in _tabs) {
				if (tab.id == id) {
					return tab;
				}
			}
		}
		if (index != null) {
			if (index < _tabs.length) {
				return _tabs[index];
			}
		}
		return null;
	}
	
	public function getTabGroup(?id:String, ?index:Null<Int>):FlxUIGroup {
		var tabGroup:FlxUIGroup;
		if (id != null) {
			for (tabGroup in _tab_groups) {
				if (tabGroup.id == id) {
					return tabGroup;
				}
			}
		}
		if (index != null) {
			if (index < _tab_groups.length) {
				return _tab_groups[index];
			}
		}
		return null;
	}
	
	public function addGroup(g:FlxUIGroup):Void {
		if (g == this) {
			return;			//DO NOT ADD A GROUP TO ITSELF
		}
		
		if (!hasThis(g)) {	//ONLY ADD IF IT DOESN'T EXIST
			g.y = (_back.y - y);
			add(g);
			_tab_groups.push(g);
		}
		
		//hide the new group
		_showOnlyGroup("");
		
		//if this is our first group, show it right now
		if (_tab_groups.length == 1) {
			selected_tab = 0;
		}	
		
		//refresh selected tab after group is added
		if (_selected_tab != -1) {
			selected_tab = _selected_tab;
		}
	}
	
	private function _onTabEvent(id:String):Void {
		showTabId(id);
		if (broadcastToFlxUI) {
			FlxUI.event(CLICK_EVENT, this, id);
		}
	}
	
	public function showTabId(id:String):Void {
		
		_selected_tab = -1;
		_selected_tab_id = "";
		
		var i:Int = 0;
		for (tab in _tabs) {
			tab.toggled = false;
			tab.forceStateHandler(FlxUITypedButton.OUT_EVENT);
			if (tab.id == id) {
				tab.toggled = true;
				_selected_tab_id = id;
				_selected_tab = i;
			}
			i++;
		}
		
		_showOnlyGroup(id);
		stackTabs();
	}
	
	/***PRIVATE***/
	
	private var _back:FlxSprite;
	private var _tabs:Array<FlxUIButton>;
	private var _tab_groups:Array<FlxUIGroup>;
	private var _stretch_tabs:Bool = false;
	private var _tab_spacing:Null<Float> = null;
	private var _tab_stacking:Array<String> = null;
	private var _tab_offset:FlxPoint = null;
	
	private var _selected_tab_id:String = "";
	private var _selected_tab:Int = -1;
	
	private function stackTabs():Void {
		var _backx:Float = _back.x;
		var _backy:Float = _back.y;
		
		var _tabPts:Array<FlxPoint> = [];
		
		remove(_back, true);
		
		for (tab in _tabs) {
			if (tab.toggled) {
				_tabPts.push(FlxPoint.get(tab.x, tab.y));
				remove(tab, true);
			}
		}
		
		add(_back);
		
		for (tab in _tabs) {
			if (tab.toggled) {
				add(tab);
				tab.x = _tabPts[0].x;
				tab.y = _tabPts[0].y;
				_tabPts[0].put();
				_tabPts.splice(0, 1);
			}
		}
		
		//Put tab groups back on top
		for (group in _tab_groups) {
			var tempX:Float = group.x;
			var tempY:Float = group.y;
			remove(group, true);
			add(group);
			group.x = tempX;
			group.y = tempY;
		}
		
		_back.x = _backx;
		_back.y = _backy;
	}
	
	private function sortTabs(a:FlxUIButton, b:FlxUIButton):Int {
		if (a.id < b.id) {
			return -1;
		}else if (a.id > b.id) {
			return 1;
		}
		return -1;
	}
	
	private function showTabInt(i:Int):Void {
		if(i >= 0 && _tabs != null && _tabs.length > i){
			var _tab:FlxUIButton = _tabs[i];
			var id:String = _tab.id;
			showTabId(id);
		}else {
			showTabId("");
		}
	}
	
	private function _showOnlyGroup(id:String):Void {
		for (group in _tab_groups) {
			if (group.id == id) {
				group.visible = group.active = true;
			}else {
				group.visible = group.active = false;
			}
		}
	}
	
	private function getFirstTab():FlxUIButton{
		var _the_tab:FlxUIButton = null;
		if(_tabs != null && _tabs.length > 0){
			_the_tab = _tabs[0];
		}
		return _the_tab;
	}
	
	private function distributeTabs():Void {
		var xx:Float = 0;
		
		var tab_width:Float = 0;
		
		var diff_size:Float = 0;
		if (_stretch_tabs) {
			tab_width = _back.width / _tabs.length;
			var tot_size:Float = (Std.int(tab_width) * _tabs.length);
			if (tot_size < _back.width) {
				diff_size = (_back.width - tot_size);
			}
		}
		
		_tabs.sort(sortTabs);
		
		for (tab in _tabs) {
			
			tab.x = x + xx;
			tab.y = y + 0;
			
			if (_tab_offset != null) {
				tab.x += _tab_offset.x;
				tab.y += _tab_offset.y;
			}
			
			if (_stretch_tabs) {
				if(diff_size > 0){
					tab.resize(tab_width + 1, tab.get_height());
					xx += (Std.int(tab_width)+1);
					diff_size -= 1;
				}else {
					tab.resize(tab_width, tab.get_height());
					xx += Std.int(tab_width);
				}
			}else {
				if(_tab_spacing != null){
					xx += tab.width + _tab_spacing;
				}else {
					xx += tab.width;
				}
			}
		}
		
		if (_tabs != null && _tabs.length > 0 && _tabs[0] != null) {
			_back.y = _tabs[0].y + _tabs[0].height - 2;
			if (_tab_offset != null) {
				_back.y -= _tab_offset.y;
			}
		}
		
		calcBounds();
	}
}
