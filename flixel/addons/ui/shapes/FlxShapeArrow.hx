package flixel.addons.ui.shapes;
import flash.geom.Matrix;
import flixel.addons.ui.shapes.FlxShapeLine;
import flixel.util.FlxPoint;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxSpriteUtil.LineStyle;
import flixel.util.FlxVector;

/**
 * ...
 * @author 
 */
class FlxShapeArrow extends FlxShape
{
	public var outlineStyle(default, set):LineStyle;
	public var arrowSize(default, set):Float;
	
	public var point(default, set):FlxPoint;
	public var point2(default, set):FlxPoint;
	
	/**
	 * Creates a line with an arrowhead on point B
	 * @param	X				X location of the sprite canvas
	 * @param	Y				Y location of the sprite canvas
	 * @param	a				starting point of the arrow
	 * @param	b				ending point of the arrow (this is where the arrowhead is)
	 * @param	ArrowSize		how big the arrow is (height)
	 * @param	LineStyle_		line style for the line and arrowhead
	 * @param	OutlineStyle_	line style for the outer line (optional)
	 */
	
	public function new(X:Float, Y:Float, a:FlxPoint, b:FlxPoint, ArrowSize:Float, LineStyle_:LineStyle, ?OutlineStyle_:LineStyle) 
	{
		arrowSize = ArrowSize;
		outlineStyle = OutlineStyle_;
		
		shape_id = "arrow";
		
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
	
	public override function drawSpecificShape(matrix:Matrix=null):Void 
	{
		if (_matrix2 == null) {
			_matrix2 = new Matrix();
		}
		
		//generate the arrowhead
		var vertices:Array<FlxPoint> = new Array<FlxPoint>();
		vertices.push(new FlxPoint(0, arrowSize));
		vertices.push(new FlxPoint(arrowSize*2, arrowSize));
		vertices.push(new FlxPoint(arrowSize, 0));
		vertices.push(new FlxPoint(0, arrowSize));		//close it up
		
		//get arrowhead rotation vector
		var fv:FlxVector = new FlxVector(point.x - point2.x, point.y - point2.y);
		
		_matrix2.identity();
		_matrix2.translate( -arrowSize, 0);		//translate so origin is the tip of arrow
		
		//rotate so arrow tip is pointing towards point2
		_matrix2.rotate(fv.radians - Math.PI/2);
		
		//translate so that origin is lined up with point2
		_matrix2.translate(lineStyle.thickness/2+point2.x, lineStyle.thickness/2+point2.y);
		
		var buffer:Float = 0;
		
		if (outlineStyle != null) {
			//draw the outline
			FlxSpriteUtil.drawLine(this, point.x, point.y, point2.x, point2.y, outlineStyle, matrix);
			//draw the arrowhead outline
			FlxSpriteUtil.drawPolygon(this, vertices, outlineStyle.color, outlineStyle, _matrix2);
		}
		
		//draw the line itself
		FlxSpriteUtil.drawLine(this, point.x, point.y, point2.x, point2.y, lineStyle, matrix);
		
		//draw the arrowhead
		FlxSpriteUtil.drawPolygon(this, vertices, lineStyle.color, lineStyle, _matrix2);
		
		fixBoundaries(Math.abs(point.x - point2.x), Math.abs(point.y - point2.y));
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
	
	public function set_arrowSize(f:Float):Float {
		arrowSize = f;
		shapeDirty = true;
		return arrowSize;
	}
	
	public function set_outlineStyle(ls:LineStyle):LineStyle {
		outlineStyle = ls;
		shapeDirty = true;
		return outlineStyle;
	}
	
	private var _matrix2:Matrix;
	private var _vertices:Array<FlxPoint>;
}