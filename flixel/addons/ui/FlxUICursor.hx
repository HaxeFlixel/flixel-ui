package flixel.addons.ui;

import flash.events.MouseEvent;
import flixel.addons.ui.Anchor;
import flixel.addons.ui.FlxUIAssets;
import flixel.addons.ui.FlxUICursor.WidgetList;
import flixel.addons.ui.FlxUISprite;
import flixel.addons.ui.interfaces.ICursorPointable;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.mouse.FlxMouse;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;

/**
 * Cursor object that you can use to "click" on interface elements using a keyboard or gamepad
 * TODO: need to support gamepad and/or deal with absence of mouse
 */
class FlxUICursor extends FlxUISprite
{
	public var callback:String->IFlxUIWidget->Void; // callback to notify whoever's listening that I did something(presumably a FlxUI object)

	public var wrap:Bool = true; // when cycling through values, loop from back to front or stop at "edges?"

	public var location(default, set):Int = -1; // which object the cursor is pointing to (-1 means nothing)
	public var listIndex(default, set):Int = 0; // which group is my location pointing to?

	/**
	 * Exactly what it sounds like. The next input that would trigger a jump doesn't happen, then this flag is reset.
	 */
	public var ignoreNextInput:Bool;

	/**
	 * Same as setting .location, but lets you specificy what to do if that object is invisible
	 * @param	loc	the location you want to set the cursor to
	 * @param	forwardIfInvisible if object @ loc is invisible, keep adding 1 until we find a good state. If false, subtract 1.
	 * @param	wrap if true, wrap around if we reach the end of the list. If false, don't.
	 */
	public function findVisibleLocation(loc:Int, forwardIfInvisible:Bool = true, wrap:Bool = true):Void
	{
		location = loc;
		if (location == -1)
			return;

		var wrapped = false;
		while (_widgets[location] == null || _widgets[location].visible == false)
		{
			if (forwardIfInvisible)
			{
				if (location == _widgets.length - 1)
				{
					if (wrap)
					{
						if (!wrapped)
						{
							wrapped = true;
							location = 0;
						}
						else
						{
							location = -1;
							return;
						}
					}
					else
					{
						location = -1;
						return;
					}
				}
				else
				{
					location++;
				}
			}
			else
			{
				if (location == 0)
				{
					if (wrap)
					{
						if (!wrapped)
						{
							wrapped = true;
							location = _widgets.length - 1;
						}
						else
						{
							location = -1;
							return;
						}
					}
					else
					{
						location = -1;
						return;
					}
				}
				else
				{
					location--;
				}
			}
		}
	}

	/**
	 * Returns the current widget the cursor is pointing to, if any
	 * @since 2.1.0
	 */
	public function getCurrentWidget():IFlxUIWidget
	{
		if (_widgets != null && location >= 0 && location < _widgets.length)
		{
			return _widgets[location];
		}
		return null;
	}

	private function set_listIndex(i:Int):Int
	{
		if (i >= _lists.length)
		{
			i = _lists.length - 1;
		}
		else if (i < 0)
		{
			i = 0;
		}
		listIndex = i;
		location = 0;
		_updateCursor();
		return listIndex;
	}

	private override function set_visible(b:Bool):Bool
	{
		b = super.set_visible(b);
		return b;
	}

	private function set_location(i:Int):Int
	{
		if (i >= _widgets.length)
		{
			i = _widgets.length - 1;
		}
		location = i;
		_updateCursor();
		return location;
	}

	/**
	 * If a gamepad's connection is suddenly lost, what should be done?
	 */
	public var gamepadAutoConnect:GamepadAutoConnectPreference = FirstActive;

	public var gamepad(get, set):FlxGamepad;

	private function set_gamepad(g:FlxGamepad):FlxGamepad
	{
		_gamepad = g;
		setDefaultKeys(_defaultCode);
		var arr = [keysUp, keysDown, keysLeft, keysRight, keysClick];
		for (list in arr)
		{
			if (list != null)
			{
				for (keys in list)
				{
					if ((keys is FlxMultiGamepad))
					{
						var fmg:FlxMultiGamepad = cast keys;
						fmg.gamepad = _gamepad;
					}
				}
			}
		}
		return g;
	}

	private function get_gamepad():FlxGamepad
	{
		return _gamepad;
	}

	private var _gamepad:FlxGamepad;

	// Key configurations, you can set easily with setDefaultKeys(KEYS_TAB), for instance.
	public var keysUp:Array<FlxBaseMultiInput>; // List of keys (ie, tab) and/or key combinations (ie, shift+tab) that indicate intent to go "up"
	public var keysDown:Array<FlxBaseMultiInput>;
	public var keysLeft:Array<FlxBaseMultiInput>;
	public var keysRight:Array<FlxBaseMultiInput>;
	public var keysClick:Array<FlxBaseMultiInput>; // intent to "click" or select

	// Various default key configurations:
	public static inline var KEYS_TAB:Int = 0x00000001; // tab to go "right", shift+tab to go "left", enter to click
	public static inline var KEYS_WASD:Int = 0x00000010; // WASD to go up/left/down/right, enter to click
	public static inline var KEYS_ARROWS:Int = 0x00000100; // Arrows to go up/left/down/right, enter to click
	public static inline var KEYS_NUMPAD:Int = 0x00001000; // Numpad numbers to go up/left/down/right, enter to click

