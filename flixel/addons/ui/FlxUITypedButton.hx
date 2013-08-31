package flixel.addons.ui;
import flash.display.BitmapData;
import flash.events.Event;
import flixel.addons.ui.IResizable;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxTypedButton;
import flixel.util.FlxPoint;
import openfl.Assets;

/**
 * ...
 * @author 
 */
class FlxUITypedButton<T:FlxSprite> extends FlxTypedButton<T> implements IResizable
{
	public var id:String; 
	public var resize_ratio:Float = -1;
	
	//set these to adjust the bounding box for the sake of clickability
	//if -1 they are ignored
	public var mouse_width:Float = -1;
	public var mouse_height:Float = -1;
	
	public var depressOnClick:Bool = true;
	
	public var has_toggle:Bool = false;
	public var toggled:Bool = false;	

	public function new(X:Float = 0, Y:Float = 0, ?Label:String, ?OnClick:Dynamic) {
		super(X, Y, Label, OnClick);
	}
	
	/**For IResizable:**/
	
	public function get_width():Float { return width; }
	public function get_height():Float { return height; }
		
	public function resize(W:Float, H:Float):Void {
		if (W == 0) { W = 80; }
		if (H == 0) { H = 20; }
		
		if(_slice9_assets != null){		
			loadGraphicSlice9(_slice9_assets, cast W, cast H, _slice9_strings);
		}else {
			if (_no_graphic) {
				var upB:BitmapData;
				if(!has_toggle){
					upB = new BitmapData(cast W, cast (H * 3), true, 0x00000000);				
				}else {					
					upB = new BitmapData(cast W, cast (H * 6), true, 0x00000000);
				}
				loadGraphicsUpOverDown(upB);
			}else {
				//default assets
				loadGraphicSlice9(null, cast W, cast H, null);
			}
		}
	}
		
	public function forceCalcFrame():Void {
		calcFrame();
	}
		
	/**
	 * Provide a list of assets, load states from each one
	 * @param	assets
	 */
	
	public function loadGraphicsMultiple(assets:Array<String>):Void {
		var key:String = "";
				
		if (assets.length <= 3) {
			while (assets.length < 3) { assets.push(null); }
			if (assets[1] == null) { assets[1] = assets[0]; }
			if (assets[2] == null) { assets[2] = assets[1]; }
			key = assets.join(",");			
			var pixels = assembleButtonFrames(Assets.getBitmapData(assets[0]), Assets.getBitmapData(assets[1]), Assets.getBitmapData(assets[2]));
			loadGraphicsUpOverDown(pixels, false, key);
		}else if (assets.length <= 6) {
			while (assets.length < 6) { assets.push(null); }
			if (assets[4] == null) { assets[4] = assets[3]; }
			if (assets[5] == null) { assets[5] = assets[4]; }
			key = assets.join(",");
			var pixels_normal = assembleButtonFrames(Assets.getBitmapData(assets[0]), Assets.getBitmapData(assets[1]), Assets.getBitmapData(assets[2]));
			var pixels_toggle = assembleButtonFrames(Assets.getBitmapData(assets[3]), Assets.getBitmapData(assets[4]), Assets.getBitmapData(assets[5]));
			var pixels = combineToggleBitmaps(pixels_normal, pixels_toggle);
			loadGraphicsUpOverDown(pixels, false, key);
			pixels_normal.dispose();
			pixels_toggle.dispose();
		}
	}
	
	/**
	 * Provide one combined asset, load all 3 state frames from it and infer the width/height
	 * @param	asset
	 */
	
