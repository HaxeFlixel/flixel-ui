package flixel.addons.ui.interfaces;

import flixel.addons.ui.FlxUI.UIEventCallback;
import flixel.interfaces.IFlxSprite;

/**
 * ...
 * @author Lars Doucet
 */
interface IFlxUIWidget extends IFlxSprite
{
	public var id:String;
	public var width(get, set):Float;
	public var height(get, set):Float;
	
	public var uiEventCallback:UIEventCallback;
	 /*public function onFocusLost():Void;
	 public function onFocus():Void;*/
}

