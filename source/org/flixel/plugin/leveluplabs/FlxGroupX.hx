package org.flixel.plugin.leveluplabs;
import org.flixel.FlxBasic;
import org.flixel.FlxGroup;
import org.flixel.FlxObject;
import org.flixel.util.FlxPoint;
import org.flixel.FlxSprite;
import org.flixel.plugin.photonstorm.FlxButtonPlus;
#if (cpp || neko)
	import org.flixel.system.layer.Atlas;
#end

/**
 * A cheap extension of FlxGroupX that lets you move all the children around
 * without having to call reset()
 * @author Lars Doucet
 */

class FlxGroupX extends FlxGroup implements IDestroyable
{	
	/***PUBLIC VARS***/
		
	//a handy string handler id for this thing
	public var str_id:String;
	
	/***PUBLIC GETTER/SETTERS***/
	
	//just getters, based on total size of contents, kinda buggy
	public var width(default, null):Float=0;
	public var height(default, null):Float=0;
	
	//whether to update x,y instantly or on next update() call
	//set this to true to remove one-frame "flicker" on setup
	public var instant_update:Bool = false;	
		
	//ostensibly this will set the alpha of all the objects in the 
	//group. Probably should switch this so it just precomposites the
	//whole deal and then alphas the composited result
	public var alpha(get_alpha, set_alpha):Float;
		
	//move all of the contents around - it saves the last anchor point,
	//so it works "automagically"
	
	public var x(get_x, set_x):Float;
	public var y(get_y, set_y):Float;
	
		/***GETTER SETTER FUNCTIONS***/
	
		public function get_x():Float { return _anchor_x; }
		public function get_y():Float { return _anchor_y; }
	
		public function set_x(f:Float):Float { 
			_delta_x += (f - _anchor_x);
			_anchor_x = f;
			if (instant_update) { updateDirty();}
			return _anchor_x;
		}
	
		public function set_y(f:Float):Float {
			_delta_y += (f - _anchor_y);
			_anchor_y = f;
			if (instant_update) { updateDirty();}
			return _anchor_y;
		}
		
		public function get_alpha():Float { return _alpha; }
		public function set_alpha(a:Float):Float { 
			if (a < 0) a = 0;
			if (a > 1) a = 1;
			_alpha = a; 		
			for (fb in members) {
				if (Std.is(fb, FlxObject)) {
					var fs:FlxSprite = cast(fb, FlxSprite);
					fs.alpha = _alpha;
				}else if (Std.is(fb, FlxGroupX)) {
					var fg:FlxGroupX = cast(fb, FlxGroupX);
					fg.alpha = _alpha;
				}
			}return _alpha;
		}
	
	/***PUBLIC FUNCTIONS***/
	
	public function new() 
	{
		super();
	}	
	
	/*#if (cpp || neko)	
		public function makeAtlas(id:String,ww:Int,hh:Int):Void {
			//__atlas = new Atlas(id, ww, hh);
		}
	#end*/
		
	public override function remove(Object:FlxBasic,Splice:Bool=false):FlxBasic {
		var obj:FlxBasic = super.remove(Object, Splice);
		updateSize();
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
	
	public override function add(fb:FlxBasic):FlxBasic {	
		
	
		
		var obj:FlxBasic = super.add(fb);
		if (Std.is(fb, FlxObject)) {
			var fo:FlxObject = cast(fb, FlxObject);
			var ww:Float = fo.x + fo.width;
			var hh:Float = fo.y + fo.height;
			if (ww > width) width = ww;
			if (hh > height) height = hh;
			
		}else if (Std.is(fb, FlxGroupX)) {
			/*var fg:FlxGroupX = cast(fb, FlxGroupX);
			var ww:Float = fg.x + fg.width;
			var hh:Float = fg.y + fg.height;
			if (ww > width) width = ww;
			if (hh > height) height = hh;*/
		}
			
		#if (cpp || neko)
			if (__atlas != null) {
				if (obj != null) {
					/*if(Std.is(obj,FlxGroup)){
						obj.atlas = __atlas;
					}*/
				}
			}
		#end
		return obj;
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
			}else if (Std.is(fb, FlxGroupX)) {
				var fg:FlxGroupX = cast(fb, FlxGroupX);
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
			}else if (Std.is(fb, FlxGroupX)) {
				var fg:FlxGroupX = cast(fb, FlxGroupX);
				fg.set_color(col);
			}
		}
	}
	
	public override function update():Void {
		updateDirty();
		super.update();
	}
	
	/********PRIVATE**********/
	
	//the basic anchor point for the FlxGroup, think of it as it's x/y location
	private var _anchor_x:Float = 0;
	private var _anchor_y:Float = 0;
	
	private var _alpha:Float = 0;
		
	#if (cpp || neko)
		private var __atlas:Atlas;
	#end
	
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
				}else if (Std.is(fb, FlxGroupX)) {
					var fg:FlxGroupX = cast(fb, FlxGroupX);
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
	
	//Recalculate the bound size of the group's contents:
	private inline function updateSize():Void {
		var fb:FlxBasic;
		var ww:Float = 0;
		var hh:Float = 0;
		var best_w:Float = 0;
		var best_h:Float = 0;
		for (fb in members) {
			if (Std.is(fb, FlxObject)) {
				var fo:FlxObject = cast(fb, FlxObject);
				if(fo.visible){
					ww = fo.x + fo.width;
					hh = fo.y + fo.height;
					if (ww > best_w) { best_w = ww; }
					if (hh > best_h) { best_h = hh; }
				}
			}
		}
		width = best_w;
		height = best_h;
	}
	
	
}