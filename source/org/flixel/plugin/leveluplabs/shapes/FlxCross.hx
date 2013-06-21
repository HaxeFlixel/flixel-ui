package org.flixel.plugin.leveluplabs.shapes;

import flash.geom.Point;

/**

 * ...

 * @author Lars A. Doucet

 */class FlxCross extends FlxShape {

	var size : Float;
	public function new(p : Point, s : Float, thick : Float = 1, col : Int = 0xFFFFFF) {
		shape_id = "cross";
		size = s;
		super(thick, col, false, 0xFFFFFF, x, y, Std.int(size), Std.int(size));
		buffer();
	}

	public function setCrossSize(n : Float) : Void {
		size = n;
		buffer();
	}

	override public function buffer() : Void {
		drawShape.graphics.clear();
		drawShape.graphics.lineStyle(stroke_thick, stroke_col);
		drawShape.graphics.moveTo(x - size / 2, y);
		drawShape.graphics.lineTo(x + size / 2, y);
		drawShape.graphics.moveTo(x, y - size / 2);
		drawShape.graphics.lineTo(x, y + size / 2);
		super.buffer();
	}

}

