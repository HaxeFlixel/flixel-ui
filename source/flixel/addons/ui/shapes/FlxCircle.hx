package org.flixel.plugin.leveluplabs.shapes;

import flash.geom.Point;
import flixel.FlxG;

/**

 * ...

 * @author Lars A. Doucet

 */class FlxCircle extends FlxShape {

	var radius : Float;
	public function new(p : Point, r : Float, st : Float, sc : Int, fill : Bool = false, fc : Int = 0xFFFFFF) {
		shape_id = "circle";
		radius = r;
		super(st, sc, fill, fc, p.x, p.y, Std.int(radius), Std.int(radius));
		buffer();
	}

	public function setRadius(r : Float) : Void {
		radius = r;
		buffer();
	}

	override public function buffer() : Void {
		drawShape.graphics.clear();
		drawShape.graphics.lineStyle(stroke_thick, stroke_col);
		if(has_fill)  {
			drawShape.graphics.beginFill(fill_col);
		}
		drawShape.graphics.drawCircle(x, y, radius);
		if(has_fill)  {
			drawShape.graphics.endFill();
		}
		super.buffer();
	}

}