	public function loadGraphicsUpOverDown(asset:Dynamic,for_toggle:Bool=false, ?key:String):Void {
		_slice9_assets = null;
		_slice9_strings = null;
		resize_ratio = -1;
		
		if (for_toggle) {
			has_toggle = true;	//this makes it assume it's 6 images tall
		}		
		
		var upB:BitmapData = null;
		var overB:BitmapData = null;
		var downB:BitmapData = null;

		var bd:BitmapData = null;
		
		if (Std.is(asset, BitmapData)) {
			bd = cast asset;
		}else if (Std.is(asset, String)) {
			bd = Assets.getBitmapData(asset);
		}
		
		upB = grabButtonFrame(asset, FlxButton.NORMAL, has_toggle);
		overB = grabButtonFrame(asset, FlxButton.HIGHLIGHT, has_toggle);
		downB = grabButtonFrame(asset, FlxButton.PRESSED, has_toggle);

		var normalPixels:BitmapData = assembleButtonFrames(upB, overB, downB);
		
		if (has_toggle) {
			upB = grabButtonFrame(asset, FlxButton.NORMAL + 3, true);
			overB = grabButtonFrame(asset, FlxButton.HIGHLIGHT + 3, true);
			downB = grabButtonFrame(asset, FlxButton.PRESSED + 3, true);
			
			var togglePixels:BitmapData = assembleButtonFrames(upB, overB, downB);
			var combinedPixels:BitmapData = combineToggleBitmaps(normalPixels, togglePixels);
			
			normalPixels.dispose(); normalPixels = null;
			togglePixels.dispose(); togglePixels = null;
			
			loadGraphic(combinedPixels, true, false, upB.width, upB.height, false, key);
		}else {			
			loadGraphic(normalPixels, true, false, upB.width, upB.height, false, key);
		}
		
		
	}
	
	/**Graphics chopping functions**/
	
	/**
	 * Loads graphics from one or more sprites, and if slice9 is not null, 9-slice scales them.
	 * @param	assets an array of asset file ids, ready to pass into Assets.getBitmapData();
	 * @param	W width of button frame
	 * @param	H height of button frame
	 * @param	slice9 an array of slice9 strings, ie:"6,6,11,11" that specifies upper-left and bottom-right slice9 pixel points
	 */
	
