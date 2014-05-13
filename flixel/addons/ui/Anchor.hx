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
	
	public function new(XOff:Float,YOff:Float,XSide:String,YSide:String,XFlush:String,YFlush:String) 
	{
		x = new AnchorPoint(XOff, XSide, XFlush);
		y = new AnchorPoint(YOff, YSide, YFlush);
	}
	
	public function destroy():Void {
		x = null;
		y = null;
	}
	
	public function anchorThing(thing:FlxObject, destination:FlxObject):Void
	{
		var destX:Float = 0;
		var destY:Float = 0;
		
		switch(x.side)
		{
			case Anchor.LEFT:	destX = destination.x;
			case Anchor.RIGHT:	destX = destination.x + destination.width;
			case Anchor.CENTER:	destX = destination.x + (destination.width / 2);
		}
		switch(y.side) 
		{
			case Anchor.TOP:	destY = destination.y;
			case Anchor.BOTTOM:	destY = destination.y + destination.height;
			case Anchor.CENTER:	destY = destination.y + (destination.height / 2);
		}
		switch(x.flush)
		{
			case Anchor.LEFT:	//no change
			case Anchor.RIGHT:	destX = destX - thing.width;
			case Anchor.CENTER:	destX = destX - (thing.width / 2);
		}
		switch(y.flush)
		{
			case Anchor.TOP:	//no change
			case Anchor.BOTTOM:	destY = destY - thing.height;
			case Anchor.CENTER:	destY = destY - (thing.height / 2);
		}
		thing.x = destX + x.offset;
		thing.y = destY + y.offset;
	}
}