package flixel.addons.ui;
import flixel.IFlxSprite;

/**
 * ...
 * @author Lars Doucet
 */

interface IFlxUIWidget extends IFlxSprite
{
	 public var id:String;
	 public var width(get, set):Float;
	 public var height(get, set):Float;
	 
	 /*public function onFocusLost():Void;
	 public function onFocus():Void;*/
}

