package org.flixel.plugin.leveluplabs.shapes;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.Shape;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import org.flixel.FlxG;
import org.flixel.FlxObject;

/**
 * ...
 * @author Lars A. Doucet
 */
class FlxShape extends FlxObject {
	public var st_thick(never, set_st_thick) : Float;
	public var fill(never, set_fill) : Int;
	public var line_col(never, set_line_col) : Int;
	public var alpha(get_alpha, set_alpha) : Float;

	var has_fill : Bool;
	var fill_col : Int;
	var stroke_col : Int;
	var stroke_thick : Float;
	var _w : Int;
	var _h : Int;
	var drawShape : Shape;
	var _flashRect : Rectangle;
	var _alpha : Float;
	public var blend : String;
	public var movable : Bool;
	public var shape_id : String;
	public var _canvas : BitmapData;
	public var _canvasBMP : Bitmap;
	var _mat : Matrix;
	var _ct : ColorTransform;
	var _pt : Point;
	public function new(st : Float, sc : Int, fill : Bool, fc : Int, X : Float, Y : Float, w : Int, h : Int) {
		_alpha = 1;
		blend = Std.string(BlendMode.NORMAL);
		movable = false;
		shape_id = "";
		_pt = new Point();
		stroke_thick = st;
		stroke_col = sc;
		has_fill = fill;
		fill_col = fc;
		drawShape = new Shape();
		_w = w;
		_h = h;
		if(_w < 1) 
			_w = 1;
		if(_h < 1) 
			_h = 1;
		_canvas = new BitmapData(_w, _h, true, 0x00000000);
		_canvasBMP = new Bitmap(_canvas);
		_mat = new Matrix();
		_ct = new ColorTransform(1, 1, 1, 1, 0, 0, 0, 1);
		super(X, Y, w, h);
	}

	override public function destroy() : Void {
		drawShape = null;
		_flashRect = null;
		if(_canvas != null)  {
			_canvas.dispose();
			_canvas = null;
		}
		if(_canvasBMP != null)  {
			_canvasBMP.bitmapData = null;
			_canvasBMP = null;
		}
		_mat = null;
		_ct = null;
		_pt = null;
		super.destroy();
	}

	public function set_st_thick(n : Float) : Float {
		stroke_thick = n;
		buffer();
		return n;
	}

	public function set_fill(u : Int) : Int {
		fill_col = u;
		buffer();
		return u;
	}

	public function set_line_col(u : Int) : Int {
		stroke_col = u;
		buffer();
		return u;
	}

	public function set_alpha(n : Float) : Float {
		if(n > 1) 
			n = 1;
		if(n < 0) 
			n = 0;
		_alpha = n;
		return n;
	}

	public function get_alpha() : Float {
		return _alpha;
	}

	public function set_loc(X : Float, Y : Float) : Void {
		x = X;
		y = Y;
		buffer();
	}

	public function get_loc() : Point {
		return _pt.clone();
	}

	public function set_size(W : Int, H : Int) : Void {
		if(W != -1) 
			_w = W;
		if(H != -1) 
			_h = H;
		buffer();
	}

	public function buffer() : Void {
		getScreenXY(_point);
		//var m:Matrix = new Matrix();
		//m.identity();
		if(_mat == null) 
			_mat = new Matrix();
		_mat.identity();
		/*if(movable){

		_mat.translate(_point.x, _point.y);

		}*/_ct = new ColorTransform(1, 1, 1, 1, 0, 0, 0, (-255 + (255 * alpha)));
		_pt.x = _point.x;
		_pt.y = _point.y;
		_canvas.draw(drawShape);
	}

	//TODO:
	//the entire DRAW function!
	/*override public function render() : Void {
		if(movable)  {
			_canvasBMP.x = _point.x;
			_canvasBMP.y = _point.y;
		}
		if(alpha == 0)  {
			return;
		}
		if(alpha != 1 || blend != BlendMode.NORMAL)  {
			_canvasBMP.x = 0;
			_canvasBMP.y = 0;
			//_canvasBMP.alpha = alpha;
			//_canvasBMP.blendMode = blend;
			//_canvasBMP.
			_ct.alphaOffset = (-255 + (256 * alpha));
			//FlxG.buffer.draw(drawShape);
			FlxG.buffer.draw(_canvasBMP, null, _ct, blend);
		}

		else  {
			FlxG.buffer.copyPixels(_canvas, _canvas.rect, _pt, null, null, true);
		}

	}*/

}

