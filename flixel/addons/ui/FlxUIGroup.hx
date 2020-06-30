package flixel.addons.ui;

import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxRect;

/**
 * A cheap extension of FlxUIGroup that lets you move all the children around
 * without having to call reset()
 * @author Lars Doucet
 */
class FlxUIGroup extends FlxSpriteGroup implements IFlxUIWidget
{
	/***PUBLIC VARS***/
	// a handy string handler name for this thing
	public var name:String;

	public var broadcastToFlxUI:Bool = true;

	/***PUBLIC GETTER/SETTERS***/
	// public var velocity:FlxPoint;
	public var autoBounds:Bool = true;

	/***PUBLIC FUNCTIONS***/
	public function new(X:Float = 0, Y:Float = 0)
	{
		super(X, Y);
	}

	public override function destroy():Void
	{
		super.destroy();
	}

	public override function add(Object:FlxSprite):FlxSprite
	{
		var obj = super.add(Object);
		if (autoBounds)
		{
			calcBounds();
		}
		return obj;
	}

	public override function remove(Object:FlxSprite, Splice:Bool = false):FlxSprite
	{
		var obj = super.remove(Object, Splice);
		if (autoBounds)
		{
			calcBounds();
		}
		return obj;
	}

	public function setScrollFactor(X:Float, Y:Float):Void
	{
		for (obj in members)
		{
			if (obj != null)
			{
				obj.scrollFactor.set(X, Y);
			}
		}
	}

	public function hasThis(Object:FlxSprite):Bool
	{
		for (obj in members)
		{
			if (obj == Object)
			{
				return true;
			}
		}
		return false;
	}

	/**
	 * Calculates the bounds of the group and sets width/height
	 * @param	rect (optional) -- if supplied, populates this with the boundaries of the group
	 */
	public function calcBounds(rect:FlxRect = null)
	{
		if (members != null && members.length > 0)
		{
			var left:Float = Math.POSITIVE_INFINITY;
			var right:Float = Math.NEGATIVE_INFINITY;
			var top:Float = Math.POSITIVE_INFINITY;
			var bottom:Float = Math.NEGATIVE_INFINITY;
			for (fb in members)
			{
				if (fb != null)
				{
					if ((fb is IFlxUIWidget))
					{
						var flui:FlxSprite = cast fb;
						if (flui.x < left)
						{
							left = flui.x;
						}
						if (flui.x + flui.width > right)
						{
							right = flui.x + flui.width;
						}
						if (flui.y < top)
						{
							top = flui.y;
						}
						if (flui.y + flui.height > bottom)
						{
							bottom = flui.y + flui.height;
						}
					}
					else if ((fb is FlxSprite))
					{
						var flxi:FlxSprite = cast fb;
						if (flxi.x < left)
						{
							left = flxi.x;
						}
						if (flxi.x > right)
						{
							right = flxi.x;
						}
						if (flxi.y < top)
						{
							top = flxi.y;
						}
						if (flxi.y > bottom)
						{
							bottom = flxi.y;
						}
					}
				}
			}
			width = (right - left);
			height = (bottom - top);
			if (rect != null)
			{
				rect.x = left;
				rect.y = top;
				rect.width = width;
				rect.height = height;
			}
		}
		else
		{
			width = height = 0;
		}
	}

	/**
	 * Floor the positions of all children
	 */
	public function floorAll():Void
	{
		var fs:FlxSprite = null;
		for (fb in members)
		{
			fs = cast fb;
			fs.x = Math.floor(fs.x);
			fs.y = Math.floor(fs.y);
		}
	}
}
