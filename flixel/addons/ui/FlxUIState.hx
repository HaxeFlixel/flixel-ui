package flixel.addons.ui;

#if flixel_addons
import flixel.addons.transition.Transition;
import flixel.addons.transition.FlxTransitionableState;
#end
import flixel.addons.ui.interfaces.ICursorPointable;
import flixel.addons.ui.interfaces.IEventGetter;
import flixel.addons.ui.interfaces.IFireTongue;
import flixel.addons.ui.interfaces.IFlxUIState;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.FlxG;
import flixel.FlxState;
import openfl.Assets;
import openfl.events.Event;
#if haxe4
import haxe.xml.Access;
#else
import haxe.xml.Fast as Access;
#end

/**
 * This is a simple extension of FlxState that does two things:
 * 1) It implements the IFlxUIState interface
 * 2) Automatically creates a FlxUI objects from a single string id
 *
 * Usage:
 	 * Create a class that extends FlxUIState, override create, and
 	 * before you call super.create(), set _xml_id to the string id
 	 * of the corresponding UI xml file (leave off the extension).
 *
 * @author Lars Doucet
 */
#if flixel_addons
class FlxUIState extends FlxTransitionableState implements IEventGetter implements IFlxUIState
#else
class FlxUIState extends FlxState implements IEventGetter implements IFlxUIState
#end
{
	public var destroyed:Bool;
	#if FLX_MOUSE
	public var cursor:FlxUICursor = null;
	public var hideCursorOnSubstate:Bool = false;
	private var _cursorHidden:Bool = false;
	#end
	/**
	 * frontend for adding tooltips to things
	 */
	public var tooltips(default, null):FlxUITooltipManager;
	private var _xml_id:String = ""; // the xml file to load from assets
	#if (debug && sys)
	// If you want to do live reloading, set the path to your assets directory on your local disk here,
	// and it will load that instead of loading the xml specification from embedded assets
	// (only works on cpp/neko targets)
	// this should serve as a PREFIX to the _xml_id:
	// if full path="path/to/assets/xml/ui/foo.xml" and _xml_id="ui/foo.xml", then liveFilePath="path/to/assets/xml/"
	private var _liveFilePath:String = "";
	#end
	private var _makeCursor:Bool; // whether to auto-construct a cursor and load default widgets into it
	private var _ui_vars:Map<String, String>;
	private var _ui:FlxUI;
	private var _tongue:IFireTongue;
	public static var static_tongue:IFireTongue = null;
	// if this is not null, each state will grab this auto-magically
	// otherwise it's up to you to set _tongue before the UI stuff loads.
	#if (debug && sys)
	public static var static_liveFilePath:String = "";
	// if this is not "", each state will grab this auto-magically
	// otherwise it's up to you to set _liveFilePath before the UI stuff loads.
	#end
	#if (debug && sys)
	public var reload_ui_on_asset_change(default, set):Bool;
	// setting this to true will add a listener to reload the UI when assets are updated ("openfl update <proj> <target>" in OpenFL 2.0)
	// cpp/neko only
	#end
	// set this to true to make it automatically reload the UI when the window size changes
	public var reload_ui_on_resize:Bool = false;
	private var _reload:Bool = false;
	private var _reload_countdown:Int = 0;
	public var getTextFallback:String->String->Bool->String = null;

	#if (debug && sys)
	private function set_reload_ui_on_asset_change(b:Bool):Bool
	{
		// whether or not to reload UI when assets are updated
		if (b)
			Assets.addEventListener(Event.CHANGE, reloadUI);
		else
			Assets.removeEventListener(Event.CHANGE, reloadUI);
		return reload_ui_on_asset_change = b;
	}
	#end

	public override function create():Void
	{
		if (static_tongue != null)
		{
			_tongue = static_tongue;
		}

		#if (debug && sys)
		if (static_liveFilePath != null && static_liveFilePath != "")
		{
			_liveFilePath = static_liveFilePath;
		}
		#end

		#if FLX_MOUSE
		if (_makeCursor == true)
		{
			cursor = createCursor();
		}
		#end

		tooltips = new FlxUITooltipManager(this);

		var liveFile:Access = null;

		#if (debug && sys)
		if (_liveFilePath != null && _liveFilePath != "")
		{
			try
			{
				liveFile = U.readAccess(U.fixSlash(_liveFilePath + _xml_id));
				trace("liveFile = " + liveFile);
			}
			catch (msg:String)
			{
				FlxG.log.warn(msg);
				trace(msg);
				liveFile = null;
			}
		}
		_ui = createUI(null, this, null, _tongue, _liveFilePath);
		#else
		_ui = createUI(null, this, null, _tongue);
		#end
		add(_ui);

		if (getTextFallback != null)
		{
			_ui.getTextFallback = getTextFallback;
		}

		if (_xml_id != null && _xml_id != "")
		{
			var data:Access = null;
			var errorMsg:String = "";

			if (liveFile == null)
			{
				try
				{
					data = U.xml(_xml_id);
				}
				catch (msg:String)
				{
					errorMsg = msg;
				}
				if (data == null)
				{
					try
					{
						data = U.xml(_xml_id, "xml", true, ""); // try again without default directory prepend
					}
					catch (msg2:String)
					{
						errorMsg += ", " + msg2;
					}
				}
			}

			if (data == null)
			{
				if (liveFile != null)
				{
					loadUIFromData(liveFile);
				}
				else
				{
					FlxG.log.error("FlxUISubState: Could not load _xml_id \"" + _xml_id + "\"");
				}
			}
			else
			{
				loadUIFromData(data);
			}
		}
		else
		{
			loadUIFromData(null);
		}

		#if FLX_MOUSE
		if (cursor != null && _ui != null)
		{ // Cursor goes on top, of course
			add(cursor);
			cursor.addWidgetsFromUI(_ui);
			cursor.findVisibleLocation(0);
		}
		#end

		tooltips.init();

		super.create();

		cleanup();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (tooltips != null)
		{
			tooltips.update(elapsed);
		}
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

	@:access(flixel.addons.ui.FlxUI)
	private function cleanup():Void
	{
		// Clean up intermediate cached graphics that are no longer necessary
		_ui.cleanup();
	}

	private function _cleanupUIVars():Void
	{
		if (_ui_vars != null)
		{
			for (key in _ui_vars.keys())
			{
				_ui_vars.remove(key);
			}
			_ui_vars = null;
		}
	}

	public function setUIVariable(key:String, value:String):Void
	{
		if (_ui != null)
		{
			// if the UI is constructed, set the variable directly
			_ui.setVariable(key, value);
		}
		else
		{
			// if not, store it locally until the UI is constructed, then pass it in as it's being created
			if (_ui_vars == null)
				_ui_vars = new Map<String, String>();
			_ui_vars.set(key, value);
		}
	}

	public function resizeScreen(width:Float = 800, height:Float = 600):Void
	{
		/*#if sys
				//TODO: reimplement with next OpenFL
				FlxG.stage.resize(Std.int(width), Std.int(height));
				onResize(Std.int(width), Std.int(height));
			#end */
	}

	public override function openSubState(SubState:FlxSubState):Void
	{
		#if FLX_MOUSE
		if (cursor != null && hideCursorOnSubstate && cursor.visible == true)
		{
			_cursorHidden = true;
			cursor.visible = false;
		}
		#end
		super.openSubState(SubState);
	}

	public override function closeSubState():Void
	{
		#if FLX_MOUSE
		if (cursor != null && hideCursorOnSubstate && _cursorHidden)
		{
			_cursorHidden = false;
			cursor.visible = true;
		}
		#end
		super.closeSubState();
	}

	public override function onResize(Width:Int, Height:Int):Void
	{
		if (reload_ui_on_resize)
		{
			FlxG.resizeGame(Width, Height);
			_reload_countdown = 1;
			_reload = true;
		}
	}

	/** @since 2.1.0 */
	public function onShowTooltip(t:FlxUITooltip):Void
	{
		// override per subclass
	}

	public override function destroy():Void
	{
		destroyed = true;

		if (_ui != null)
		{
			_ui.destroy();
			remove(_ui, true);
			_ui = null;
		}

		if (tooltips != null)
		{
			tooltips.destroy();
			tooltips = null;
		}

		super.destroy();
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

	public function onCursorEvent(code:String, target:IFlxUIWidget):Void
	{
		getEvent(code, target, null);
	}

	public function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void
	{
		// define per subclass
	}

	public function getRequest(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Dynamic
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
		var flxui = new FlxUI(data, ptr, superIndex_, tongue_, liveFilePath_, _ui_vars);
		_cleanupUIVars(); // clear out temporary _ui_vars variable if it was set
		return flxui;
	}

	// this makes it easy to override this function in your own FlxUIState,
	// in case you want to operate on data before it is loaded
	private function loadUIFromData(data:Access):Void
	{
		_ui.load(data);
	}

	private function reloadUI(?e:Event):Void
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
		if (data != null)
		{
			loadUIFromData(data);
		}

		_reload = false;
		_reload_countdown = 0;
	}
}