	public static inline var GAMEPAD_DPAD:Int = 0x00010000; // DPAD to go up/left/down/right, A to click
	public static inline var GAMEPAD_LEFT_STICK:Int = 0x00100000; // Left STICK to go up/left/down/right, A to click
	public static inline var GAMEPAD_RIGHT_STICK:Int = 0x01000000; // Right STICK to go up/left/down/right, A to click
	public static inline var GAMEPAD_SHOULDER_BUTTONS:Int = 0x10000000; // Left / Right shoulder buttons to go left/right, A to click

	// Determines how the cursor attaches itself to the widget it's pointing to
	public var anchor:Anchor;

	public var dispatchEvents:Bool = true; // set to false if you just want to rely on callbacks rather than low-level events

	// TODO: make this work
	public var inputMethod:Int = 0x00; // simple bitmask for storing what input methods can move the cursor

	public static inline var INPUT_NONE:Int = 0x00; // No cursor input what
	public static inline var INPUT_KEYS:Int = 0x01; // Use keyboard to control the cursor
	public static inline var INPUT_GAMEPAD:Int = 0x10; // Use gamepad to control the cursor

	/*********************************/
	/**
	 * Creates a cursor that can be controlled with the keyboard or gamepad
	 * @param	Callback		callback to notify listener about when something happens
	 * @param	InputMethod		bit-flag, accepts INPUT_KEYS, INPUT_GAMEPAD, or both using "|" operator
	 * @param	DefaultKeys		default hotkey layouts, accepts KEYS_TAB, ..._WASD, etc, combine using "|" operator
	 * @param	Asset			visual asset for the cursor. If not supplied, uses default
	 */
	public function new(Callback:String->IFlxUIWidget->Void, InputMethod:Int = INPUT_KEYS, DefaultKeys:Int = KEYS_TAB, ?Asset:Dynamic)
	{
		if (Asset == null)
		{ // No asset detected? Guess based on game's resolution
			if (FlxG.height < 400)
			{
				Asset = FlxUIAssets.IMG_FINGER_SMALL; // 16x16 pixel finger
			}
			else
			{
				Asset = FlxUIAssets.IMG_FINGER_BIG; // 32x32 pixel finger
			}
		}

		super(0, 0, Asset);

		inputMethod = InputMethod;
		_lists = [
			{
				x: 0,
				y: 0,
				width: 0,
				height: 0,
				widgets: []
			}
		];
		_widgets = _lists[0].widgets;
		anchor = new Anchor(-2, 0, Anchor.LEFT, Anchor.CENTER, Anchor.RIGHT, Anchor.CENTER);
		setDefaultKeys(DefaultKeys);
		callback = Callback;

		scrollFactor.set(0, 0);

		#if FLX_MOUSE
		if (FlxG.mouse != null && (FlxG.mouse is FlxUIMouse) == false)
		{
			_newMouse = new FlxUIMouse(FlxG.mouse.cursorContainer);
			FlxG.mouse = _newMouse;
		}
		else
		{
			_newMouse = cast FlxG.mouse;
		}
		#end
	}

	public override function destroy():Void
	{
		super.destroy();

		#if FLX_MOUSE
		if (FlxG.mouse == _newMouse)
		{
			// remove the local pointer, but allow the replaced mouse object to carry on, it won't hurt anything
			_newMouse = null;
		}
		#end

		keysUp = FlxDestroyUtil.destroyArray(keysUp);
		keysDown = FlxDestroyUtil.destroyArray(keysDown);
		keysLeft = FlxDestroyUtil.destroyArray(keysLeft);
		keysRight = FlxDestroyUtil.destroyArray(keysRight);
		keysClick = FlxDestroyUtil.destroyArray(keysClick);

		anchor = FlxDestroyUtil.destroy(anchor);

		for (l in _lists)
		{
			U.clearArraySoft(l.widgets);
		}

		U.clearArraySoft(_lists);
		_widgets = null;
	}

	public override function update(elapsed:Float):Void
	{
		#if FLX_GAMEPAD
		if (gamepad == null)
		{
			var g = getGamepad(false);
			if (g != null)
			{
				gamepad = g;
			}
		}
		#end

		#if FLX_MOUSE
		if (lastMouseX != FlxG.mouse.x || lastMouseY != FlxG.mouse.y)
		{
			var oldVis = visible;

			// Ad hoc fix to avoid world coordinates on UI elements
			if (scrollFactor.x == 0 && scrollFactor.y == 0)
				jumpToXY(FlxG.mouse.screenX, FlxG.mouse.screenY);
			else
				jumpToXY(FlxG.mouse.x, FlxG.mouse.y);
			visible = oldVis;

			lastMouseX = FlxG.mouse.x;
			lastMouseY = FlxG.mouse.y;
		}
		#end

		_checkKeys();
		_clickTime += elapsed;
		super.update(elapsed);
	}

