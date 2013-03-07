package org.flixel.plugin.leveluplabs.shapes;

import nme.geom.Point;

/**
 * ...
 * @author Lars A. Doucet
 */class LineSegment {

	public var a : Point;
	public var b : Point;
	public var thick : Int;
	public function new(_a : Point, _b : Point, t : Int = 1) {
		thick = 1;
		a = _a.clone();
		b = _b.clone();
		thick = t;
	}

	public function copy() : LineSegment {
		return new LineSegment(a, b, thick);
	}

}

