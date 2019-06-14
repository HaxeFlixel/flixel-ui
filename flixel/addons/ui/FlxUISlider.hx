package flixel.addons.ui;

#if FLX_MOUSE
import flixel.addons.ui.FlxSlider;
import flixel.addons.ui.interfaces.IFlxUIWidget;

class FlxUISlider extends FlxSlider implements IFlxUIWidget
{
	public var name:String;

	public var broadcastToFlxUI:Bool = true;

	public static inline var CHANGE_EVENT:String = "change_slider"; // change in any way
}
#end