	public function addWidgetsFromUI(ui:FlxUI)
	{
		if (ui.cursorLists != null)
		{
			for (list in ui.cursorLists)
			{
				addWidgetList(list);
			}
			_widgets = _lists[0].widgets;
			location = 0;
			listIndex = 0;
		}
		else
		{
			for (widget in ui.members)
			{
				if ((widget is ICursorPointable) || (widget is FlxUIGroup)) // if it's directly pointable or a group
				{
					addWidget(cast widget); // add it
				}
			}
		}
	}

	/**
	 * Forces the cursor to change its location to point to this widget, if the widget is in its list
	 * @param	widget
	 * @return	whether the widget was found or not
	 */
	public function jumpTo(widget:IFlxUIWidget):Bool
	{
		var listi:Int = 0;
		var i:Int = 0;
		if (_lists != null)
		{
			for (list in _lists)
			{
				i = list.widgets.indexOf(widget);
				if (i != -1)
				{
					listIndex = listi;
					location = i;
					return true;
				}
				listi++;
			}
		}
		else
		{
			i = _widgets.indexOf(widget);
			location = i;
			return true;
		}
		return false;
	}

	/**
	 * Forces the cursor to to point to whatever widget's center is closest to X,Y -- IF the widget is in its list
	 * @param	X
	 * @param	Y
	 * @return
	 */
	public function jumpToXY(X:Float, Y:Float):Bool
	{
		var listi:Int = 0;

		var bestd2 = Math.POSITIVE_INFINITY;
		var bestli = -1;
		var besti = -1;

		if (_lists != null)
		{
			for (list in _lists)
			{
				for (i in 0...list.widgets.length)
				{
					var w:IFlxUIWidget = list.widgets[i];
					if (w.visible == true && X >= w.x && Y >= w.y && X <= w.x + w.width && Y <= w.y + w.height)
					{
						var dx = ((w.x + w.width / 2) - X);
						var dy = ((w.y + w.height / 2) - Y);
						var d2 = dx * dx + dy * dy;
						if (d2 < bestd2)
						{
							bestd2 = d2;
							bestli = listi;
							besti = i;
						}
					}
				}
				listi++;
			}
			if (bestli != -1 && besti != -1)
			{
				listIndex = bestli;
				location = besti;
				return true;
			}
		}
		else
		{
			for (i in 0..._widgets.length)
			{
				var w:IFlxUIWidget = _widgets[i];
				if (w.visible == true && X >= w.x && Y >= w.y && X <= w.x + w.width && Y <= w.y + w.height)
				{
					var dx = ((w.x + w.width / 2) - X);
					var dy = ((w.y + w.height / 2) - Y);
					var d2 = dx * dx + dy * dy;
					if (d2 < bestd2)
					{
						bestd2 = d2;
						besti = i;
					}
				}
			}
			if (besti != -1)
			{
				location = besti;
				return true;
			}
		}
		return false;
	}

	public function addWidgetList(list:Array<IFlxUIWidget>):Void
	{
		for (l in _lists)
		{
			if (FlxArrayUtil.equals(l.widgets, list))
			{
				return;
			}
		}

		var x1 = Math.POSITIVE_INFINITY;
		var y1 = Math.POSITIVE_INFINITY;
		var x2 = Math.NEGATIVE_INFINITY;
		var y2 = Math.NEGATIVE_INFINITY;

		for (w in list)
		{
			if (w.x < x1)
				x1 = w.x;
			if (w.y < y1)
				y1 = w.y;
			if (w.x + w.width > x2)
				x2 = w.x;
			if (w.y + w.height > y2)
				y2 = w.y;
		}

		var theList:WidgetList = null;
		if (_lists.length == 1 && _lists[0].widgets != null && _lists[0].widgets.length == 0)
		{
			_lists[0].widgets = [];
			_lists[0].x = Std.int(x1);
			_lists[0].y = Std.int(y1);
			_lists[0].width = Std.int(x2 - x1);
			_lists[0].height = Std.int(y2 - y1);
			theList = _lists[0];
		}
		else
		{
			_lists.push({
				x: Std.int(x1),
				y: Std.int(y1),
				width: Std.int(x2 - x1),
				height: Std.int(y2 - y1),
				widgets: []
			});
			theList = _lists[_lists.length - 1];
		}

		var oldWidgets = _widgets;
		_widgets = theList.widgets;
		for (ifw in list)
		{
			addWidget(ifw);
		}
		_widgets = oldWidgets;

		_lists.sort(_sortXYWidgetList);
		for (widgetList in _lists)
		{
			widgetList.widgets.sort(_sortXYVisible);
		}
	}

	public function addWidget(widget:IFlxUIWidget):Void
	{
		if ((widget is ICursorPointable)) // directly pointable? add it
		{
			_widgets.push(widget);
		}
		else if ((widget is FlxUIGroup)) // it's a group?
		{
			var g:FlxUIGroup = cast widget;
			for (member in g.members)
			{
				if ((member is IFlxUIWidget))
				{
					addWidget(cast member); // add each member individually
				}
			}
		}
		_widgets.sort(_sortXYVisible);
	}

	public function sortWidgets(method:SortMethod, ?list:Array<IFlxUIWidget>):Void
	{
		if (list == null)
		{
			list = _widgets;
		}
		switch (method)
		{
			case XY:
				list.sort(_sortXYVisible);
			case ID:
				list.sort(_sortIDVisible);
		}
	}

