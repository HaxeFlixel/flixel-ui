package flixel.addons.ui;

import flash.display.BitmapData;
import flash.geom.Point;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.interfaces.IResizable;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

/**
 * This is mostly just for testing purposes, it is NOT a replacement for FlxTileMap
 */
class FlxUITileTest extends FlxUISprite implements IResizable implements IFlxUIWidget
{
	public var widthInTiles(get, never):Int;
	public var heightInTiles(get, never):Int;
	public var tileWidth(default, null):Int;
	public var tileHeight(default, null):Int;

	private function get_widthInTiles():Int
	{
		return _tilesWide;
	}

	private function get_heightInTiles():Int
	{
		return _tilesTall;
	}

	private var _tilesWide:Int = 2;
	private var _tilesTall:Int = 2;
	private var _color1:FlxColor = 0;
	private var _color2:FlxColor = 0;

	public var floorToEven:Bool = false;
	public var baseTileSize:Int = -1;

	public function new(X:Float, Y:Float, TileWidth:Int, TileHeight:Int, tilesWide:Int, tilesTall:Int, color1:FlxColor = 0x808080, color2:FlxColor = 0xc4c4c4,
			FloorToEven:Bool = false)
	{
		super(X, Y);

		tileWidth = TileWidth;
		tileHeight = TileHeight;

		_tilesWide = tilesWide;
		_tilesTall = tilesTall;
		_color1 = color1;
		_color2 = color2;

		floorToEven = FloorToEven;

		makeTiles(tileWidth, tileHeight, _tilesWide, _tilesTall, _color1, _color2);
	}

	private function makeTiles(tileWidth:Int, tileHeight:Int, tilesWide:Int, tilesTall:Int, color1:FlxColor = 0xff808080, color2:FlxColor = 0xffc4c4c4):Void
	{
		var size:FlxPoint = constrain(tileWidth * _tilesWide, tileHeight * _tilesTall);

		tileWidth = Std.int(size.x);
		tileHeight = Std.int(size.y);

		makeGraphic(tilesWide, tilesTall, color1);

		var canvas:BitmapData = pixels;

		var j:Int = 0;
		for (ix in 0...tilesWide)
		{
			for (iy in 0...tilesTall)
			{
				if (j % 2 == 0)
				{
					canvas.setPixel(ix, iy, color2);
				}
				j++;
			}
			if (tilesWide % 2 != 0)
			{
				j++;
			}
		}

		pixels = canvas;
		scale.set(tileWidth, tileHeight);
		updateHitbox();
	}

	private function constrain(w:Float, h:Float):FlxPoint
	{
		var tileWidth = Std.int(w / _tilesWide);
		var tileHeight = Std.int(h / _tilesTall);

		if (tileWidth < tileHeight)
		{
			tileHeight = tileWidth;
		}
		else if (tileHeight < tileWidth)
		{
			tileWidth = tileHeight;
		}

		if (floorToEven)
		{
			if ((tileWidth % 2) == 1)
			{
				tileWidth -= 1;
				tileHeight = tileWidth;
			}
		}

		// if defined, force scaling to whole number multiple of tile sizes
		if (baseTileSize > 0)
		{
			tileWidth = Std.int(tileWidth / baseTileSize) * baseTileSize;
			tileHeight = tileWidth;
		}

		return new FlxPoint(tileWidth, tileHeight);
	}

	public override function resize(w:Float, h:Float):Void
	{
		makeTiles(tileWidth, tileHeight, _tilesWide, _tilesTall, _color1, _color2);
	}
}
