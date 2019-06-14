package flixel.addons.ui.interfaces;

import flash.display.BitmapData;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUIText;
import flixel.FlxSprite;
import flixel.system.FlxAssets;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flixel.math.FlxPoint;

/**
 * This interface keeps me from having to use a Dynamic variable to point to a value holding a FlxUITypedButton
 * that could be either a FlxUIButton or a FlxUISpriteButton
 * @author larsiusprime
 */
@:access(flixel.ui.FlxButton)
interface IFlxUIButton extends IFlxUIWidget extends IHasParams extends IFlxDestroyable
{
	public var up_color:Null<FlxColor>;
	public var over_color:Null<FlxColor>;
	public var down_color:Null<FlxColor>;

	public var up_toggle_color:Null<FlxColor>;
	public var over_toggle_color:Null<FlxColor>;
	public var down_toggle_color:Null<FlxColor>;

	public var up_visible:Bool;
	public var over_visible:Bool;
	public var down_visible:Bool;

	public var up_toggle_visible:Bool;
	public var over_toggle_visible:Bool;
	public var down_toggle_visible:Bool;

	public var resize_ratio:Float;
	public var resize_point:FlxPoint;

	public var has_toggle:Bool;
	public var toggled(default, set):Bool;

	public var toggle_label(default, set):FlxSprite;

	public var autoResizeLabel:Bool;

	public var justMousedOver(get, never):Bool;
	public var mouseIsOver(get, never):Bool;
	public var mouseIsOut(get, never):Bool;
	public var justMousedOut(get, never):Bool;

	public function autoCenterLabel():Void;
	public function loadGraphicSlice9(assets:Array<FlxGraphicAsset> = null, W:Int = 80, H:Int = 20, slice9:Array<Array<Int>> = null,
		Tile:Int = FlxUI9SliceSprite.TILE_NONE, Resize_Ratio:Float = -1, isToggle:Bool = false, src_w:Int = 0, src_h:Int = 0,
		frame_indeces:Array<Int> = null):Void;
	public function loadGraphicsMultiple(assets:Array<FlxGraphicAsset>, Key:String = ""):Void;
	public function loadGraphicsUpOverDown(asset:Dynamic, for_toggle:Bool = false, ?key:String):Void;
	public function forceStateHandler(event:String):Void;

	public var status(default, set):Int;
}
