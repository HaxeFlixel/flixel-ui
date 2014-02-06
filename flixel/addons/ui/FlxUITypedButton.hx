package flixel.addons.ui;

import flash.display.BitmapData;
import flash.errors.Error;
import flixel.addons.ui.interfaces.IFlxUIButton;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.interfaces.IHasParams;
import flixel.addons.ui.interfaces.IResizable;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.ui.FlxButton;
import flixel.ui.FlxTypedButton;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxPoint;
import flixel.util.FlxStringUtil;
import openfl.Assets;

class FlxUITypedButton<T:FlxSprite> extends FlxTypedButton<T> implements IResizable implements IFlxUIWidget implements IFlxUIButton implements IHasParams
{
	public var id:String; 
	public var resize_ratio:Float = -1;
	public var resize_point:FlxPoint = null;
	public var tile:Int = FlxUI9SliceSprite.TILE_NONE;
	
	public var has_toggle:Bool = false;
	public var toggled:Bool = false;
	
	public var uiEventCallback:String->IFlxUIWidget->Dynamic->Void;
	
	//Change these to something besides 0 to make the label use that color
	//when that state is active
	public var up_color:Int = 0;
	public var over_color:Int = 0;
	public var down_color:Int = 0;
	
	public var up_toggle_color:Int = 0;
	public var over_toggle_color:Int = 0;
	public var down_toggle_color:Int = 0;
	
	public static inline var CLICK_EVENT:String = "click_button";
	public static inline var OVER_EVENT:String = "over_button";
	public static inline var DOWN_EVENT:String = "down_button";
	public static inline var OUT_EVENT:String = "out_button";
	
	public var skipButtonUpdate(default, set):Bool = false;
	public function set_skipButtonUpdate(b:Bool):Bool {
		skipButtonUpdate = b;
		return skipButtonUpdate;
	}
	
	public var params(default, set):Array<Dynamic>;
	public function set_params(p:Array <Dynamic>):Array<Dynamic>{
		params = p;
		return params;
	}
	
	public override function destroy():Void {
		uiEventCallback = null;
		resize_point = null;
		super.destroy();
	}
	
	/**
	 * Creates a new <code>FlxUITypedButton</code> object with a gray background.
	 * 
	 * @param	X			The X position of the button.
	 * @param	Y			The Y position of the button.
	 * @param	Label		The text that you want to appear on the button.
	 * @param	OnClick		The function to call whenever the button is clicked.
	 */
	public function new(X:Float = 0, Y:Float = 0, ?Label:String, ?OnClick:Void->Void)
	{
		super(X, Y, Label, OnClick);
		
		_centerLabelOffset = new FlxPoint(0, 0);
		
		//By default, the button depresses the label by 1 pixel when pressed
		labelOffsets[FlxButton.HIGHLIGHT].x = 0;
		labelOffsets[FlxButton.HIGHLIGHT].y = 0;
		
		labelOffsets[FlxButton.PRESSED].x = 0;
		labelOffsets[FlxButton.PRESSED].y = 1;
		
		labelOffsets[FlxButton.NORMAL].x = 0;
		labelOffsets[FlxButton.NORMAL].y = 0;
		
		labelAlphas[FlxButton.HIGHLIGHT] = 1;
		labelAlphas[FlxButton.PRESSED] = 1;
		labelAlphas[FlxButton.NORMAL] = 1;
	}
	
	public override function update():Void {
		super.update();
		
		// Label positioning
		if (label != null)
		{
			label.x = x;
			label.y = y;
			
			label.x += _centerLabelOffset.x;	//CENTER the label offsets using the private variable
			label.y += _centerLabelOffset.y;
			
			label.x += labelOffsets[status].x;	//apply status-specific user label offset using the public variable
			label.y += labelOffsets[status].y;
			
			label.scrollFactor = scrollFactor;
		}
		
		if (animation != null){
			// Then pick the appropriate frame of animation
			if (toggled){
				animation.frameIndex =  3 + status;
			}else {
				animation.frameIndex = status;
			}
		}
	}
	
