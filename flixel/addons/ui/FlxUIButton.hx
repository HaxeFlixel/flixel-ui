package flixel.addons.ui;
import flash.events.Event;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flash.display.BitmapData;
import flixel.util.FlxPoint;
import flixel.util.FlxTimer;
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

class FlxUIButton extends FlxUITypedButton<FlxUIText> implements ILabeled
{
	public function new(X:Float = 0, Y:Float = 0, ?Label:String, ?OnClick:Dynamic) {
		super(X, Y, null, OnClick);		
		if (Label != null) {
			//create a FlxUIText label
			//labelOffset = new FlxPoint(-1, 3);
			label = new FlxUIText(0, 0, 80, Label, 8);
			label.setFormat(null, 8, 0x333333, "center");
		}
		autoCenterLabel();
	}	
	
	/**For ILabeled:**/
	
	public function set_label(t:FlxUIText):FlxUIText { label = t; return label;}
	public function get_label():FlxUIText { return label;}
		
		/**For IResizable:**/
	
	public override function resize(W:Float, H:Float):Void {
		super.resize(W, H);
		label.width = W;		
	}
	
	/**********PRIVATE*********/
			
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