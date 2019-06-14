package flixel.addons.ui;

import flixel.FlxObject;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

/**
 * A class that describes how some object should be positioned relative to another
 */
class Anchor implements IFlxDestroyable
{
	public var x:AnchorPoint;
	public var y:AnchorPoint;

	public static inline var LEFT:String = "left";
	public static inline var RIGHT:String = "right";
	public static inline var TOP:String = "top";
	public static inline var BOTTOM:String = "bottom";
	public static inline var CENTER:String = "center";
	public static inline var UNKNOWN:String = "unknown";

	public function new(XOff:Float, YOff:Float, XSide:String, YSide:String, XFlush:String, YFlush:String)
	{
		x = new AnchorPoint(XOff, XSide, XFlush);
		y = new AnchorPoint(YOff, YSide, YFlush);
	}

	public function destroy():Void
	{
		x = null;
		y = null;
	}

	public function anchorThing(thing:FlxObject, destination:FlxObject):Void
	{
		var destX:Float = 0;
		var destY:Float = 0;

		destX = switch (x.side)
		{
			case Anchor.LEFT: destination.x;
			case Anchor.RIGHT: destination.x + destination.width;
			case Anchor.CENTER: destination.x + (destination.width / 2);
			default: destination.x;
		}
		destY = switch (y.side)
		{
			case Anchor.TOP: destination.y;
			case Anchor.BOTTOM: destination.y + destination.height;
			case Anchor.CENTER: destination.y + (destination.height / 2);
			default: destination.y;
		}
		destX = switch (x.flush)
		{
			case Anchor.LEFT: destX; // no change
			case Anchor.RIGHT: destX - thing.width;
			case Anchor.CENTER: destX = destX - (thing.width / 2);
			default: destX;
		}
		destY = switch (y.flush)
		{
			case Anchor.TOP: destY; // no change
			case Anchor.BOTTOM: destY - thing.height;
			case Anchor.CENTER: destY - (thing.height / 2);
			default: destY;
		}
		thing.x = destX + x.offset;
		thing.y = destY + y.offset;
	}

	public function getFlipped(FlipX:Bool, FlipY:Bool, ?AnchorObject:Anchor):Anchor
	{
		var xoff = FlipX ? -1 * x.offset : x.offset;
		var yoff = FlipY ? -1 * y.offset : y.offset;

		var xside = FlipX ? flipAnchorSide(x.side) : x.side;
		var yside = FlipY ? flipAnchorSide(y.side) : y.side;

		var xflush = FlipX ? flipAnchorSide(x.flush) : x.flush;
		var yflush = FlipY ? flipAnchorSide(y.flush) : y.flush;

		if (AnchorObject == null)
		{
			AnchorObject = new Anchor(xoff, yoff, xside, yside, xflush, yflush);
		}
		else
		{
			AnchorObject.x.offset = xoff;
			AnchorObject.y.offset = yoff;
			AnchorObject.x.side = xside;
			AnchorObject.y.side = yside;
			AnchorObject.x.flush = xflush;
			AnchorObject.y.flush = yflush;
		}

		return AnchorObject;
	}

	public function clone():Anchor
	{
		return new Anchor(x.offset, y.offset, x.side, y.side, x.flush, y.flush);
	}

	private function flipAnchorSide(str:String):String
	{
		if (str == Anchor.LEFT)
			return Anchor.RIGHT;
		if (str == Anchor.RIGHT)
			return Anchor.LEFT;
		if (str == Anchor.TOP)
			return Anchor.BOTTOM;
		if (str == Anchor.BOTTOM)
			return Anchor.TOP;
		return str;
	}
}