	/** @since 2.1.0 */
	public function clearWidgets():Void
	{
		FlxArrayUtil.clearArray(_widgets);
	}

	public function removeWidget(widget:IFlxUIWidget, ?list:Array<IFlxUIWidget>):Bool
	{
		if (list == null)
		{
			list = _widgets;
		}
		var value:Bool = false;
		if (list != null)
		{
			if (list.indexOf(widget) != -1)
			{
				value = list.remove(widget);
				list.sort(_sortXYVisible);
			}
		}
		return value;
	}

	/**
	 * Set the default key layout quickly using a constant.
	 * @param	code	KEYS_TAB, ..._WASD, etc, combine with "|" operator
	 */
	public function setDefaultKeys(code:Int):Void
	{
		_defaultCode = code;
		_clearKeys();
		_newKeys();
		if (code & KEYS_TAB == KEYS_TAB)
		{
			_addToKeys(keysRight, new FlxMultiKey(TAB, null, [SHIFT])); // Tab, (but NOT Shift+Tab!)
			_addToKeys(keysLeft, new FlxMultiKey(TAB, [SHIFT])); // Shift+Tab
			_addToKeys(keysClick, new FlxMultiKey(ENTER));
		}
		if (code & KEYS_ARROWS == KEYS_ARROWS)
		{
			_addToKeys(keysRight, new FlxMultiKey(RIGHT));
			_addToKeys(keysLeft, new FlxMultiKey(LEFT));
			_addToKeys(keysDown, new FlxMultiKey(DOWN));
			_addToKeys(keysUp, new FlxMultiKey(UP));
			_addToKeys(keysClick, new FlxMultiKey(ENTER));
		}
		if (code & KEYS_WASD == KEYS_WASD)
		{
			_addToKeys(keysRight, new FlxMultiKey(D));
			_addToKeys(keysLeft, new FlxMultiKey(A));
			_addToKeys(keysDown, new FlxMultiKey(S));
			_addToKeys(keysUp, new FlxMultiKey(W));
			_addToKeys(keysClick, new FlxMultiKey(ENTER));
		}
		if (code & KEYS_NUMPAD == KEYS_NUMPAD)
		{
			_addToKeys(keysRight, new FlxMultiKey(NUMPADSIX));
			_addToKeys(keysLeft, new FlxMultiKey(NUMPADFOUR));
			_addToKeys(keysDown, new FlxMultiKey(NUMPADTWO));
			_addToKeys(keysUp, new FlxMultiKey(NUMPADEIGHT));
			_addToKeys(keysClick, new FlxMultiKey(ENTER));
		}

		#if FLX_GAMEPAD
		if (gamepad == null)
		{
			_gamepad = getGamepad(); // set _gamepad to avoid a stack overflow loop
		}

		if (code & GAMEPAD_DPAD == GAMEPAD_DPAD)
		{
			_addToKeys(keysLeft, new FlxMultiGamepad(gamepad, FlxGamepadInputID.DPAD_LEFT));
			_addToKeys(keysRight, new FlxMultiGamepad(gamepad, FlxGamepadInputID.DPAD_RIGHT));
			_addToKeys(keysDown, new FlxMultiGamepad(gamepad, FlxGamepadInputID.DPAD_DOWN));
			_addToKeys(keysUp, new FlxMultiGamepad(gamepad, FlxGamepadInputID.DPAD_UP));
			_addToKeys(keysClick, new FlxMultiGamepad(gamepad, FlxGamepadInputID.A));
		}
		if (code & GAMEPAD_SHOULDER_BUTTONS == GAMEPAD_SHOULDER_BUTTONS)
		{
			_addToKeys(keysLeft, new FlxMultiGamepad(gamepad, FlxGamepadInputID.LEFT_SHOULDER));
			_addToKeys(keysRight, new FlxMultiGamepad(gamepad, FlxGamepadInputID.RIGHT_SHOULDER));
			_addToKeys(keysClick, new FlxMultiGamepad(gamepad, FlxGamepadInputID.A));
		}
		if (code & GAMEPAD_LEFT_STICK == GAMEPAD_LEFT_STICK)
		{
			_addToKeys(keysLeft, new FlxMultiGamepadAnalogStick(gamepad, {id: LEFT_ANALOG_STICK, axis: X, positive: false}));
			_addToKeys(keysRight, new FlxMultiGamepadAnalogStick(gamepad, {id: LEFT_ANALOG_STICK, axis: X, positive: true}));
			_addToKeys(keysUp, new FlxMultiGamepadAnalogStick(gamepad, {id: LEFT_ANALOG_STICK, axis: Y, positive: false}));
			_addToKeys(keysDown, new FlxMultiGamepadAnalogStick(gamepad, {id: LEFT_ANALOG_STICK, axis: Y, positive: true}));
			_addToKeys(keysClick, new FlxMultiGamepad(gamepad, FlxGamepadInputID.A));
		}
		if (code & GAMEPAD_RIGHT_STICK == GAMEPAD_RIGHT_STICK)
		{
			_addToKeys(keysLeft, new FlxMultiGamepadAnalogStick(gamepad, {id: RIGHT_ANALOG_STICK, axis: X, positive: false}));
			_addToKeys(keysRight, new FlxMultiGamepadAnalogStick(gamepad, {id: RIGHT_ANALOG_STICK, axis: X, positive: true}));
			_addToKeys(keysUp, new FlxMultiGamepadAnalogStick(gamepad, {id: RIGHT_ANALOG_STICK, axis: Y, positive: false}));
			_addToKeys(keysDown, new FlxMultiGamepadAnalogStick(gamepad, {id: RIGHT_ANALOG_STICK, axis: Y, positive: true}));
			_addToKeys(keysClick, new FlxMultiGamepad(gamepad, FlxGamepadInputID.A));
		}
		#end
	}

