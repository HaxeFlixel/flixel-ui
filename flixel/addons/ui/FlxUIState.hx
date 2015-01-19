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
import haxe.xml.Fast;
import openfl.Assets;
import openfl.events.Event;

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
	
	#if !FLX_NO_MOUSE
	public var cursor:FlxUICursor = null;
	#end
	
	private var _xml_id:String = "";			//the xml file to load from assets
	
	#if (debug && sys)
		//If you want to do live reloading, set the path to your assets directory on your local disk here, 
		//and it will load that instead of loading the xml specification from embedded assets
		//(only works on cpp/neko targets)
		//this should serve as a PREFIX to the _xml_id:
		//if full path="path/to/assets/xml/ui/foo.xml" and _xml_id="ui/foo.xml", then liveFilePath="path/to/assets/xml/"
		private var _liveFilePath:String = "";
	#end
	private var _makeCursor:Bool;		//whether to auto-construct a cursor and load default widgets into it
	
	private var _ui:FlxUI;
	private var _tongue:IFireTongue;
	
	public static var static_tongue:IFireTongue=null;
	//if this is not null, each state will grab this auto-magically
	//otherwise it's up to you to set _tongue before the UI stuff loads.
	
	#if (debug && sys)
		public static var static_liveFilePath:String = "";
		//if this is not "", each state will grab this auto-magically
		//otherwise it's up to you to set _liveFilePath before the UI stuff loads.
	#end
	
	#if (debug && sys)
		public var reload_ui_on_asset_change(default, set):Bool;
		// setting this to true will add a listener to reload the UI when assets are updated ("openfl update <proj> <target>" in OpenFL 2.0)
		// cpp/neko only
	#end
	
	//set this to true to make it automatically reload the UI when the window size changes
	public var reload_ui_on_resize:Bool = false;
	
	private var _reload:Bool = false;
	private var _reload_countdown:Int = 0;
	
	public var getTextFallback:String->String->Bool->String = null;
	
	#if (debug && sys)
		private function set_reload_ui_on_asset_change(b:Bool):Bool {
			// whether or not to reload UI when assets are updated
			if (b) Assets.addEventListener(Event.CHANGE, reloadUI);
			else Assets.removeEventListener(Event.CHANGE, reloadUI);
			return reload_ui_on_asset_change = b;
		}
	#end
	
	public override function create():Void {
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
		
		#if !FLX_NO_MOUSE
		if (_makeCursor == true)
		{
			cursor = new FlxUICursor(onCursorEvent);
		}
		#end
		
		var liveFile:Fast = null;
		
		if (_xml_id != null && _xml_id != "")
		{
			#if (debug && sys)
				if (_liveFilePath != null && _liveFilePath != "")
				{
					try
					{
						liveFile = U.readFast(U.fixSlash(_liveFilePath + _xml_id));
						trace("liveFile = " + liveFile);
					}
					catch(msg:String)
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
			
			
			var data:Fast = null;
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
						data = U.xml(_xml_id, "xml", true, "");	//try again without default directory prepend
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
		#if !FLX_NO_MOUSE
		if (cursor != null) {			//Cursor goes on top, of course
			add(cursor);
			var widget:IFlxUIWidget;
			for (widget in _ui.members) {
				if (Std.is(widget, ICursorPointable) || Std.is(widget, FlxUIGroup))//if it's directly pointable or a group
				{		
					cursor.addWidget(cast widget);	//add it
				}
			}
			cursor.location = 0;
		}
		#end
		
		super.create();
	}
	
	public function resizeScreen(width:Float=800, height:Float=600):Void {
		/*#if sys
			//TODO: reimplement with next OpenFL
			FlxG.stage.resize(Std.int(width), Std.int(height));
			onResize(Std.int(width), Std.int(height));
		#end*/
	}
		
	public override function onResize(Width:Int, Height:Int):Void {
		FlxG.resizeGame(Width, Height);	
		_reload_countdown = 1;
		_reload = true;
	}
	
	public override function destroy():Void {
		destroyed = true;

		if(_ui != null){
			_ui.destroy();
			remove(_ui, true);
			_ui = null;
		}
		
		super.destroy();
	}
		
	public function forceFocus(b:Bool, thing:IFlxUIWidget):Void {
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
	
	public function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void {
		//define per subclass
	}
	
	public function getRequest(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Dynamic {
		//define per subclass
		return null;
	}
	
	public function getText(Flag:String,Context:String="ui",Safe:Bool=true):String{
		if (_tongue != null) {
			return _tongue.get(Flag, Context, Safe);
		}
		if (getTextFallback != null){
			return getTextFallback(Flag, Context, Safe);
		}
		return Flag;
	}
	
	//this makes it easy to override this function in your own FlxUIState,
	//in case you want to instantiate a custom class that extends FlxUI instead
	private function createUI(data:Fast = null, ptr:IEventGetter = null, superIndex_:FlxUI = null, tongue_:IFireTongue = null, liveFilePath_:String=""):FlxUI
	{
		return new FlxUI(data, ptr, superIndex_, tongue_, liveFilePath_);
	}
	
	//this makes it easy to override this function in your own FlxUIState,
	//in case you want to operate on data before it is loaded
	private function loadUIFromData(data:Fast):Void
	{
		_ui.load(data);
	}
	
	private function reloadUI(?e:Event):Void {
		if (_ui != null) {
			remove(_ui, true);
			_ui.destroy();
			_ui = null;
		}
		
		_ui = createUI(null,this,null,_tongue);
		add(_ui);
				
		var data:Fast = U.xml(_xml_id);
		if (data != null)
		{
			loadUIFromData(data);
		}
		
		_reload = false;
		_reload_countdown = 0;
	}
	
}
