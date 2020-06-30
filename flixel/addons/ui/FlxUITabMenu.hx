package flixel.addons.ui;

import flash.geom.Rectangle;
import flixel.addons.ui.interfaces.IEventGetter;
import flixel.addons.ui.interfaces.IFlxUIButton;
import flixel.addons.ui.interfaces.IFlxUIClickable;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.interfaces.IResizable;
import flixel.FlxSprite;
import flixel.system.FlxAssets;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxArrayUtil;
import flixel.math.FlxPoint;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;

/**
 * @author Lars Doucet
 */
class FlxUITabMenu extends FlxUIGroup implements IResizable implements IFlxUIClickable implements IEventGetter
{
	public static inline var CLICK_EVENT:String = "tab_menu_click";

	public static inline var STACK_FRONT:String = "front"; // button goes in front of backing
	public static inline var STACK_BACK:String = "back"; // buton goes behind backing

	public var numTabs(get, never):Int;

	public function get_numTabs():Int
	{
		if (_tabs != null)
		{
			return _tabs.length;
		}
		return 0;
	}

	/**To make IEventGetter happy**/
	public function getEvent(name:String, sender:IFlxUIWidget, data:Dynamic, ?params:Array<Dynamic>):Void
	{
		// donothing
	}

	public function getRequest(name:String, sender:IFlxUIWidget, data:Dynamic, ?params:Array<Dynamic>):Dynamic
	{
		// donothing
		return null;
	}

	/**For IFlxUIClickable**/
	public var skipButtonUpdate(default, set):Bool;

	private function set_skipButtonUpdate(b:Bool):Bool
	{
		skipButtonUpdate = b;
		for (tab in _tabs)
		{
			var tabtyped:FlxUITypedButton<FlxSprite> = cast tab;
			tabtyped.skipButtonUpdate = b;
		}
		for (group in _tab_groups)
		{
			for (sprite in group.members)
			{
				if ((sprite is IFlxUIClickable))
				{
					var widget:IFlxUIClickable = cast sprite;
					widget.skipButtonUpdate = b;
				}
			}
		}
		return b;
	}

	/**For IResizable**/
	private override function get_width():Float
	{
		return _back.width;
	}

	private override function get_height():Float
	{
		var fbt = getFirstTab();
		if (fbt != null)
		{
			return (_back.y + _back.height) - fbt.y;
		}
		return _back.height;
	}

	public function resize(W:Float, H:Float):Void
	{
		var ir:IResizable;
		if ((_back is IResizable))
		{
			distributeTabs(W);
			ir = cast _back;
			var fbt:FlxUITypedButton<FlxSprite> = cast getFirstTab();
			if (fbt != null)
			{
				ir.resize(W, H - fbt.get_height());
			}
			else
			{
				ir.resize(W, H);
			}
		}
		else
		{
			distributeTabs();
		}
	}

	public var selected_tab(get, set):Int;

	private function get_selected_tab():Int
	{
		return _selected_tab;
	}

	private function set_selected_tab(i:Int):Int
	{
		showTabInt(i); // this modifies _selected_tab/_selected_tab_id
		return _selected_tab;
	}

	public var selected_tab_id(get, set):String;

	private function get_selected_tab_id():String
	{
		return _selected_tab_id;
	}

	private function set_selected_tab_id(str:String):String
	{
		showTabId(str); // this modifies _selected_tab/_selected_tab_id
		return _selected_tab_id;
	}

