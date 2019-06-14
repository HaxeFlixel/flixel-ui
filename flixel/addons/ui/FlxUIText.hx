package flixel.addons.ui;

import flixel.addons.ui.FlxUI.UIEventCallback;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.interfaces.IHasParams;
import flixel.addons.ui.interfaces.IResizable;
import flixel.FlxSprite;
import flixel.text.FlxText;
import openfl.text.TextField;

/**
 * Simple extension to the basic text field class.
 * @author Lars Doucet
 */
class FlxUIText extends FlxText implements IResizable implements IFlxUIWidget implements IHasParams
{
	public var broadcastToFlxUI:Bool = true;
	public var name:String;
	public var params(default, set):Array<Dynamic>;
	public var minimumHeight(default, set):Float = 1;

	public function new(X:Float = 0, Y:Float = 0, FieldWidth:Float = 0, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true)
	{
		super(X, Y, FieldWidth, Text, Size, EmbeddedFont);
	}

	public function resize(w:Float, h:Float):Void
	{
		var sign:Int = 1;

		if (h < minimumHeight)
		{
			h = minimumHeight;
		}

		if (h < height)
		{
			sign = -1;
		}

		width = w;
		height = h;

		textField.width = width;

		var old_size:Int = size;
		var diff:Float = (height - graphic.bitmap.height);

		#if flash
		var oldText:String = text;
		if (oldText == "")
		{
			text = "T";
		}
		diff = height - (Std.int(textField.textHeight) + 4);
		#end

		var failsafe:Int = 0;

		var numLines:Int = textField.numLines;

		while ((diff * sign) > 0 && failsafe < 999)
		{
			failsafe++;
			size += (1 * sign);
			if (sign > 0 && textField.numLines > numLines) // Failsafe in case the expanding text causes it to break to a new line
			{
				size -= (1 * sign);
				break;
			}
			_regen = true;
			calcFrame(true);

			#if flash
			diff = height - (Std.int(textField.textHeight) + 4);
			#else
			diff = (h - graphic.bitmap.height);
			#end

			diff = (h - graphic.bitmap.height);
		}

		#if flash
		text = oldText;
		#end

		if (failsafe >= 999)
		{
			FlxG.log.warn("Loop failsafe tripped while resizing FlxUIText to height(" + h + ")");
			size = old_size;
		}

		width = w;
		height = h;

		_regen = true;
		calcFrame(true);
	}

	public function set_minimumHeight(H:Float):Float
	{
		if (H < 1)
		{
			H = 1;
		}
		minimumHeight = H;
		return minimumHeight;
	}

	public function set_params(p:Array<Dynamic>):Array<Dynamic>
	{
		params = p;
		return params;
	}

	public override function clone():FlxUIText
	{
		var newText = new FlxUIText();
		newText.width = width;
		newText.height = height;

		var theFont:String = font;
		#if (flash || !openfl_legacy)
		theFont = FontFixer.fix(font);
		#end
		newText.setFormat(theFont, size, color);

		// for some reason, naively setting (f.alignment = alignment) causes cast errors!
		if (_defaultFormat != null && _defaultFormat.align != null)
		{
			newText.alignment = alignment;
		}
		newText.setBorderStyle(borderStyle, borderColor, borderSize, borderQuality);
		newText.text = text;
		return newText;
	}
}
