package flixel.addons.ui;
import flash.display.BitmapData;
import flash.geom.Point;

/**
 * This is mostly just for testing purposes, it is NOT a replacement for FlxTileMap
 * @author 
 */

class FlxUITileTest extends FlxUISprite implements IResizable implements IFlxUIWidget 
{
	private var _tilesWide:Int=2;
	private var _tilesTall:Int=2;
	private var _color1:Int=0;
	private var _color2:Int = 0;
	
	public var floorToEven:Bool = true;
	
	public function new(X:Float,Y:Float,tileWidth:Int,tileHeight:Int,tilesWide:Int,tilesTall:Int,color1:Int=0xff808080,color2:Int=0xffc4c4c4) 
	{
		super(X, Y);
		
		_tilesWide = tilesWide;
		_tilesTall = tilesTall;
		_color1 = color1;
		_color2 = color2;
		
		makeTiles(tileWidth,tileHeight,_tilesWide,_tilesTall,_color1,_color2);
	}
	
	//For IResizable
	public function get_width():Float { return width; }
	public function get_height():Float { return height; }
	
	private function makeTiles(tileWidth:Int,tileHeight:Int,tilesWide:Int,tilesTall:Int,color1:Int=0xff808080,color2:Int=0xffc4c4c4):Void {
		makeGraphic(tileWidth * tilesWide, tileHeight * tilesTall, color1);
		
		var brush:BitmapData = new BitmapData(tileWidth, tileHeight, true, color2);
		var canvas:BitmapData = pixels;
		
		var j:Int = 0;
		var pt:Point = new Point(0, 0);
		for (ix in 0...tilesWide) {
			for (iy in 0...tilesTall) {
				if (j % 2 == 0) {
					pt.x = ix * tileWidth;
					pt.y = iy * tileHeight;
					canvas.copyPixels(brush, brush.rect, pt);
				}
				j++;
			}
			if (tilesWide % 2 != 0) {
				j++;
			}
		}
		
		pt = null;
		pixels = canvas;
	}
	
	public function resize(w:Float, h:Float):Void {		
		var tileWidth:Int = Std.int(w / _tilesWide);
		var tileHeight:Int = Std.int(h / _tilesTall);
		
		if (tileWidth < tileHeight) { tileHeight = tileWidth; }		
		else if (tileHeight < tileWidth) { tileWidth = tileHeight; }
		
		if(floorToEven){
			if ((tileWidth % 2) == 1) {
				tileWidth -= 1;
				tileHeight = tileWidth;
			}
		}
		
		makeTiles(tileWidth,tileHeight,_tilesWide,_tilesTall,_color1,_color2);
	}
	
}