package flixel.addons.ui;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;
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
	private var _noIconGraphicsBkup:BitmapData;
	
	public function new(X:Float = 0, Y:Float = 0, ?Label:String, ?OnClick:Dynamic) {
		super(X, Y, null, OnClick);
		if (Label != null) {
			//create a FlxUIText label
			//labelOffsets[status].set(-1, 3);
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
		if(label != null){
			label.width = W;
		}
	}
	
	public function addIcon(icon:FlxSprite,center:Bool=true)
	{
		// Creates a backup of current button image.
		_noIconGraphicsBkup = cachedGraphics.bitmap.clone();
		
		var sx:Int = 0;
		var sy:Int = 0;
		
		if(center){
			sx = Std.int((width - icon.width) / 2);
			sy = Std.int((height - icon.height) / 2);
		}
		
		// Stamps the icon in every frame of this button.
		for (i in 0...frames)
		{
			this.stamp(icon, sx, sy + Std.int(i * height));
		}
	}
	
	public function removeIcon()
	{
		if (_noIconGraphicsBkup != null)
		{
			// Retreives the stored button image before icon was applied.
			cachedGraphics.bitmap.fillRect(cachedGraphics.bitmap.rect, 0x0);					// clears the bitmap first.
			cachedGraphics.bitmap.copyPixels(_noIconGraphicsBkup, new Rectangle(0, 0, _noIconGraphicsBkup.width, _noIconGraphicsBkup.height), new Point());
			resetFrameBitmapDatas();
			
			#if flash
			calcFrame();
			#end
		}
	}
	
	public function changeIcon(newIcon:FlxSprite)
	{
		removeIcon();
		addIcon(newIcon);
	}
	
	override public function destroy():Void
	{
		if (_noIconGraphicsBkup != null)
		{
			_noIconGraphicsBkup.dispose();
		}
		
		super.destroy();
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