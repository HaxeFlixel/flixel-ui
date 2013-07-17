package flixel.addons.ui;
import flash.display.BitmapData;
import flash.geom.Point;

/**
 * This is mostly just for testing purposes, it is NOT a replacement for FlxTileMap
 * @author 
 */

class FlxTileTest extends FlxSpriteX
{

	public function new(X:Float,Y:Float,tileWidth:Int,tileHeight:Int,tilesWide:Int,tilesTall:Int,color1:Int=0xff808080,color2:Int=0xffc4c4c4) 
	{
		super(X, Y);
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
	
}