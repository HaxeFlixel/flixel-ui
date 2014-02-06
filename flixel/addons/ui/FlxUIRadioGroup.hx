package flixel.addons.ui;

import flixel.addons.ui.FlxUI.NamedBool;
import flixel.addons.ui.interfaces.IFlxUIButton;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.interfaces.IHasParams;
import flixel.util.FlxPoint;

/**
 * @author Lars Doucet
 */
class FlxUIRadioGroup extends FlxUIGroup implements IFlxUIButton implements IHasParams
{
	public var clickable(get_clickable, set_clickable):Bool;
	public var selectedId(get_selectedId, set_selectedId):String;
	public var selectedLabel(get_selectedLabel, set_selectedLabel):String;
	public var selectedIndex(get_selectedIndex, set_selectedIndex):Int;
	
	public static inline var CLICK_EVENT:String = "click_radio_group";
	
	public var skipButtonUpdate(default, set):Bool;
	public function set_skipButtonUpdate(b:Bool):Bool {
		skipButtonUpdate = b;
		var fcb:FlxUICheckBox;
		for (fcb in _list_radios) {
			fcb.skipButtonUpdate = b;
		}
		return skipButtonUpdate;
	}
	
	public var params(default, set):Array<Dynamic>;
	public function set_params(p:Array <Dynamic>):Array<Dynamic>{
		params = p;
		return params;
	}
	
	public function new(X:Float, Y:Float, ids_:Array<String>,labels_:Array<String>, callback_:Dynamic, y_space_:Float=25, width_:Int=100, height_:Int=20, label_width_:Int=100):Void {
		super();
		_y_space = y_space_;
		_width = width_;
		_height = height_;
		_label_width = label_width_;
		x = X;
		y = Y;
		_list_radios = new Array<FlxUICheckBox>();
		updateRadios(ids_, labels_);
		loadGraphics(null, null);
	}
	
	public function loadGraphics(Box:Dynamic,Dot:Dynamic):Void {
		if(Box != null){
			_box_asset = Box;
		}else {
			_box_asset = FlxUIAssets.IMG_RADIO;
		}
		if(Dot != null){
			_dot_asset = Dot;
		}else {
			_dot_asset = FlxUIAssets.IMG_RADIO_DOT;
		}
		
		for (c in _list_radios) {
			c.box.loadGraphic(_box_asset, true, false);
			c.mark.loadGraphic(_dot_asset);
		}	
		_refreshRadios();
	}
	
	public override function destroy():Void {
		if (_list_radios != null) {
			U.clearArray(_list_radios);	
		}
		_ids = null;
		_labels = null;
		super.destroy();
	}
	
	public function updateLabel(i:Int, label_:String):Bool{
		if (i >= _list_radios.length) return false;
		_labels[i] = label_;
		var c:FlxUICheckBox = _list_radios[i];
		if (c != null) {
			c.button.width = _label_width;
			c.text = label_;
		}		
		return true;
	}
	
	public function updateId(i:Int, id_:String):Bool{
		if (i >= _list_radios.length) return false;
		_ids[i] = id_;
		return true;
	}
	
	public function show(b:Bool):Void {
		for(fo in members) {
			fo.visible = b;
		}
	}
	
	public function updateRadios(ids_:Array<String>, labels_:Array<String>):Void {
		_ids = ids_;
		_labels = labels_;
		for(c in _list_radios) {
			c.visible = false;
		}
		_refreshRadios();
	}
	
	/***GETTER / SETTER***/
	
	public function get_clickable():Bool { return _clickable; }
	public function set_clickable(b:Bool):Bool { 
		_clickable = b;
		for(c in _list_radios) {
			c.active = b;
		}
		return _clickable;
	}
	
	public function get_selectedIndex():Int { return _selected; }
	public function set_selectedIndex(i:Int):Int {
		_selected = i;
		var j:Int = 0;
		for(c in _list_radios) {
			c.checked = false;
			if (j == i) {
				c.checked = true;
			}
			j++;
		}
		return _selected;
	}
	
