package org.flixel.plugin.leveluplabs;
import haxe.xml.Fast;
import flash.display.BitmapData;
import flash.Lib;
import org.flixel.FlxBasic;
import org.flixel.FlxButton;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxObject;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxText;

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
		//define per subclass
	}
	
	public function getRequest(id:String, sender:Dynamic, data:Dynamic):Dynamic {
		//define per subclass
		return null;
	}
	
}