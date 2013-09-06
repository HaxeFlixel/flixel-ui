package flixel.addons.ui;
import flixel.FlxSprite.IFlxSprite;

/**
 * ...
 * @author Lars Doucet
 */

interface IFlxUIWidget extends IFlxSprite{

	 public var id:String;
	 public var width(default, set):Float;
	 public var height(default, set):Float;
}