	/****PRIVATE****/
	private var _lists:Array<WidgetList>; // list of lists of widgets with boundary metadata

	private var _widgets:Array<IFlxUIWidget>; // list of widgets under cursor's control
	#if FLX_MOUSE
	private var _newMouse:FlxUIMouse;
	private var lastMouseX:Float = 0;
	private var lastMouseY:Float = 0;
	#end
	private var _clickPressed:Bool = false;

	private var _defaultCode:Int;

	private var _rightAnchor:Anchor;
	private var _topAnchor:Anchor;
	private var _leftAnchor:Anchor;
	private var _bottomAnchor:Anchor;

	private var _clickTime:Float = 0;

	#if FLX_GAMEPAD
	private function getGamepad(exhaustive:Bool = true):FlxGamepad
	{
		var gamepad = switch (gamepadAutoConnect)
		{
			case Never: null;
			case FirstActive: FlxG.gamepads.getFirstActiveGamepad();
			case LastActive: FlxG.gamepads.lastActive;
			case GamepadID(i): FlxG.gamepads.getByID(i);
		}
		if (gamepad == null && exhaustive)
		{
			for (i in 0...FlxG.gamepads.numActiveGamepads)
			{
				gamepad = FlxG.gamepads.getByID(i);
				if (gamepad != null)
				{
					return gamepad;
				}
			}
		}
		return gamepad;
	}
	#end

	private function _sortIDVisible(a:IFlxUIWidget, b:IFlxUIWidget):Int
	{
		if (a.visible && !b.visible)
			return -1;
		if (b.visible && !a.visible)
			return 1;
		if (a.ID < b.ID)
			return -1;
		if (a.ID > b.ID)
			return 1;
		return 0;
	}

	private function _sortXYWidgetList(a:WidgetList, b:WidgetList):Int
	{
		if (a.y < b.y)
			return -1;
		if (a.y > b.y)
			return 1;
		if (a.x < b.x)
			return -1;
		if (a.x > b.x)
			return 1;
		return 0;
	}

	private function _sortXYVisible(a:IFlxUIWidget, b:IFlxUIWidget):Int
	{
		if (a.visible && !b.visible)
			return -1;
		if (b.visible && !a.visible)
			return 1;
		if (a.y < b.y)
			return -1;
		if (a.y > b.y)
			return 1;
		if (a.x < b.x)
			return -1;
		if (a.x > b.x)
			return 1;
		return 0;
	}

	private function _addToKeys(keys:Array<FlxBaseMultiInput>, m:FlxBaseMultiInput)
	{
		var exists:Bool = false;
		for (mk in keys)
		{
			if (m.equals(mk))
			{
				exists = true;
				break;
			}
		}
		if (!exists)
		{
			keys.push(m);
		}
	}

	private function _clearKeys():Void
	{
		U.clearArray(keysUp);
		keysUp = null;
		U.clearArray(keysDown);
		keysDown = null;
		U.clearArray(keysLeft);
		keysLeft = null;
		U.clearArray(keysRight);
		keysRight = null;
		U.clearArray(keysClick);
		keysClick = null;
	}

	private function _newKeys():Void
	{
		keysUp = [];
		keysDown = [];
		keysLeft = [];
		keysRight = [];
		keysClick = [];
	}

	private function _checkKeys():Void
	{
		var wasInvisible = (visible == false);
		var lastLocation = location;

		for (key in keysUp)
		{
			if (key.justPressed())
			{
				_doInput(0, -1);
				break;
			}
		}
		for (key in keysDown)
		{
			if (key.justPressed())
			{
				_doInput(0, 1);
				break;
			}
		}
		for (key in keysLeft)
		{
			if (key.justPressed())
			{
				_doInput(-1, 0);
				break;
			}
		}
		for (key in keysRight)
		{
			if (key.justPressed())
			{
				_doInput(1, 0);
				break;
			}
		}

		if (wasInvisible && visible && lastLocation != -1)
		{
			location = lastLocation;
		}

		if (_clickKeysJustPressed()) // JUST PRESSED: send a press event only the first time it's pressed
		{
			if (!ignoreNextInput)
			{
				_clickPressed = true;
				_clickTime = 0;
				_doPress();
			}
			else
			{
				ignoreNextInput = false;
			}
		}

		if (_clickKeysPressed()) // STILL PRESSED: keep the cursor in that position while the key is down
		{
			_clickPressed = true;
			_doMouseMove();
		}
		else if (_clickTime > 0) // NOT PRESSED and not exact same frame as when it was just pressed
		{
			if (_clickPressed) // if we were previously just pressed...
			{
				_doRelease(); // do the release action
				_clickPressed = false; // count this as "just released"
			}
		}
	}

