package flixel.addons.ui.shapes;

import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.Shape;
import flash.geom.Matrix;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxSpriteUtil.LineStyle;

class FlxShapeSquareDonut extends FlxShape 
{
	public var radius_out(default, set):Float;
	public var radius_in(default, set):Float;

	/**
	 * Creates a FlxSprite with a square donut drawn on top of it. 
	 * X/Y is where the SPRITE is, the square's upper-left
	 * @param	X x position of the canvas
	 * @param	Y y position of the canvas
	 * @param	RadiusIn 
	 * @param	RadiusOut 
	 * @param	LineStyle_
	 * @param	FillStyle_
	 */
	
	public function new(X:Float, Y:Float, RadiusOut:Float, RadiusIn:Float, LineStyle_:LineStyle, FillStyle_:FillStyle) 
	{
		shape_id = "square_donut";
		
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
		
		_drawStyle.matrix = matrix;
		FlxSpriteUtil.drawRect(this, 0, 0, radius_out * 2, radius_out * 2, fillStyle.color, lineStyle, fillStyle, _drawStyle);
		if (radius_in > 0) {
			_drawStyle.blendMode = BlendMode.ERASE;
			_drawStyle.smoothing = true;
			FlxSpriteUtil.drawRect(this, (radius_out - radius_in), (radius_out - radius_in), radius_in * 2, radius_in * 2, 0xffff0000, null, fillStyle, _drawStyle);
		}
		_drawStyle.blendMode = BlendMode.NORMAL;
		FlxSpriteUtil.drawRect(this, (radius_out - radius_in), (radius_out - radius_in), radius_in * 2, radius_in * 2, 0x00000000, lineStyle, null, _drawStyle);
	}
}