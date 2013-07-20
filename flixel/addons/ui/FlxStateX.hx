package flixel.addons.ui;
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
	 * Create a class that extends FlxStateX, override create, and 
	 * before you call super.create(), set _xml_id to the string id
	 * of the corresponding UI xml file (leave off the extension).
 * 
 * @author Lars Doucet
 */

class FlxStateX extends FlxState implements IEventGetter
{
	private var _xml_id:String = "";	//the xml to load
	private var _ui:FlxUI;
	
	public function new() 
	{
		super();
	}
	
	public override function create():Void {
		if (_xml_id == "") {
			throw "FlxStateX has no xml id defined!";
		}
		
		_ui = new FlxUI(null,this);
		add(_ui);
				
		var data:Fast = U.xml(_xml_id);
		_ui.load(data);
		
		useMouse = true;
	}
	
	public override function destroy():Void {
		_ui.destroy();
		remove(_ui, true);
		_ui = null;
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
	
	/**
	 * Convenient helper function to make sure your event data is safe
	 * @param	data
	 * @return
	 */
	
	private static inline function processEventData(data:Dynamic):Array<Dynamic> {
		if (data != null && Std.is(data, Array)) {
			var arr:Array<Dynamic> = cast data;
			if (arr.length >= 1) {
				return arr;
			}
		}
		return null;
	}
	
}