	public function resize(W:Float, H:Float):Void {
		var old_width:Float = width;
		var old_height:Float = height;
		
		var old_offx:Float = 0;
		var old_offy:Float = 0;
		if (label != null) {
			autoCenterLabel();						//reset to center position
		}
		
		if (W == 0) { W = 80; }
		if (H == 0) { H = 20; }
		
		if(_slice9_assets != null){
			loadGraphicSlice9(_slice9_assets, Std.int(W), Std.int(H), _slice9_arrays,tile,resize_ratio,has_toggle,_src_w,_src_h,_frame_indeces);
		} else {
			if (_no_graphic) {
				var upB:BitmapData;
				if(!has_toggle){
					upB = new BitmapData(Std.int(W), Std.int(H * 3), true, 0x00000000);
				}else {
					upB = new BitmapData(Std.int(W), Std.int(H * 6), true, 0x00000000);
				}
				loadGraphicsUpOverDown(upB);
			}else {
				//default assets
				loadGraphicSlice9(null, Std.int(W), Std.int(H), null,tile);
			}
		}
		
		autoCenterLabel();			//center based on new dimensions
		
		var diff_w:Float = width - old_width;
		var diff_h:Float = height - old_height;
		
		if (resize_point != null){
			var delta_x:Float = diff_w * resize_point.x;
			var delta_y:Float = diff_h * resize_point.y;
			x -= delta_x;
			y -= delta_y;
		}
	}
	
	/**
	 * Provide a list of assets, load states from each one
	 * @param	assets
	 * @param   key string key for caching (optional)
	 */
	
