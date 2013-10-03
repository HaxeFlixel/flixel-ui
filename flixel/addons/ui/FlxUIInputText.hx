package flixel.addons.ui;

/**
 * @author Lars Doucet
 */

class FlxUIInputText extends FlxInputText implements IResizable implements IFlxUIWidget 
{
	public var id:String;
	
	public function new(X:Float, Y:Float, Width:Int = 200, Text:String = null, size:Int = 8, TextColor:Int = 0xFF000000, BackgroundColor:Int = 0xFFFFFFFF, EmbeddedFont:Bool = true) {
		super(X, Y, Width, Text, size, TextColor, BackgroundColor, EmbeddedFont);
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