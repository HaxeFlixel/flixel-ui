package org.flixel.plugin.leveluplabs.shapes;

import nme.display.BitmapData;
import nme.display.Shape;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxPoint;

class FlxLine extends FlxShape {
	public var point(getPoint, setPoint) : FlxPoint;
	public var point2(getPoint2, setPoint2) : FlxPoint;

	var _pt : FlxPoint;
	var _pt2 : FlxPoint;
	public function new(a : FlxPoint, b : FlxPoint, thick : Float = 1, col : Int = 0xFFFFFF) {
		shape_id = "line";
		_pt = new FlxPoint(a.x, a.y);
		_pt2 = new FlxPoint(b.x, b.y);
		var w : Float = Math.abs(a.x - b.x) + thick * 4;
		var h : Float = Math.abs(a.y - b.y) + thick * 4;
		if(w <= 0)  {
			w = thick * 4;
		}
		if(h <= 0)  {
			h = thick * 4;
		}
		super(thick, col, false, col, 0, 0, w, h);
		buffer();
	}

	public function getPoint() : FlxPoint {
		return _pt;
	}

	public function getPoint2() : FlxPoint {
		return _pt2;
	}

	public function setPoint(p : FlxPoint) : FlxPoint {
		if(_pt == null)  {
			_pt = new FlxPoint(p.x, p.y);
		}

		else  {
			_pt.x = p.x;
			_pt.y = p.y;
		}

		_point.x = _pt.x;
		_point.y = _pt.y;
		return p;
	}

	public function setPoint2(p : FlxPoint) : FlxPoint {
		if(_pt2 == null)  {
			_pt2 = new FlxPoint(p.x, p.y);
		}

		else  {
			_pt2.x = p.x;
			_pt2.y = p.y;
		}

		return p;
	}

	override public function buffer() : Void {
		drawShape.graphics.clear();
		drawShape.graphics.lineStyle(stroke_thick, stroke_col);
		drawShape.graphics.moveTo(_pt.x, _pt.y);
		drawShape.graphics.lineTo(_pt2.x, _pt2.y);
		_canvas = new BitmapData(_pt.x + drawShape.width, _pt.y + drawShape.height, true, 0x000000);
		_canvasBMP.bitmapData = _canvas;
		super.buffer();
	}

}

