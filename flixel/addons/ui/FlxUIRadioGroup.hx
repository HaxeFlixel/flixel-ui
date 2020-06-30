package flixel.addons.ui;

import flixel.addons.ui.FlxUI.NamedBool;
import flixel.addons.ui.interfaces.IFlxUIButton;
import flixel.addons.ui.interfaces.IFlxUIClickable;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.interfaces.IHasParams;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.math.FlxPoint;

/**
 * @author Lars Doucet
 */
class FlxUIRadioGroup extends FlxUIGroup implements IFlxUIClickable implements IHasParams
{
	public var clickable(get, set):Bool;
	public var selectedId(get, set):String;
	public var selectedLabel(get, set):String;
	public var selectedIndex(get, set):Int;

	public var activeStyle(default, set):CheckStyle;

	private function set_activeStyle(b:CheckStyle):CheckStyle
	{
		activeStyle = b;
		updateActives();
		return activeStyle;
	}

	public var inactiveStyle(default, set):CheckStyle;

	private function set_inactiveStyle(b:CheckStyle):CheckStyle
	{
		inactiveStyle = b;
		updateActives();
		return inactiveStyle;
	}

	public var numRadios(get, never):Int;

	private function get_numRadios():Int
	{
		return _list_radios.length;
	}

	public static inline var CLICK_EVENT:String = "click_radio_group";

	public var skipButtonUpdate(default, set):Bool;

	private function set_skipButtonUpdate(b:Bool):Bool
	{
		skipButtonUpdate = b;
		for (fcb in _list_radios)
		{
			fcb.skipButtonUpdate = b;
		}
		return skipButtonUpdate;
	}

	public var callback:String->Void;

	public var params(default, set):Array<Dynamic>;

	private function set_params(p:Array<Dynamic>):Array<Dynamic>
	{
		params = p;
		return params;
	}

	/**
	 * If this is false, when the size changes it auto-expands the scroll canvas
	 * If this is true, when the size changes it forces it to scroll
	 */
	public var fixedSize:Bool = false;

	public override function set_width(Value:Float):Float
	{
		super.set_width(Value);
		if (fixedSize)
		{
			if (_list != null)
			{
				_list.width = Value;
			}
		}
		return Value;
	}

	public override function set_height(Value:Float):Float
	{
		super.set_height(Value);
		if (fixedSize)
		{
			if (_list != null)
			{
				_list.height = Value;
			}
		}
		return Value;
	}

	/**
	 * Creates a set of radio buttons
	 * @param	X				X location
	 * @param	Y				Y location
	 * @param	ids_			list of string identifiers
	 * @param	labels_			list of string labels for each button (what the user sees)
	 * @param	callback_		optional callback expecting a string identifier of selected radio button
	 * @param	y_space_		vertical space between buttons
	 * @param	width_			maximum width of a button
	 * @param	height_			height of a button
	 * @param	label_width_	maximum width of a label
	 * @param	MoreString		Localized string that says "<X> more..." in your language. MUST have "<X>" token
	 * @param	PrevButtonOffset	Offset for the "previous" scroll button
	 * @param	NextButtonOffset	Offset for the "next" scroll button
	 * @param	PrevButton		Your own custom button for the "previous" scroll button
	 * @param	NextButton		Your own custom button for the "next" scroll button
	 */
	public function new(X:Float, Y:Float, ?ids_:Array<String>, ?labels_:Array<String>, ?callback_:String->Void = null, y_space_:Float = 25, width_:Int = 100,
			height_:Int = 20, label_width_:Int = 100, MoreString:String = "<X> more...", PrevButtonOffset:FlxPoint = null, NextButtonOffset:FlxPoint = null,
			PrevButton:IFlxUIButton = null, NextButton:IFlxUIButton = null):Void
	{
		super();
		_y_space = y_space_;
		_width = width_;
		_height = height_;
		_label_width = label_width_;
		if (ids_ == null)
			ids_ = [];
		if (labels_ == null)
			labels_ = [];
		callback = callback_;
		_list_radios = new Array<FlxUICheckBox>();
		_list_active = [];
		_list = new FlxUIList(0, 0, null, 0, 0, MoreString, FlxUIList.STACK_VERTICAL, 0, PrevButtonOffset, NextButtonOffset, PrevButton, NextButton);
		add(_list);
		updateRadios(ids_, labels_);
		loadGraphics(null, null);
		x = X;
		y = Y;
	}

