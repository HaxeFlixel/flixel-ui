package flixel.addons.ui.shapes;

import flash.display.BitmapData;
import flash.display.Shape;
import flash.geom.Matrix;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxPoint;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxSpriteUtil.LineStyle;

class FlxShapeLine extends FlxShape 
{
	public var point(default, set):FlxPoint;
	public var point2(default, set):FlxPoint;

	/**
	 * Creates a FlxSprite with a line drawn on top of it. 
	 * X/Y is where the SPRITE is, and points a&b are RELATIVE to this object's origin. 
	 * Points with negative values will not draw correctly since they'll appear beyond the sprite's canvas.
	 * @param	X x position of the canvas
	 * @param	Y y position of the canvas
	 * @param	a first point in the line (relative to the sprite's origin)
	 * @param	b second point in the line (relative to the sprite's origin)
	 * @param	LineStyle_
	 */
	
	public function new(X:Float, Y:Float, a:FlxPoint, b:FlxPoint, LineStyle_:LineStyle) 
	{
		shape_id = "line";
		
		lineStyle = LineStyle_;
		
		point = a;
		point2 = b;
		
		var strokeBuffer:Float = (lineStyle.thickness);
		
		var trueWidth:Float = Math.abs(a.x - b.x);	//actual geometric size
		var trueHeight:Float = Math.abs(a.y - b.y);
		
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
		
		super(X, Y, w, h, lineStyle, null, trueWidth, trueHeight);
	}
	
	public function set_point(p:FlxPoint):FlxPoint 
	{
		if (point == null)
		{
			point = new FlxPoint(p.x, p.y);
		}
		else
		{
			point.x = p.x;
			point.y = p.y;
		}
		
		shapeDirty = true;
		return point;
	}

	public function set_point2(p:FlxPoint):FlxPoint 
	{
		if (point2 == null)
		{
			point2 = new FlxPoint(p.x, p.y);
		}
		else
		{
			point2.x = p.x;
			point2.y = p.y;
		}
		
		shapeDirty = true;
		return point2;
	}

	public override function drawSpecificShape(matrix:Matrix=null):Void 
	{
		_drawStyle.matrix = matrix;
		FlxSpriteUtil.drawLine(this, point.x, point.y, point2.x, point2.y, lineStyle, _drawStyle);
	}
}