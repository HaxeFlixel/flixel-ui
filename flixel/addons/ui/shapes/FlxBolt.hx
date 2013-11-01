package flixel.addons.ui.shapes;

import flash.display.BitmapData;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.Vector;

import flixel.util.FlxPoint;

import flixel.addons.ui.Vector2D;

/**
 * ...
 * @author Lars A. Doucet
 */
class FlxBolt extends FlxShape 
{
	private var point:Point;
	//endpoint of the lightning
	private var halo_cols:Array<Dynamic>;
	//colors that surrounds it
	private var detail:Float;
	//low number = higher detail
	private var magnitude:Float;
	private var list_segs:Vector<LineSegment>;
	private var list_branch:Vector<LineSegment>;
	private var displace:Float;
	private var num_branches:Int;
	private var curr_branches:Int;
	private var branch_lvl:Int;
	private var default_cols:Array<Dynamic>;
	
	/**
	 * Creates a lightning bolt!
	 * @param	a	start point
	 * @param	b	end point
	 * @param	det	detail level. lower = more detail
	 * @param	disp displacement. higher = more chaotic
	 * @param	branches how many major sub-bolts
	 * @param	branches how many sub-branch levels
	 * @param	thick line thickness
	 * @param	col	color of the bolt
	 * @param	halo_c colors of the halo
	 */	
	public function new(a:Point, b:Point, det:Float = 1, disp:Float = 200, branches:Int = 5, branch_level:Int = 3, thick:Float = 3, col:Int = 0xFFFFFF, halo_c:Array<Dynamic> = null) 
	{
		curr_branches = 0;
		default_cols = [0x88aaee, 0x5555cc, 0x334488];
		shape_id = "bolt";
		point = b;
		var v:Vector2D = new Vector2D(a.x - b.x, a.y - b.y);
		magnitude = v.length;
		if (halo_c != null)  
		{
			halo_cols = halo_c.concat();
		}
		else
		{
			halo_cols = default_cols.concat();
		}
		
		detail = det;
		displace = disp;
		num_branches = branches;
		branch_lvl = branch_level;
		list_segs = new Vector<LineSegment>();
		list_branch = new Vector<LineSegment>();
		var w:Float = Math.abs(new Vector2D(a.x - point.x).x);
		var h:Float = Math.abs(new Vector2D(a.y - point.y).y);
		super(thick, col, false, 0, a.x, a.y, w, h);
		//create the main lightning bolt
		calc(a, b, displace, 0);
		//draw the shape
		buffer();
	}

	function addSegment(a:Point, b:Point, t:Int):Void 
	{
		list_segs.push(new LineSegment(a, b, t));
	}

	function calc(a:Point, b:Point, disp:Float, iteration:Int):Void 
	{
		if (disp < detail)
		{
			var thick:Float = stroke_thick;
			var i:Int = 0;
			while (i < iteration) 
			{
				thick *= 0.75;
				i++;
			}
			addSegment(a, b, thick);
		}
		else
		{
			var mid:Point = new Point();
			mid.x = (a.x + b.x) / 2;
			mid.y = (a.y + b.y) / 2;
			var dispX:Float = Math.random() - 0.5;
			var dispY:Float = Math.random() - 0.5;
			mid.x += dispX * disp;
			mid.y += dispY * disp;
			calc(a, mid, disp / 2, iteration);
			calc(b, mid, disp / 2, iteration);
		}
	}

	override public function buffer():Void 
	{
		drawShape.graphics.clear();
		var ul:FlxPoint = new FlxPoint(9999, 9999);
		var lr:FlxPoint = new FlxPoint(0, 0);
		for (l in list_segs/* AS3HX WARNING could not determine type for var: l exp: EIdent(list_segs) type: Vector<LineSegment>*/) {
			drawShape.graphics.lineStyle(l.thick, stroke_col);
			drawShape.graphics.moveTo(l.a.x, l.a.y);
			drawShape.graphics.lineTo(l.b.x, l.b.y);
			if(l.a.x < ul.x) 
				ul.x = l.a.x;
			if(l.b.x < ul.x) 
				ul.x = l.b.x;
			if(l.a.y < ul.y) 
				ul.y = l.a.y;
			if(l.b.y < ul.y) 
				ul.y = l.b.y;
			if(l.a.x > lr.x) 
				lr.x = l.a.x;
			if(l.b.x > lr.x) 
				lr.x = l.b.x;
			if(l.a.y > lr.y) 
				lr.y = l.a.y;
			if(l.b.y > lr.y) 
				lr.y = l.b.y;
		}
		
		var a:Array<Dynamic> = new Array<Dynamic>();
		var i:Int = 0;
		while (i < halo_cols.length) 
		{
			a.push(new GlowFilter(halo_cols[i], (1.0 - (0.15 * i)), 3, 3));
			i++;
		}
		
		drawShape.filters = a;
		_canvas = new BitmapData(ul.x + drawShape.width, ul.y + drawShape.height, true, 0x00000000);
		_canvasBMP.bitmapData = _canvas;
		super.buffer();
	}
}