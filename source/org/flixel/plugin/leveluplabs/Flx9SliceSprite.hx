package org.flixel.plugin.leveluplabs;
import flash.geom.Point;
import flash.geom.Matrix;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Rectangle;
import flash.display.BitmapData;
import openfl.Assets;
import org.flixel.FlxObject;
import org.flixel.FlxSprite;

/**
 * @author Lars Doucet
 */

class Flx9SliceSprite extends FlxSprite implements IResizable
{
	
	private static var bitmapsCreated:Int = 0; // for debug

	private static var _canvas:Sprite;	//drives the 9-slice drawing
	
	private static var useSectionCache:Bool = true;
	private static var sectionCache:Map<String,BitmapData>;
	
	private var _slice9:String = "";
	private var _tile:Bool = false;
	private var _smooth:Bool = false;
	private var _asset_id:String = "";
	
	/** 
	 * @param	X	X position of final sprite
	 * @param	Y	Y position of final sprite
	 * @param	Graphic	Asset
	 * @param	Rect	Width/Height of the final scaled sprite
	 * @param	slice9	"x1,y1,x2,y2" : 2 points (upper-left middle and lower-right middle) that define the 9-slice grid
	 * @param	tile	Whether to tile the middle pieces or stretch them (default is false --> stretch)
	 * @param	smooth	When stretching, whether to smooth middle pieces (default false)
	 * @param 	id	if Graphic is a BitmapData, manually specify its original source id, if any
	 */
	
	public function new(X:Float, Y:Float, Graphic:Dynamic, rc:Rectangle, slice9:String="", tile:Bool=false, smooth:Bool=false, id:String="") 
	{
		super(X, Y, null);
		
		_slice9 = slice9;
		_tile = tile;
		_smooth = smooth;
				
		_asset_id = "";
		
		if(Std.is(Graphic,String)){
			_asset_id = Graphic;
		}else if (Std.is(Graphic, BitmapData)) {
			_asset_id = id;
		}
				
		resize(rc.width, rc.height);
		
		/*if (_slice9 == "" || _slice9 == null) {
			_slice9 = "4,4,7,7";
		}
		
		if(_canvas == null){
			_canvas = new Sprite();		
		}
		
		_canvas.graphics.clear();

		var asset_id:String = "";
		
		if(Std.is(Graphic,String)){
			asset_id = Graphic;
		}else if (Std.is(Graphic, BitmapData)) {
			asset_id = id;
		}
				
		paintScale9(_canvas.graphics, asset_id, _slice9, _rc, _tile, _smooth);
		
		var bitmap_data:BitmapData = new BitmapData(Std.int(rc.width), Std.int(rc.height),true,0x00ffffff);
		bitmap_data.draw(_canvas);
		
		//for caching purposes:
		var key:String = asset_id + "_" + _slice9 + "_" + rc.width + "x" + rc.height;
		
		loadGraphic(bitmap_data,false,false,bitmap_data.width,bitmap_data.height,false,key);*/
	}
	
	public function resize(w:Float, h:Float):Void {		
		if (_slice9 == "" || _slice9 == null) {
			_slice9 = "4,4,7,7";
		}
		
		if(_canvas == null){
			_canvas = new Sprite();		
		}
		
		_canvas.graphics.clear();

		paintScale9(_canvas.graphics, _asset_id, _slice9, new Rectangle(0,0,w,h), _tile, _smooth);
		
		var iw:Int = Std.int(w);
		var ih:Int = Std.int(h);
		
		var bitmap_data:BitmapData = new BitmapData(iw, ih,true,0x00ffffff);
		bitmap_data.draw(_canvas);
		
		//for caching purposes:
		var key:String = _asset_id + "_" + _slice9 + "_" + iw + "x" + ih;
		
		loadGraphic(bitmap_data, false, false, bitmap_data.width, bitmap_data.height, false, key);
	}
	