	private function _clickKeysJustPressed():Bool
	{
		for (key in keysClick)
		{
			if (key.justPressed())
			{
				return true;
			}
		}
		return false;
	}

	private function _clickKeysPressed():Bool
	{
		for (key in keysClick)
		{
			if (key.pressed())
			{
				return true;
			}
		}
		return false;
	}

	private function _getWidgetPoint(?Camera:FlxCamera):FlxPoint
	{
		if (Camera == null)
			Camera = FlxG.camera;

		// get the widget;
		var currWidget:IFlxUIWidget = _widgets[location];
		if (currWidget == null)
		{
			return null;
		}

		var fo:FlxObject;
		var widgetPoint:FlxPoint = null;

		// Try to convert to FlxObject if possible
		if ((currWidget is FlxObject))
		{
			fo = cast currWidget;
			// success! Get ScreenXY, to deal with any possible scrolling/camera craziness
			widgetPoint = fo.getScreenPosition();
		}

		widgetPoint.x *= Camera.totalScaleX;
		widgetPoint.y *= Camera.totalScaleY;

		if (widgetPoint == null)
		{
			// otherwise just make your best guess from current raw position
			widgetPoint = FlxPoint.get(currWidget.x, currWidget.y);
		}

		// get center point of object
		widgetPoint.x += currWidget.width / 2;
		widgetPoint.y += currWidget.height / 2;

		return widgetPoint;
	}

