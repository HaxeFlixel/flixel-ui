package flixel.addons.ui;
import flash.geom.Point;
import flash.geom.Matrix;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Rectangle;
import flash.display.BitmapData;
import openfl.Assets;
import flixel.FlxObject;
import flixel.FlxSprite;

/**
 * @author Lars Doucet
 */

class FlxUI9SliceSprite extends FlxSprite implements IResizable
{
	
	private static var bitmapsCreated:Int = 0; // for debug

	private static var _canvas:Sprite;	//drives the 9-slice drawing
	
	private static var useSectionCache:Bool = true;
	private static var sectionCache:Map<String,BitmapData>;
	
	private var _slice9:String = "";
	private var _tile:Bool = false;
	private var _smooth:Bool = false;
	private var _asset_id:String = "";
	
	private var _raw_pixels:BitmapData;
	
	private var _resize_ratio:Float = -1; 	//resize ratio to force when resizing, == (W/H)
	
	/** 
	 * @param	X	X position of final sprite
	 * @param	Y	Y position of final sprite
	 * @param	Graphic	Asset
	 * @param	Rect	Width/Height of the final scaled sprite
	 * @param	slice9	"x1,y1,x2,y2" : 2 points (upper-left middle and lower-right middle) that define the 9-slice grid
	 * @param	tile	Whether to tile the middle pieces or stretch them (default is false --> stretch)
	 * @param	smooth	When stretching, whether to smooth middle pieces (default false)
	 * @param 	id	if Graphic is a BitmapData, manually specify its original source id, if any
	 * @param   ratio	Resize ratio to force, if desired (W/H)
	 */
	
	public function new(X:Float, Y:Float, Graphic:Dynamic, Rect:Rectangle, slice9:String="", tile:Bool=false, smooth:Bool=false, id:String="",ratio:Float=-1) 
	{
		super(X, Y, null);
		
		_slice9 = slice9;
		_tile = tile;
		_smooth = smooth;
				
		_asset_id = "";
		
		if (Graphic == null) {
			Graphic = FlxUIAssets.IMG_CHROME;
		}
		
		if(Std.is(Graphic,String)){
			_asset_id = Graphic;
			_raw_pixels = null;
		}else if (Std.is(Graphic, BitmapData)) {
			_asset_id = id;
			_raw_pixels = cast Graphic;
		}
		
		_resize_ratio = ratio;
				
		resize(Rect.width, Rect.height);
	}
	
	public var resize_ratio(get, set):Float;
	public function get_resize_ratio():Float { return _resize_ratio;}
	public function set_resize_ratio(r:Float):Float { _resize_ratio = r; return r;}

	//For IResizable
	public function get_width():Float { return width; }
	public function get_height():Float { return height; }
	