	public static inline function getRectFromString(str:String):Rectangle{
		var coords:Array<String> = str.split(",");
		var rect:Rectangle = null;
		if(coords != null && coords.length == 4){
			var x_:Int = Std.parseInt(coords[0]);
			var y_:Int = Std.parseInt(coords[1]);
			var w_:Int = Std.parseInt(coords[2]);
			var h_:Int = Std.parseInt(coords[3]);
			rect = new Rectangle(x_,y_,w_,h_);
		}
		return rect;
	}
	
	public static inline function getRectIntsFromString(str:String):Array<Int>{
		var coords:Array<String> = str.split(",");
		if(coords != null && coords.length == 4){
			var x1:Int = Std.parseInt(coords[0]);
			var y1:Int = Std.parseInt(coords[1]);
			var x2:Int = Std.parseInt(coords[2]);
			var y2:Int = Std.parseInt(coords[3]);
			return [x1, y1, x2, y2];
		}
		return null;
	}
	
	//These functions were borrowed from:
	//https://github.com/ianharrigan/YAHUI/blob/master/src/yahui/style/StyleHelper.hx
	
	/**
	 * Does the actual drawing for a 9-slice scaled graphic
	 * @param	g the graphics object for drawing to (ie, sprite.graphic)
	 * @param	assetId id of bitmapdata asset you are scaling
	 * @param	scale9 string defining 2 points that define the grid as "x1,y1,x2,y2" (upper-interior-left, lower-interior-right)
	 * @param	rc rectangle object defining how big you want to scale it to
	 * @param	tile if false, scale middle pieces, if true, tile them (default false)
	 * @param 	smooth whether to smooth when scaling or not (default false)
	 */
	
	public static function paintScale9(g:Graphics, assetId:String, scale9:String, rc:Rectangle, tile:Bool=false, smooth:Bool = false):Void {
		if (scale9 != null) { // create parts
			var w:Int = Assets.getBitmapData(assetId).width;
			var h:Int = Assets.getBitmapData(assetId).height;
			var coords:Array<String> = scale9.split(",");
			var x1:Int = Std.parseInt(coords[0]);
			var y1:Int = Std.parseInt(coords[1]);
			var x2:Int = Std.parseInt(coords[2]);
			var y2:Int = Std.parseInt(coords[3]);

			var rects:Map<String,Rectangle> = new Map<String,Rectangle>();

			rects.set("top.left", new Rectangle(0, 0, x1, y1));
			rects.set("top", new Rectangle(x1, 0, x2 - x1, y1));
			rects.set("top.right", new Rectangle(x2, 0, w - x2, y1));

			rects.set("left", new Rectangle(0, y1, x1, y2 - y1));
			rects.set("middle", new Rectangle(x1, y1, x2 - x1, y2 - y1));
			rects.set("right", new Rectangle(x2, y1, w - x2, y2 - y1));

			rects.set("bottom.left", new Rectangle(0, y2, x1, h - y2));
			rects.set("bottom", new Rectangle(x1, y2, x2 - x1, h - y2));
			rects.set("bottom.right", new Rectangle(x2, y2, w - x2, h - y2));

			paintCompoundBitmap(g, assetId, rects, rc, tile);
		}
	}

