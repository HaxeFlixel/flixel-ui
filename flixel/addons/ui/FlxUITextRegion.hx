package flixel.addons.ui;
import flixel.addons.ui.interfaces.IFlxUIText;
import flixel.addons.ui.interfaces.IHasParams;
import flixel.text.FlxBitmapText;

/**
 * A FlxUIRegion that can also hold a font definition, useful for when you want to create text layouts without instantly drawing them at load time
 * @author 
 */
class FlxUITextRegion extends FlxUIRegion implements IHasParams implements IFlxUIText
{
	public var fontDef:FontDef;
	public var text(default, set):String;
	public var size(default, set):Int;
	public var embedFonts:Bool;
	public var fieldWidth(default, set):Float;
	public var params(default, set):Array<Dynamic>;
	
	public function new(X:Float = 0, Y:Float = 0, FieldWidth:Float = 0, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true)
	{
		fieldWidth = FieldWidth;
		var W = fieldWidth;
		var H = Size + 4;
		text = Text;
		size = Size;
		embedFonts = EmbeddedFont;
		super(X, Y, W, H);
	}
	
	override public function resize(w:Float, h:Float):Void 
	{
		if (w < 8) w = 8;
		if (h < 8) h = 8;
		super.resize(w, h);
		size = Std.int(h - 4);
		if (size < 0) size = 1;
	}
	
	public function createFlxUIText():FlxUIText
	{
		var t:FlxUIText = new FlxUIText(x, y, fieldWidth, text, size, embedFonts);
		fontDef.applyFlx(t);
		return t;
	}
	
	private function set_size(s:Int):Int
	{
		size = s;
		height = size + 4;
		return s;
	}
	
	private function set_text(t:String):String
	{
		text = t;
		return t;
	}
	
	private function set_fieldWidth(w:Float):Float
	{
		fieldWidth = w;
		width = fieldWidth;
		return fieldWidth;
	}
	
	private function set_params(p:Array <Dynamic>):Array<Dynamic>
	{
		params = p;
		return p;
	}
}