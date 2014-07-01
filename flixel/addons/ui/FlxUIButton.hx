package flixel.addons.ui;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.Font;
import flash.text.TextFormat;
import flixel.addons.ui.BorderDef;
import flixel.addons.ui.FontDef;
import flixel.addons.ui.interfaces.IFlxUIButton;
import flixel.addons.ui.interfaces.IHasParams;
import flixel.addons.ui.interfaces.ILabeled;
import flixel.FlxSprite;
import flixel.system.FlxAssets;
import flixel.text.FlxText;
import flixel.util.FlxDestroyUtil;
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
class FlxUIButton extends FlxUITypedButton<FlxUIText> implements ILabeled implements IFlxUIButton
{
	private var _noIconGraphicsBkup:BitmapData;
	
	public var up_style:ButtonLabelStyle = null;
	public var over_style:ButtonLabelStyle = null;
	public var down_style:ButtonLabelStyle = null;
	
	public var up_toggle_style:ButtonLabelStyle = null;
	public var over_toggle_style:ButtonLabelStyle = null;
	public var down_toggle_style:ButtonLabelStyle = null;
	
	/**
	 * Creates a new FlxUIButton.
	 * 
	 * @param	X			The X position of the button.
	 * @param	Y			The Y position of the button.
	 * @param	Label		The text that you want to appear on the button.
	 * @param	OnClick		The function to call whenever the button is clicked.
	 */
	public function new(X:Float = 0, Y:Float = 0, ?Label:String, ?OnClick:Void->Void) {
		super(X, Y, OnClick);
		if (Label != null) {
			//create a FlxUIText label
			label = new FlxUIText(0, 0, 80, Label, 8);
			label.setFormat(null, 8, 0x333333, "center");
		}
		resize(width, height);	//force it to be "FlxUI style"
		autoCenterLabel();
	}
	
	public function copy():FlxUIButton
	{
		var Label:String = null;
		if (label != null)
		{
			Label = label.text;
		}
		var f:FlxUIButton = new FlxUIButton(0, 0, Label, onUp.callback);
		f.copyGraphic(cast this);
		f.copyStyle(cast this);
		return f;
	}
	
	public override function copyStyle(other:FlxUITypedButton<FlxSprite>):Void {
		super.copyStyle(other);
		if (Std.is(other, FlxUIButton)) {
			var fuib:FlxUIButton = cast other;
			
			up_style = fuib.up_style;
			over_style = fuib.over_style;
			down_style = fuib.down_style;
			
			up_toggle_style = fuib.up_toggle_style;
			over_toggle_style = fuib.over_toggle_style;
			down_toggle_style = fuib.down_toggle_style;
			
			var t:FlxUIText = fuib.label;
			
			var tf:TextFormat = t.textField.defaultTextFormat;
			
			if (t.font.indexOf(FlxAssets.FONT_DEFAULT) == -1) 
			{
				var fd:FontDef = FontDef.copyFromFlxText(t);
				fd.apply(label);
			}
			else 
			{
				//put "null" for the default font
				label.setFormat(null, tf.size, tf.color, cast tf.align, t.borderStyle, t.borderColor, t.embedded);
			}
		}
	}
	
	/**For ILabeled:**/
	
	public function setLabel(t:FlxUIText):FlxUIText { label = t; return label;}
	public function getLabel():FlxUIText { return label;}	
	
	/**For IResizable:**/
	
	public override function resize(W:Float, H:Float):Void {
		super.resize(W, H);
		if(label != null){
			label.width = W;
			label.fieldWidth = W;
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
			label.fieldWidth = label.width;
			label.size = label.size;
		}
	}
	
	override private function onDownHandler():Void
	{
		super.onDownHandler();
		if (label != null) {
			if (toggled && down_toggle_style != null) {
				label.color = down_toggle_style.color;
				if (down_toggle_style != null) {
					label.borderStyle = down_toggle_style.border.style;
					label.borderColor = down_toggle_style.border.color;
					label.borderSize = down_toggle_style.border.size;
					label.borderQuality = down_toggle_style.border.quality;
				}
			}else if (!toggled && down_style != null) {
				label.color = down_style.color;
				if(down_style != null){
					label.borderStyle = down_style.border.style;
					label.borderColor = down_style.border.color;
					label.borderSize = down_style.border.size;
					label.borderQuality = down_style.border.quality;
				}
			}
		}
	}
	
	override private function onOverHandler():Void
	{
		super.onOverHandler();
		if (label != null) {
			if (toggled && over_toggle_style != null) {
				label.color = over_toggle_style.color;
				if(over_toggle_style != null){
					label.borderStyle = over_toggle_style.border.style;
					label.borderColor = over_toggle_style.border.color;
					label.borderSize = over_toggle_style.border.size;
					label.borderQuality = over_toggle_style.border.quality;
				}
			}else if (!toggled && over_style != null) {
				label.color = over_style.color;
				if(over_style != null){
					label.borderStyle = over_style.border.style;
					label.borderColor = over_style.border.color;
					label.borderSize = over_style.border.size;
					label.borderQuality = over_style.border.quality;
				}
			}
		}
	}
	
	override private function onOutHandler():Void
	{
		super.onOutHandler();
		if (label != null) {
			if (toggled && up_toggle_style != null) {
				label.color = up_toggle_style.color;
				if(up_toggle_style.border != null){
					label.borderStyle = up_toggle_style.border.style;
					label.borderColor = up_toggle_style.border.color;
					label.borderSize = up_toggle_style.border.size;
					label.borderQuality = up_toggle_style.border.quality;
				}
			}else if (!toggled && up_style != null) {
				label.color = up_style.color;
				if(up_style.border != null){
					label.borderStyle = up_style.border.style;
					label.borderColor = up_style.border.color;
					label.borderSize = up_style.border.size;
					label.borderQuality = up_style.border.quality;
				}
			}
		}
	}
	
	override private function onUpHandler():Void
	{
		super.onUpHandler();
		if (label != null) {
			if (toggled && up_toggle_style != null) {
				label.color = up_toggle_style.color;
				if(up_toggle_style.border != null){
					label.borderStyle = up_toggle_style.border.style;
					label.borderColor = up_toggle_style.border.color;
					label.borderSize = up_toggle_style.border.size;
					label.borderQuality = up_toggle_style.border.quality;
				}
			}else if (!toggled && up_style != null) {
				label.color = up_style.color;
				if(up_style.border != null){
					label.borderStyle = up_style.border.style;
					label.borderColor = up_style.border.color;
					label.borderSize = up_style.border.size;
					label.borderQuality = up_style.border.quality;
				}
			}
		}
	}
}