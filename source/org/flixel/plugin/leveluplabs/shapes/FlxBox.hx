package org.flixel.plugin.leveluplabs.shapes;

import flash.geom.Point;

/**

 * ...

 * @author Lars A. Doucet

 */class FlxBox extends FlxShape {

	public function new(p : Point, w : Int, h : Int, st : Float = 1, sc : Int = 0xFFFFFF, fill : Bool = false, fc : Int = 0xFFFFFF) {
		shape_id = "box";
		super(st, sc, fill, fc, p.x, p.y, w, h);
		buffer();
	}

	override public function buffer() : Void {
		drawShape.graphics.clear();
		drawShape.graphics.lineStyle(stroke_thick, stroke_col);
		if(has_fill)  {
			drawShape.graphics.beginFill(fill_col);
		}
		drawShape.graphics.drawRect(x, y, _w, _h);
		if(has_fill)  {
			drawShape.graphics.endFill();
		}
		super.buffer();
	}

}

