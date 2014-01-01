package flixel.addons.ui.shapes;
import flash.geom.Matrix;
import flixel.addons.ui.shapes.FlxShapeBox;
import flixel.util.FlxSpriteUtil;

/**
 * ...
 * @author 
 */
class FlxShapeGrid extends FlxShapeBox
{
	public var cellWidth(default, set):Float;
	public var cellHeight(default, set):Float;
	public var cellsWide(default, set):Int;
	public var cellsTall(default, set):Int;
	
	/**
	 * Creates a FlxSprite with a grid drawn on top of it. 
	 * X/Y is where the SPRITE is, the grid upper-left
	 * @param	X 			x position of the canvas
	 * @param	Y 			y position of the canvas
	 * @param	CellWidth 	width of a grid cell
	 * @param	CellHeight 	height of a grid cell
	 * @param	CellsWide	how many cells wide
	 * @param	CellsTalls	how many cells tall
	 * @param	LineStyle_	line style
	 * @param	FillStyle_	fill style
	 */
	
	public function new(X:Float, Y:Float, CellWidth:Float, CellHeight:Float, CellsWide:Int, CellsTall:Int, LineStyle_:LineStyle, FillStyle_:FillStyle) 
	{
		var w:Float = CellWidth * CellsWide;
		var h:Float = CellHeight * CellsTall;
		
		cellsWide = CellsWide;
		cellsTall = CellsTall;
		cellWidth = CellWidth;
		cellHeight = CellHeight;
		
		super(X, Y, w, h, LineStyle_, FillStyle_);
	}
	
	public override function drawSpecificShape(matrix:Matrix=null):Void 
	{
		var ox:Float = (lineStyle.thickness / 2);
		var oy:Float = (lineStyle.thickness / 2);
		
		//draw the fill
		FlxSpriteUtil.drawRect(this, ox, oy, shapeWidth, shapeHeight, fillStyle.color, null);
		
		//draw vertical lines
		for (iw in 0...cellsWide+1) {
			FlxSpriteUtil.drawLine(this, ox + (cellWidth * iw), oy, ox + (cellWidth * iw), oy + shapeHeight, lineStyle);
		}
		
		//draw horizontal lines
		for (ih in 0...cellsTall+1) {
			FlxSpriteUtil.drawLine(this, ox, oy + (cellHeight * ih), ox + shapeWidth, oy + (cellHeight * ih), lineStyle);
		}
	}
	
	public function set_cellWidth(f:Float):Float {
		cellWidth = f;
		shapeDirty = true;
		return cellWidth;
	}
	
	public function set_cellHeight(f:Float):Float {
		cellHeight = f;
		shapeDirty = true;
		return cellHeight;
	}
	
	public function set_cellsWide(i:Int):Int {
		cellsWide = i;
		shapeDirty = true;
		return cellsWide;
	}
	
	public function set_cellsTall(i:Int):Int {
		cellsTall = i;
		shapeDirty = true;
		return cellsTall;
	}
}