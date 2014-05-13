package flixel.addons.ui.interfaces;

import flash.display.BitmapData;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUIText;
import flixel.FlxSprite;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flixel.util.FlxPoint;

/**
 * This interface keeps me from having to use a Dynamic variable to point to a value holding a FlxUITypedButton 
 * that could be either a FlxUIButton or a FlxUISpriteButton
 * @author larsiusprime
 */
interface IFlxUIButton extends IFlxUIWidget extends IHasParams extends IFlxDestroyable
{
	public var up_color:Int;
	public var over_color:Int;
	public var down_color:Int;
	
	public var up_toggle_color:Int;
	public var over_toggle_color:Int;
	public var down_toggle_color:Int;
	
	public var up_visible:Bool;
	public var over_visible:Bool;
	public var down_visible:Bool;
	
	public var up_toggle_visible:Bool;
	public var over_toggle_visible:Bool;
	public var down_toggle_visible:Bool;
	
	public var resize_ratio:Float;
	public var resize_point:FlxPoint;
	
	public var has_toggle:Bool;
	public var toggled:Bool;
	
	public var toggle_label(default,set):FlxSprite;
	
	public function autoCenterLabel():Void;
	public function loadGraphicSlice9(assets:Array<String> = null, W:Int = 80, H:Int = 20, slice9:Array<Array<Int>> = null, Tile:Int = FlxUI9SliceSprite.TILE_NONE, Resize_Ratio:Float = -1, isToggle:Bool = false, src_w:Int = 0, src_h:Int = 0, frame_indeces:Array<Int> = null):Void;
	public function loadGraphicsMultiple(assets:Array<String>, Key:String = ""):Void;
	public function loadGraphicsUpOverDown(asset:Dynamic, for_toggle:Bool = false, ?key:String):Void;
	public function forceStateHandler(event:String):Void;
}