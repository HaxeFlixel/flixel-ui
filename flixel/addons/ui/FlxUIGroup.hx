package flixel.addons.ui;
import flixel.FlxBasic;
import flixel.group.FlxGroup;
import flixel.FlxObject;
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

class FlxUIGroup extends FlxGroup implements IDestroyable implements IFlxUIWidget
{	
	/***PUBLIC VARS***/
		
	//a handy string handler id for this thing
	public var id:String;
	
	/***PUBLIC GETTER/SETTERS***/
	
	//just getters, based on total size of contents, kinda buggy
	public var width(default, set):Float=0;
	public var height(default, set):Float=0;
	
	//whether to update x,y instantly or on next update() call
	//set this to true to remove one-frame "flicker" on setup
	public var instant_update:Bool = false;	
		
	//ostensibly this will set the alpha of all the objects in the 
	//group. Probably should switch this so it just precomposites the
	//whole deal and then alphas the composited result
	public var alpha(default, set):Float=1;
	
	public var velocity:FlxPoint;
	
	public var autoBounds:Bool = true;
	
	//move all of the contents around - it saves the last anchor point,
	//so it works "automagically"
	
	public var x(default, set):Float=0;
	public var y(default, set):Float=0;
	
		/***GETTER SETTER FUNCTIONS***/
				
		public function set_x(f:Float):Float { 
			x = f;
			_delta_x += (f - _anchor_x);
			_anchor_x = f;
			if (instant_update) { updateDirty();}
			return _anchor_x;
		}
	
		public function set_y(f:Float):Float {
			y = f;
			_delta_y += (f - _anchor_y);
			_anchor_y = f;
			if (instant_update) { updateDirty();}
			return _anchor_y;
		}
		
		public function set_width(f:Float):Float {
			width = f;
			return width;
		}
		
		public function set_height(f:Float):Float {
			height = f;
			return height;
		}
		
		public function set_alpha(a:Float):Float { 
			if (a < 0) a = 0;
			if (a > 1) a = 1;
			alpha = a; 		
			for (fb in members) {
				if (Std.is(fb, FlxObject)) {
					var fs:FlxSprite = cast(fb, FlxSprite);
					fs.alpha = alpha;
				}else if (Std.is(fb, FlxUIGroup)) {
					var fg:FlxUIGroup = cast(fb, FlxUIGroup);
					fg.alpha = alpha;
				}
			}return alpha;
		}
	
	/***PUBLIC FUNCTIONS***/
	
	public function new() 
	{
		super();
	}	
		
	public override function remove(Object:FlxBasic,Splice:Bool=false):FlxBasic {
		var obj:FlxBasic = super.remove(Object, Splice);
		if (autoBounds) {
			calcBounds();
		}
		return obj;
	}
	
	public function hasThis(Object:FlxBasic):Bool {
		for (obj in members) {
			if (obj == Object) {
				return true;
			}
		}
		return false;
	}
	
	/*public override function add(fb:FlxBasic):FlxBasic {					
		var obj:FlxBasic = super.add(fb);
		if (autoBounds) {
			calcBounds();
		}		
		return obj;
	}*/
	
	public inline function calcBounds():Void {
		var left:Float = Math.NEGATIVE_INFINITY;
		var right:Float = Math.POSITIVE_INFINITY;
		var top:Float = Math.NEGATIVE_INFINITY;
		var bottom:Float = Math.POSITIVE_INFINITY;
		for (fb in members) {
			if (Std.is(fb, IFlxUIWidget)) {
				var flui:IFlxUIWidget = cast fb;
				if (flui.x < left) { left = flui.x; }
				if (flui.x + flui.width > right) { right = flui.x + flui.width; }
				if (flui.y < top) { top = flui.y; }
				if (flui.y + flui.height > bottom) { bottom = flui.y + flui.height;}
			}
		}
		width = (right - left);
		height = (bottom - top);
	}
	
	/**
	 * Floor the positions of all children
	 */
	
	public function floorAll():Void {
		var fb:FlxBasic;
		for (fb in members) {
			if (Std.is(fb, FlxObject)) {
				var fo:FlxObject = cast(fb, FlxObject);
				fo.x = Math.floor(fo.x);
				fo.y = Math.floor(fo.y);
			}else if (Std.is(fb, FlxUIGroup)) {
				var fg:FlxUIGroup = cast(fb, FlxUIGroup);
				fg.x = Math.floor(fg.x);
				fg.y = Math.floor(fg.y);
			}
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
		if (velocity != null)
		{
			var temp:Bool = instant_update;
			instant_update = false;
			set_x(x + velocity.x);
			set_y(y + velocity.y);
			instant_update = temp;
		}
		updateDirty();
		super.update();
	}
	
	/********PRIVATE**********/
	
	//the basic anchor point for the FlxGroup, think of it as it's x/y location
	private var _anchor_x:Float = 0;
	private var _anchor_y:Float = 0;
	
	//offset from the anchor position - if not 0, will force a repositioning of 
	//all its children
	private var _delta_x:Float = 0;
	private var _delta_y:Float = 0;
	
	//Reposition everything as necessary, also recalculate bounds
	//TODO: Bounds calculating is kind of iffy, might also be disabled
	private inline function updateDirty():Void {
		if (_delta_x != 0 || _delta_y != 0) {
			var best_w:Float = 0;
			var best_h:Float = 0;
			var ww:Float = 0;
			var hh:Float = 0;
			var fb:FlxBasic;
			for (fb in members) {
				if (Std.is(fb, FlxObject)) {
					var fo:FlxObject = cast(fb, FlxObject);
					fo.x += _delta_x;
					fo.y += _delta_y;
					if(fo.visible){
						ww = fo.x + fo.width;
						hh = fo.y + fo.height;
						if (ww > best_w) { best_w = ww; }
						if (hh > best_h) { best_h = hh; }
					}
				}else if (Std.is(fb, FlxUIGroup)) {
					var fg:FlxUIGroup = cast(fb, FlxUIGroup);
					fg.instant_update = instant_update;
					fg.x += _delta_x;
					fg.y += _delta_y;
					if(fg.visible){
						ww = fg.x + fg.width;
						hh = fg.y + fg.height;
						if (ww > best_w) { best_w = ww; }
						if (hh > best_h) { best_h = hh; }
					}
				}else if (Std.is(fb, FlxButtonPlus)) {
					var fbp:FlxButtonPlus = cast(fb, FlxButtonPlus);
					fbp.x += Std.int(_delta_x);
					fbp.y += Std.int(_delta_y);
					if (fbp.visible) {
						ww = fbp.x + fbp.width;
						hh = fbp.y + fbp.height;
						if (ww > best_w) { best_w = ww; }
						if (hh > best_h) { best_h = hh; }
					}
				}
			}
			_delta_x = 0;
			_delta_y = 0;
			width = best_w;
			height = best_h;
		}
	}
	
	/**
	 * Helper to change the position of this group of objects.
	 * @param	x
	 * @param	y
	 */
	public function reset(X:Float, Y:Float)
	{
		set_x(X);
		set_y(Y);
	}
		
}