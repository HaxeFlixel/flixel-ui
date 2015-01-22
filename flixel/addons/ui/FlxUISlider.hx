package flixel.addons.ui;
import flixel.addons.ui.FlxSlider;
import flixel.addons.ui.interfaces.IFlxUIWidget;

/**
 * ...
 * @author 
 */
class FlxUISlider extends FlxSlider implements IFlxUIWidget
{
	public var name:String;
	
	public var broadcastToFlxUI:Bool=true;
	
	public static inline var CHANGE_EVENT:String = "change_slider";		//change in any way
	
	
	//private var internalObject
}
