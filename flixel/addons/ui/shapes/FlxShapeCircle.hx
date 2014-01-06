package flixel.addons.ui.shapes;

import flash.display.BitmapData;
import flash.display.Shape;
import flash.geom.Matrix;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxSpriteUtil.LineStyle;

class FlxShapeCircle extends FlxShape 
{
	public var radius(default, set):Float;

	/**
	 * Creates a FlxSprite with a circle drawn on top of it. 
	 * X/Y is where the SPRITE is, the circle's upper-left
	 * @param	X x position of the canvas
	 * @param	Y y position of the canvas
	 * @param	Radius 
	 * @param	LineStyle_
	 * @param	FillStyle_
	 */
	
	public function new(X:Float, Y:Float, Radius:Float, LineStyle_:LineStyle, FillStyle_:FillStyle) 
	{
		shape_id = "circle";
		
		lineStyle = LineStyle_;
		fillStyle = FillStyle_;
		
		var strokeBuffer:Float = (lineStyle.thickness);
		
		radius = Radius;
		
		var trueWidth:Float = radius * 2;
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
	
	public function set_radius(r:Float):Float
	{
		radius = r;
		shapeDirty = true;
		return radius;
	}

	public override function drawSpecificShape(matrix:Matrix=null):Void 
	{
		_drawStyle.matrix = matrix;
		FlxSpriteUtil.drawCircle(this, Math.ceil(width / 2), Math.ceil(height / 2), radius, fillStyle.color, lineStyle, _drawStyle);
	}
}