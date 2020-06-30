package flixel.addons.ui;

import flixel.addons.ui.interfaces.IEventGetter;
import flixel.addons.ui.interfaces.IFireTongue;
import flixel.addons.ui.interfaces.IFlxUIState;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
#if haxe4
import haxe.xml.Access;
#else
import haxe.xml.Fast as Access;
#end

/**
 * This is a simple extension of FlxState that does two things:
 * 1) It implements the IEventGetter interface
 * 2) Automatically creates a FlxUI objects from a single string id
 *
 * Usage:
 	 * Create a class that extends FlxUIState, override create, and
 	 * before you call super.create(), set _xml_id to the string id
 	 * of the corresponding UI xml file (leave off the extension).
 *
 * @author Lars Doucet
 */
class FlxUISubState extends FlxSubState implements IFlxUIState
{
	public var destroyed:Bool;

	#if FLX_MOUSE
	public var cursor:FlxUICursor = null;
	#end

	private var _makeCursor:Bool; // whether to auto-construct a cursor and load default widgets into it

	/**
	 * frontend for adding tooltips to things
	 */
	public var tooltips(default, null):FlxUITooltipManager;

	private var _xml_id:String = ""; // the xml to load
	private var _ui:FlxUI;
	private var _tongue:IFireTongue;

	// set this to true to make it automatically reload the UI when the window size changes
	public var reload_ui_on_resize:Bool = false;

	private var _reload:Bool = false;
	private var _reload_countdown:Int = 0;

	public var getTextFallback:String->String->Bool->String = null;

	public function new(BGColor:FlxColor = 0)
	{
		super(BGColor);
	}

	public function forceScrollFactor(X:Float, Y:Float):Void
	{
		if (_ui != null)
		{
			for (w in _ui.group.members)
			{
				w.scrollFactor.set(X, Y);
			}
			if (_ui.scrollFactor != null)
			{
				_ui.scrollFactor.set(X, Y);
			}
		}
	}

	public function forceFocus(b:Bool, thing:IFlxUIWidget):Void
	{
		if (_ui != null)
		{
			if (b)
			{
				_ui.focus = thing;
			}
			else
			{
				_ui.focus = null;
			}
		}
	}

	public override function create():Void
	{
		if (FlxUIState.static_tongue != null)
		{
			_tongue = FlxUIState.static_tongue;
		}

		#if FLX_MOUSE
		if (_makeCursor == true)
		{
			cursor = createCursor();
		}
		#end

		tooltips = new FlxUITooltipManager(this);

		_ui = createUI(null, this, null, _tongue);
		add(_ui);

		_ui.getTextFallback = getTextFallback;

		if (_xml_id != "" && _xml_id != null)
		{
			var data:Access = U.xml(_xml_id);
			if (data == null)
			{
				data = U.xml(_xml_id, "xml", true, ""); // try without default directory prepend
			}

			if (data == null)
			{
				#if debug
				FlxG.log.error("FlxUISubstate: Could not load _xml_id \"" + _xml_id + "\"");
				#end
			}
			else
			{
				_ui.load(data);
			}
		}
		else
		{
			_ui.load(null);
		}

		#if FLX_MOUSE
		if (cursor != null && _ui != null)
		{ // Cursor goes on top, of course
			add(cursor);
			cursor.addWidgetsFromUI(_ui);
			cursor.findVisibleLocation(0);
		}

		FlxG.mouse.visible = true;
		#end

		tooltips.init();

		super.create();

		cleanup();

		if ((_parentState is FlxUIState))
		{
			reload_ui_on_resize = cast(_parentState, FlxUIState).reload_ui_on_resize;
		}
	}

	public function onCursorEvent(code:String, target:IFlxUIWidget):Void
	{
		getEvent(code, target, null);
	}

	public function onShowTooltip(t:FlxUITooltip):Void
	{
		// override per subclass
	}

	public override function onResize(Width:Int, Height:Int):Void
	{
		if (reload_ui_on_resize)
		{
			FlxG.resizeGame(Width, Height);
			_reload_countdown = 5;
			_reload = true;
		}
	}

	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		tooltips.update(elapsed);
		if (_reload)
		{
			if (_reload_countdown > 0)
			{
				_reload_countdown--;
				if (_reload_countdown == 0)
				{
					reloadUI();
				}
			}
		}
	}

	public override function destroy():Void
	{
		destroyed = true;

		if (tooltips != null)
		{
			tooltips.destroy();
			tooltips = null;
		}

		if (_ui != null)
		{
			_ui.destroy();
			remove(_ui, true);
			_ui = null;
		}

		super.destroy();
	}

	public function getEvent(id:String, sender:IFlxUIWidget, data:Dynamic, ?params:Array<Dynamic>):Void
	{
		// define per subclass
	}

	public function getRequest(id:String, sender:IFlxUIWidget, data:Dynamic, ?params:Array<Dynamic>):Dynamic
	{
		// define per subclass
		return null;
	}

	public function getText(Flag:String, Context:String = "ui", Safe:Bool = true):String
	{
		if (_tongue != null)
		{
			return _tongue.get(Flag, Context, Safe);
		}
		if (getTextFallback != null)
		{
			return getTextFallback(Flag, Context, Safe);
		}
		return Flag;
	}

	@:access(flixel.addons.ui.FlxUI)
	private function cleanup():Void
	{
		// Clean up intermediate cached graphics that are no longer necessary
		_ui.cleanup();
	}

	/**
	 * Creates a cursor. Makes it easy to override this function in your own FlxUIState.
	 * @return
	 */
	private function createCursor():FlxUICursor
	{
		return new FlxUICursor(onCursorEvent);
	}

	// this makes it easy to override this function in your own FlxUIState,
	// in case you want to instantiate a custom class that extends FlxUI instead
	private function createUI(data:Access = null, ptr:IEventGetter = null, superIndex_:FlxUI = null, tongue_:IFireTongue = null,
			liveFilePath_:String = ""):FlxUI
	{
		return new FlxUI(data, ptr, superIndex_, tongue_, liveFilePath_);
	}

	private function reloadUI():Void
	{
		if (_ui != null)
		{
			remove(_ui, true);
			_ui.destroy();
			_ui = null;
		}

		_ui = createUI(null, this, null, _tongue);
		add(_ui);

		var data:Access = U.xml(_xml_id);
		_ui.load(data);

		_reload = false;
		_reload_countdown = 0;
	}
}