	public function resize(w:Float, h:Float):Void {		
		
		if(_resize_ratio > 0){
			var effective_ratio:Float = (w / h);
			if (Math.abs(effective_ratio - _resize_ratio) > 0.0001) {
				h = w * (1 / _resize_ratio);
			}
		}
		
		if (_slice9 == "" || _slice9 == null) {
			_slice9 = "4,4,7,7";
		}
		
		if(_canvas == null){
			_canvas = new Sprite();		
		}
		
		_canvas.graphics.clear();
		
		_flashRect2.width = w;
		_flashRect2.height = h;
		paintScale9(_canvas.graphics, _asset_id, _slice9, _flashRect2, _tile, _smooth, _raw_pixels);
		
		var iw:Int = Std.int(w); 
		if (iw < 1) { 
			iw = 1;
		}
		var ih:Int = Std.int(h); 
		if (ih < 1) { 
			ih = 1;
		}
		
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
	 * @param	assetID id of bitmapdata asset you are scaling
	 * @param	scale9 string defining 2 points that define the grid as "x1,y1,x2,y2" (upper-interior-left, lower-interior-right)
	 * @param	rc rectangle object defining how big you want to scale it to
	 * @param	tile if false, scale middle pieces, if true, tile them (default false)
	 * @param 	smooth whether to smooth when scaling or not (default false)
	 * @param 	raw raw pixels supplied, if any
	 */
	
	public static function paintScale9(g:Graphics, assetID:String, scale9:String, rc:Rectangle, tile:Bool=false, smooth:Bool = false, raw:BitmapData=null):Void {
		if (scale9 != null) { // create parts
			
			var w:Int;
			var h:Int;
			if (raw == null) {
				w = Assets.getBitmapData(assetID).width;
				h = Assets.getBitmapData(assetID).height;
			}else {
				w = raw.width;
				h = raw.height;
			}
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

			paintCompoundBitmap(g, assetID, rects, rc, tile,false,raw);
		}
	}

	public static function paintCompoundBitmap(g:Graphics, assetID:String, sourceRects:Map<String,Rectangle>, targetRect:Rectangle, tile:Bool=false, smooth:Bool = false, raw:BitmapData=null):Void {
		var fillcolor = #if (neko) { rgb:0x00FFFFFF, a:0 }; #else 0x00FFFFFF; #end
		targetRect.left = Std.int(targetRect.left);
		targetRect.top = Std.int(targetRect.top);
		targetRect.right = Std.int(targetRect.right);
		targetRect.bottom = Std.int(targetRect.bottom);

		// top row
		var tl:Rectangle = sourceRects.get("top.left");
		if (tl != null) {
			paintBitmapSection(g, assetID, tl, new Rectangle(0, 0, tl.width, tl.height),null,tile,false,raw);
		} else {
			tl = new Rectangle();
		}

		var tr:Rectangle = sourceRects.get("top.right");
		if (tr != null) {
			paintBitmapSection(g, assetID, tr, new Rectangle(targetRect.width - tr.width, 0, tr.width, tr.height),null,tile,false,raw);
		} else {
			tr = new Rectangle();
		}

		var t:Rectangle = sourceRects.get("top");
		if (t != null) {
			paintBitmapSection(g, assetID, t, new Rectangle(tl.width, 0, (targetRect.width - tl.width - tr.width), t.height),null,tile,false,raw);
		} else {
			t = new Rectangle();
		}

		// bottom row
		var bl:Rectangle = sourceRects.get("bottom.left");
		if (bl != null) {
			paintBitmapSection(g, assetID, bl, new Rectangle(0, targetRect.height - bl.height, bl.width, bl.height),null,tile,false,raw);
		} else {
			bl = new Rectangle();
		}

		var br:Rectangle = sourceRects.get("bottom.right");
		if (br != null) {
			paintBitmapSection(g, assetID, br, new Rectangle(targetRect.width - br.width, targetRect.height - br.height, br.width, br.height),null,tile,false,raw);
		} else {
			br = new Rectangle();
		}

		var b:Rectangle = sourceRects.get("bottom");
		if (b != null) {
			paintBitmapSection(g, assetID, b, new Rectangle(bl.width, targetRect.height - b.height, (targetRect.width - bl.width - br.width), b.height),null,tile,false,raw);
		} else {
			b = new Rectangle();
		}

		// middle row
		var l:Rectangle = sourceRects.get("left");
		if (l != null) {
			paintBitmapSection(g, assetID, l, new Rectangle(0, tl.height, l.width, (targetRect.height - tl.height - bl.height)),null,tile,false,raw);
		} else {
			l = new Rectangle();
		}

		var r:Rectangle = sourceRects.get("right");
		if (r != null) {
			paintBitmapSection(g, assetID, r, new Rectangle(targetRect.width - r.width, tr.height, r.width, (targetRect.height - tl.height - bl.height)),null,tile,false,raw);
		} else {
			r = new Rectangle();
		}

		var m:Rectangle = sourceRects.get("middle");
		if (m != null) {
			paintBitmapSection(g, assetID, m, new Rectangle(l.width, t.height, (targetRect.width - l.width - r.width), (targetRect.height - t.height - b.height)),null,tile,false,raw);
		} else {
			m = new Rectangle();
		}
	}

	public static function paintBitmapSection(g:Graphics, assetId:String, src:Rectangle, dst:Rectangle, srcData:BitmapData = null, tile:Bool = false, smooth:Bool = false, raw:BitmapData=null):Void {
		if (srcData == null) {
			if (raw != null) {
				srcData = raw;
			}else{
				srcData = Assets.getBitmapData(assetId);
			}
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
			var fillcolor = 0x00FFFFFF;
			section = new BitmapData(Std.int(src.width), Std.int(src.height), true, fillcolor);
			section.copyPixels(srcData, src, new Point(0,0));
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