	public function loadGraphicSlice9(assets:Array<String>=null,W:Int=80,H:Int=20,slice9:Array<String>=null,Resize_Ratio:Float=-1,isToggle:Bool=false):Void{
	
		has_toggle = isToggle;
		
		resize_ratio = Resize_Ratio;	
		
		_slice9_assets = assets;
		_slice9_strings = slice9;
		
		var key:String = null;
		
		var arr_bmpData:Array<BitmapData> = [];		
		var arr_flx9:Array<FlxUI9SliceSprite> = [];
		
		if (W == 0) {
			W = 80;
		}
		if (H == 0) {
			H = 20;
		}
		
		if (assets == null) {
			//default asset
			if(!isToggle){
				assets = [FlxUIAssets.IMG_BUTTON];
				slice9 = [FlxUIAssets.SLICE9_BUTTON];
			}else {
				assets = [FlxUIAssets.IMG_BUTTON_TOGGLE];
				slice9 = [FlxUIAssets.SLICE9_BUTTON_TOGGLE];
			}
		}
		
		if (!has_toggle && assets.length <= 3) {
			//3 states - assume normal button
			arr_bmpData = [null, null, null];
			arr_flx9 = [null, null, null];
		}else {
			//6 states - assume toggle button
			has_toggle = true;
			arr_bmpData = [null, null, null, null, null, null];
			arr_flx9 = [null, null, null, null, null, null];
		}
		
		_flashRect2.width = W;
		_flashRect2.height = H;
				
		if(assets.length == 1){								//loading everything from one graphic
			var all = Assets.getBitmapData(assets[0]);		//load the image
			
			if(all.height > H){								//looks like a multi-frame graphic
				for (i in 0...arr_bmpData.length) {
					arr_bmpData[i] = grabButtonFrame(all, i, has_toggle);		//get each button frame					
				}									
				
				if (slice9 != null && slice9[0] != "") {		//9slicesprites					
					
					//Scale each 9slicesprite
					for (i in 0...arr_bmpData.length) {
						arr_flx9[i] = new FlxUI9SliceSprite(0, 0, arr_bmpData[i], _flashRect2, slice9[0],false,false,assets[0]+":"+i,resize_ratio);
					}
			
					//grab the pixel data:
					for (i in 0...arr_bmpData.length) {
						arr_bmpData[i] = arr_flx9[i].pixels;						
					}
						
					//in case the resize_ratio resulted in different dimensions
					W = arr_bmpData[0].width;
					H = arr_bmpData[0].height;
				}
			}else {					//just one frame
				arr_bmpData[0] = all;			
			}
		}else {						//loading multiple image files
			
			//ensure asset list is at least 3 long, fill with blanks if necessary
			if(!has_toggle){
				while (assets.length < 3) {		
					assets.push("");
				}
			}else {
				while (assets.length < 6) {
					assets.push("");
				}
			}
			
			if (assets[0] != "") {
				if (slice9 != null && slice9[0] != "") {	//load as 9slicesprites
						
					//make at least 3(or 6) long, fill with blanks if necessary
					while (slice9.length < assets.length) {
						slice9.push("");
					}
					
					arr_flx9[0] = new FlxUI9SliceSprite(0, 0, assets[0],_flashRect2, slice9[0],false,false,"",resize_ratio);
					arr_bmpData[0] = arr_flx9[0].pixels;
					
					for (i in 1...assets.length) {
						if (assets[i] != "") {
							arr_flx9[i] = new FlxUI9SliceSprite(0, 0, assets[i], _flashRect2, slice9[i],false,false,"",resize_ratio);
							arr_bmpData[i] = arr_flx9[i].pixels;							
						}						
					}
					
					//in case the resize_ratio resulted in different dimensions
					W = arr_bmpData[0].width;
					H = arr_bmpData[0].height;
				
					
				}else {			//load as static buttons						
					key = "";
					for(i in 0...assets.length){					
						arr_bmpData[i] = Assets.getBitmapData(assets[i]);
						key += assets[i];
						if (i < assets.length - 1) {
							key += ",";
						}
					}	
					W = arr_bmpData[0].width;
					H = arr_bmpData[0].height;
				}
			}else {
				if (W == 0) { W = 80; }
				if (H == 0) { H = 20; }
				arr_bmpData[0] = new BitmapData(W, H * 3, true, 0x00000000);
				key = "Blank_" + W + "x" + (H * 3);
				_no_graphic = true;
			}
		}
		
		var normalPixels:BitmapData = assembleButtonFrames(arr_bmpData[0], arr_bmpData[1], arr_bmpData[2]);
			
		if(!has_toggle){
			loadGraphic(normalPixels, true, false, W, H, false, key);
		}else {
 			var togglePixels:BitmapData = assembleButtonFrames(arr_bmpData[3], arr_bmpData[4], arr_bmpData[5]);
			var combinedPixels:BitmapData = combineToggleBitmaps(normalPixels, togglePixels);
						
			//cleanup
			normalPixels.dispose(); normalPixels = null;
			togglePixels.dispose(); togglePixels = null;

			loadGraphic(combinedPixels, true, false, W, H);
		}
		
		//cleanup
		for (i in 0...arr_bmpData.length) {
			if (arr_flx9[i] != null) {
				arr_flx9[i].destroy();
				arr_flx9[i] = null;
			}
		}
		while (arr_flx9.length > 0) { arr_flx9.pop(); } arr_flx9 = null;
		while (arr_bmpData.length > 0) { arr_bmpData.pop(); } arr_bmpData = null;
	}
	
	
	
	/***UTILITY FUNCTIONS***/
	
	/**
	 * Give me a sprite with three vertically stacked button frames and the 
	 * frame index you want and I'll slice it off for you
	 * @param	all_frames
	 * @param	button_state
	 * @return
	 */
	
	public function grabButtonFrame(all_frames:BitmapData, button_state:Int, for_toggle:Bool=false):BitmapData{
		var h:Int;
		if (!for_toggle) {
			h = cast all_frames.height / 3;
		}else {
			h = cast all_frames.height / 6;
		}
		var w:Int = cast all_frames.width;
		var pixels:BitmapData = new BitmapData(w,h);
		_flashRect.x = 0;
		_flashRect.y = button_state * h;
		_flashRect.width = w;
		_flashRect.height = h;		
		pixels.copyPixels(all_frames, _flashRect, _flashPointZero);
		return pixels;
	}
	
	/**
	 * Combines two stacked button images for a toggle button
	 * @param	normal
	 * @param	toggle
	 * @return
	 */
	