	public function get_selectedLabel():String { return _labels[_selected]; }
	public function set_selectedLabel(str:String):String {
		var i:Int = 0;
		for(c in _list_radios) {
			c.checked = false;
			if (_labels[i] == str) {
				_selected = i;
				c.checked = true;
				break;
			}
			i++;
		}
		return _labels[_selected];
	}
	
	public function get_selectedId():String { return _ids[_selected]; }
	public function set_selectedId(str:String):String {
		var i:Int = 0;
		for(c in _list_radios) {
			c.checked = false;
			if (_ids[i] == str) {
				_selected = i;
				c.checked = true;
				break;
			}
			i++;
		}
		return _ids[_selected];
	}
	
	/**
	 * If you want to show only a portion of the radio group, scrolled line-by-line
	 * This will scroll the "pane" by that amount and return how many lines are above/below
	 * the currently visible pane
	 * @param	scroll How many lines DOWN you have scrolled
	 * @param	max_items Max amount of lines visible
	 * @return a FlxPoint of off-pane radio lines : (count_above,count_below)
	 */
	
	public function setLineScroll(scroll:Int, max_items:Int):FlxPoint{
		var i:Int = 1;
		var yy:Float = y;
		var more_above:Int = 0;
		var more_below:Int = 0;
		for(c in _list_radios) {
			if (i <= scroll) {
				c.visible = false;
				more_above++;
			}else if (i > scroll + max_items) {
				c.visible = false;
				more_below++;
			}else {
				c.x = Std.int(x);
				c.y = Std.int(yy);
				yy += _y_space;
				c.visible = true;
			}
			i++;
		}
		return new FlxPoint(more_above, more_below);
	}
	
	/***GETTER / SETTER***/
	
	
	
	/***PRIVATE***/
	
	private var _box_asset:Dynamic;
	private var _dot_asset:Dynamic;
	
	private var _labels:Array<String>;
	private var _ids:Array<String>;
	
	private var _label_width:Int = 100;
	private var _width:Int = 100;
	private var _height:Int = 20;
	
	private var _y_space:Float = 25;
	private var _selected:Int = 0;
	
	private var _clickable:Bool = true;
	private var _list_radios:Array<FlxUICheckBox>;
	
	/**
	 * Create the radio elements if necessary, and/or just refresh them
	 */
	
	private function _refreshRadios():Void {
		var xx:Float = 0;
		var yy:Float = 0;
		var i:Int = 0;
		for(id in _ids) {
			var label:String = "";
			if (_labels != null && _labels.length > i) {
				label = _labels[i];
			}else {
				label = "<" + id + ">";	//"soft" error, indicates undefined label
			}
			var c:FlxUICheckBox;
			if (_list_radios.length > i) {
				c = _list_radios[i];
				c.visible = true;
				c.text = label;
				if (i == 0) {
					xx = c.x;
					yy = c.y;
				}
			}else {
				c = new FlxUICheckBox(0, 0, _box_asset, _dot_asset, label, _label_width, [id, false]);
				c.uiEventCallback = _onCheckBoxEvent;
				c.x = Std.int(xx);
				c.y = Std.int(yy);
				
				add(c);
				c.text = label;
				_list_radios.push(c);
			}
			yy += _y_space;
			i++;
		}
	}
	
	private function _onCheckBoxEvent(id:String, sender:IFlxUIWidget, data:Dynamic):Void {
		_onClick(cast sender, true);
	}
	
	private function _onClick(checkBox:FlxUICheckBox, doCallback:Bool):Bool{
		if (!_clickable) { return false; }
		
		var i:Int = 0;
		for (c in _list_radios) {
			c.checked = false;
			if (checkBox == c) {
				_selected = i;
				c.checked = true;
			}
			i++;
		}
		
		if (doCallback) {
			if (uiEventCallback != null) {
				if(params != null){
					uiEventCallback(CLICK_EVENT, this, [_ids[_selected], params]);
				}else {
					uiEventCallback(CLICK_EVENT, this, [_ids[_selected]]);
				}
			}
		}
		return true;
	}
}