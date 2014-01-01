package flixel.addons.ui.shapes;

import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.Shape;
import flash.geom.Matrix;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxSpriteUtil.LineStyle;

class FlxShapeDonut extends FlxShape 
{
	public var radius_out(default, set):Float;
	public var radius_in(default, set):Float;

	/**
	 * Creates a FlxSprite with a circle drawn on top of it. 
	 * X/Y is where the SPRITE is, the circle's upper-left
	 * @param	X x position of the canvas
	 * @param	Y y position of the canvas
	 * @param	Radius 
	 * @param	LineStyle_
	 * @param	FillStyle_
	 */
	
	public function new(X:Float, Y:Float, RadiusOut:Float, RadiusIn:Float, LineStyle_:LineStyle, FillStyle_:FillStyle) 
	{
		shape_id = "circle";
		
		lineStyle = LineStyle_;
		fillStyle = FillStyle_;
		
		var strokeBuffer:Float = (lineStyle.thickness);
		
		radius_out = RadiusOut;
		radius_in = RadiusIn;
		
		var trueWidth:Float = radius_out * 2;
		var trueHeight:Float = trueWidth;
		
		var w:Float = trueWidth + strokeBuffer;		//create buffer space for stroke
		var h:Float = trueHeight + strokeBuffer;
		
		if (w <= 0)
		{
			w = strokeBuffer;
		}
		if (h <= 0) 
		{
			h = strokeBuffer;
		}
		
		super(X, Y, w, h, lineStyle, fillStyle, trueWidth, trueHeight);
	}
	
	public function set_radius_out(r:Float):Float
	{
		radius_out = r;
		shapeDirty = true;
		return radius_out;
	}

	public function set_radius_in(r:Float):Float
	{
		radius_in = r;
		shapeDirty = true;
		return radius_in;
	}

	public override function drawSpecificShape(matrix:Matrix=null):Void 
	{
		var cx:Float = Math.ceil(width / 2);
		var cy:Float = Math.ceil(height / 2);
		FlxSpriteUtil.drawCircle(this, cx, cy, radius_out, fillStyle.color, lineStyle, matrix);
		if (radius_in > 0) {
			FlxSpriteUtil.drawCircle(this, cx, cy, radius_in, 0xffff0000, null, matrix, BlendMode.ERASE, true);
		}
		FlxSpriteUtil.drawCircle(this, cx, cy, radius_in, 0x00000000, lineStyle, matrix);
	}
}