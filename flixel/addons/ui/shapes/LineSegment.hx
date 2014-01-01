package flixel.addons.ui.shapes;

import flash.geom.Point;
import flixel.util.FlxPoint;

/**
 * Helper for FlxShapeLightning
 * @author Lars A. Doucet
 */
class LineSegment 
{
	public var a:FlxPoint;
	public var b:FlxPoint;
	
	public function new(A:FlxPoint, B:FlxPoint) 
	{
		a = new FlxPoint(A.x,A.y);
		b = new FlxPoint(B.x,B.y);
	}

	public function copy():LineSegment 
	{
		return new LineSegment(a, b);
	}
}