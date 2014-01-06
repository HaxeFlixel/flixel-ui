package flixel.addons.ui.shapes;
import flash.geom.Matrix;
import flixel.addons.ui.shapes.FlxShapeDonut;
import flixel.util.FlxSpriteUtil;

/**
 * ...
 * @author 
 */
class FlxShapeDoubleCircle extends FlxShapeDonut
{
	/**
	 * Creates a FlxSprite with a double-circle drawn on top of it. 
	 * X/Y is where the SPRITE is, the double-circle's upper-left
	 * @param	X x position of the canvas
	 * @param	Y y position of the canvas
	 * @param	RadiusIn 
	 * @param	RadiusOut 
	 * @param	LineStyle_
	 * @param	FillStyle_
	 */
	
	public function new(X:Float, Y:Float, RadiusOut:Float, RadiusIn:Float, LineStyle_:LineStyle, FillStyle_:FillStyle) 
	{
		super(X, Y, RadiusOut, RadiusIn, LineStyle_, FillStyle_);
	}
	
	public override function drawSpecificShape(matrix:Matrix=null):Void 
	{
		var cx:Float = Math.ceil(width / 2);
		var cy:Float = Math.ceil(height / 2);
		FlxSpriteUtil.drawCircle(this, cx, cy, radius_out, fillStyle.color, lineStyle,  { matrix: matrix });
		FlxSpriteUtil.drawCircle(this, cx, cy, radius_in, 0x00000000, lineStyle,  { matrix: matrix });
	}
}