	public static function paintCompoundBitmap(g:Graphics, assetId:String, sourceRects:Map<String,Rectangle>, targetRect:Rectangle, tile:Bool=false, smooth:Bool = false):Void {
		var fillcolor = #if (neko) { rgb:0x00FFFFFF, a:0 }; #else 0x00FFFFFF; #end
		targetRect.left = Std.int(targetRect.left);
		targetRect.top = Std.int(targetRect.top);
		targetRect.right = Std.int(targetRect.right);
		targetRect.bottom = Std.int(targetRect.bottom);

		// top row
		var tl:Rectangle = sourceRects.get("top.left");
		if (tl != null) {
			paintBitmapSection(g, assetId, tl, new Rectangle(0, 0, tl.width, tl.height),null,tile);
		} else {
			tl = new Rectangle();
		}

		var tr:Rectangle = sourceRects.get("top.right");
		if (tr != null) {
			paintBitmapSection(g, assetId, tr, new Rectangle(targetRect.width - tr.width, 0, tr.width, tr.height),null,tile);
		} else {
			tr = new Rectangle();
		}

		var t:Rectangle = sourceRects.get("top");
		if (t != null) {
			paintBitmapSection(g, assetId, t, new Rectangle(tl.width, 0, (targetRect.width - tl.width - tr.width), t.height),null,tile);
		} else {
			t = new Rectangle();
		}

		// bottom row
		var bl:Rectangle = sourceRects.get("bottom.left");
		if (bl != null) {
			paintBitmapSection(g, assetId, bl, new Rectangle(0, targetRect.height - bl.height, bl.width, bl.height),null,tile);
		} else {
			bl = new Rectangle();
		}

		var br:Rectangle = sourceRects.get("bottom.right");
		if (br != null) {
			paintBitmapSection(g, assetId, br, new Rectangle(targetRect.width - br.width, targetRect.height - br.height, br.width, br.height),null,tile);
		} else {
			br = new Rectangle();
		}

		var b:Rectangle = sourceRects.get("bottom");
		if (b != null) {
			paintBitmapSection(g, assetId, b, new Rectangle(bl.width, targetRect.height - b.height, (targetRect.width - bl.width - br.width), b.height),null,tile);
		} else {
			b = new Rectangle();
		}

		// middle row
		var l:Rectangle = sourceRects.get("left");
		if (l != null) {
			paintBitmapSection(g, assetId, l, new Rectangle(0, tl.height, l.width, (targetRect.height - tl.height - bl.height)),null,tile);
		} else {
			l = new Rectangle();
		}

		var r:Rectangle = sourceRects.get("right");
		if (r != null) {
			paintBitmapSection(g, assetId, r, new Rectangle(targetRect.width - r.width, tr.height, r.width, (targetRect.height - tl.height - bl.height)),null,tile);
		} else {
			r = new Rectangle();
		}

		var m:Rectangle = sourceRects.get("middle");
		if (m != null) {
			paintBitmapSection(g, assetId, m, new Rectangle(l.width, t.height, (targetRect.width - l.width - r.width), (targetRect.height - t.height - b.height)),null,tile);
		} else {
			m = new Rectangle();
		}
	}

	public static function paintBitmapSection(g:Graphics, assetId:String, src:Rectangle, dst:Rectangle, srcData:BitmapData = null, tile:Bool = false, smooth:Bool = false):Void {
		if (srcData == null) {
			srcData = Assets.getBitmapData(assetId);
		}

		g.lineStyle(0, 0, 0);

		src.left = Std.int(src.left);
		src.top = Std.int(src.top);
		src.bottom = Std.int(src.bottom);
		src.right = Std.int(src.right);
		dst.left = Std.int(dst.left);
		dst.top = Std.int(dst.top);
		dst.bottom = Std.int(dst.bottom);
		dst.right = Std.int(dst.right);

		var section:BitmapData = null;
		var cacheId:String = null;
		if (useSectionCache == true && assetId != null) {
			if (sectionCache == null) {
				sectionCache = new Map<String,BitmapData>();
			}
			cacheId = assetId + "_" + src.left + "_" + src.top + "_" + src.width + "_" + src.height;
			section = sectionCache.get(cacheId);
		}

		if (section == null) {
			var fillcolor = #if (neko) {rgb:0x00FFFFFF, a:0 }; #else 0x00FFFFFF; #end
			section = new BitmapData(Std.int(src.width), Std.int(src.height), true, fillcolor);
			section.copyPixels(srcData, src, new Point(0, 0));
			if (useSectionCache == true && cacheId != null) {
				sectionCache.set(cacheId, section);
			}
			bitmapsCreated++;
		}

		var mat:Matrix = new Matrix();
		
		if (!tile) {
			mat = new Matrix();
			mat.scale(dst.width / section.width, dst.height / section.height);
			mat.translate(dst.left, dst.top);			
			g.beginBitmapFill(section, mat, false, false);
		}else {
			mat.identity();
			mat.translate(dst.left, dst.top);
			g.beginBitmapFill(section, mat, true, false);
		}		

        g.drawRect(dst.x, dst.y, dst.width, dst.height);
        g.endFill();
	}
}