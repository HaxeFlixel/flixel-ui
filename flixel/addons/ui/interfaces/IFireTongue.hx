package flixel.addons.ui.interfaces;

/**
 * An interface to match FireTongue, so we can use this without making
 * a full dependency
 * @author Lars Doucet
 */
interface IFireTongue {
	public function get(flag:String, context:String = "data", safe:Bool = true):String;
	
	public var locale(default, null):String;
}

