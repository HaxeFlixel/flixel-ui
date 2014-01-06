package flixel.addons.ui.shapes;

import flash.display.BitmapData;
import flash.display.Shape;
import flash.geom.Matrix;
import flixel.FlxG;
import flixel.util.FlxPoint;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxSpriteUtil.LineStyle;

/**
 * A cross shape drawn onto a FlxSprite. Useful for tactics games and stuff!
 */

class FlxShapeCross extends FlxShape 
{
	public var horizontalLength(default, set):Float;
	public var horizontalSize(default, set):Float;
	
	public var verticalLength(default, set):Float;
	public var verticalSize(default, set):Float;
	
	public var intersectionV(default, set):Float;
	public var intersectionH(default, set):Float;
	
	/**
	 * Set how long the horizontal arm of the cross is
	 * @param	f
	 * @return
	 */
	
	public function set_horizontalLength(f:Float):Float {
		horizontalLength = f;
		shapeDirty = true;
		return horizontalLength;
	}
	
	/**
	 * Set how thick the horizontal arm of the cross is
	 * @param	f
	 * @return
	 */
	
	public function set_horizontalSize(f:Float):Float {
		horizontalSize = f;
		shapeDirty = true;
		return horizontalSize;
	}
	
	/**
	 * Set how long the vertical arm of the cross is
	 * @param	f
	 * @return
	 */
	
	public function set_verticalLength(f:Float):Float {
		verticalLength = f;
		shapeDirty = true;
		return verticalLength;
	}
	
	/**
	 * Set how thick the vertical arm of the cross is
	 * @param	f
	 * @return
	 */
	
	public function set_verticalSize(f:Float):Float {
		verticalSize = f;
		shapeDirty = true;
		return verticalSize;
	}
	
	/**
	 * Sets where the two arms intersect vertically
	 * @param	f	value (0-1): 0 makes a T, 1 makes inverted T, 0.5 makes a +; (if intersectionH is 0.5)
	 * @return
	 */
	public function set_intersectionV(f:Float):Float {
		if (f > 1) { f = 1; }
		if (f < 0) { f = 0; }
		intersectionV = f;
		shapeDirty = true;
		return intersectionV;
	}
	
	/**
	 * Sets where the two arms intersect horizontally
	 * @param	f	value (0-1): 0 makes a |-, 1 makes a -|, 0.5 makes a +; (if intersectionV is 0.5)
	 * @return
	 */
	public function set_intersectionH(f:Float):Float {
		if (f > 1) { f = 1; }
		if (f < 0) { f = 0; }
		intersectionH = f;
		shapeDirty = true;
		return intersectionH;
	}
	
	public function new(X:Float, Y:Float, HLength:Float, HSize:Float, VLength:Float, VSize:Float, IntersectionH:Float, IntersectionV:Float, LineStyle_:LineStyle, FillStyle_:FillStyle) 
	{
		shape_id = "cross";
		
		lineStyle = LineStyle_;
		fillStyle = FillStyle_;
		
		horizontalLength = HLength;
		horizontalSize = HSize;
		verticalLength = VLength;
		verticalSize = VSize;
		intersectionH = IntersectionH;
		intersectionV = IntersectionV;
		
		var strokeBuffer:Float = (lineStyle.thickness);
		
		var w:Float = horizontalLength + strokeBuffer;				//create buffer space for stroke
		var h:Float = verticalLength   + strokeBuffer;
		
		if (w <= 0)
		{
			w = strokeBuffer;
		}
		if (h <= 0) 
		{
			h = strokeBuffer;
		}
		
		FlxG.log.add("size = (" + w + "," + h + ")");
		FlxG.log.add("hvsize = (" + horizontalLength + "," + verticalLength + ")");
		
		super(X, Y, w, h, lineStyle, fillStyle, horizontalLength, verticalLength);
	}
	
	public override function destroy():Void {
		super.destroy();
		if (vertices != null) {
			while (vertices.length > 0) {
				vertices.pop();
			}
		}
		vertices = null;
	}
	
	public override function drawSpecificShape(matrix:Matrix=null):Void 
	{
		if (vertices == null) {
			vertices = new Array<FlxPoint>();
			var i:Int = 13;
			while (i > 0) {
				vertices.push(new FlxPoint());
				i--;
			}
		}
		
		//For sanity/readability's sake, I worked out the math using two rectangles
		
		//fr == vertical rectangle
		_flashRect.x = (horizontalLength - verticalSize) * intersectionH;	//line up the vertical rectangle with center
		_flashRect.y = 0;
		_flashRect.width = verticalSize;
		_flashRect.height = verticalLength;
		
		//fr2 == horizontal rectangle
		_flashRect2.x = 0;
		_flashRect2.y = (verticalLength - horizontalSize) * intersectionV;
		_flashRect2.width = horizontalLength;
		_flashRect2.height = horizontalSize;
		
		//Copy vertices from the two rectangles
		vertices[0].y = _flashRect.top;		vertices[0].x = _flashRect.left;	//top-left of vertical beam
		vertices[1].y = _flashRect.top;		vertices[1].x = _flashRect.right;	//top-right
		vertices[6].y = _flashRect.bottom;	vertices[6].x = _flashRect.right;	//bottom-right 
		vertices[7].y = _flashRect.bottom;	vertices[7].x = _flashRect.left;	//bottom-left
		
		//Copy vertices from the two rectangles
		vertices[3].y = _flashRect2.top;	vertices[3].x = _flashRect2.right;	//top-right of horizontal beam
		vertices[4].y = _flashRect2.bottom;	vertices[4].x = _flashRect2.right;	//bottom-right
		vertices[9].y = _flashRect2.bottom;	vertices[9].x = _flashRect2.left;	//bottom-left
		vertices[10].y = _flashRect2.top;	vertices[10].x = _flashRect2.left;	//top-left
				
		//Create intersection points
		vertices[2].x = vertices[1].x;		//NE intersection
		vertices[2].y = vertices[3].y;
		
		vertices[5].x = vertices[6].x;		//SE intersection
		vertices[5].y = vertices[4].y;
		
		vertices[8].x = vertices[7].x;		//SW intersection
		vertices[8].y = vertices[9].y;
		
		vertices[11].x = vertices[0].x;		//NW intersection
		vertices[11].y = vertices[10].y;
		
		//close it up
		vertices[12].x = vertices[0].x;
		vertices[12].y = vertices[0].y;
		
		//reset these just in case that's important
		_flashRect.x = 0;  _flashRect.y = 0;
		_flashRect2.x = 0; _flashRect2.y = 0;
		
		//I don't know why these next two lines are necessary, but without them only half of the object is drawn
			pixels.fillRect(pixels.rect, 0x00000000);
			pixels = pixels;
		
		_matrix.identity();
		_matrix.translate(lineStyle.thickness / 2, lineStyle.thickness / 2);
		
		_drawStyle.matrix = _matrix;
		FlxSpriteUtil.drawPolygon(this, vertices, fillStyle.color, lineStyle, fillStyle, _drawStyle);
		
		fixBoundaries(horizontalLength, verticalLength);
	}
	
	private var vertices:Array<FlxPoint>;
}