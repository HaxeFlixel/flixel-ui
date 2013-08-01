package flixel.addons.ui;

/**
 * An interface to match FireTongue, so we can use this without making
 * a full dependency
 * @author Lars Doucet
 */interface IFireTongue {

	public function get(flag:String, context:String = "data", safe:Bool = true):String;
	
	public var locale(get, null):String;		
	public function get_locale():String;
		
}

