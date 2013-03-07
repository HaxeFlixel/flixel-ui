package org.flixel.plugin.leveluplabs.shapes;

import nme.display.BitmapData;
import nme.display.BlendMode;
import nme.display.Shape;
import nme.geom.ColorTransform;
import nme.geom.Matrix;
import nme.geom.Point;
import nme.geom.Rectangle;
import org.flixel.FlxG;
import org.flixel.plugin.leveluplabs.FlxTextX;

/**
 * ...
 * @author Lars A. Doucet
 */class FlxDoubleCircle extends FlxShape {

	var radius_out : Float;
	var radius_in : Float;
	var erase : Shape;
	var canvas : BitmapData;
	var draw_rect : Rectangle;
	var draw_point : Point;
	var line_alpha : Float;
	var fill_alpha : Float;
	var out_text : FlxTextX;
	var in_text : FlxTextX;
	var out_str : String;
	var in_str : String;
	public function new(p : Point, r1 : Float, r2 : Float, st : Float, sc : Int, la : Float = 1, fill : Bool = false, fc : Int = 0xFFFFFF, fa : Float = 1, outlabel : String = "", inlabel : String = "") {
		out_str = outlabel;
		in_str = inlabel;
		shape_id = "double_circle";
		radius_out = r1;
		radius_in = r2;
		erase = new Shape();
		line_alpha = la;
		fill_alpha = fa;
		if(radius_out <= 0) 
			radius_out = 1;
		super(st, sc, fill, fc, p.x, p.y, radius_out, radius_out);
		canvas = new BitmapData(radius_out * 2, radius_out * 2, true, 0x000000FF);
		draw_rect = new Rectangle(0, 0, radius_out * 2, radius_out * 2);
		draw_point = new Point(x - radius_out, y - radius_out);
		out_text = new FlxTextX(0, 0, radius_out, out_str);
		out_text.setFormat("Verdana_12pt_st", 12, sc, "center", 1);
		out_text.dropShadow = true;
		out_text.bold = true;
		in_text = new FlxTextX(0, 0, radius_in, in_str);
		in_text.setFormat("Verdana_12pt_st", 12, sc, "center", 1);
		in_text.dropShadow = true;
		in_text.bold = true;
		buffer();
	}

	override public function setLoc(X : Float, Y : Float) : Void {
		super.setLoc(X, Y);
		out_text.x = x - radius_out / 2;
		in_text.x = x - radius_in / 2;
		out_text.y = y - radius_out - 15;
		in_text.y = y - radius_in - 15;
	}

	public function setRadii(r1 : Float, r2 : Float) : Void {
		radius_out = r1;
		radius_in = r2;
		buffer();
	}

	override public function buffer() : Void {
		drawShape.graphics.clear();
		drawShape.graphics.lineStyle(stroke_thick, stroke_col, line_alpha);
		if(has_fill)  {
			drawShape.graphics.beginFill(fill_col, fill_alpha);
		}
		drawShape.graphics.drawCircle(radius_out, radius_out, radius_out - (stroke_thick / 2));
		if(has_fill)  {
			drawShape.graphics.endFill();
		}
		drawShape.graphics.lineStyle(stroke_thick * 1.5, stroke_col, line_alpha, false, "normal", "none");
		var points : Array<Dynamic> = getCircleCoords(24, radius_in, radius_out, radius_out);
		//erase.graphics.clear();
		if(radius_in > 0)  {
			var i : Int = 0;
			while(i < points.length) {
				if(i % 2 == 0)  {
					drawShape.graphics.moveTo(points[i].x, points[i].y);
					if(i + 1 < points.length)  {
						drawShape.graphics.lineTo(points[i + 1].x, points[i + 1].y);
					}
				}
				i++;
			}
		}

		draw_point.x = x - radius_out;
		draw_point.y = y - radius_out;
		canvas.fillRect(draw_rect, 0x00000000);
		canvas.draw(drawShape);
		in_text.y = y - radius_in - 15;
		out_text.y = y - radius_out - 15;
		in_text.x = x - (radius_in) / 2;
		out_text.x = x - (radius_out) / 2;
		//canvas.draw(erase,null,null,"erase",null,true);
		super.buffer();
	}

	function getCircleCoords(gaps : Int, radius : Float, offx : Float = 0, offy : Float = 0) : Array<Dynamic> {
		var points : Array<Dynamic> = new Array<Dynamic>();
		var circumf : Float = 2 * Math.PI * radius;
		var segs : Float = gaps * 2;
		var gap_size : Float = (circumf) / segs;
		var v : Vector2D = new Vector2D(radius, 0);
		var rotate : Float = (Math.PI * 2) / segs;
		var i : Int = 0;
		while(i < segs) {
			points.push(new Point(v.x + offx, v.y + offy));
			v.rotateVector(rotate);
			i++;
		}
		return points;
	}

	override public function render() : Void {
		getScreenXY(_point);
		_flashPoint.x = _point.x;
		_flashPoint.y = _point.y;
		var m : Matrix = new Matrix();
		m.identity();
		m.transformPoint(_flashPoint);
		var c : ColorTransform = new ColorTransform(1, 1, 1, 1, 0, 0, 0, (-255 + (256 * alpha)));
		FlxG.buffer.copyPixels(canvas, draw_rect, draw_point, null, null, true);
		out_text.render();
		in_text.render();
	}

}

