package flixel.addons.ui;

import flixel.addons.ui.FlxUIBar.FlxBarStyle;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.interfaces.IHasParams;
import flixel.addons.ui.interfaces.IResizable;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;

/**
 * ...
 * @author larsiusprime
 */
class FlxUIBar extends FlxBar implements IResizable implements IFlxUIWidget implements IHasParams
{
	public var name:String;
	public var style(default, set):FlxBarStyle;
	public var params(default, set):Array<Dynamic>;
	public var broadcastToFlxUI:Bool;

	/**
	 * Create a new FlxBar Object
	 *
	 * @param	x			The x coordinate location of the resulting bar (in world pixels)
	 * @param	y			The y coordinate location of the resulting bar (in world pixels)
	 * @param	direction 	The fill direction, LEFT_TO_RIGHT by default
	 * @param	width		The width of the bar in pixels
	 * @param	height		The height of the bar in pixels
	 * @param	parentRef	A reference to an object in your game that you wish the bar to track
	 * @param	variable	The variable of the object that is used to determine the bar position. For example if the parent was an FlxSprite this could be "health" to track the health value
	 * @param	min			The minimum value. I.e. for a progress bar this would be zero (nothing loaded yet)
	 * @param	max			The maximum value the bar can reach. I.e. for a progress bar this would typically be 100.
	 * @param	showBorder	Include a 1px border around the bar? (if true it adds +2 to width and height to accommodate it)
	 */
	public function new(x:Float = 0, y:Float = 0, ?direction:FlxBarFillDirection, width:Int = 100, height:Int = 10, ?parentRef:Dynamic, variable:String = "",
			min:Float = 0, max:Float = 100, showBorder:Bool = false)
	{
		super(x, y, direction, width, height, parentRef, variable, min, max, showBorder);
	}

	override public function clone():FlxSprite
	{
		var w:Int = Std.int(width);
		var h:Int = Std.int(height);
		var showBorder = (style != null && style.borderColor != null);
		if (showBorder)
		{
			w -= 2;
			h -= 2;
		}
		var b:FlxUIBar = new FlxUIBar(x, y, fillDirection, w, h, parent, parentVariable, min, max, showBorder);
		b.style = style;
		b.value = value;
		return b;
	}

	/**
	 * Applies a new style to this FlxBar and redraws it
	 */
	public function set_style(Style:FlxBarStyle):FlxBarStyle
	{
		style = Style;
		resize(barWidth, barHeight);
		return style;
	}

	public function resize(w:Float, h:Float):Void
	{
		width = w;
		height = h;

		barWidth = Std.int(width);
		barHeight = Std.int(height);

		if (FlxG.renderBlit)
		{
			makeGraphic(barWidth, barHeight, FlxColor.TRANSPARENT, true);
		}

		var showBorder = (style.borderColor != null);

		var ec = style.emptyColor == null ? FlxColor.BLACK : style.emptyColor;
		var fc = style.filledColor == null ? FlxColor.RED : style.filledColor;
		var bc = style.borderColor == null ? FlxColor.BLACK : style.borderColor;

		if (style.filledColor != null)
		{
			createFilledBar(ec, fc, showBorder, bc);
		}

		if (style.filledColors != null)
		{
			var ecs = style.emptyColors == null ? [FlxColor.BLACK] : style.emptyColors;
			var fcs = style.filledColors == null ? [FlxColor.RED] : style.filledColors;
			var chunk = style.chunkSize == null ? 1 : style.chunkSize;
			var gradRot = style.emptyImgSrc == null ? 180 : style.gradRotation;
			createGradientBar(ecs, fcs, chunk, gradRot, showBorder, bc);
		}

		if (style.filledImgSrc != "")
		{
			createImageBar(style.emptyImgSrc, style.filledImgSrc, ec, fc);
		}

		setRange(min, max);
		value = value;
	}

	private function set_params(p:Array<Dynamic>):Array<Dynamic>
	{
		params = p;
		return params;
	}
}

typedef FlxBarStyle =
{
	var filledColors:Array<FlxColor>;
	var emptyColors:Array<FlxColor>;

	var chunkSize:Null<Int>;
	var gradRotation:Null<Int>;
	var filledColor:Null<FlxColor>;
	var emptyColor:Null<FlxColor>;
	var borderColor:Null<FlxColor>;
	var filledImgSrc:String;
	var emptyImgSrc:String;
}