	/***PUBLIC***/
	public function new(?back_:FlxSprite, ?tabs_:Array<IFlxUIButton>, ?tab_names_and_labels_:Array<{name:String, label:String}>, ?tab_offset:FlxPoint,
			?stretch_tabs:Bool = false, ?tab_spacing:Null<Float> = null, ?tab_stacking:Array<String> = null)
	{
		super();

		if (back_ == null)
		{
			// default, make this:
			back_ = new FlxUI9SliceSprite(0, 0, FlxUIAssets.IMG_CHROME_FLAT, new Rectangle(0, 0, 200, 200));
		}

		_back = back_;
		add(_back);

		if (tabs_ == null)
		{
			if (tab_names_and_labels_ != null)
			{
				tabs_ = new Array<IFlxUIButton>();

				// load default graphic data if only tab_names_and_labels are provided
				for (tdata in tab_names_and_labels_)
				{
					// set label and name
					var fb:FlxUIButton = new FlxUIButton(0, 0, tdata.label);

					// default style:
					fb.up_color = 0xffffff;
					fb.down_color = 0xffffff;
					fb.over_color = 0xffffff;
					fb.up_toggle_color = 0xffffff;
					fb.down_toggle_color = 0xffffff;
					fb.over_toggle_color = 0xffffff;

					fb.label.color = 0xFFFFFF;
					fb.label.setBorderStyle(OUTLINE);

					fb.name = tdata.name;

					// load default graphics
					var graphic_names:Array<FlxGraphicAsset> = [
						FlxUIAssets.IMG_TAB_BACK,
						FlxUIAssets.IMG_TAB_BACK,
						FlxUIAssets.IMG_TAB_BACK,
						FlxUIAssets.IMG_TAB,
						FlxUIAssets.IMG_TAB,
						FlxUIAssets.IMG_TAB
					];
					var slice9tab:Array<Int> = FlxStringUtil.toIntArray(FlxUIAssets.SLICE9_TAB);
					var slice9_names:Array<Array<Int>> = [slice9tab, slice9tab, slice9tab, slice9tab, slice9tab, slice9tab];
					fb.loadGraphicSlice9(graphic_names, 0, 0, slice9_names, FlxUI9SliceSprite.TILE_NONE, -1, true);
					tabs_.push(fb);
				}
			}
		}

		_tabs = tabs_;
		_stretch_tabs = stretch_tabs;
		_tab_spacing = tab_spacing;
		_tab_stacking = tab_stacking;
		if (_tab_stacking == null)
		{
			_tab_stacking = [STACK_FRONT, STACK_BACK];
		}
		_tab_offset = tab_offset;

		var i:Int = 0;
		var tab:FlxUITypedButton<FlxSprite> = null;
		for (t in _tabs)
		{
			tab = cast t;
			add(tab);
			tab.onUp.callback = _onTabEvent.bind(tab.name);
			i++;
		}

		distributeTabs();

		_tab_groups = new Array<FlxUIGroup>();
	}

	public override function destroy():Void
	{
		super.destroy();
		U.clearArray(_tab_groups);
		U.clearArray(_tabs);
		_back = null;
		_tabs = null;
		_tab_groups = null;
	}

	public function getTab(?name:String, ?index:Null<Int>):IFlxUIButton
	{
		if (name != null)
		{
			for (tab in _tabs)
			{
				if (tab.name == name)
				{
					return tab;
				}
			}
		}
		if (index != null)
		{
			if (index < _tabs.length)
			{
				return _tabs[index];
			}
		}
		return null;
	}

	public function getTabGroup(?name:String, ?index:Null<Int>):FlxUIGroup
	{
		if (name != null)
		{
			for (tabGroup in _tab_groups)
			{
				if (tabGroup.name == name)
				{
					return tabGroup;
				}
			}
		}
		if (index != null)
		{
			if (index < _tab_groups.length)
			{
				return _tab_groups[index];
			}
		}
		return null;
	}

	public function getBack():FlxSprite
	{
		return _back;
	}

	public function replaceBack(newBack:FlxSprite):Void
	{
		var i:Int = members.indexOf(_back);
		if (i != -1)
		{
			var oldBack = _back;
			if ((newBack is IResizable))
			{
				var ir:IResizable = cast newBack;
				ir.resize(oldBack.width, oldBack.height);
			}
			members[i] = newBack;
			newBack.x = oldBack.x;
			newBack.y = oldBack.y;
			oldBack.destroy();
		}
	}

	public function addGroup(g:FlxUIGroup):Void
	{
		if (g == this)
		{
			return; // DO NOT ADD A GROUP TO ITSELF
		}

		if (!hasThis(g))
		{ // ONLY ADD IF IT DOESN'T EXIST
			g.y = (_back.y - y);
			add(g);
			_tab_groups.push(g);
		}

		// hide the new group
		_showOnlyGroup("");

		// if this is our first group, show it right now
		if (_tab_groups.length == 1)
		{
			selected_tab = 0;
		}

		// refresh selected tab after group is added
		if (_selected_tab != -1)
		{
			selected_tab = _selected_tab;
		}
	}

	private function _onTabEvent(name:String):Void
	{
		showTabId(name);
		var tab = getTab(name);
		var params = (tab != null) ? tab.params : null;
		if (broadcastToFlxUI)
		{
			FlxUI.event(CLICK_EVENT, this, name, params);
		}
	}

