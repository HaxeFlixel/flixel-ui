package flixel.addons.ui.interfaces;

/**
 * ...
 * @author Lars Doucet
 */
interface IResizable
{
	function resize(w:Float, h:Float):Void;
	public var width(get, set):Float;
	public var height(get, set):Float;
}