	private function _doMouseMove(?pt:FlxPoint):Void
	{
		var dispose:Bool = false;
		if (pt == null)
		{
			pt = _getWidgetPoint();
			if (pt == null)
			{
				return;
			}
			dispose = true;
		}
		if (dispatchEvents)
		{
			#if FLX_MOUSE
			// REALLY force it to this location
			FlxG.mouse.setGlobalScreenPositionUnsafe(pt.x, pt.y);

			if (_newMouse != null)
			{
				_newMouse.updateGlobalScreenPosition = false; // don't low-level-update the mouse while I'm overriding the mouse position
			}

			#if FLX_KEYBOARD
			FlxG.stage.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE, true, false, pt.x, pt.y, FlxG.stage, FlxG.keys.pressed.CONTROL,
				FlxG.keys.pressed.ALT, FlxG.keys.pressed.SHIFT));
			#end
			#end
		}
		if (dispose)
		{
			pt.put();
		}
	}

	private function _doPress(?pt:FlxPoint):Void
	{
		var currWidget:IFlxUIWidget = _widgets[location];
		if (currWidget == null)
		{
			return;
		}

		var dispose:Bool = false;
		if (pt == null)
		{
			pt = _getWidgetPoint();
			if (pt == null)
			{
				return;
			}
			dispose = true;
		}

		#if FLX_MOUSE
		if (dispatchEvents)
		{
			var rawMouseX:Float = pt.x * FlxG.camera.zoom;
			var rawMouseY:Float = pt.y * FlxG.camera.zoom;
			#if FLX_KEYBOARD
			FlxG.stage.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, rawMouseX, rawMouseY, FlxG.stage, FlxG.keys.pressed.CONTROL,
				FlxG.keys.pressed.ALT, FlxG.keys.pressed.SHIFT));
			#else
			FlxG.stage.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, rawMouseX, rawMouseY, FlxG.stage));
			#end
		}
		#end

		if (callback != null)
		{
			// notify the listener that we just "pressed" the widget
			callback("cursor_down", currWidget);
		}
		if (dispose)
		{
			pt.put();
		}
	}

	private function _doRelease(?pt:FlxPoint):Void
	{
		var currWidget:IFlxUIWidget = _widgets[location];
		if (currWidget == null)
		{
			return;
		}

		var dispose:Bool = false;
		if (pt == null)
		{
			pt = _getWidgetPoint();
			if (pt == null)
			{
				return;
			}
			dispose = true;
		}

		#if FLX_MOUSE
		var rawMouseX:Float = pt.x * FlxG.camera.zoom;
		var rawMouseY:Float = pt.y * FlxG.camera.zoom;

		if (dispatchEvents)
		{
			// dispatch a low-level mouse event to the FlxG.stage object itself
			#if FLX_KEYBOARD
			FlxG.stage.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP, true, false, rawMouseX, rawMouseY, FlxG.stage, FlxG.keys.pressed.CONTROL,
				FlxG.keys.pressed.ALT, FlxG.keys.pressed.SHIFT));
			if (_clickPressed)
				FlxG.stage.dispatchEvent(new MouseEvent(MouseEvent.CLICK, true, false, rawMouseX, rawMouseY, FlxG.stage, FlxG.keys.pressed.CONTROL,
					FlxG.keys.pressed.ALT, FlxG.keys.pressed.SHIFT));
			#else
			FlxG.stage.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP, true, false, rawMouseX, rawMouseY, FlxG.stage));
			if (_clickPressed)
				FlxG.stage.dispatchEvent(new MouseEvent(MouseEvent.CLICK, true, false, rawMouseX, rawMouseY, FlxG.stage));
			#end
		}
		#end

		if (callback != null)
		{
			// notify the listener that we just "clicked" the widget
			callback("cursor_click", currWidget);
		}
		if (dispose)
		{
			pt.put();
		}

		#if FLX_MOUSE
		if (_newMouse != null)
		{
			_newMouse.updateGlobalScreenPosition = true; // resume low-level-mouse updating now that I'm done overriding it
			_newMouse.setGlobalScreenPositionUnsafe(Std.int(FlxG.game.mouseX), Std.int(FlxG.game.mouseY));
		}
		#end
	}

	private function _findNextY(Y:Int, indexValue:Int, listWidget:Array<IFlxUIWidget>, listLists:Array<WidgetList>):Int
	{
		var currX:Int = 0;
		var currY:Int = 0;
		var length:Int = 0;

		if (listWidget != null)
		{
			currX = Std.int(listWidget[indexValue].x);
			currY = Std.int(listWidget[indexValue].y);
			length = listWidget.length;
		}
		else if (listLists != null)
		{
			currX = listLists[indexValue].x;
			currY = listLists[indexValue].y;
			length = listLists.length;
		}

		var nextX:Int = 0;
		var nextY:Int = 0;

		var dx:Float = Math.POSITIVE_INFINITY;
		var dy:Float = Math.POSITIVE_INFINITY;

		var bestdx:Float = dx;
		var bestdy:Float = dy;

		var besti:Int = -1;

		// DESIRED BEHAVIOR: Jump to the CLOSEST OBJECT that ALSO:
		// is located ABOVE/BELOW me (depending on Y's sign)

		for (i in 0...length)
		{
			if (i != indexValue)
			{
				if (listWidget != null)
				{
					nextX = Std.int(listWidget[i].x);
					nextY = Std.int(listWidget[i].y);
				}
				else if (listLists != null)
				{
					nextX = listLists[i].x;
					nextY = listLists[i].y;
				}

				dy = nextY - currY; // Get y distance
				if (FlxMath.sameSign(dy, Y) && dy != 0) // If it's in the right direction, and not at same Y, consider it
				{
					dy = Math.abs(dy);
					if (dy < bestdy) // If abs. y distance is closest so far
					{
						bestdy = dy;
						bestdx = Math.abs(currX - nextX); // reset this every time a better dy is found
						besti = i;
					}
					else if (dy == bestdy)
					{
						dx = Math.abs(currX - nextX); // If abs. x distance is closest so far
						if (dx < bestdx)
						{
							bestdx = dx;
							besti = i;
						}
					}
				}
			}
		}
		return besti;
	}

	private function _wrapX(X:Int, indexValue:Int, listLength:Int):Int
	{
		if (indexValue + X < 0)
		{
			indexValue = (indexValue + X) + listLength;
		}
		else if (indexValue + X >= listLength)
		{
			indexValue = (indexValue + X) - listLength;
		}
		return indexValue;
	}

	private function _wrapY(Y:Int, indexValue:Int, listWidget:Array<IFlxUIWidget>, listLists:Array<WidgetList>):Int
	{
		var dx:Float = Math.POSITIVE_INFINITY;
		var dy:Float = Math.POSITIVE_INFINITY;

		var bestdx:Float = dx;
		var bestdy:Float = dy;

		var besti:Int = -1;

		bestdx = Math.POSITIVE_INFINITY;
		bestdy = 0; // Now we want the FURTHEST object from us

		var length:Int = 0;
		var currX:Int = 0;
		var currY:Int = 0;

		if (listWidget != null)
		{
			length = listWidget.length;
			currX = Std.int(listWidget[indexValue].x);
			currY = Std.int(listWidget[indexValue].y);
		}
		if (listLists != null)
		{
			length = listLists.length;
			currX = listLists[indexValue].x;
			currY = listLists[indexValue].y;
		}

		for (i in 0...length)
		{
			if (i != location)
			{
				var xx = 0;
				var yy = 0;
				if (listWidget != null)
				{
					xx = Std.int(listWidget[i].x);
					yy = Std.int(listWidget[i].y);
				}
				else if (listLists != null)
				{
					xx = Std.int(listLists[i].x);
					yy = Std.int(listLists[i].y);
				}

				dy = yy - currY;

				if (FlxMath.sameSign(dy, Y) == false && dy != 0)
				{ // I want the WRONG direction this time
					dy = Math.abs(dy);
					if (dy > bestdy)
					{
						bestdy = dy;
						bestdx = Math.abs(currX - xx);
						besti = i;
					}
					else if (dy == bestdy)
					{
						dx = Math.abs(currX - xx);
						if (dx < bestdx)
						{
							bestdx = dx;
							besti = i;
						}
					}
				}
			}
		}
		if (besti != -1)
		{
			indexValue = besti;
		}
		return indexValue;
	}

	private function _doInput(X:Int, Y:Int, recursion:Int = 0):Void
	{
		if (ignoreNextInput)
		{
			ignoreNextInput = false;
			return;
		}
		var currWidget:IFlxUIWidget = null;

		if (Y == 0) // horizontal, just move back/forth
		{
			// Easy: go to the next index in the array, loop around if needed

			if (location + X >= 0 && location + X < _widgets.length) // within bounds
			{
				location = location + X;
			}
			else // at the boundary
			{
				if (wrap) // if wrapping
				{
					if (_lists.length == 1) // if we only have one list, wrap within the list
					{
						location = _wrapX(X, location, _widgets.length);
					}
					else // if we have multiple lists, go to the next list
					{
						if (listIndex + X >= 0 && listIndex + X < _lists.length)
						{
							listIndex = listIndex + X;
						}
						else
						{
							listIndex = _wrapX(X, listIndex, _lists.length);
						}
						if (X == -1)
						{
							location = _widgets.length - 1;
						}
					}
				}
			}
			currWidget = _widgets[location];
		}
		else // move UP/DOWN
		{
			// Harder: iterate through array, looking for widget with higher or lower y value
			var nextY = _findNextY(Y, location, _widgets, null);

			if (nextY != -1) // found something, just jump to that
			{
				location = nextY;
				currWidget = _widgets[location];
			}
			else // didn't find anything
			{
				if (wrap) // try wrapping around
				{
					if (_lists.length == 1) // if we only have one list, wrap within list
					{
						location = _wrapY(Y, location, _widgets, null);
						currWidget = _widgets[location];
					}
					else // if we have several, go to the next list
					{
						var nextListY = _findNextY(Y, listIndex, null, _lists);
						if (nextListY != -1) // within bounds, just go there
						{
							listIndex = nextListY;
							currWidget = _widgets[location];
						}
						else // out of bounds, try wrapping
						{
							listIndex = _wrapY(Y, listIndex, null, _lists);
						}
						if (Y == -1)
						{
							location = _widgets.length - 1;
						}
					}
					currWidget = _widgets[location];
				}
			}
		}

		if (currWidget != null && _widgets != null)
		{
			if (currWidget.visible == false && (recursion < _widgets.length))
			{
				_doInput(X, Y, recursion + 1);
				return;
			}
		}

		if (callback != null)
		{
			// notify the listener that the cursor has moved
			callback("cursor_jump", currWidget);
		}
	}

	private function _updateCursor():Void
	{
		_widgets = _lists[listIndex].widgets;

		if (location < 0 || _lists == null || _widgets == null)
		{
			visible = false;
			return;
		}

		visible = active = true;

		var currWidget:IFlxUIWidget = _widgets[location];
		var flippedX:Bool = false;
		var flippedY:Bool = false;

		if (currWidget != null)
		{
			var target:FlxObject = cast currWidget;

			if ((target is FlxSprite))
			{
				var fs:FlxSprite = cast target;
				if (fs != null && fs.scrollFactor != null)
				{
					scrollFactor.set(fs.scrollFactor.x, fs.scrollFactor.y);
				}
			}

			if ((currWidget is FlxUICheckBox))
			{
				var check:FlxUICheckBox = cast target;
				target = check.box;
			}

			anchor.anchorThing(this, target);
			if (x < 0)
			{
				_flipAnchor(Anchor.LEFT, target);
				flippedX = true;
			}
			else if (x > FlxG.width + width)
			{
				_flipAnchor(Anchor.RIGHT, target);
				flippedX = true;
			}
			if (y < 0)
			{
				_flipAnchor(Anchor.TOP, target);
				flippedY = true;
			}
			else if (y > FlxG.height + height)
			{
				_flipAnchor(Anchor.BOTTOM, target);
				flippedY = true;
			}
			this.flipX = flippedX;
			this.flipY = flippedY;
		}
	}

	private function _flipAnchor(AnchorDir:String, destination:FlxObject):Void
	{
		var theAnchor = null;
		switch (AnchorDir)
		{
			case Anchor.LEFT:
				if (anchor.x.side == Anchor.LEFT)
				{
					_leftAnchor = anchor.getFlipped(true, false, _leftAnchor);
					theAnchor = _leftAnchor;
				}
			case Anchor.RIGHT:
				if (anchor.x.side == Anchor.RIGHT)
				{
					_topAnchor = anchor.getFlipped(true, false, _rightAnchor);
					theAnchor = _rightAnchor;
				}
			case Anchor.TOP:
				if (anchor.y.side == Anchor.TOP)
				{
					_topAnchor = anchor.getFlipped(true, false, _topAnchor);
					theAnchor = _topAnchor;
				}
			case Anchor.BOTTOM:
				if (anchor.y.side == Anchor.BOTTOM)
				{
					_bottomAnchor = anchor.getFlipped(true, false, _bottomAnchor);
					theAnchor = _bottomAnchor;
				}
		}
		if (theAnchor != null)
		{
			theAnchor.anchorThing(this, destination);
		}
	}
}

typedef WidgetList =
{
	var x:Int;
	var y:Int;
	var width:Int;
	var height:Int;
	var widgets:Array<IFlxUIWidget>;
}

enum GamepadAutoConnectPreference
{
	Never;
	FirstActive;
	LastActive;
	GamepadID(i:Int);
}

enum SortMethod
{
	XY;
	ID;
}
