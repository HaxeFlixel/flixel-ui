package flixel.addons.ui;

/**

 * ...

 * @author Lars Doucet

 */
 interface IResizable{

	function resize(w:Float, h:Float) : Void;
	public var width(default, set):Float;
	public var height(default, set):Float;
	
}