	public function stackTabs():Void
	{
		var _backx:Float = _back.x;
		var _backy:Float = _back.y;

		group.remove(_back, true);

		var tab:FlxUITypedButton<FlxSprite> = null;
		for (t in _tabs)
		{
			tab = cast t;
			if (tab.toggled)
			{
				group.remove(tab, true);
			}
		}

		group.add(_back);

		for (t in _tabs)
		{
			tab = cast t;
			if (tab.toggled)
			{
				group.add(tab);
			}
		}

		// Put tab groups back on top
		for (group in _tab_groups)
		{
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

	public function showTabId(name:String):Void
	{
		_selected_tab = -1;
		_selected_tab_id = "";

		var i:Int = 0;
		for (tab in _tabs)
		{
			tab.toggled = false;
			tab.forceStateHandler(FlxUITypedButton.OUT_EVENT);
			if (tab.name == name)
			{
				tab.toggled = true;
				_selected_tab_id = name;
				_selected_tab = i;
			}
			i++;
		}

		_showOnlyGroup(name);
		stackTabs();
	}

	/***PRIVATE***/
	private var _back:FlxSprite;

	private var _tabs:Array<IFlxUIButton>;
	private var _tab_groups:Array<FlxUIGroup>;
	private var _stretch_tabs:Bool = false;
	private var _tab_spacing:Null<Float> = null;
	private var _tab_stacking:Array<String> = null;
	private var _tab_offset:FlxPoint = null;

	private var _selected_tab_id:String = "";
	private var _selected_tab:Int = -1;

	private function sortTabs(a:IFlxUIButton, b:IFlxUIButton):Int
	{
		if (a.name < b.name)
		{
			return -1;
		}
		else if (a.name > b.name)
		{
			return 1;
		}
		return -1;
	}

	private function showTabInt(i:Int):Void
	{
		if (i >= 0 && _tabs != null && _tabs.length > i)
		{
			var _tab:IFlxUIButton = _tabs[i];
			var name:String = _tab.name;
			showTabId(name);
		}
		else
		{
			showTabId("");
		}
	}

	private function _showOnlyGroup(name:String):Void
	{
		for (group in _tab_groups)
		{
			if (group.name == name)
			{
				group.visible = group.active = true;
			}
			else
			{
				group.visible = group.active = false;
			}
		}
	}

	private function getFirstTab():IFlxUIButton
	{
		var _the_tab:IFlxUIButton = null;
		if (_tabs != null && _tabs.length > 0)
		{
			_the_tab = _tabs[0];
		}
		return _the_tab;
	}

	private function distributeTabs(W:Float = -1):Void
	{
		var xx:Float = 0;

		var tab_width:Float = 0;

		if (W == -1)
		{
			W = _back.width;
		}

		var diff_size:Float = 0;
		if (_stretch_tabs)
		{
			tab_width = W / _tabs.length;
			var tot_size:Float = (Std.int(tab_width) * _tabs.length);
			if (tot_size < W)
			{
				diff_size = (W - tot_size);
			}
		}

		_tabs.sort(sortTabs);

		var i:Int = 0;
		var firstHeight:Float = 0;

		var tab:FlxUITypedButton<FlxSprite>;
		for (t in _tabs)
		{
			tab = cast t;

			tab.x = x + xx;
			tab.y = y + 0;

			if (_tab_offset != null)
			{
				tab.x += _tab_offset.x;
				tab.y += _tab_offset.y;
			}

			if (_stretch_tabs)
			{
				var theHeight:Float = tab.get_height();
				if (i != 0)
				{
					// when stretching, if resize_ratios are set, tabs can wind up with wrong heights since they might have different widths.
					// to solve this we cancel resize_ratios for all tabs except the first and make sure all subsequent tabs match the height
					// of the first tab
					theHeight = firstHeight;
					tab.resize_ratio = -1;
				}
				if (diff_size > 0)
				{
					tab.resize(tab_width + 1, theHeight);
					xx += (Std.int(tab_width) + 1);
					diff_size -= 1;
				}
				else
				{
					tab.resize(tab_width, theHeight);
					xx += Std.int(tab_width);
				}
			}
			else
			{
				if (_tab_spacing != null)
				{
					xx += tab.width + _tab_spacing;
				}
				else
				{
					xx += tab.width;
				}
			}
			if (i == 0)
			{
				firstHeight = tab.get_height(); // if we are stretching we will make everything match the height of the first tab
			}
			i++;
		}

		if (_tabs != null && _tabs.length > 0 && _tabs[0] != null)
		{
			_back.y = _tabs[0].y + _tabs[0].height - 2;
			if (_tab_offset != null)
			{
				_back.y -= _tab_offset.y;
			}
		}

		calcBounds();
	}
}
