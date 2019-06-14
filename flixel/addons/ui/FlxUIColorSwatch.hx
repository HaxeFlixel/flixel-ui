package flixel.addons.ui;

import flash.geom.Rectangle;
import flixel.addons.ui.FlxUISprite;
import flixel.addons.ui.interfaces.ICursorPointable;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;

class FlxUIColorSwatch extends FlxUIButton
{
	public var multiColored(default, set):Bool;
	public var hilight(default, set):Int;
	public var midtone(default, set):Int;
	public var shadowMid(default, set):Int;
	public var shadowDark(default, set):Int;
	public var colors(default, set):SwatchData;

	public var callback:Void->Void;

	public static inline var CLICK_EVENT:String = "click_color_swatch";

	/**SETTERS**/
	private override function set_color(Color:Int):Int
	{
		midtone = Color; // color does double duty for midtone
		return super.set_color(color);
	}

	public override function destroy():Void
	{
		callback = null;
		super.destroy();
	}

	/**
	 * Set a color at a specific index in the swatch
	 * @param	Color
	 * @param	index
	 */
	public function setColorAtIndex(Color:Int, index:Int):Void
	{
		_skipRefresh = true;
		switch (index)
		{
			case 0:
				hilight = Color;
			case 1:
				midtone = Color;
			case 2:
				shadowMid = Color;
			case 3:
				shadowDark = Color;
			default:
				colors.colors[index] = Color;
		}
		_skipRefresh = false;
		refreshColor();
	}

	private function set_colors(Colors:SwatchData):SwatchData
	{
		if (colors != null)
		{
			colors.destroy();
			colors = null;
		}

		_skipRefresh = true;

		colors = Colors.copy();

		hilight = colors.hilight;
		midtone = colors.midtone;
		shadowMid = colors.shadowMid;
		shadowDark = colors.shadowDark;

		_skipRefresh = false;
		refreshColor();
		return Colors;
	}

	/**
	 * If true, the swatch will draw itself dynamically based on the four colors provided
	 */
	private function set_multiColored(b:Bool):Bool
	{
		multiColored = b;
		refreshColor();
		return multiColored;
	}

	private function set_hilight(i:Int):Int
	{
		hilight = i;
		colors.hilight = hilight;
		refreshColor();
		return hilight;
	}

	private function set_midtone(i:Int):Int
	{
		midtone = i;
		colors.midtone = midtone;
		refreshColor();
		return midtone;
	}

	private function set_shadowMid(i:Int):Int
	{
		shadowMid = i;
		colors.shadowMid = shadowMid;
		refreshColor();
		return shadowMid;
	}

	private function set_shadowDark(i:Int):Int
	{
		shadowDark = i;
		colors.shadowDark = shadowDark;
		refreshColor();
		return shadowDark;
	}

	/**
	 * Creates a new color swatch that can store and display a color value
	 * @param	Color			Single color for the swatch
	 * @param	Colors			Multiple colors for the swatch
	 * @param	Asset			An asset for the swatch graphic (optional)
	 * @param	Callback		Function to call when clicked
	 */
	public function new(X:Float, Y:Float, ?Color:Int = 0xFFFFFF, ?Colors:SwatchData, ?Asset:Dynamic, ?Callback:Void->Void, Width:Int = -1, Height:Int = -1)
	{
		super(X, Y, onClick);

		callback = Callback;

		_skipRefresh = true;

		if (Width != -1 && Height != -1)
		{
			makeGraphic(Width, Height, FlxColor.WHITE, true, "Swatch" + Width + "x" + Height);
		}
		else if (Asset != null)
		{
			loadGraphic(Asset); // load custom asset if provided
		}
		else
		{
			loadGraphic(FlxUIAssets.IMG_SWATCH); // load default monochrome swatch
		}

		_origKey = graphic.key;

		if (Color != 0xFFFFFF)
		{
			multiColored = false;
			color = Color;
		}

		if (Colors != null)
		{
			multiColored = true;
			colors = Colors;
		}

		_skipRefresh = false;
		refreshColor();
	}

	public function equalsSwatch(swatch:SwatchData):Bool
	{
		return swatch.doColorsEqual(colors);
	}

	public function getRawDifferenceSwatch(swatch:SwatchData):Int
	{
		return swatch.getRawDifference(colors);
	}

	public function refreshColor():Void
	{
		if (_skipRefresh)
		{
			return;
		}

		var key:String = colorKey();

		if (multiColored)
		{
			if (graphic.key != key)
			{
				if (FlxG.bitmap.checkCache(key) == false) // draw the swatch dynamically from supplied color values
				{
					makeGraphic(Std.int(width), Std.int(height), 0xFFFFFFFF, true, key);
					_flashRect.x = 0;
					_flashRect.y = 0;
					_flashRect.width = pixels.width;
					_flashRect.height = pixels.height;
					pixels.fillRect(_flashRect, 0xFF000000); // start with black outline

					var tempCols:Array<Int> = [];

					for (i in 0...colors.colors.length)
					{
						var col:Int = colors.colors[i];
						if (col != 0)
						{
							tempCols.push(col);
						}
					}

					var thickW:Int = Std.int(Std.int((width - 2) / 2) / tempCols.length);
					var thickH:Int = Std.int(Std.int((height - 2) / 2) / tempCols.length);

					_flashRect.x += 1;
					_flashRect.y += 1;
					_flashRect.width -= 2;
					_flashRect.height -= 2;
					for (i in 0...tempCols.length)
					{
						var col:Int = tempCols[(tempCols.length - 1) - i];
						pixels.fillRect(_flashRect, col);
						_flashRect.width -= (thickW * 2);
						_flashRect.height -= (thickH * 2);
						_flashRect.x += thickW;
						_flashRect.y += thickH;
					}

					U.clearArray(tempCols);
					tempCols = null;

					calcFrame();
				}
				else
				{
					loadGraphic(key);
				}
			}
		}
		else
		{
			if (graphic.key != key) // load the right asset
			{
				loadGraphic(key);
			}
			color = midtone; // just rely on color-tinting
		}
	}

	private var _origKey:String = "";
	private var _skipRefresh:Bool = false;

	private function onClick():Void
	{
		if (callback != null)
		{
			callback();
		}
		if (broadcastToFlxUI)
		{
			if (multiColored)
			{
				FlxUI.event(CLICK_EVENT, this, colors);
			}
			else
			{
				FlxUI.event(CLICK_EVENT, this, color);
			}
		}
	}

	public function colorKey():String
	{
		if (multiColored)
		{
			var str:String = _origKey;
			for (c in colors.colors)
			{
				str += "+" + c.toWebString();
			}
			return str;
		}
		return _origKey;
	}
}
