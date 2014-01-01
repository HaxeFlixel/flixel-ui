package flixel.addons.ui.shapes;

import flash.display.BitmapData;
import flash.display.Shape;
import flash.geom.Matrix;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxSpriteUtil.LineStyle;

class FlxShapeBox extends FlxShape 
{
	public var shapeWidth(default, set):Float;		//the actual boundaries of the underlying shape, 
	public var shapeHeight(default, set):Float;
	
	/**
	 * Creates a FlxSprite with a circle drawn on top of it. 
	 * X/Y is where the SPRITE is, the circle's upper-left
	 * @param	X x position of the canvas
	 * @param	Y y position of the canvas
	 * @param	Width
	 * @param	Height
	 * @param	LineStyle_
	 * @param	FillStyle_
	 */
	
	public function new(X:Float, Y:Float, W:Float, H:Float, LineStyle_:LineStyle, FillStyle_:FillStyle) 
	{
		shape_id = "box";
		
		lineStyle = LineStyle_;
		fillStyle = FillStyle_;
		
		var strokeBuffer:Float = (lineStyle.thickness);
		shapeWidth = W;
		shapeHeight = H;
		
		var w:Float = shapeWidth + strokeBuffer;		//create buffer space for stroke
		var h:Float = shapeHeight + strokeBuffer;
		
		if (w <= 0)
		{
			w = strokeBuffer;
		}
		if (h <= 0) 
		{
			h = strokeBuffer;
		}
		
		super(X, Y, w, h, lineStyle, fillStyle, shapeWidth, shapeHeight);
	}
	
	public function set_shapeWidth(f:Float):Float
	{
		shapeWidth = f;
		shapeDirty = true;
		return shapeWidth;
	}

	public function set_shapeHeight(f:Float):Float
	{
		shapeHeight = f;
		shapeDirty = true;
		return shapeHeight;
	}
	
	public override function drawSpecificShape(matrix:Matrix=null):Void 
	{
		FlxSpriteUtil.drawRect(this, lineStyle.thickness/2, lineStyle.thickness/2, shapeWidth, shapeHeight, fillStyle.color, lineStyle);
	}
}