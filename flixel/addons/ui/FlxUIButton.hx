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
import flixel.math.FlxMath;
import flixel.system.FlxAssets;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import openfl.Assets;
import openfl.text.TextFormatAlign;

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
	 * @param	LoadDefaultGraphics	By default it will load up with placeholder graphics. Pass false if you want to skip this (i.e. if you will provide your own graphics subsequently, can save time)
	 * @param	LoadBlank	Load this button without ANY visible graphics, but still functions (in case you need an invisible click area)
	 */
	public function new(X:Float = 0, Y:Float = 0, ?Label:String, ?OnClick:Void->Void, ?LoadDefaultGraphics:Bool = true, ?LoadBlank:Bool = false,
			?Color:FlxColor = FlxColor.WHITE)
	{
		super(X, Y, OnClick);
		color = Color;
		if (Label != null)
		{
			// create a FlxUIText label
			label = new FlxUIText(0, 0, 80, Label, 8);
			label.setFormat(null, 8, 0x333333, FlxTextAlign.CENTER);
		}

		if (LoadBlank)
		{
			_no_graphic = true;
		}

		if (LoadDefaultGraphics)
		{
			resize(width, height); // force it to be "FlxUI style"
		}
		else
		{
			if (_no_graphic == false)
			{
				doResize(width, height, false);
				// initialize dimensions but don't initialize any graphics yet.
				// this is ugly, but if you're about to set the graphics
				// yourself in a subsequent call it's much faster to skip!
			}
			else
			{
				doResize(width, height, true);
			}
		}
	}

	/**
	 * You can use this if you have a lot of text parameters
	 * to set instead of the individual properties.
	 *
	 * @param	Font			The name of the font face for the text display.
	 * @param	Size			The size of the font (in pixels essentially).
	 * @param	Color			The color of the text in traditional flash 0xRRGGBB format.
	 * @param	Alignment		The desired alignment
	 * @param	BorderStyle		NONE, SHADOW, OUTLINE, or OUTLINE_FAST (use setBorderFormat)
	 * @param	BorderColor 	Int, color for the border, 0xRRGGBB format
	 * @param	EmbeddedFont	Whether this text field uses embedded fonts or not
	 * @return	This FlxText instance (nice for chaining stuff together, if you're into that).
	 */
	public function setLabelFormat(?Font:String, Size:Int = 8, Color:FlxColor = FlxColor.WHITE, ?Alignment:FlxTextAlign, ?BorderStyle:FlxTextBorderStyle,
			BorderColor:FlxColor = FlxColor.TRANSPARENT, Embedded:Bool = true):FlxText
	{
		if (label != null)
		{
			label.setFormat(Font, Size, Color, Alignment, BorderStyle, BorderColor, Embedded);
			#if flash
			// A VERY NECESSARY HACK
			// on Flash target, the height does not update for another frame, so autocentering will break
			// HOWEVER! height is always equal to the truncated textHeight + 4 (there's a 2-pixel gutter on top & bottom)
			// so we go ahead and set that right away for autocentering purposes:
			label.height = Std.int(label.textField.textHeight) + 4;
			#end
			return label;
		}
		return null;
	}

	public override function autoCenterLabel():Void
	{
		super.autoCenterLabel();
	}

	public override function clone():FlxUIButton
	{
		var newButton = new FlxUIButton(0, 0, (label == null) ? null : label.text, onUp.callback, false);
		newButton.copyGraphic(cast this);
		newButton.copyStyle(cast this);
		return newButton;
	}

	public override function copyStyle(other:FlxUITypedButton<FlxSprite>):Void
	{
		super.copyStyle(other);
		if ((other is FlxUIButton))
		{
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
				var flxAlign = FlxTextAlign.fromOpenFL(tf.align);

				// put "null" for the default font
				label.setFormat(null, Std.int(tf.size), tf.color, flxAlign, t.borderStyle, t.borderColor, t.embedded);
			}
		}
	}

	/**For ILabeled:**/
	public function setLabel(t:FlxUIText):FlxUIText
	{
		label = t;
		return label;
	}

	public function getLabel():FlxUIText
	{
		return label;
	}

	/**For IResizable:**/
	public override function resize(W:Float, H:Float):Void
	{
		super.resize(W, H);
	}

	public function addIcon(icon:FlxSprite, X:Int = 0, Y:Int = 0, ?center:Bool = true)
	{
		// Creates a backup of current button image.
		_noIconGraphicsBkup = graphic.bitmap.clone();

		// create a new bitmap to avoid caching issues
		var newBmp = _noIconGraphicsBkup.clone();

		// create a unique key for the new graphic
		var key = graphic.key + ",icon:" + icon.graphic.key;
		var newGraphic = FlxG.bitmap.add(newBmp, false, key);

		// load the new bitmap
		loadGraphic(newGraphic, true, Std.int(width), Std.int(height));

		var sx:Int = X;
		var sy:Int = Y;

		if (center)
		{
			sx = Std.int((width - icon.width) / 2);
			sy = Std.int((height - icon.height) / 2);
		}

		// Stamps the icon in every frame of this button.
		for (i in 0...numFrames)
		{
			stamp(icon, sx
				+ Std.int(labelOffsets[FlxMath.minInt(i, 2)].x), sy
				+ Std.int(i * height)
				+ Std.int(labelOffsets[FlxMath.minInt(i, 2)].y));
		}
	}

	public function removeIcon()
	{
		if (_noIconGraphicsBkup != null)
		{
			// Retreives the stored button image before icon was applied.
			graphic.bitmap.fillRect(graphic.bitmap.rect, 0x0); // clears the bitmap first.
			graphic.bitmap.copyPixels(_noIconGraphicsBkup, new Rectangle(0, 0, _noIconGraphicsBkup.width, _noIconGraphicsBkup.height), new Point());
			dirty = true;

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
	override function loadDefaultGraphic():Void
	{
		// do nothing -- suppresses FlxTypedButton's default graphics loader
	}

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
		if (label != null)
		{
			if (toggled && down_toggle_style != null)
			{
				label.color = down_toggle_style.color;
				if (down_toggle_style.border != null)
				{
					label.borderStyle = down_toggle_style.border.style;
					label.borderColor = down_toggle_style.border.color;
					label.borderSize = down_toggle_style.border.size;
					label.borderQuality = down_toggle_style.border.quality;
				}
			}
			else if (!toggled && down_style != null)
			{
				label.color = down_style.color;
				if (down_style.border != null)
				{
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
		if (label != null)
		{
			if (toggled && over_toggle_style != null)
			{
				label.color = over_toggle_style.color;
				if (over_toggle_style.border != null)
				{
					label.borderStyle = over_toggle_style.border.style;
					label.borderColor = over_toggle_style.border.color;
					label.borderSize = over_toggle_style.border.size;
					label.borderQuality = over_toggle_style.border.quality;
				}
			}
			else if (!toggled && over_style != null)
			{
				label.color = over_style.color;
				if (over_style.border != null)
				{
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
		if (label != null)
		{
			if (toggled && up_toggle_style != null)
			{
				label.color = up_toggle_style.color;
				if (up_toggle_style.border != null)
				{
					label.borderStyle = up_toggle_style.border.style;
					label.borderColor = up_toggle_style.border.color;
					label.borderSize = up_toggle_style.border.size;
					label.borderQuality = up_toggle_style.border.quality;
				}
			}
			else if (!toggled && up_style != null)
			{
				label.color = up_style.color;
				if (up_style.border != null)
				{
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
		if (label != null)
		{
			if (toggled && up_toggle_style != null)
			{
				label.color = up_toggle_style.color;
				if (up_toggle_style.border != null)
				{
					label.borderStyle = up_toggle_style.border.style;
					label.borderColor = up_toggle_style.border.color;
					label.borderSize = up_toggle_style.border.size;
					label.borderQuality = up_toggle_style.border.quality;
				}
			}
			else if (!toggled && up_style != null)
			{
				label.color = up_style.color;
				if (up_style.border != null)
				{
					label.borderStyle = up_style.border.style;
					label.borderColor = up_style.border.color;
					label.borderSize = up_style.border.size;
					label.borderQuality = up_style.border.quality;
				}
			}
		}
	}
}
