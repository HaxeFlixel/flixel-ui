package flixel.addons.ui;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxRect;
import flixel.addons.ui.interfaces.IFlxUIWidget;
#if (flixel >= "5.7.0")
import flixel.group.FlxSpriteContainer;
#end

#if (flixel < "5.4.0" && FLX_NO_POINT_POOL)
	/* This is a weird haxe bug I haven't figured out, fixed in 5.4.0
	 * via https://github.com/HaxeFlixel/flixel/pull/2808
	 * Note: this is only the case when FLX_NO_POINT_POOL is defined.
	 */
	#error "This version of flixel-ui is not compatible with flixel versions less than 5.4.0";
#end

/**
 * A cheap extension of FlxSpriteGroup that lets you move all the children around
 * without having to call reset()
 * @author Lars Doucet
 */
typedef FlxUIGroup = FlxTypedUIGroup<FlxSprite>;
/**
 * A cheap extension of FlxSpriteGroup that lets you move all the children around
 * without having to call reset()
 * @author Lars Doucet
 */
class FlxTypedUIGroup<T:FlxSprite>
	extends #if(flixel < "5.7.0") FlxTypedSpriteGroup<T> #else FlxTypedSpriteContainer<T> #end
	implements IFlxUIWidget
{
	/** a handy string handler name for this thing */
	public var name:String;

	/** If true, will issue FlxUI.event() and FlxUI.request() calls */
	public var broadcastToFlxUI:Bool = true;

	/** Will automatically adjust the width and height to the members, on add/remove calls */ 
	public var autoBounds:Bool = true;

	public function new(x = 0.0, y = 0.0)
	{
		super(x, y);
	}

	override function add(sprite:T):T
	{
		final obj = super.add(sprite);
		if (autoBounds)
		{
			calcBounds();
		}
		return sprite;
	}

	public override function remove(sprite:T, splice:Bool = false):T
	{
		final obj = super.remove(sprite, splice);
		if (autoBounds)
		{
			calcBounds();
		}
		return obj;
	}

	public function setScrollFactor(x:Float, y:Float):Void
	{
		for (sprite in members)
		{
			if (sprite != null)
			{
				sprite.scrollFactor.set(x, y);
			}
		}
	}

	/**
	 * Whether this group contains the sprite.
	 */
	@:deprecated("Use contains, instead")
	inline public function hasThis(sprite:T):Bool
	{
		return contains(sprite);
	}

	/**
	 * Whether this group contains the sprite.
	 */
	public function contains(sprite:T):Bool
	{
		return members.contains(sprite);
	}

	/**
	 * Calculates the bounds of the group and sets width/height
	 * @param   rect  If supplied, populates this with the boundaries of the group
	 */
	public function calcBounds(?rect:FlxRect)
	{
		if (members == null || members.length == 0)
		{
			width = height = 0;
			if (rect != null) rect.set();
			return;
		}
		
		var left:Float = Math.POSITIVE_INFINITY;
		var right:Float = Math.NEGATIVE_INFINITY;
		var top:Float = Math.POSITIVE_INFINITY;
		var bottom:Float = Math.NEGATIVE_INFINITY;
		for (sprite in members)
		{
			if (sprite != null)
			{
				if (sprite.x < left)
				{
					left = sprite.x;
				}
				
				if (sprite.x + sprite.width > right)
				{
					right = sprite.x + sprite.width;
				}
				
				if (sprite.y < top)
				{
					top = sprite.y;
				}
				
				if (sprite.y + sprite.height > bottom)
				{
					bottom = sprite.y + sprite.height;
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

	/**
	 * Floor the positions of all children
	 */
	public function floorAll():Void
	{
		for (sprite in members)
		{
			sprite.x = Math.floor(sprite.x);
			sprite.y = Math.floor(sprite.y);
		}
	}
}
