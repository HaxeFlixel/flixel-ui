package flixel.addons.ui;
import flixel.FlxBasic;
import flixel.group.FlxGroup;
import flixel.FlxObject;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxPoint;
import flixel.FlxSprite;
import flixel.addons.ui.FlxButtonPlus;
#if (cpp || neko)
	import flixel.atlas.FlxAtlas;
#end

/**
 * A cheap extension of FlxUIGroup that lets you move all the children around
 * without having to call reset()
 * @author Lars Doucet
 */

class FlxUIGroup extends FlxSpriteGroup implements IDestroyable implements IFlxUIWidget
{	
	/***PUBLIC VARS***/
		
	//a handy string handler id for this thing
	public var id:String;
	
	/***PUBLIC GETTER/SETTERS***/
	
	//just getters, based on total size of contents, kinda buggy
	public var width(default, set):Float=0;
	public var height(default, set):Float=0;
	
	//public var velocity:FlxPoint;
	
	public var autoBounds:Bool = true;
	
		/***GETTER SETTER FUNCTIONS***/				

		public function set_width(f:Float):Float {
			width = f;
			return width;
		}
		
		public function set_height(f:Float):Float {
			height = f;
			return height;
		}
		
	/***PUBLIC FUNCTIONS***/
	
	public function new() 
	{
		super();
	}	
		
	public override function remove(Object:IFlxSprite,Splice:Bool=false):IFlxSprite {
		var obj = super.remove(Object, Splice);
		if (autoBounds) {
			calcBounds();
		}
		return obj;
	}
	
	public function hasThis(Object:IFlxSprite):Bool {
		for (obj in members) {
			if (obj == Object) {
				return true;
			}
		}
		return false;
	}
	
	public override function add(fb:IFlxSprite):IFlxSprite {					
		var obj = super.add(fb);
		if (autoBounds) {
			calcBounds();
		}		
		return obj;
	}
	
	public inline function calcBounds():Void {
		if(members != null && members.length > 0){
			var left:Float = Math.POSITIVE_INFINITY;
			var right:Float = Math.NEGATIVE_INFINITY;
			var top:Float = Math.POSITIVE_INFINITY;
			var bottom:Float = Math.NEGATIVE_INFINITY;
			for (fb in members) {
				if(fb != null){
					if (Std.is(fb, IFlxUIWidget)) {
						var flui:IFlxUIWidget = cast fb;
						if (flui.x < left) { left = flui.x; }
						if (flui.x + flui.width > right) { right = flui.x + flui.width; }
						if (flui.y < top) { top = flui.y; }
						if (flui.y + flui.height > bottom) { bottom = flui.y + flui.height;}
					}else {
						if (fb.x < left)   { left = fb.x; }
						if (fb.x > right)  { right = fb.x; }
						if (fb.y < top)    { top = fb.y; }
						if (fb.y > bottom) { bottom = fb.y;} 
					}
				}
			}
			width = (right - left);
			height = (bottom - top);
		}else {
			width = height = 0;
		}
	}
	
	/**
	 * Floor the positions of all children
	 */
	
	public function floorAll():Void {
		var fs:IFlxSprite;
		for (fs in members) {
			fs.x = Math.floor(fs.x);
			fs.y = Math.floor(fs.y);			
		}
	}
	
	public function set_color(col:Int=0xffffff):Void {
		var fb:FlxBasic;
		for (fb in members) {
			if (Std.is(fb, FlxSprite)) {
				var fo:FlxSprite = cast(fb, FlxSprite);
				fo.color = col;
			}else if (Std.is(fb, FlxUIGroup)) {
				var fg:FlxUIGroup = cast(fb, FlxUIGroup);
				fg.set_color(col);
			}
		}
	}
	
	public override function update():Void {
		super.update();
	}	
}