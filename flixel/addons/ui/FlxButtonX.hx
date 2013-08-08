package flixel.addons.ui;
import flixel.ui.FlxButton;

class FlxButtonX extends FlxButton implements IResizable
{
	public var id:String; 
	public var resize_ratio:Float = 1;
	public var labelX(get, set):FlxTextX;
	public var up_color:Int = 0;
	public var over_color:Int = 0;
	public var down_color:Int = 0;
	
	private var _new_color:Int = 0;
	
	public function new(X:Float = 0, Y:Float = 0, ?Label:String, ?OnClick:Dynamic, Resize_Ratio:Float = 1) {
		resize_ratio = Resize_Ratio;
		super(X, Y, Label, OnClick);
	}	
	
	public function get_labelX():FlxTextX {
		if (label != null && Std.is(label, FlxTextX)) {
			return cast label;
		}
		return null;
	}
	
	public function set_labelX(ftx:FlxTextX):FlxTextX {
		label = ftx;
		return ftx;
	}
	
	/**For IResizable:**/
	
	public function get_width():Float { return width; }
	public function get_height():Float { return height; }
	
	public function resize(W:Float, H:Float):Void {
		//TODO: resize stuff!
	}
	
	public function forceCalcFrame():Void {
		calcFrame();
	}
	
	public override function update():Void {
		super.update();
		if (label == null) {
			return;
		}
		label.alpha = 1;
		switch (frame)
		{
			case FlxButton.HIGHLIGHT:
				if (_new_color != over_color) {
					_new_color = over_color;
				}
			case FlxButton.PRESSED:
				if (_new_color != down_color) {
					_new_color = down_color;
				}
			default:
				if (_new_color != up_color) {
					_new_color = up_color;
				}
		}
		if (_new_color != 0) {
			label.color = _new_color;
			trace("new color = " + _new_color);
			_new_color = 0;
		}
	}
	
}