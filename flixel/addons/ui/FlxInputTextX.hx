package flixel.addons.ui;

/**
 * @author Lars Doucet
 */

class FlxInputTextX extends FlxInputText implements IResizable
{
	public function new(X:Float, Y:Float, Width:Int = 200, Text:String = null, size:Int = 8, TextColor:Int = 0xFF000000, BackgroundColor:Int = 0xFFFFFFFF, EmbeddedFont:Bool = true, isStatic:Bool = false) {
		super(X, Y, Width, Text, size, TextColor, BackgroundColor, EmbeddedFont, isStatic);
	}
	
	public function get_width():Float {
		return width;
	}
	
	public function get_height():Float {
		return height;
	}
	
	public function resize(w:Float, h:Float):Void {
		width = w;
		height = h;
		calcFrame();
	}
	
	public function forceCalcFrame():Void {
		calcFrame();
	}
	
}