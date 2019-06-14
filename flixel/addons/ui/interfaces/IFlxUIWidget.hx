package flixel.addons.ui.interfaces;

import flixel.addons.ui.FlxUI.UIEventCallback;
import flixel.FlxSprite;

/**
 * ...
 * @author Lars Doucet
 */
interface IFlxUIWidget extends IFlxSprite
{
	public var name:String;
	public var width(get, set):Float;
	public var height(get, set):Float;

	public var broadcastToFlxUI:Bool; // if false, does not issue FlxUI.event() and FlxUI.request() calls
}
