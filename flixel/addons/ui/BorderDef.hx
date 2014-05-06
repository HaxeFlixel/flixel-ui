package flixel.addons.ui;
import flixel.text.FlxText;

class BorderDef
{
	public var style:Int; 
	public var color:Int; 
	public var size:Float;
	public var quality:Float;
	
	public function new(Style:Int, Color:Int, Size:Float=1, Quality:Float=1) {
		style = Style;
		color = Color;
		size = Size;
		quality = Quality;
	}
	
	public function apply(f:FlxText):Void {
		f.setBorderStyle(style, color, size, quality);
	}
}