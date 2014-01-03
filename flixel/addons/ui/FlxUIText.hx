package flixel.addons.ui;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFormat;
import flixel.text.FlxText;

/**
 * Simple extension to the basic text field class.
 * @author Lars Doucet
 */

class FlxUIText extends FlxText implements IResizable implements IFlxUIWidget 
{
	public var id:String; 
	
	public function new(X:Float, Y:Float, Width:Int, Text:String = null, size:Int=8, EmbeddedFont:Bool = true)
	{
		super(X, Y, Width, Text, size, EmbeddedFont);
	}
	
	public function resize(w:Float, h:Float):Void {
		width = w;
		height = h;
		calcFrame();
	}
	
	public function textWidth():Float {	return _textField.textWidth; }
	public function textHeight():Float { return _textField.textHeight; }
	
	public function forceCalcFrame():Void {
		_regen = true;
		calcFrame();
	}
	
	public function getTextField()
	{
		return _textField;
	}
	
}