	public function combineToggleBitmaps(normal:BitmapData,toggle:BitmapData):BitmapData {
		var combined:BitmapData = new BitmapData(normal.width, normal.height + toggle.height);
		
		combined.copyPixels(normal, normal.rect, _flashPointZero);
		_flashPoint.x = 0;
		_flashPoint.y = normal.height;
		combined.copyPixels(toggle, toggle.rect, _flashPoint);
		
		return combined;
	}
	
	/**
	 * Give me three bitmapdatas and I'll return an assembled button bitmapdata for you.
	 * If overB or downB are missing, it will not include those frames.
	 * @param	upB
	 * @param	overB
	 * @param	downB
	 * @return
	 */
	
	public function assembleButtonFrames(upB:BitmapData, overB:BitmapData, downB:BitmapData):BitmapData {
		var pixels:BitmapData;
		
		if (overB != null) {
			if (downB != null) {
				pixels = new BitmapData(upB.width, upB.height * 3);						
			}else {				
				pixels = new BitmapData(upB.width, upB.height * 2);						
			}
		}else {
			pixels = new BitmapData(upB.width, upB.height);						
		}
		
		pixels.copyPixels(upB, upB.rect, _flashPointZero);
		
		if(overB != null){
			_flashPoint.x = 0;
			_flashPoint.y = upB.height;		
			pixels.copyPixels(overB, overB.rect, _flashPoint);
			if (downB != null) {
				_flashPoint.y = upB.height * 2;
				pixels.copyPixels(downB, downB.rect, _flashPoint);		
			}
		}
		
		return pixels;
	}
	
	/**
	 * Overriden to allow the user to manually specify where the clickable regions are
	 * @param	point
	 * @param	InScreenSpace
	 * @param	?Camera
	 * @return
	 */
	
	override public function overlapsPoint(point:FlxPoint, InScreenSpace:Bool = false, ?Camera:FlxCamera):Bool
	{
		var mw:Float = width;
		var mh:Float = height;
		if (mouse_width != -1) { 
			mw = mouse_width;
		}
		if (mouse_height != -1) {
			mh = mouse_height;
		}
		
		if (scale.x == 1 && scale.y == 1)
		{
			if (!InScreenSpace)
			{
				return (point.x > x) && (point.x < x + mw) && (point.y > y) && (point.y < y + mh);
			}
			
			if (Camera == null)
			{
				Camera = FlxG.camera;
			}
			var X:Float = point.x - Camera.scroll.x;
			var Y:Float = point.y - Camera.scroll.y;
			getScreenXY(_point, Camera);
			return (X > _point.x) && (X < _point.x + mw) && (Y > _point.y) && (Y < _point.y + mh);

		}
		
		if (!InScreenSpace)
		{
			return (point.x > x - 0.5 * mw * (scale.x - 1)) && (point.x < x + mw + 0.5 * mw * (scale.x - 1)) && (point.y > y - 0.5 * mh * (scale.y - 1)) && (point.y < y + mh + 0.5 * mh * (scale.y - 1));
		}
		
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		var X:Float = point.x - Camera.scroll.x;
		var Y:Float = point.y - Camera.scroll.y;
		getScreenXY(_point, Camera);
		return (X > _point.x - 0.5 * mw * (scale.x - 1)) && (X < _point.x + mw + 0.5 * mw * (scale.x - 1)) && (Y > _point.y - 0.5 * mh * (scale.y - 1)) && (Y < _point.y + mh + 0.5 * mh * (scale.y - 1));
	}
	
	public override function updateButton():Void {
		super.updateButton();
				
		// Then pick the appropriate frame of animation
		if(toggled){
			frame = 3 + status;
		}else {
			frame = status;
		}
	}

	/*********PRIVATE************/
	
	private var _no_graphic:Bool = false;
	
	//if you're doing 9-slice resizing:
	private var _slice9_strings:Array<String>;	//the 9-slice scaling rules for the original assets
	private var _slice9_assets:Array<String>;	//the asset id's of the original 9-slice scale assets
	
	private override function onMouseUp(event:Event):Void
	{
		if (!exists || !visible || !active || (status != FlxButton.PRESSED)) {
			return;
		}		
		toggled = !toggled;
		super.onMouseUp(event);
	}
}