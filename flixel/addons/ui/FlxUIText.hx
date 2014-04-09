package flixel.addons.ui;

import flixel.addons.ui.FlxUI.UIEventCallback;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.interfaces.IResizable;
import flixel.text.FlxText;

/**
 * Simple extension to the basic text field class.
 * @author Lars Doucet
 */
class FlxUIText extends FlxText implements IResizable implements IFlxUIWidget 
{
	public var broadcastToFlxUI:Bool = true;
	
	public var id:String; 
	
	public function resize(w:Float, h:Float):Void {
		width = w;
		height = h;
		calcFrame();
	}
}

class FontDef
{
	public var name:String=null;
	public var size:Null<Int>=null;
	public var style:String=null;
	
	public function new(Name:String, ?Size:Null<Int>, ?Style:String) {
		name = Name;
		size = Size;
		style = Style;
	}
	
	public function apply(f:FlxText):Void {
		f.font = name;
		f.size = size;
	}
}

class BorderDef
{
	public var style:Int; 
	public var color:Int; 
	public var size:Int;
	public var quality:Float;
	
	public function new(Style:Int, Color:Int, Size:Int=1, Quality:Float=1) {
		style = Style;
		color = Color;
		size = Size;
		quality = Quality;
	}
	
	public function apply(f:FlxText):Void {
		f.setBorderStyle(style, color, size, quality);
	}
}