	public function loadGraphics(Box:Dynamic, Dot:Dynamic):Void
	{
		if (Box != null)
		{
			_box_asset = Box;
		}
		else
		{
			_box_asset = FlxUIAssets.IMG_RADIO;
		}
		if (Dot != null)
		{
			_dot_asset = Dot;
		}
		else
		{
			_dot_asset = FlxUIAssets.IMG_RADIO_DOT;
		}

		if ((_box_asset is FlxSprite))
		{
			var fs:FlxSprite = cast _box_asset;
			_box_asset = fs.graphic.key;
		}

		if ((_dot_asset is FlxSprite))
		{
			var fs:FlxSprite = cast _dot_asset;
			_dot_asset = fs.graphic.key;
		}

		for (c in _list_radios)
		{
			c.box.loadGraphic(_box_asset, true);
			c.mark.loadGraphic(_dot_asset);
		}
		_refreshRadios();
	}

	public override function destroy():Void
	{
		if (_list_radios != null)
		{
			U.clearArray(_list_radios);
		}
		if (_list_active != null)
		{
			U.clearArray(_list_active);
		}
		_list_active = null;
		_list_radios = null;
		_list = null;
		_ids = null;
		_labels = null;
		super.destroy();
	}

	public function updateLabel(i:Int, label_:String):Bool
	{
		if (i >= _list_radios.length)
			return false;
		_labels[i] = label_;
		var c:FlxUICheckBox = _list_radios[i];
		if (c != null)
		{
			c.button.width = _label_width;
			c.text = label_;
		}
		return true;
	}

	public function updateId(i:Int, id_:String):Bool
	{
		if (i >= _list_radios.length)
			return false;
		_ids[i] = id_;
		return true;
	}

	public function show(b:Bool):Void
	{
		for (fo in _list.members)
		{
			fo.visible = b;
		}
	}

	public function updateRadios(ids_:Array<String>, labels_:Array<String>):Void
	{
		_ids = ids_;
		_labels = labels_;
		for (c in _list_radios)
		{
			c.visible = false;
		}
		_refreshRadios();
	}

	public function getRadios():Array<FlxUICheckBox>
	{
		return _list_radios;
	}

	public function getLabel(i:Int):String
	{
		if (i >= 0 && i < _labels.length)
		{
			return _labels[i];
		}
		return null;
	}

	public function getId(i:Int):String
	{
		if (i >= 0 && i < _ids.length)
		{
			return _ids[i];
		}
		return null;
	}

	public function getIsVisible(i:Int):Bool
	{
		if (i >= 0 && i < _list_radios.length)
		{
			return _list_radios[i].visible;
		}
		return false;
	}

	/***GETTER / SETTER***/
	private function get_clickable():Bool
	{
		return _clickable;
	}

	private function set_clickable(b:Bool):Bool
	{
		_clickable = b;
		for (c in _list_radios)
		{
			c.active = b;
		}
		return _clickable;
	}

	private function get_selectedIndex():Int
	{
		return _selected;
	}

	private function set_selectedIndex(i:Int):Int
	{
		_selected = i;
		var j:Int = 0;
		for (c in _list_radios)
		{
			c.checked = false;
			if (j == i)
			{
				c.checked = true;
			}
			j++;
		}
		if (_selected < 0 || _selected >= _list_radios.length)
		{
			_selected = -1;
		}
		return _selected;
	}

	private function get_selectedLabel():String
	{
		return _labels[_selected];
	}

	private function set_selectedLabel(str:String):String
	{
		var i:Int = 0;
		_selected = -1;
		for (c in _list_radios)
		{
			c.checked = false;
			if (_labels[i] == str)
			{
				_selected = i;
				c.checked = true;
			}
			i++;
		}
		if (_selected >= 0 && _selected < _labels.length)
		{
			return _labels[_selected];
		}
		return null;
	}

	private function get_selectedId():String
	{
		return _ids[_selected];
	}

	private function set_selectedId(str:String):String
	{
		var i:Int = 0;
		_selected = -1;
		for (c in _list_radios)
		{
			c.checked = false;
			if (_ids[i] == str)
			{
				_selected = i;
				c.checked = true;
			}
			i++;
		}
		if (_selected >= 0 && _selected < _ids.length)
		{
			return _ids[_selected];
		}
		return null;
	}

	/**
	 * If you want to show only a portion of the radio group, scrolled line-by-line
	 * This will scroll the "pane" by that amount and return how many lines are above/below
	 * the currently visible pane
	 * @param	scroll How many lines DOWN you have scrolled
	 * @param	max_items (optional) Max amount of lines visible
	 * @return a FlxPoint of off-pane radio lines : (count_above,count_below)
	 */
	public function setLineScroll(scroll:Int, ?max_items:Int):FlxPoint
	{
		_list.scrollIndex = scroll;
		if (max_items != null)
		{
			if (_list.stacking == FlxUIList.STACK_VERTICAL)
			{
				height = (_y_space * max_items) + 1;
			}
		}
		return FlxPoint.get(_list.amountPrevious, _list.amountNext);
	}

