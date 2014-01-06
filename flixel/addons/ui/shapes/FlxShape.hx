package flixel.addons.ui.shapes;

import flash.display.BlendMode;
import flash.display.Shape;
import flash.geom.Matrix;
import flixel.FlxSprite;
import flixel.util.FlxSpriteUtil.FillStyle;
import flixel.util.FlxSpriteUtil.LineStyle;
import flixel.util.FlxSpriteUtil.DrawStyle;

/**
 * A convenience class for wrapping vector shape drawing in FlxSprites, all ready to go.
 * Don't use this class by itself -- use things like FlxLine, FlxCircle, that extend it
 * 
 * 
 * 
 * @author Lars A. Doucet
 */

class FlxShape extends FlxSprite
{
	public var lineStyle(default, set):LineStyle;		//stroke settings
	public var fillStyle(default, set):FillStyle;		//fill settings
	
	public var shape_id:String;						//string id of the shape
	public var shapeDirty:Bool = false;				//flag to flip to force it to redraw the shape
	
	/**
	 * (You should never instantiate this directly, only call it as a super)
	 * Creates a Shape wrapped in a FlxSprite
	 * @param	X				X location
	 * @param	Y				Y location
	 * @param	CanvasWidth		Width of pixel canvas
	 * @param	CanvasHeight	Height of pixel canvas
	 * @param	LineStyle_		Drawing style for strokes -- see flixel.util.FlxSpriteUtil.LineStyle
	 * @param	FillStyle_		Drawing style for fills -- see flixel.util.FlxSpriteUtil.FillStyle
	 * @param	TrueWidth		Width of raw unstyled geometric object, ignoring line thickness, filters, etc
	 * @param	TrueHeight		Height of raw unstyled geometric object, ignoring line thickness, filters, etc
	 */
	
	public function new(X:Float, Y:Float, CanvasWidth:Float, CanvasHeight:Float, LineStyle_:LineStyle, FillStyle_:FillStyle, TrueWidth:Float=0, TrueHeight:Float=0) 
	{
		super(X, Y);
		
		shape_id = "";
		
		if (CanvasWidth < 1) { CanvasWidth = 1; }
		if (CanvasHeight < 1) { CanvasHeight = 1; }
		
		width = CanvasWidth;
		height = CanvasHeight;
		
		makeGraphic(Std.int(width), Std.int(height), 0x00000000, true);
		
		lineStyle = LineStyle_;
		fillStyle = FillStyle_;
		
		//we'll eventually want a public drawStyle parameter, but we'll also need an internval _drawStyle to do 
		//some specific tricks for various shapes (special matrices, punching holes in Donut shapes by using ERASE blend mode, etc)
		_drawStyle = {matrix:null,colorTransform:null,blendMode:BlendMode.NORMAL,clipRect:null,smoothing:true};
		
		if (TrueWidth != 0 && TrueHeight != 0) {
			if(TrueWidth < CanvasWidth && TrueHeight < CanvasHeight){
				fixBoundaries(TrueWidth, TrueHeight);
			}
		}
		
		shapeDirty = true;		//draw the shape next draw() command
	}
	
	private var _drawStyle:DrawStyle;
	
	/**
	 * Fixes boundaries so that the sprite's bbox & origin line up with the underlying geometric object's
	 * @param	trueWidth	width of geometric object (ignoring strokes, etc)
	 * @param	trueHeight	height of geometric object (ignoring strokes, etc)
	 */
	
	private function fixBoundaries(trueWidth:Float, trueHeight:Float):Void {
		width = trueWidth;		//reset width/height to geometric reality 
		height = trueHeight;
		
		var strokeBuffer:Float = (lineStyle.thickness);
		
		//set offsets so that X/Y correspond to shape's geometric upper-left, ignoring stroke boundaries
		offset.x = strokeBuffer / 2;
		offset.y = strokeBuffer / 2;
		
		shapeDirty = true;		//redraw the shape next draw() command
	}

	override public function destroy():Void 
	{
		lineStyle = null;
		fillStyle = null;
		super.destroy();
	}
	
	public function set_lineStyle(ls:LineStyle):LineStyle {
		lineStyle = ls;
		shapeDirty = true;
		return lineStyle;
	}
	
	public function set_fillStyle(fs:FillStyle):FillStyle {
		fillStyle = fs;
		shapeDirty = true;
		return fillStyle;
	}
	
	
	public function redrawShape():Void
	{
		pixels.fillRect(pixels.rect, 0x00000000);
		if (lineStyle.thickness > 1) {
			var matrix:Matrix = getStrokeOffsetMatrix(_matrix);
			drawSpecificShape(matrix);
		}else {
			drawSpecificShape();
		}
	}
	
	private function getStrokeOffsetMatrix(matrix:Matrix):Matrix{
		var buffer:Float = lineStyle.thickness / 2;
		matrix.identity();
		matrix.translate(buffer, buffer);
		return matrix;
	}
	
	private function drawSpecificShape(matrix:Matrix=null):Void {
		//override per subclass
		//put your actual drawing function here
	}

	public override function draw():Void {
		if (shapeDirty) {
			redrawShape();
			shapeDirty = false;				//call this AFTER incase redrawShape() sets shapeDirty = true
		}
		super.draw();
	}

}