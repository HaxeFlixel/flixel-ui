package flixel.addons.ui.shapes;

import flash.display.BitmapData;
import flash.display.Shape;
import flash.filters.GlowFilter;
import flash.geom.Matrix;
import flixel.addons.ui.shapes.FlxShapeLightning.LightningStyle;
import flixel.effects.FlxSpriteFilter;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxPoint;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxSpriteUtil.LineStyle;
import flixel.util.FlxVector;

/**
 * This creates a Lightning bolt drawn on top of a FlxSprite object. 
 * 
 * TODO:
	 * I'm not currently adding enough border room to properly account for the filter effect
 */

class FlxShapeLightning extends FlxShapeLine
{

	public var lightningStyle(default, set):LightningStyle;
	
	/**
	 * Creates a lightning bolt!
	 * @param	X			X location of the sprite canvas
	 * @param	Y			Y location of the sprite canvas
	 * @param	A			start point, relative to canvas
	 * @param	B			end point, relative to canvas
	 * @param	Style		LightningStyle object
	 * @param	UseDefaults	use default settings to fill in style gaps?
	 */	
	public function new(X:Float, Y:Float, A:FlxPoint, B:FlxPoint, Style:LightningStyle, UseDefaults:Bool=true) 
	{
		shape_id = "lightning";
		lightningStyle = Style;
		
		var v:FlxVector = new FlxVector(A.x - B.x, A.y - B.y);
		magnitude = v.length;
		
		if (lightningStyle.halo_colors == null && UseDefaults == true) {
			lightningStyle.halo_colors = [0xff88aaee, 0xff5555cc, 0xff334488];	//default colors
		}
		
		list_segs = new Array<LineSegment>();
		list_branch = new Array<LineSegment>();
		
		var w:Float = Math.abs(A.x - B.x);
		var h:Float = Math.abs(B.y - B.y);
		
		var testStyle:LineStyle = { thickness:1, color:0xffffffff };
		super(X, Y, A, B, testStyle);
		
		//create the main lightning bolt
		calculate(A, B, lightningStyle.displacement, 0);
	}
	
	private function addSegment(A:FlxPoint, B:FlxPoint):Void 
	{
		list_segs.push(new LineSegment(A, B));
	}
	
	private function calculate(A:FlxPoint, B:FlxPoint, Displacement:Float, Iteration:Int):Void 
	{
		if (Displacement < lightningStyle.detail){
			addSegment(A, B);
		}else{
			var mid:FlxPoint = new FlxPoint();
			mid.x = (A.x + B.x) / 2;
			mid.y = (A.y + B.y) / 2;
			var dispX:Float = Math.random() - 0.5;
			var dispY:Float = Math.random() - 0.5;
			mid.x += dispX * Displacement;
			mid.y += dispY * Displacement;
			calculate(A, mid, Displacement / 2, Iteration);
			calculate(B, mid, Displacement / 2, Iteration);
		}
		shapeDirty = true;
	}
	
	public function set_lightningStyle(Style:LightningStyle):LightningStyle {
		lightningStyle = Style;
		shapeDirty = true;
		return lightningStyle;
	}
	
	private function copyLineStyle(ls:LineStyle):LineStyle {
		var ls2:LineStyle = 
		{
			thickness:ls.thickness,
			color:ls.color,
			pixelHinting:ls.pixelHinting,
			scaleMode:ls.scaleMode,
			capsStyle:ls.capsStyle,
			jointStyle:ls.jointStyle,
			miterLimit:ls.miterLimit
		}
		return ls2;
	}

