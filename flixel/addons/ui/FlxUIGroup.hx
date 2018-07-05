package flixel.addons.ui;

import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;

/**
 * A cheap extension of FlxUIGroup that lets you move all the children around
 * without having to call reset()
 * @author Lars Doucet
 */
class FlxUIGroup extends FlxSpriteGroup implements IFlxUIWidget
{	
	/***PUBLIC VARS***/
	
	//a handy string handler name for this thing
	public var name:String;
	
	public var broadcastToFlxUI:Bool = true;
	
	/***PUBLIC GETTER/SETTERS***/
	
	
	//public var velocity:FlxPoint;
	
	public var autoBounds:Bool = true;
	
	/***PUBLIC FUNCTIONS***/
	
	public function new(X:Float = 0, Y:Float = 0) 
	{
		super(X, Y);
	}
	
	public override function destroy():Void {
		super.destroy();
	}
	
	public override function add(Object:FlxSprite):FlxSprite {
		var obj = super.add(Object);
		if (autoBounds) {
			calcBounds();
		}
		return obj;
	}
	
	public override function remove(Object:FlxSprite,Splice:Bool=false):FlxSprite {
		var obj = super.remove(Object, Splice);
		if (autoBounds) {
			calcBounds();
		}
		return obj;
	}
	
	public function setScrollFactor(X:Float, Y:Float):Void
	{
		if (members == null) return;
		for (obj in members)
		{
			if (obj != null)
			{
				if (obj.scrollFactor == null)
				{
					obj.scrollFactor = new FlxPoint();
				}
				obj.scrollFactor.set(X, Y);
			}
		}
	}
	
	public function hasThis(Object:FlxSprite):Bool {
		for (obj in members) {
			if (obj == Object) {
				return true;
			}
		}
		return false;
	}
	
	/**
	 * Calculates the bounds of the group and sets width/height
	 * @param	rect (optional) -- if supplied, populates this with the boundaries of the group
	 */
	
	public function calcBounds(rect:FlxRect=null){
		if(members != null && members.length > 0){
			var left:Float = Math.POSITIVE_INFINITY;
			var right:Float = Math.NEGATIVE_INFINITY;
			var top:Float = Math.POSITIVE_INFINITY;
			var bottom:Float = Math.NEGATIVE_INFINITY;
			for (fb in members)
			{
				if (fb != null)
				{
					if (Std.is(fb, IFlxUIWidget))
					{
						var fbWidth = 0.0;
						var fbHeight = 0.0;
						if (Std.is(fb, FlxUIText))
						{
							var flui:FlxSprite = cast fb;
							fbWidth = flui.width;
							fbHeight = flui.height;
						}
						if (fb.x < left) { left = fb.x; }
						if (fb.x + fbWidth > right) { right = fb.x + fbWidth; }
						if (fb.y < top) { top = fb.y; }
						if (fb.y + fbHeight > bottom) { bottom = fb.y + fbHeight;}
					}
					else
					{
						if (fb.x < left)   { left = fb.x; }
						if (fb.x > right)  { right = fb.x; }
						if (fb.y < top)    { top = fb.y; }
						if (fb.y > bottom) { bottom = fb.y;} 
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
		}else {
			width = height = 0;
		}
	}
	
	@:access(flixel.text.FlxText)
	private function safeTextSize(text:FlxUIText, isWidth:Bool):Float
	{
		var oldRegen = text._regen;
		text._regen = false;
		var returnVal = 0.0;
		if (isWidth)
		{
			returnVal = text.width;
		}
		else
		{
			returnVal = text.height;
		}
		text._regen = oldRegen;
		return returnVal;
	}
	
	/**
	 * Floor the positions of all children
	 */
	
	public function floorAll():Void {
		var fs:FlxSprite = null;
		for (fb in members) {
			fs = cast fb;
			fs.x = Math.floor(fs.x);
			fs.y = Math.floor(fs.y);
		}
	}
}