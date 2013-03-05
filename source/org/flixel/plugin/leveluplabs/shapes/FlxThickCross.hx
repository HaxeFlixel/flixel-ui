package org.flixel.plugin.leveluplabs.shapes;

import nme.geom.Point;

/**
 * ...
 * @author Lars A. Doucet
 */class FlxThickCross extends FlxShape {

	var size : Float;
	var arm_size : Float;
	var points : Array<Dynamic>;
	var fill_alpha : Float;
	public function new(p : Point, s : Float, arm_s : Float, thick : Float = 1, s_c : UInt = 0xFFFFFF, s_a : Float = 1, fill_ : Bool = false, fc : UInt = 0xffffff, fa : Float = 1) {
		shape_id = "cross";
		size = s;
		arm_size = arm_s;
		fill_alpha = fa;
		trace("FlxThickCross() arm_size = " + arm_size);
		super(thick, s_c, fill_, fc, x, y, size, size);
		buffer();
	}

	function calcPoints() : Void {
		trace("FlxThickCross.calcPoints() armSize = " + arm_size);
		points = new Array<Dynamic>();
		var ah : Float = arm_size / 2;
		points.push(new Point(x + ah, y - ah));
		//right upper corner
		points.push(new Point(x + size, y - ah));
		//right arm edge
		points.push(new Point(x + size, y + ah));
		points.push(new Point(x + ah, y + ah));
		//right lower corner
		points.push(new Point(x + ah, y + size));
		//lower arm edge
		points.push(new Point(x - ah, y + size));
		points.push(new Point(x - ah, y + ah));
		//left lower corner
		points.push(new Point(x - size, y + ah));
		//left arm edge
		points.push(new Point(x - size, y - ah));
		points.push(new Point(x - ah, y - ah));
		//left upper corner
		points.push(new Point(x - ah, y - size));
		//upper arm edge
		points.push(new Point(x + ah, y - size));
		points.push(new Point(x + ah, y - ah));
	}

	public function setCrossSize(s : Float, a_s : Float) : Void {
		size = s;
		arm_size = a_s;
		trace("FlxThickCross.setCrossSize() arm_size = " + arm_size);
		buffer();
	}

	override public function buffer() : Void {
		calcPoints();
		drawShape.graphics.clear();
		drawShape.graphics.lineStyle(stroke_thick, stroke_col);
		if(has_fill)  {
			drawShape.graphics.beginFill(fill_col, fill_alpha);
		}
		drawShape.graphics.moveTo(points[0].x, points[1].y);
		for(p in points){
			drawShape.graphics.lineTo(p.x, p.y);
		}

		if(has_fill)  {
			drawShape.graphics.endFill();
		}
		super.buffer();
	}

}

