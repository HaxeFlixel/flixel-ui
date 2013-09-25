package flixel.addons.ui;
import flixel.FlxCamera;
import haxe.xml.Fast;
import flash.display.BitmapData;
import flash.Lib;
import flixel.FlxBasic;
import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;

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

class FlxUIState extends FlxState implements IEventGetter
{
	public var destroyed:Bool;
	private var _xml_id:String = "";	//the xml to load
	private var _ui:FlxUI;
	private var _tongue:IFireTongue;
	
	public static var static_tongue:IFireTongue=null;	
	//if this is not null, each state will grab this auto-magically
	//otherwise it's up to you to set _tongue before the UI stuff loads.
	
	//set this to true to make it automatically reload the UI when the window size changes
	public var reload_ui_on_resize:Bool = false;	
	
	private var _reload:Bool = false;
	private var _reload_countdown:Int = 0;
	
	public var getTextFallback:String->String->Bool->String = null;
	
	public function new() 
	{
		super();
		//FlxG.console.addCommand("resizeScreen", this, resizeScreen);
	}
	
	public override function create():Void {
		if (static_tongue != null) {
			_tongue = static_tongue;
		}
		
		if(_xml_id != "" && _xml_id != null){
			_ui = new FlxUI(null,this,null,_tongue);
			add(_ui);
			
			_ui.getTextFallback = getTextFallback;
		
			var data:Fast = U.xml(_xml_id);
			if (data == null) {
				data = U.xml(_xml_id, ".xml", true, "");	//try without default directory prepend
			}
			
			if (data == null) {
				#if debug
					trace("ERROR! Could not load _xml_id \"" + _xml_id + "\"");
				#end
			}else{			
				_ui.load(data);
			}
		}
		
		useMouse = true;
	}
	
	
	
	public function resizeScreen(width:Float=800, height:Float=600):Void {
		#if sys
			FlxG.stage.resize(cast width, cast height);
			onResize(cast width,cast height);
		#end
	}
		
	public override function onResize(Width:Int, Height:Int):Void {
		FlxG.resizeGame(Width, Height);	
		_reload_countdown = 1;
		_reload = true;
	}
	
	public override function update():Void {
		super.update();
		#if debug
			if (_reload) {
				if (_reload_countdown > 0) {
					_reload_countdown--;
					if (_reload_countdown == 0) {
						_reload = false;
						#if debug
							trace("RELOAD UI!");
						#end
						reloadUI();
					}
				}
			}
		#end
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
		
	public function getEvent(id:String, sender:Dynamic, data:Dynamic):Void {		
		eventResponse(id, sender, processEventData(data));
	}
	
	public function eventResponse(id:String, sender:Dynamic, data:Array<Dynamic>):Void {
		//define per subclass
	}
	
	public function getRequest(id:String, sender:Dynamic, data:Dynamic):Dynamic {
		//define per subclass
		return null;
	}
	
	private function reloadUI():Void {
		if (_ui != null) {
			remove(_ui, true);
			_ui.destroy();
			_ui = null;
		}
		
		_ui = new FlxUI(null,this,null,_tongue);
		add(_ui);
				
		var data:Fast = U.xml(_xml_id);
		_ui.load(data);
		
		_reload = false;
		_reload_countdown = 0;
	}
	
	
	/**
	 * Convenient helper function to make sure your event data is safe
	 * @param	data
	 * @return
	 */
	
	private static function processEventData(data:Dynamic):Array<Dynamic> {
		if (data != null && Std.is(data, Array)) {
			var arr:Array<Dynamic> = cast data;
			if (arr.length >= 1) {
				return arr;
			}
		}
		return null;
	}
	
}
