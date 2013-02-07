package org.flixel.plugin.leveluplabs;

/**
 * ...
 * @author Lars Doucet
 */

class IntPt 
{
	public var x:Int;
	public var y:Int;
	
	public function new(_x:Int,_y:Int) 
	{
		x = _x;
		y = _y;
	}
	
	public function toString():String {
		return "{x:" + x + ",y:" + y + "}";
	}
	
}