	public function loadGraphicsMultiple(assets:Array<String>, Key:String = ""):Void {
		var key:String = "";
		
		if (assets.length <= 3) {
			while (assets.length < 3) { assets.push(null); }
			if (assets[1] == null) { assets[1] = assets[0]; }
			if (assets[2] == null) { assets[2] = assets[1]; }
			key = assets.join(",");			
			var pixels = assembleButtonFrames(Assets.getBitmapData(assets[0]), Assets.getBitmapData(assets[1]), Assets.getBitmapData(assets[2]));
			if (Key != "")
			{
				key = Key; // replaces generated key with provided key.
			}
			loadGraphicsUpOverDown(pixels, false, key);
		}else if (assets.length <= 6) {
			while (assets.length < 6) { assets.push(null); }
			if (assets[4] == null) { assets[4] = assets[3]; }
			if (assets[5] == null) { assets[5] = assets[4]; }
			key = assets.join(",");
			if (Key != "")
			{
				key = Key; // replaces generated key with provided key.
			}
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
	 * @param	asset graphic to load
	 * @param   for_toggle whether this is for a toggle button or not
	 * @param   key string key for caching (optional)
	 */
	
	public function loadGraphicsUpOverDown(asset:Dynamic, for_toggle:Bool=false, ?key:String):Void {
		_slice9_assets = null;
		_slice9_arrays = null;
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
	 * NOTE: If you only provide 1 asset, you MUST define src_w and src_h
	 * @param	assets an array of asset file ids, ready to pass into Assets.getBitmapData();
	 * @param	W width of button frame
	 * @param	H height of button frame
	 * @param	slice9 an array of slice9 int-arrays, ie:[6,6,11,11] that specifies upper-left and bottom-right slice9 pixel points
	 * @param	tile	Whether to tile the middle pieces or stretch them (default is false --> stretch)
	 * @param	Resize_Ratio ratio to force during resizing (W/H). -1 means ignore
	 * @param	isToggle whether this is for a toggle button or not
	 * @param 	src_w width of source button frame (optional, inferred if not defined)
	 * @param 	src_h height of source button frame (optional, inferred if not defined)
	 * @param	frame_indeces array of which image frames go with which button frames (optional)
	 */
	
	public function loadGraphicSlice9(assets:Array<String>=null,W:Int=80,H:Int=20,slice9:Array<Array<Int>>=null,Tile:Int=FlxUI9SliceSprite.TILE_NONE,Resize_Ratio:Float=-1,isToggle:Bool=false,src_w:Int=0,src_h:Int=0,frame_indeces:Array<Int>=null):Void{
	
		if (src_w != 0) {
			_src_w = src_w;
		}
		if (src_h != 0) {
			_src_h = src_h;
		}
		
		tile = Tile;
		
		has_toggle = isToggle;
		
		resize_ratio = Resize_Ratio;
		
		_slice9_assets = assets;
		_slice9_arrays = slice9;
		
		var key:String = null;
		
		var arr_bmpData:Array<BitmapData> = [];
		var arr_flx9:Array<FlxUI9SliceSprite> = [];
		
		//Validate frame_indeces array
		if (frame_indeces == null) {
			//if it doesn't exist, create default setup
			if (has_toggle) { frame_indeces = [0, 1, 2, 3, 4, 5];}
					   else { frame_indeces = [0, 1, 2];}
		}else {
			var max_index:Int = 2;
			if (has_toggle) { max_index = 5;}
			
			//if it's less than 3 (or 6 for toggle), add missing entries
			//and use the default frame index to fill the gap 
			//(ie, [a,b] --> [a,b,2])
			while (frame_indeces.length < max_index + 1) {
				frame_indeces.push(frame_indeces.length - 1);
			}			
			
			//make sure indeces are all within bounds
			for (i in 0...frame_indeces.length) {
				if (frame_indeces[i] > 5) { 
					frame_indeces[i] = 5; 
				}else if (frame_indeces[i] < 0) {
					frame_indeces[i] = 0;
				}
			}
		}
		
		_frame_indeces = frame_indeces;
		
		if (W == 0) {
			W = 80;
		}
		if (H == 0) {
			H = 20;
		}
		
		if (assets == null) {
			var temp:BitmapData;
			
			//default asset
			if(!isToggle){
				assets = [FlxUIAssets.IMG_BUTTON];
				slice9 = [FlxStringUtil.toIntArray(FlxUIAssets.SLICE9_BUTTON)];
				temp = Assets.getBitmapData(assets[0]);
				_src_w = Std.int(temp.width);
				_src_h = Std.int(temp.height / 3);				//calc default source width/height
			}else {
				assets = [FlxUIAssets.IMG_BUTTON_TOGGLE];
				slice9 = [FlxStringUtil.toIntArray(FlxUIAssets.SLICE9_BUTTON_TOGGLE)];
				temp = Assets.getBitmapData(assets[0]);
				_src_w = Std.int(temp.width);
				_src_h = Std.int(temp.height / 6);				//calc default source width/height
			}
			
			temp = null;
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
			
			if (_src_w == 0 || _src_h == 0) {
				throw new Error("Ambiguous situation! If you only provide one asset, you MUST provide src_w and src_h. Otherwise I can't tell if it's a stacked set of frames or a single frame.");
			}else{
			
				if(all.height > _src_h){						//looks like a multi-frame graphic
					for (i in 0...arr_bmpData.length) {
						arr_bmpData[i] = grabButtonFrame(all, i, has_toggle,_src_w, _src_h);		//get each button frame
					}
					
					if (slice9 != null && slice9[0] != []) {		//9slicesprites
						
						//Scale each 9slicesprite
						for (i in 0...arr_bmpData.length) {
							arr_flx9[i] = new FlxUI9SliceSprite(0, 0, arr_bmpData[i], _flashRect2, slice9[0], tile, false, assets[0] + ":" + i , resize_ratio);
							arr_flx9[i].resize_point = resize_point;
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
				if (slice9 != null && slice9[0] != []) {	//load as 9slicesprites
						
					//make at least 3(or 6) long, fill with blanks if necessary
					while (slice9.length < assets.length) {
						slice9.push(null);
					}
					
					arr_flx9[0] = new FlxUI9SliceSprite(0, 0, assets[0],_flashRect2, slice9[0], tile, false,"",resize_ratio);
					arr_bmpData[0] = arr_flx9[0].pixels;
					
					for (i in 1...assets.length) {
						if (assets[i] != "") {
							arr_flx9[i] = new FlxUI9SliceSprite(0, 0, assets[i], _flashRect2, slice9[i], tile, false,"",resize_ratio);
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
		
		var normalPixels:BitmapData = assembleButtonFrames(arr_bmpData[frame_indeces[0]], 
														   arr_bmpData[frame_indeces[1]], 
														   arr_bmpData[frame_indeces[2]]);
														   
		if(!has_toggle){
			loadGraphic(normalPixels, true, false, W, H, false, key);
		}else {
 			var togglePixels:BitmapData = assembleButtonFrames(arr_bmpData[frame_indeces[3]], 
															   arr_bmpData[frame_indeces[4]], 
															   arr_bmpData[frame_indeces[5]]);
															   
			var combinedPixels:BitmapData = combineToggleBitmaps(normalPixels, togglePixels);
						
			//cleanup
			normalPixels.dispose(); normalPixels = null;
			togglePixels.dispose(); togglePixels = null;
			
			loadGraphic(combinedPixels, true, false, W, H);
		}
		
		//cleanup
		for (i in 0...arr_flx9.length) {
			if (arr_flx9[i] != null) {
				arr_flx9[i].destroy();
				arr_flx9[i] = null;
			}
		}
		while (arr_flx9.length > 0) { arr_flx9.pop(); } arr_flx9 = null;
		while (arr_bmpData.length > 0) { arr_bmpData.pop(); } arr_bmpData = null;
	}
	
	/**
	 * Sets labelOffset to center the label horizontally and vertically
	 */
	
	public function autoCenterLabel():Void {
		if (label != null) {
			var offX:Float = 0;
			var offY:Float = 0;
			
			offX = (width - label.width);
			
			if (Std.is(label, FlxUIText)) {
				var tlabel:FlxUIText = cast label;
				offY = (height - tlabel.height) / 2;
			}else {
				offX = (width - label.width) / 2;
				offY = (height - label.height)/2;
			}
			
			_centerLabelOffset.x = offX;
			_centerLabelOffset.y = offY;
			
			if (Std.is(label, FlxUIText)) {
				var t:FlxUIText = cast label;
			}
		}
	}
	
	
	/***UTILITY FUNCTIONS***/
	
	
	
	/**
	 * Give me a sprite with three vertically stacked button frames and the 
	 * frame index you want and I'll slice it off for you
	 * @param	all_frames
	 * @param	button_state
	 * @param	for_toggle
	 * @param	src_w
	 * @param	src_h
	 * @return
	 */
	
	public function grabButtonFrame(all_frames:BitmapData, button_state:Int, for_toggle:Bool=false, src_w:Int=0, src_h:Int=0):BitmapData{
		var h:Int = src_h;
		if(h == 0){
			if (!for_toggle) {
				h = Std.int(all_frames.height / 3);
			}else {
				h = Std.int(all_frames.height / 6);
			}
		}
		var w:Int = src_w;
		if (w == 0) {
			w = cast all_frames.width;
		}
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
	
	public override function updateButton():Void {
		if (!skipButtonUpdate){
			super.updateButton();
		}
	}
	
	override private function onUpHandler():Void
	{
		toggled = !toggled;
		super.onUpHandler();
		if(label != null){
			label.color = (toggled) ? up_toggle_color : up_color;
		}
		if (uiEventCallback != null) {
			uiEventCallback(CLICK_EVENT, this, params);
		}
	}
	
	override private function onDownHandler():Void
	{
		super.onDownHandler();
		if(label != null){
			label.color = (toggled) ? down_toggle_color : down_color;
		}
		if (uiEventCallback != null) {
			uiEventCallback(DOWN_EVENT, this, params);
		}
	}
	
	override private function onOverHandler():Void
	{
		super.onOverHandler();
		if(label != null){
			label.color = (toggled) ? over_toggle_color : over_color;
		}
		if (uiEventCallback != null) {
			uiEventCallback(OVER_EVENT, this, params);
		}
	}
	
	override private function onOutHandler():Void
	{
		super.onOutHandler();
		if(label != null){
			label.color = (toggled) ? up_toggle_color : up_color;
		}
		if (uiEventCallback != null) {
			uiEventCallback(OUT_EVENT, this, params);
		}
	}

	/*********PRIVATE************/
	
	private var _no_graphic:Bool = false;
	
	private var _src_w:Int = 0;	//frame size of the source image. If 0, make an inferred guess.
	private var _src_h:Int = 0;
	
	private var _frame_indeces:Array<Int>;
	
	//if you're doing 9-slice resizing:
	private var _slice9_arrays:Array<Array<Int>>;	//the 9-slice scaling rules for the original assets
	private var _slice9_assets:Array<String>;		//the asset id's of the original 9-slice scale assets
	
	private var _centerLabelOffset:FlxPoint = null;	//this is the offset necessary to center ALL the labels
}
