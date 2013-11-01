package flixel.addons.ui.shapes;

import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.geom.Point;

/**
 * ...
 * @author Lars A. Doucet
 */
class FlxGrid extends FlxShape
{
	public var grid_size:Float;
	public var data:Array<Dynamic>;
	public var illegal_color:Int;
	
	public SQUARES_WIDE:Int = 10;
	public SQUARES_TALL:Int = 10;
	
	public function new(p:Point, w:Float, h:Float, size:Float, st:Float = 1, sc:Int = 0xFFFFFF, arr:Array<Dynamic> = null, i_color:Int = 0) 
	{
		grid_size = 1;
		shape_id = "grid";
		grid_size = size;
		if (arr != null)
		{
			data = arr;
		}
		illegal_color = i_color;
		super(st, sc, false, 0, p.x, p.y, w, h);
		buffer();
	}

	override public function render():Void 
	{
		super.render();
	}

	override public function buffer():Void 
	{
		drawShape.graphics.clear();
		var xx:Float;
		var yy:Float;
		if (data != null)
		{
			yy = 0;
			while (yy < SQUARES_TALL)
			{
				xx = 0;
				while (xx < SQUARES_WIDE) 
				{
					if (!data[yy * SQUARES_WIDE + xx])
					{
						drawShape.graphics.lineStyle();
						drawShape.graphics.beginFill(illegal_color, 1);
						drawShape.graphics.drawRect(xx * grid_size, yy * grid_size, grid_size, grid_size);
						drawShape.graphics.endFill();
					}
					xx++;
				}
				yy++;
			}
			yy = 0;
			while (yy < SQUARES_TALL) 
			{
				xx = 0;
				while (xx < SQUARES_WIDE) 
				{
					if (data[yy * SQUARES_WIDE + xx])
					{
						drawShape.graphics.lineStyle(stroke_thick, stroke_col);
						drawShape.graphics.drawRect(xx * grid_size, yy * grid_size, grid_size, grid_size);
					}
					xx++;
				}
				yy++;
			}
		}
		_canvas = new BitmapData(drawShape.width, drawShape.height, true, 0x00000000);
		_canvasBMP.bitmapData = _canvas;
		super.buffer();
	}
}