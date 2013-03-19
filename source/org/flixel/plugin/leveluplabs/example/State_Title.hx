package org.flixel.plugin.leveluplabs.example;
import com.leveluplabs.tdrpg.BasicEntity;
import org.flixel.FlxG;
import org.flixel.plugin.leveluplabs.FlxStateX;

/**
 * @author Lars Doucet
 */

class State_Title extends FlxStateX
{

	override public function create():Void
	{
		#if !neko
		FlxG.bgColor = 0xff131c1b;
		#else
		FlxG.bgColor = {rgb: 0x131c1b, a: 0xff};
		#end		
		FlxG.mouse.show();
		
		_xml_id = "state_title";
		super.create();
		
	}
	
	public override function getEvent(id:String, sender:Dynamic, data:Dynamic):Void {
		if (Std.is(data, String)) {
			switch(cast(data, String)) {
				case "saves": FlxG.switchState(new State_SaveMenu());
				case "menu": FlxG.switchState(new State_TestMenu());
			}
		}
	}
	
}