	public override function drawSpecificShape(matrix:Matrix=null):Void 
	{
		var up:Float = 9999;
		var left:Float = 9999;
		var down:Float = 0;
		var right:Float = 0;
		
		var l:LineSegment;
		for (l in list_segs) {
			if (l.a.x < left)	{ left	= l.a.x; }
			if (l.b.x < left)	{ left	= l.b.x; }
			if (l.a.y < up)		{ up	= l.a.y; }
			if (l.b.y < up)		{ up	= l.b.y; }
			if (l.a.x > right)	{ right	= l.a.x; }
			if (l.b.x > right)	{ right	= l.b.x; }
			if (l.a.y > down)	{ down	= l.a.y; }
			if (l.b.y > down)	{ down	= l.b.y; }
		}
		
		FlxG.log.add("ul = (" + left + "," + up + ")");
		FlxG.log.add("lr = (" + down + "," + right + ")");
		
		var strokeBuffer:Float = lightningStyle.thickness;
		
		//point-to-point size, unstroked
		var trueWidth:Float = Math.abs(point.x - point2.x);
		var trueHeight:Float = Math.abs(point.y - point2.y);
		
		//bbox size, unstroked
		var newWidth:Float = right - left;
		var newHeight:Float = down - up;
		
		//size of canvas, w/ borders to account for stroke
		var canvasWidth:Int = Std.int(newWidth + strokeBuffer);
		var canvasHeight:Int = Std.int(newHeight + strokeBuffer);
		
		offset.x = 0;
		offset.y = 0;
		width = canvasWidth;
		height = canvasHeight;
		
		if(canvasWidth != pixels.width || canvasHeight != pixels.height){
			makeGraphic(canvasWidth, canvasHeight, 0x00000000, true);
		}else {
			pixels.fillRect(pixels.rect, 0x00000000);
		}
		
		_matrix.identity();
		
		var dw:Int = 0;
		var dh:Int= 0;
		
		//if it's poking of the left or top, I need to adjust the drawing location
		if (left < 0) { dw = Std.int(-left + (strokeBuffer/2)); }
		if (up   < 0) { dh = Std.int(-up   + (strokeBuffer/2)); }
		
		//lineStyle.thickness = 1;		//lightningStyle.thickness;
		//lineStyle.color = 0xffffff00; 	//lightningStyle.color;
		
		for(l in list_segs) {
			FlxSpriteUtil.drawLine(this, l.a.x+dw, l.a.y+dh, l.b.x+dw, l.b.y+dh, lineStyle);
		}
		
		//lineStyle.thickness = 1;
		var fillStyle:FillStyle = { hasFill:false };
		
			/****DEBUGGING*****
			//draw canvas border
			lineStyle.color = 0x88ffffff;
			FlxSpriteUtil.drawRect(this, 0, 0, canvasWidth-1, canvasHeight-1, 0, lineStyle, fillStyle);
		
			//draw point-to-point border
			lineStyle.color = 0xff00aaff;
			FlxSpriteUtil.drawRect(this, dw, dh, dw + trueWidth - 1, dh + trueHeight - 1, 0, lineStyle, fillStyle);
			*******************/
		
		width = trueWidth;
		height = trueHeight;
		
		offset.x = dw;
		offset.y = dh;
		
		shapeDirty = true;
		filterDirty = true;		//update filters too
	}
	
	private override function fixBoundaries(trueWidth:Float, trueHeight:Float):Void {
		//doNothing, because this class requires special treatement
		//and I don't want this to get called by accident and screw things up
	}
	
	public override function draw():Void {
		super.draw();
		if (filterDirty) {
			if (lightningStyle.halo_colors == null) {
				filterDirty = false;
				return;
			}
				
			
			var sizeInc:Int = lightningStyle.halo_colors.length * 3;
			
			var i:Int = 0;
			var a:Array<GlowFilter> = new Array<GlowFilter>();
			for (halo_color in lightningStyle.halo_colors) {
				a.push(new GlowFilter(halo_color, (1.0 - (0.15 * i)), 3, 3));
				i++;
			}
		
			for (gf in a) {
				var pixels2:BitmapData = pixels.clone();
				pixels2.applyFilter(pixels, pixels.rect, _flashPointZero, gf);
				
				//remember size settings
				var w:Float = width;
				var h:Float = height;
				var ox:Float = offset.x;
				var oy:Float = offset.y;
				
				//update pixels
				pixels = pixels2;
				
				//restore size settings
				width = w;
				height = h;
				offset.x = ox;
				offset.y = oy;
			}
			
			filterDirty = false;
		}
	}
	
	/***PRIVATE***/
	
	//colors that surrounds it
	private var halo_cols:Array<Dynamic>;
	
	//low number = higher detail
	private var detail:Float;
	
	private var magnitude:Float;
	
	private var list_segs:Array<LineSegment>;
	private var list_branch:Array<LineSegment>;
	
	//private var flxSpriteFilter:FlxSpriteFilter;
	private var filterDirty:Bool = false;
}

typedef LightningStyle = {
	?thickness:Float,
	?color:Int,
	?displacement:Float,
	?detail:Float,
	?halo_colors:Array<Int>
}