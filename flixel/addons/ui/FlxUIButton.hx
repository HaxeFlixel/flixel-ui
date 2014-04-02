package flixel.addons.ui;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.addons.ui.FlxUIButton.LabelStyle;
import flixel.addons.ui.interfaces.IFlxUIButton;
import flixel.addons.ui.interfaces.IHasParams;
import flixel.addons.ui.interfaces.ILabeled;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxDestroyUtil;

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
class FlxUIButton extends FlxUITypedButton<FlxUIText> implements ILabeled implements IFlxUIButton
{
	private var _noIconGraphicsBkup:BitmapData;
	
	public var up_style:LabelStyle = null;
	public var over_style:LabelStyle = null;
	public var down_style:LabelStyle = null;
	
	public var up_toggle_style:LabelStyle = null;
	public var over_toggle_style:LabelStyle = null;
	public var down_toggle_style:LabelStyle = null;
	
	
	/**
	 * Creates a new FlxUIButton.
	 * 
	 * @param	X			The X position of the button.
	 * @param	Y			The Y position of the button.
	 * @param	Label		The text that you want to appear on the button.
	 * @param	OnClick		The function to call whenever the button is clicked.
	 */
	public function new(X:Float = 0, Y:Float = 0, ?Label:String, ?OnClick:Void->Void) {
		super(X, Y, null, OnClick);
		if (Label != null) {
			
			//create a FlxUIText label
			label = new FlxUIText(0, 0, 90, Label, 8);
			label.wordWrap = false;
			label.setFormat(null, 8, 0x333333, "center");
		}
		resize(width, height);	//force it to be "FlxUI style"
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
	
	public function addIcon(icon:FlxSprite,X:Int=0,Y:Int=0,?center:Bool=true)
	{
		// Creates a backup of current button image.
		_noIconGraphicsBkup = cachedGraphics.bitmap.clone();
		
		var sx:Int = X;
		var sy:Int = Y;
		
		if(center){
			sx = Std.int((width - icon.width) / 2);
			sy = Std.int((height - icon.height) / 2);
		}
		
		// Stamps the icon in every frame of this button.
		for (i in 0...frames)
		{
			stamp(icon, sx, sy + Std.int(i * height));
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
		_noIconGraphicsBkup = FlxDestroyUtil.dispose(_noIconGraphicsBkup);
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
	
	override private function onDownHandler():Void
	{
		super.onDownHandler();
		if (label != null) {
			if (toggled && down_toggle_style != null) {
				label.color = down_toggle_style.color;
				label.borderStyle = down_toggle_style.borderStyle;
				label.borderColor = down_toggle_style.borderColor;
			}else if (!toggled && down_style != null) {
				label.color = down_style.color;
				label.borderStyle = down_style.borderStyle;
				label.borderColor = down_style.borderColor;
			}
		}
	}
	
	override private function onOverHandler():Void
	{
		super.onOverHandler();
		if (label != null) {
			if (toggled && over_toggle_style != null) {
				label.color = over_toggle_style.color;
				label.borderStyle = over_toggle_style.borderStyle;
				label.borderColor = over_toggle_style.borderColor;
			}else if (!toggled && over_style != null) {
				label.color = over_style.color;
				label.borderStyle = over_style.borderStyle;
				label.borderColor = over_style.borderColor;
			}
		}
	}
	
	override private function onOutHandler():Void
	{
		super.onOutHandler();
		if (label != null) {
			if (toggled && up_toggle_style != null) {
				label.color = up_toggle_style.color;
				label.borderStyle = up_toggle_style.borderStyle;
				label.borderColor = up_toggle_style.borderColor;
			}else if (!toggled && up_style != null) {
				label.color = up_style.color;
				label.borderStyle = up_style.borderStyle;
				label.borderColor = up_style.borderColor;
			}
		}
	}
	
	override private function onUpHandler():Void
	{
		super.onUpHandler();
		if (label != null) {
			if (toggled && up_toggle_style != null) {
				label.color = up_toggle_style.color;
				label.borderStyle = up_toggle_style.borderStyle;
				label.borderColor = up_toggle_style.borderColor;
			}else if (!toggled && up_style != null) {
				label.color = up_style.color;
				label.borderStyle = up_style.borderStyle;
				label.borderColor = up_style.borderColor;
			}
		}
	}
}

class LabelStyle 
{
	public var color:Int;
	public var borderStyle:Int;
	public var borderColor:Int;
	
	public function new(Color:Int, BorderStyle:Int, BorderColor:Int) {
		color = Color;
		borderStyle = BorderStyle;
		borderColor = BorderColor;
	}
}