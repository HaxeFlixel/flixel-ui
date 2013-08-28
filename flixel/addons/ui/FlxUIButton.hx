package flixel.addons.ui;
import flash.events.Event;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flash.display.BitmapData;
import flixel.util.FlxPoint;
import openfl.Assets;

/**
 * This class extends FlxUITypedButton and has a Text label, and is thus
 * most analagous to the regular FlxButton
 * 
 * Like all FlxUITypedButton's, it can work as a toggle button, and load
 * 9-slice sprites for its button images, and be dynamically resized 
 * accordingly.
 * 
 * Furthermore, you have the ability to set the text's coloring for each
 * state just by adjusting a few public variables
 */

class FlxUIButton extends FlxUITypedButton<FlxUIText> implements IResizable
{
	//Change these to something besides 0 to make the label use that color
	//when that state is active
	public var up_color:Int = 0;
	public var over_color:Int = 0;
	public var down_color:Int = 0;
	
	public var up_toggle_color:Int = 0;
	public var over_toggle_color:Int = 0;
	public var down_toggle_color:Int = 0;
	
	public function new(X:Float = 0, Y:Float = 0, ?Label:String, ?OnClick:Dynamic) {
		super(X, Y, null, OnClick);		
		if (Label != null) {
			//create a FlxUIText label
			labelOffset = new FlxPoint( -1, 3);
			label = new FlxUIText(X + labelOffset.x, Y + labelOffset.y, 80, Label, 8);
			label.setFormat(null, 8, 0x333333, "center");
		}
	}	
		
	/**For IResizable:**/
		
	public override function resize(W:Float, H:Float):Void {
		super.resize(W, H);
		label.width = W;
	}
		
	public override function update():Void {
		
		/**Adds more control for coloring text in each state**/
		
		super.update();
		if (label == null) {
			return;
		}
		label.alpha = 1;
		switch (status)
		{
			case FlxButton.HIGHLIGHT:
				if (!toggled) {					
					if (_new_color != over_color) {
						_new_color = over_color;
					}
				}else{
					if (_new_color != over_toggle_color) {
						_new_color = over_toggle_color;
					}
				}
			case FlxButton.PRESSED:
				if (frame == FlxButton.PRESSED) {
					if (!depressOnClick) {
						label.y--;			//undo the depress movement
					}
				}else {
					if (depressOnClick) {	
						label.y++;			//b/c FlxButton switches on frame,not status
					}
				}
				if(!toggled){
					if (_new_color != down_color) {
						_new_color = down_color;
					}
				}else {
					if (_new_color != down_toggle_color) {
						_new_color = down_toggle_color;
					}
				}
			default:
				if(!toggled){
					if (_new_color != up_color) {
						_new_color = up_color;
					}
				}else {
					if (_new_color != up_toggle_color) {
						_new_color = up_toggle_color;
					}
				}
		}
		if (_new_color != 0) {
			label.color = _new_color;
			_new_color = 0;
		}		
	}			
	
	/***********PRIVATE**************/
	
	private var _new_color:Int = 0;	
	
	/**
	 * Updates the size of the text field to match the button.
	 */
	override private function resetHelpers():Void
	{
		super.resetHelpers();
		
		if (label != null)
		{
			label.width = label.frameWidth = Std.int(width);
			label.size = label.size;
		}
	}
}