	public function setRadioActive(i:Int, b:Bool):Void
	{
		if (i >= 0 && i < _list_active.length)
		{
			_list_active[i] = b;
		}
		updateActives();
	}

	/***PRIVATE***/
	private var _list_active:Array<Bool>; // list of inactive radios

	private var _list:FlxUIList;

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
	private function _refreshRadios():Void
	{
		var xx:Float = x;
		var yy:Float = y;
		var i:Int = 0;

		var maxX:Float = 0;
		var maxY:Float = 0;

		_list._skipRefresh = true;

		for (id in _ids)
		{
			var label:String = "";
			if (_labels != null && _labels.length > i)
			{
				label = _labels[i];
			}
			else
			{
				label = "<" + id + ">"; // "soft" error, indicates undefined label
			}
			var c:FlxUICheckBox;
			if (_list_radios.length > i)
			{
				c = _list_radios[i];
				c.visible = true;
				c.text = label;
				if (i == 0)
				{
					xx = c.x;
					yy = c.y;
				}
				else
				{
					c.x = Std.int(xx);
					c.y = Std.int(yy);
				}
			}
			else
			{
				c = new FlxUICheckBox(0, 0, _box_asset, _dot_asset, label, _label_width, [id, false]);
				c.broadcastToFlxUI = false; // internal communication only
				c.callback = _onCheckBoxEvent.bind(c);

				_list.add(c);

				c.x = Std.int(xx);
				c.y = Std.int(yy);

				c.text = label;
				if (_list_radios.length > 0)
				{
					c.button.copyStyle(cast _list_radios[0].button);
					if (activeStyle == null)
					{
						activeStyle = makeActiveStyle();
					}
					c.button.width = _list_radios[0].button.width;
					c.button.height = _list_radios[0].button.height;
					c.textX = _list_radios[0].textX;
					c.textY = _list_radios[0].textY;
				}

				_list_radios.push(c);
				_list_active.push(true);
			}

			if (xx + c.width > maxX)
			{
				maxX = xx + c.width;
			}
			if (yy + c.height > maxY)
			{
				maxY = yy + c.height;
			}

			yy += _y_space;
			i++;
		}
		if (fixedSize == false)
		{
			maxX += 5; // add some buffer
			maxY += 5;
			if (maxX > _list.width)
			{
				_list.width = maxX;
			}
			if (maxY > _list.height)
			{
				_list.height = maxY;
			}
			width = maxX;
			height = maxY;
		}
		_list._skipRefresh = false;

		if (fixedSize == true)
		{
			_list.refreshList();
		}

		updateActives();
	}

	private function updateActives():Void
	{
		var i:Int = 0;
		for (r in _list_radios)
		{
			r.active = _list_active[i];

			if (_list_active[i] == false && inactiveStyle != null)
			{
				inactiveStyle.applyToCheck(r);
			}
			else if (_list_active[i] == true && activeStyle != null)
			{
				activeStyle.applyToCheck(r);
			}
			i++;
		}
	}

	private function makeActiveStyle():CheckStyle
	{
		if (_list_radios.length > 0)
		{
			var btn = _list_radios[0].button;
			var t:FlxText = btn.label;
			var fd:FontDef = FontDef.copyFromFlxText(t);
			var bd:BorderDef = new BorderDef(t.borderStyle, t.borderColor, t.borderSize, t.borderQuality);
			var cs = new CheckStyle(0xFFFFFF, fd, t.alignment, t.color, bd);
			return cs;
		}
		return null;
	}

	private function _onCheckBoxEvent(checkBox:FlxUICheckBox):Void
	{
		_onClick(checkBox, true);
	}

	private function _onClick(checkBox:FlxUICheckBox, doCallback:Bool):Bool
	{
		if (!_clickable)
		{
			return false;
		}

		var i:Int = 0;
		for (c in _list_radios)
		{
			c.checked = false;
			if (checkBox == c)
			{
				_selected = i;
				c.checked = true;
			}
			i++;
		}

		if (doCallback)
		{
			if (callback != null)
			{
				callback(selectedId);
			}

			if (broadcastToFlxUI)
			{
				FlxUI.event(CLICK_EVENT, this, _ids[_selected], params);
			}
		}
		return true;
	}
}

class CheckStyle extends ButtonLabelStyle
{
	public var checkColor:Null<Int> = null;

	public function new(CheckColor:Null<Int> = null, ?Font:FontDef, ?Align:FlxTextAlign, ?Color:Int, ?Border:BorderDef)
	{
		checkColor = CheckColor;
		super(Font, Align, Color, Border);
	}

	public function applyToCheck(c:FlxUICheckBox):Void
	{
		if (checkColor != null)
		{
			c.color = checkColor;
		}
		apply(c.button.label);
	}
}
