package org.flixel.plugin.leveluplabs.shapes;

import nme.display.Shape;
import nme.geom.ColorTransform;
import nme.geom.Matrix;
import org.cheezeworld.math.Vector2D;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxPoint;

class FlxArrow extends FlxShape {
	public var point(getPoint, setPoint) : FlxPoint;
	public var point2(getPoint2, setPoint2) : FlxPoint;

	var _pt : FlxPoint;
	var _pt2 : FlxPoint;
	var _line1 : FlxLine;
	var _line2 : FlxLine;
	var _triangle : Shape;
	var vec : Vector2D;
	var arrow_angle : Float;
	public function new(a : FlxPoint, b : FlxPoint, thick : Float = 1, col : Int = 0xFFFFFF, col2 : Int = 0x000000) {
		arrow_angle = 0;
		vec = new Vector2D(0, 0);
		shape_id = "line";
		_pt = new FlxPoint(a.x, a.y);
		_pt2 = new FlxPoint(b.x, b.y);
		var w : Float = Math.abs(a.x - b.x) + thick * 4;
		var h : Float = Math.abs(a.y - b.y) + thick * 4;
		_line2 = new FlxLine(a, b, thick + 2, col2);
		_line1 = new FlxLine(a, b, thick, col);
		super(thick, col, false, col, 0, 0, w, h);
		_triangle = new Shape();
		_triangle.graphics.lineStyle(1, col2);
		_triangle.graphics.beginFill(col);
		_triangle.graphics.moveTo(thick * -2, 0);
		_triangle.graphics.lineTo(thick * 2, 0);
		_triangle.graphics.lineTo(0, thick * -2);
		_triangle.graphics.lineTo(thick * -2, 0);
		_triangle.graphics.endFill();
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
		_line1.point = _pt;
		_line1.point2 = _pt2;
		_line2.point = _pt;
		_line2.point2 = _pt2;
		_line1.buffer();
		_line2.buffer();
		var vec2d : Vector2D = new Vector2D(_pt2.x - _pt.x, _pt2.y - _pt.y);
		vec.x = 0;
		vec.y = -1;
		arrow_angle = vec.angleTo(vec2d);
		//this just gets the shortest angle between the vectors
		if(vec2d.x < 0)  {
			//this fixes the ambiguity mentioned above and makes sure angle is in right quadrant
			arrow_angle = (Math.PI * 2) - arrow_angle;
		}
;
		var degrees : Float = arrow_angle * (180 / Math.PI);
		super.buffer();
	}

	override public function render() : Void {
		_line2.render();
		drawTriangle();
		_line1.render();
	}

	function drawTriangle() : Void {
		getScreenXY(_point);
		var m : Matrix = new Matrix();
		m.identity();
		m.rotate(arrow_angle);
		m.translate(_pt2.x, _pt2.y);
		//trace("angle to = " + angle);
		var c : ColorTransform = new ColorTransform(1, 1, 1, 1, 0, 0, 0, (-255 + (256 * alpha)));
		//FlxG.buffer.copyPixels(_framePixels,_flashRect,_flashPoint,null,null,true);
		FlxG.buffer.draw(_triangle, m, c, blend);
	}

}

