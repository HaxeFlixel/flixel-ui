package flixel.addons.ui.interfaces;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

/**
 * @author 
 */
interface IFlxUIText extends IFlxUIWidget extends IFlxDestroyable
{
	public var text(default, set):String;
	
	public var alpha(default, set):Float;
	
	private function set_text(Text:String):String;
	private function set_color(Color:FlxColor):Int;
	
	public function draw():Void;
}
