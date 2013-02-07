package org.flixel.plugin.leveluplabs.example;
import haxe.xml.Fast;
import nme.Lib;
import org.flixel.FlxG;
import org.flixel.plugin.leveluplabs.FlxStateX;

/**
 * ...
 * @author Lars Doucet
 */

class State_SaveMenu extends FlxStateX
{

	override public function create() 
	{
		_xml_id = "state_save";
		super.create();
	}
	
	public override function getRequest(id:String, target:Dynamic, data:Dynamic):Dynamic {
		return null;
	}
	
	public override function getEvent(id:String,target:Dynamic,data:Dynamic):Void {
		if (Std.is(data, String)) {
			switch(cast(data, String)) {
				case "back": FlxG.switchState(new State_Title());
			}
		}
	}
	
	public override function update():Void {
		super.update();
	}
}