package flixel.addons.ui;

import flash.display.BitmapData;
import flash.errors.Error;
import flixel.addons.ui.FlxUI.UIEventCallback;
import flixel.addons.ui.interfaces.ICursorPointable;
import flixel.addons.ui.interfaces.IFlxUIButton;
import flixel.addons.ui.interfaces.IFlxUIClickable;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.interfaces.IHasParams;
import flixel.addons.ui.interfaces.IResizable;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.input.FlxInput;
import flixel.input.IFlxInput;
import flixel.ui.FlxButton;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxPoint;
import flixel.util.FlxStringUtil;
import openfl.Assets;
import flixel.system.FlxAssets.FlxGraphicAsset;

class FlxUITypedButton<T:FlxSprite> extends FlxTypedButton<T> implements IFlxUIButton implements IResizable implements IFlxUIWidget implements IFlxUIClickable
		implements IHasParams implements ICursorPointable
{
	public var name:String;
	public var resize_ratio:Float = -1;

	// whether the resize_ratio means X in terms of Y, or Y in terms of X
	public var resize_ratio_axis:Int = FlxUISprite.RESIZE_RATIO_Y;

	public var resize_point:FlxPoint = null;
	public var tile:Int = FlxUI9SliceSprite.TILE_NONE;

	public var has_toggle:Bool = false;
	public var toggled(default, set):Bool = false;

	public function set_toggled(b:Bool):Bool
	{
		toggled = b;
		updateStatusAnimation();
		return toggled;
	}

	public var broadcastToFlxUI:Bool = true;

	private var inputOver:FlxInput<Int>;

	public var justMousedOver(get, never):Bool;
	public var mouseIsOver(get, never):Bool;
	public var mouseIsOut(get, never):Bool;
	public var justMousedOut(get, never):Bool;

	private inline function get_justMousedOver():Bool
	{
		return inputOver.justPressed;
	}

	private inline function get_justMousedOut():Bool
	{
		return inputOver.justReleased;
	}

	private inline function get_mouseIsOver():Bool
	{
		return inputOver.pressed;
	}

	private inline function get_mouseIsOut():Bool
	{
		return inputOver.released;
	}

	// Change these to something besides 0 to make the label use that color
	// when that state is active
	public var up_color:Null<FlxColor> = null;
	public var over_color:Null<FlxColor> = null;
	public var down_color:Null<FlxColor> = null;

	public var up_toggle_color:Null<FlxColor> = null;
	public var over_toggle_color:Null<FlxColor> = null;
	public var down_toggle_color:Null<FlxColor> = null;

	public var up_visible:Bool = true;
	public var over_visible:Bool = true;
	public var down_visible:Bool = true;

	public var up_toggle_visible:Bool = true;
	public var over_toggle_visible:Bool = true;
	public var down_toggle_visible:Bool = true;

	public var toggle_label(default, set):FlxSprite;

	public function set_toggle_label(f:FlxSprite):FlxSprite
	{
		if (label != null)
		{
			toggle_label = f;
			return toggle_label;
		}
		return null;
	}

	override function set_visible(Value:Bool):Bool
	{
		if (visible && Value == false)
		{
			inputOver.release();
		}
		return super.set_visible(Value);
	}

	// If this is true, the label object's actual coordinates are rounded to the nearest pixel
	// you can still use floats for _centerLabelOffset and labelOffets, it's rounded as the very last step in placement
	public var round_labels:Bool = true;

	public static inline var CLICK_EVENT:String = "click_button";
	public static inline var OVER_EVENT:String = "over_button";
	public static inline var DOWN_EVENT:String = "down_button";
	public static inline var OUT_EVENT:String = "out_button";

	public var skipButtonUpdate(default, set):Bool = false;

	private function set_skipButtonUpdate(b:Bool):Bool
	{
		skipButtonUpdate = b;
		return skipButtonUpdate;
	}

	public var params(default, set):Array<Dynamic>;

	private function set_params(p:Array<Dynamic>):Array<Dynamic>
	{
		params = p;
		return params;
	}

	public override function destroy():Void
	{
		resize_point = FlxDestroyUtil.put(resize_point);
		super.destroy();
	}

	// TODO: add ability to set this property via xml, add documentation
	public var autoResizeLabel:Bool = false; // if this is true, when resize() is called on the button, it calls resize() on the label

	/**
	 * Creates a new FlxUITypedButton object with a gray background.
	 *
	 * @param	X			The X position of the button.
	 * @param	Y			The Y position of the button.
	 * @param	OnClick		The function to call whenever the button is clicked.
	 */
	public function new(X:Float = 0, Y:Float = 0, ?OnClick:Void->Void)
	{
		super(X, Y, OnClick);

		_centerLabelOffset = FlxPoint.get(0, 0);

		statusAnimations[3] = "normal_toggled";
		statusAnimations[4] = "highlight_toggled";
		statusAnimations[5] = "pressed_toggled";

		labelAlphas = [for (i in 0...3) 1];

		inputOver = new FlxInput(0);
	}

	override public function graphicLoaded():Void
	{
		super.graphicLoaded();

		setupAnimation("normal_toggled", 3);
		setupAnimation("highlight_toggled", 4);
		setupAnimation("pressed_toggled", 5);

		if (_autoCleanup)
		{
			cleanup();
		}
	}

	@:access(flixel.addons.ui.FlxUITypedButton)
	public function copyGraphic(other:FlxUITypedButton<FlxSprite>):Void
	{
		_src_w = other._src_w;
		_src_h = other._src_h;
		_frame_indeces = U.copy_shallow_arr_i(other._frame_indeces);
		tile = other.tile;
		resize_ratio = other.resize_ratio;

		if (other._centerLabelOffset == null)
		{
			_centerLabelOffset = null;
		}
		else
		{
			_centerLabelOffset = new FlxPoint(other._centerLabelOffset.x, other._centerLabelOffset.y);
		}

		_no_graphic = other._no_graphic;

		if (other._slice9_arrays != null)
		{
			_slice9_arrays = other._slice9_arrays.copy();
		}
		if (other._slice9_assets != null)
		{
			_slice9_assets = other._slice9_assets.copy();
		}

		if (_slice9_arrays == null || _slice9_assets == null)
		{
			loadGraphic(other.graphic, true, cast other.width, cast other.height);
		}
		else
		{
			resize(other.width, other.height);
		}
	}

	public function copyStyle(other:FlxUITypedButton<FlxSprite>):Void
	{
		up_color = other.up_color;
		over_color = other.over_color;
		down_color = other.down_color;

		up_toggle_color = other.up_toggle_color;
		over_toggle_color = other.over_toggle_color;
		down_toggle_color = other.over_toggle_color;

		up_visible = other.up_visible;
		over_visible = other.over_visible;
		down_visible = other.down_visible;

		up_toggle_visible = other.up_toggle_visible;
		over_toggle_visible = other.over_toggle_visible;
		down_toggle_visible = other.down_toggle_visible;

		var ctPt:FlxPoint = other.getCenterLabelOffset();
		setCenterLabelOffset(ctPt.x, ctPt.y);

		var i:Int = 0;
		for (flxPt in other.labelOffsets)
		{
			labelOffsets[i].x = flxPt.x;
			labelOffsets[i].y = flxPt.y;
			i++;
		}

		i = 0;
		for (alpha in other.labelAlphas)
		{
			labelAlphas[i] = alpha;
			i++;
		}
	}

	/**
	 * Set all 3 sets of labelOffsets at once
	 */
	public function setAllLabelOffsets(X:Float, Y:Float):Void
	{
		for (labelOffset in labelOffsets)
		{
			labelOffset.set(X, Y);
		}
	}

	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (status == FlxButton.NORMAL && mouseIsOver && input.justReleased == false)
		{
			// Detect rare edge case:
			// The button is not in a hilight/pressed state, but the button has ALSO not just been released, HOWEVER it thinks the mouse is still hovering
			// Tell the mouseOver to release:
			inputOver.release();
		}

		inputOver.update();

		// Label positioning
		if (label != null)
		{
			var theLabel = fetchAndShowCorrectLabel();
			theLabel.x = x + _centerLabelOffset.x + labelOffsets[status].x;
			theLabel.y = y + _centerLabelOffset.y + labelOffsets[status].y;

			if (round_labels)
			{
				theLabel.x = Std.int(theLabel.x + 0.5);
				theLabel.y = Std.int(theLabel.y + 0.5);
			}

			theLabel.scrollFactor = scrollFactor;
		}
	}

	/**
	 * Offset the statusAnimations-index by 3 when toggled.
	 */
	override public function updateStatusAnimation():Void
	{
		if (has_toggle && toggled)
		{
			animation.play(statusAnimations[status + 3]);
		}
		else
		{
			super.updateStatusAnimation();
		}
	}

	/**
	 * Just draws the button graphic and text label to the screen.
	 */
	override public function draw():Void
	{
		super.draw();
		if (has_toggle && toggled && toggle_label != null && toggle_label.visible == true)
		{
			toggle_label.cameras = cameras;
			toggle_label.draw();
		}
	}

	public function resize(W:Float, H:Float):Void
	{
		doResize(W, H);
	}

	private function doResize(W:Float, H:Float, Redraw:Bool = true):Void
	{
		var old_width:Float = width;
		var old_height:Float = height;

		var label_diffx:Float = 0;
		var label_diffy:Float = 0;
		if (label != null)
		{
			label_diffx = width - _spriteLabel.width;
			label_diffy = height - _spriteLabel.height;
		}

		if (W <= 0)
		{
			W = 80;
		}
		if (H <= 0)
		{
			H = 20;
		}

		if (Redraw)
		{
			if (_slice9_assets != null)
			{
				loadGraphicSlice9(_slice9_assets, Std.int(W), Std.int(H), _slice9_arrays, tile, resize_ratio, has_toggle, _src_w, _src_h, _frame_indeces);
			}
			else
			{
				if (_no_graphic)
				{
					var upB:BitmapData;
					if (!has_toggle)
					{
						upB = new BitmapData(Std.int(W), Std.int(H * 3), true, 0x00000000);
					}
					else
					{
						upB = new BitmapData(Std.int(W), Std.int(H * 6), true, 0x00000000);
					}
					loadGraphicsUpOverDown(upB);
				}
				else
				{
					// default assets
					loadGraphicSlice9(null, Std.int(W), Std.int(H), null, tile);
				}
			}
		}

		if (label != null && autoResizeLabel)
		{
			if ((label is IResizable))
			{
				var targetW:Float = W - label_diffx;
				var targetH:Float = H - label_diffy;
				var ir:IResizable = cast label;
				ir.resize(targetW, targetH);
			}
		}

		autoCenterLabel(); // center based on new dimensions

		var diff_w:Float = width - old_width;
		var diff_h:Float = height - old_height;

		if (resize_point != null)
		{
			var delta_x:Float = diff_w * resize_point.x;
			var delta_y:Float = diff_h * resize_point.y;
			x -= delta_x;
			y -= delta_y;
		}
	}

	private function getBmp(asset:FlxGraphicAsset):BitmapData
	{
		return U.getBmp(asset);
	}

	/**
	 * Provide a list of assets, load states from each one
	 * @param	assets
	 * @param   key string key for caching (optional)
	 */
	public function loadGraphicsMultiple(assets:Array<FlxGraphicAsset>, Key:String = ""):Void
	{
		_slice9_assets = null;
		_slice9_arrays = null;
		resize_ratio = -1;

		var key:String = "";

		if (assets.length <= 3)
		{
			while (assets.length < 3)
			{
				assets.push(null);
			}
			if (assets[1] == null)
			{
				assets[1] = assets[0];
			}
			if (assets[2] == null)
			{
				assets[2] = assets[1];
			}
			key = assets.join(",");
			if (Key != "")
			{
				key = Key; // replaces generated key with provided key.
			}

			if (FlxG.bitmap.checkCache(key))
			{
				loadGraphicsUpOverDown(key, false, key);
			}
			else
			{
				var pixels = assembleButtonFrames(getBmp(assets[0]), getBmp(assets[1]), getBmp(assets[2]));
				loadGraphicsUpOverDown(pixels, false, key);
			}
		}
		else if (assets.length <= 6)
		{
			while (assets.length < 6)
			{
				assets.push(null);
			}
			if (assets[4] == null)
			{
				assets[4] = assets[3];
			}
			if (assets[5] == null)
			{
				assets[5] = assets[4];
			}
			key = assets.join(",");
			if (Key != "")
			{
				key = Key; // replaces generated key with provided key.
			}

			if (FlxG.bitmap.checkCache(key))
			{
				loadGraphicsUpOverDown(key, true, key);
			}
			else
			{
				var pixels_normal = assembleButtonFrames(getBmp(assets[0]), getBmp(assets[1]), getBmp(assets[2]));
				var pixels_toggle = assembleButtonFrames(getBmp(assets[3]), getBmp(assets[4]), getBmp(assets[5]));
				var pixels = combineToggleBitmaps(pixels_normal, pixels_toggle);
				loadGraphicsUpOverDown(pixels, true, key);
				pixels_normal.dispose();
				pixels_toggle.dispose();
			}
		}
	}

	/**
	 * Provide one combined asset, load all 3 state frames from it and infer the width/height
	 * @param	asset graphic to load
	 * @param   for_toggle whether this is for a toggle button or not
	 * @param   key string key for caching (optional)
	 */
	public function loadGraphicsUpOverDown(asset:Dynamic, for_toggle:Bool = false, ?key:String):Void
	{
		_slice9_assets = null;
		_slice9_arrays = null;
		resize_ratio = -1;

		if (for_toggle)
		{
			has_toggle = true; // this makes it assume it's 6 images tall
		}

		var upB:BitmapData = null;
		var overB:BitmapData = null;
		var downB:BitmapData = null;

		var bd:BitmapData = null;

		if ((asset is BitmapData))
		{
			bd = cast asset;
		}
		else if ((asset is String))
		{
			bd = getBmp(asset);
		}

		upB = grabButtonFrame(bd, FlxButton.NORMAL, has_toggle, 0, 0, key);
		overB = grabButtonFrame(bd, FlxButton.HIGHLIGHT, has_toggle, 0, 0, key);
		downB = grabButtonFrame(bd, FlxButton.PRESSED, has_toggle, 0, 0, key);

		var normalGraphic:FlxGraphicAsset = key;
		if (key == null || key == "" || FlxG.bitmap.checkCache(key) == false)
		{
			normalGraphic = assembleButtonFrames(upB, overB, downB);
		}

		if (has_toggle)
		{
			var normalPixels:BitmapData = assembleButtonFrames(upB, overB, downB);

			upB = grabButtonFrame(bd, FlxButton.NORMAL + 3, true, 0, 0, key);
			overB = grabButtonFrame(bd, FlxButton.HIGHLIGHT + 3, true, 0, 0, key);
			downB = grabButtonFrame(bd, FlxButton.PRESSED + 3, true, 0, 0, key);

			var togglePixels:BitmapData = assembleButtonFrames(upB, overB, downB);
			var combinedPixels:BitmapData = combineToggleBitmaps(normalPixels, togglePixels);

			normalPixels = FlxDestroyUtil.dispose(normalPixels);
			togglePixels = FlxDestroyUtil.dispose(togglePixels);

			loadGraphic(combinedPixels, true, upB.width, upB.height, false, key);
		}
		else
		{
			loadGraphic(normalGraphic, true, upB.width, upB.height, false, key);
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
	public function loadGraphicSlice9(assets:Array<FlxGraphicAsset> = null, W:Int = 80, H:Int = 20, slice9:Array<Array<Int>> = null,
			Tile:Int = FlxUI9SliceSprite.TILE_NONE, Resize_Ratio:Float = -1, isToggle:Bool = false, src_w:Int = 0, src_h:Int = 0,
			frame_indeces:Array<Int> = null):Void
	{
		if (src_w != 0)
		{
			_src_w = src_w;
		}
		if (src_h != 0)
		{
			_src_h = src_h;
		}

		tile = Tile;

		has_toggle = isToggle;

		resize_ratio = Resize_Ratio;

		_slice9_assets = assets;
		_slice9_arrays = slice9;

		var key:String = "";

		var arr_bmpData:Array<BitmapData> = [];
		var arr_flx9:Array<FlxUISprite> = [];

		// Validate frame_indeces array
		if (frame_indeces == null)
		{
			// if it doesn't exist, create default setup
			if (has_toggle)
			{
				frame_indeces = [0, 1, 2, 3, 4, 5];
			}
			else
			{
				frame_indeces = [0, 1, 2];
			}
		}
		else
		{
			var max_index:Int = 2;
			if (has_toggle)
			{
				max_index = 5;
			}

			// if it's less than 3 (or 6 for toggle), add missing entries
			// and use the default frame index to fill the gap
			// (ie, [a,b] --> [a,b,2])
			while (frame_indeces.length < max_index + 1)
			{
				frame_indeces.push(frame_indeces.length - 1);
			}

			// make sure indeces are all within bounds
			for (i in 0...frame_indeces.length)
			{
				if (frame_indeces[i] > 5)
				{
					frame_indeces[i] = 5;
				}
				else if (frame_indeces[i] < 0)
				{
					frame_indeces[i] = 0;
				}
			}
		}

		_frame_indeces = frame_indeces;

		if (W == 0)
		{
			W = 80;
		}
		if (H == 0)
		{
			H = 20;
		}

		var pt = U.applyResize(resize_ratio, resize_ratio_axis, W, H);
		W = Std.int(pt.x);
		H = Std.int(pt.y);

		if (assets == null)
		{
			var temp:BitmapData;

			// default asset
			if (!isToggle)
			{
				assets = [FlxUIAssets.IMG_BUTTON];
				slice9 = [FlxStringUtil.toIntArray(FlxUIAssets.SLICE9_BUTTON)];
				temp = getBmp(assets[0]);
				_src_w = Std.int(temp.width);
				_src_h = Std.int(temp.height / 3); // calc default source width/height
			}
			else
			{
				assets = [FlxUIAssets.IMG_BUTTON_TOGGLE];
				slice9 = [FlxStringUtil.toIntArray(FlxUIAssets.SLICE9_BUTTON_TOGGLE)];
				temp = getBmp(assets[0]);
				_src_w = Std.int(temp.width);
				_src_h = Std.int(temp.height / 6); // calc default source width/height
			}

			temp = null;
		}

		if (!has_toggle && assets.length <= 3)
		{
			// 3 states - assume normal button
			arr_bmpData = [null, null, null];
			arr_flx9 = [null, null, null];
		}
		else
		{
			// 6 states - assume toggle button
			has_toggle = true;
			arr_bmpData = [null, null, null, null, null, null];
			arr_flx9 = [null, null, null, null, null, null];
		}

		_flashRect2.width = W;
		_flashRect2.height = H;

		key += assets + "_slice9=" + slice9 + "_src=" + _src_w + "x" + _src_h;

		var midKey = key;

		key += "_final=" + W + "x" + H + "_fi=" + _frame_indeces;

		if (assets.length == 1)
		{
			// loading everything from one graphic
			var all = getBmp(assets[0]); // load the image

			var keySuffix:String = "_all";

			if (_src_w == 0 || _src_h == 0)
			{
				throw new Error("Ambiguous situation! If you only provide one asset, you MUST provide src_w and src_h. Otherwise I can't tell if it's a stacked set of frames or a single frame.");
			}

			var multiFrame = all.height > _src_h;

			keySuffix += multiFrame ? "_multiframe" : "";

			key += keySuffix;
			midKey += keySuffix;

			//*************************************************************/
			// Check if we can exit early because this key is already cached
			if (FlxG.bitmap.checkCache(key))
			{
				loadGraphic(key, true, W, H);
				return;
			}
			//*************************************************************/

			// No dice -- keep processing

			if (multiFrame)
			{
				// looks like a multi-frame graphic
				for (i in 0...arr_bmpData.length)
				{
					arr_bmpData[i] = grabButtonFrame(all, i, has_toggle, _src_w, _src_h, midKey); // get each button frame
				}

				if (slice9 != null && slice9[0] != [])
				{
					// 9slicesprites

					// Scale each 9slicesprite
					for (i in 0...arr_bmpData.length)
					{
						arr_flx9[i] = new FlxUI9SliceSprite(0, 0, arr_bmpData[i], _flashRect2, slice9[0], tile, false, assets[0] + ":" + i, resize_ratio);
						arr_flx9[i].resize_point = resize_point;
					}

					// grab the pixel data:
					for (i in 0...arr_bmpData.length)
					{
						arr_bmpData[i] = arr_flx9[i].pixels;
					}

					// in case the resize_ratio resulted in different dimensions
					W = arr_bmpData[0].width;
					H = arr_bmpData[0].height;
				}
			}
			else
			{
				// just one frame
				arr_bmpData[0] = all;
			}
		}
		else
		{
			// loading multiple image files

			//*************************************************************/
			// Check if we can exit early because this key is already cached
			if (FlxG.bitmap.checkCache(key))
			{
				loadGraphic(key, true, W, H);
				return;
			}
			//*************************************************************/

			// No dice -- keep processing

			// ensure asset list is at least 3 long, fill with blanks if necessary
			if (!has_toggle)
			{
				while (assets.length < 3)
				{
					assets.push("");
				}
			}
			else
			{
				while (assets.length < 6)
				{
					assets.push("");
				}
			}

			if (assets[0] != "")
			{
				if (slice9 != null && slice9.length > 0 && slice9[0] != null && slice9[0].length > 0)
				{
					// load as 9slicesprites

					// make at least 3(or 6) long, fill with blanks if necessary
					while (slice9.length < assets.length)
					{
						slice9.push(null);
					}

					if (slice9[0] != null)
					{
						arr_flx9[0] = new FlxUI9SliceSprite(0, 0, assets[0], _flashRect2, slice9[0], tile, false, "", resize_ratio);
					}
					else
					{
						arr_flx9[0] = new FlxUISprite(0, 0, assets[0]);
					}
					arr_bmpData[0] = arr_flx9[0].pixels;

					for (i in 1...assets.length)
					{
						if (assets[i] != "")
						{
							if (slice9[i] != null)
							{
								arr_flx9[i] = new FlxUI9SliceSprite(0, 0, assets[i], _flashRect2, slice9[i], tile, false, "", resize_ratio);
							}
							else
							{
								arr_flx9[i] = new FlxUISprite(0, 0, assets[i]);
							}
							arr_bmpData[i] = arr_flx9[i].pixels;
						}
					}

					// in case the resize_ratio resulted in different dimensions
					W = arr_bmpData[0].width;
					H = arr_bmpData[0].height;
				}
				else
				{
					// load as static buttons
					for (i in 0...assets.length)
					{
						arr_bmpData[i] = getBmp(assets[i]);
					}
					W = arr_bmpData[0].width;
					H = arr_bmpData[0].height;
				}
			}
			else
			{
				if (W == 0)
				{
					W = 80;
				}
				if (H == 0)
				{
					H = 20;
				}

				arr_bmpData[0] = new BitmapData(W, H * 3, true, 0x00000000);

				_no_graphic = true;
			}
		}

		// If we've gotten here there's no shortcuts we need to draw the actual button graphic

		var normalPixels:BitmapData = null;

		if (!has_toggle)
		{
			normalPixels = assembleButtonFrames(arr_bmpData[frame_indeces[0]], arr_bmpData[frame_indeces[1]], arr_bmpData[frame_indeces[2]]);
			FlxG.bitmap.add(normalPixels, true, key);
			loadGraphic(key, true, W, H);
		}
		else
		{
			var normalPixels:BitmapData = assembleButtonFrames(arr_bmpData[frame_indeces[0]], arr_bmpData[frame_indeces[1]], arr_bmpData[frame_indeces[2]]);

			var togglePixels:BitmapData = assembleButtonFrames(arr_bmpData[frame_indeces[3]], arr_bmpData[frame_indeces[4]], arr_bmpData[frame_indeces[5]]);

			var combinedPixels:BitmapData = combineToggleBitmaps(normalPixels, togglePixels);

			// cleanup
			normalPixels = FlxDestroyUtil.dispose(normalPixels);
			togglePixels = FlxDestroyUtil.dispose(togglePixels);

			FlxG.bitmap.add(combinedPixels, true, key);
			loadGraphic(key, true, W, H);
		}

		// cleanup
		for (i in 0...arr_flx9.length)
		{
			if (arr_flx9[i] != null)
			{
				arr_flx9[i].destroy();
				arr_flx9[i] = null;
			}
		}
		while (arr_flx9.length > 0)
		{
			arr_flx9.pop();
		}
		arr_flx9 = null;
		while (arr_bmpData.length > 0)
		{
			arr_bmpData.pop();
		}
		arr_bmpData = null;
	}

	/**
	 * Sets labelOffset to center the label horizontally and vertically
	 */
	public function autoCenterLabel():Void
	{
		if (label != null)
		{
			var offX:Float = 0;
			var offY:Float = 0;

			offX = (width - _spriteLabel.width);

			if ((label is FlxUIText))
			{
				var tlabel:FlxUIText = cast label;
				offX = (width - tlabel.fieldWidth) / 2;
				offY = (height - tlabel.height) / 2;
			}
			else
			{
				offX = (width - _spriteLabel.width) / 2;
				offY = (height - _spriteLabel.height) / 2;
			}

			_centerLabelOffset.x = offX;
			_centerLabelOffset.y = offY;
		}
	}

	public function setCenterLabelOffset(X:Float, Y:Float):Void
	{
		_centerLabelOffset.x = X;
		_centerLabelOffset.y = Y;
	}

	public function getCenterLabelOffset():FlxPoint
	{
		return FlxPoint.get(_centerLabelOffset.x, _centerLabelOffset.y);
	}

	public function forceStateHandler(event:String):Void
	{
		switch (event)
		{
			case OUT_EVENT:
				onOutHandler();
			case OVER_EVENT:
				onOverHandler();
			case DOWN_EVENT:
				onDownHandler();
			case CLICK_EVENT:
				onUpHandler();
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
	public function grabButtonFrame(all_frames:BitmapData, button_state:Int, for_toggle:Bool = false, src_w:Int = 0, src_h:Int = 0,
			?key:String = null):BitmapData
	{
		var h:Int = src_h;
		if (h == 0)
		{
			if (!for_toggle)
			{
				h = Std.int(all_frames.height / 3);
			}
			else
			{
				h = Std.int(all_frames.height / 6);
			}
		}
		var w:Int = src_w;
		if (w == 0)
		{
			w = cast all_frames.width;
		}

		_flashRect.x = 0;
		_flashRect.y = button_state * h;
		_flashRect.width = w;
		_flashRect.height = h;
		if (_flashRect.y >= all_frames.height)
		{
			// we're off the bitmap, start making educated guesses
			var framesHigh:Int = Std.int(all_frames.height / h);
			if (framesHigh == 4)
			{
				// we have exactly 4 frames, assume "up","over","down","down_over"
				if (button_state == FlxButton.HIGHLIGHT + 3)
				{
					// toggle-hilight
					_flashRect.y = (3) * h; // show "down_over"
				}
				else if (button_state == FlxButton.PRESSED + 3)
				{
					// toggle-pressed
					_flashRect.y = (2) * h; // show "down"
				}
			}
		}

		// Check to see if we can return the cached image instead
		var frameKey = key + "{x:" + _flashRect.x + "y:" + _flashRect.y + "w:" + _flashRect.width + "h:" + _flashRect.height + "}";
		if (frameKey != null)
		{
			if (FlxG.bitmap.checkCache(frameKey))
			{
				return FlxG.bitmap.get(frameKey).bitmap;
			}
		}

		var pixels:BitmapData = new BitmapData(w, h);
		pixels.copyPixels(all_frames, _flashRect, _flashPointZero);
		if (key != null)
		{
			FlxG.bitmap.add(pixels, true, frameKey);
			addToCleanup(frameKey);
		}
		return pixels;
	}

	/**
	 * Combines two stacked button images for a toggle button
	 */
	public function combineToggleBitmaps(normal:BitmapData, toggle:BitmapData):BitmapData
	{
		var combined = new BitmapData(normal.width, normal.height + toggle.height);

		combined.copyPixels(normal, normal.rect, _flashPointZero);
		_flashPoint.x = 0;
		_flashPoint.y = normal.height;
		combined.copyPixels(toggle, toggle.rect, _flashPoint);

		return combined;
	}

	/**
	 * Give me three bitmapdatas and I'll return an assembled button bitmapdata for you.
	 * If overB or downB are missing, it will not include those frames.
	 */
	public function assembleButtonFrames(upB:BitmapData, overB:BitmapData, downB:BitmapData):BitmapData
	{
		var pixels:BitmapData;

		if (overB != null)
		{
			if (downB != null)
			{
				pixels = new BitmapData(upB.width, upB.height * 3);
			}
			else
			{
				pixels = new BitmapData(upB.width, upB.height * 2);
			}
		}
		else
		{
			pixels = new BitmapData(upB.width, upB.height);
		}

		pixels.copyPixels(upB, upB.rect, _flashPointZero);

		if (overB != null)
		{
			_flashPoint.x = 0;
			_flashPoint.y = upB.height;
			pixels.copyPixels(overB, overB.rect, _flashPoint);
			if (downB != null)
			{
				_flashPoint.y = upB.height * 2;
				pixels.copyPixels(downB, downB.rect, _flashPoint);
			}
		}

		return pixels;
	}

	public override function updateButton():Void
	{
		if (!skipButtonUpdate)
		{
			super.updateButton();
		}
	}

	private function addToCleanup(str:String):Void
	{
		if (_assetsToCleanup == null)
		{
			_assetsToCleanup = [];
		}
		if (_assetsToCleanup.indexOf(str) == -1)
		{
			_assetsToCleanup.push(str);
		}
	}

	private function cleanup():Void
	{
		if (_assetsToCleanup == null)
			return;

		for (key in _assetsToCleanup)
		{
			FlxG.bitmap.removeByKey(key);
		}
		_assetsToCleanup = null;
	}

	private function fetchAndShowCorrectLabel():FlxSprite
	{
		if (has_toggle)
		{
			if (toggled && toggle_label != null)
			{
				_spriteLabel.visible = false;
				toggle_label.visible = true;
				return toggle_label;
			}
			else
			{
				if (toggle_label != null)
				{
					toggle_label.visible = false;
				}
				_spriteLabel.visible = true;
				return label;
			}
		}
		return label;
	}

	override private function onUpHandler():Void
	{
		if (has_toggle)
		{
			toggled = !toggled;
		}

		super.onUpHandler();
		if (label != null)
		{
			var theLabel = fetchAndShowCorrectLabel();
			theLabel.visible = (toggled) ? up_toggle_visible : up_visible;
			var thecol:Null<FlxColor> = (toggled) ? up_toggle_color : up_color;
			if (thecol != null)
			{
				theLabel.color = thecol;
			}
		}
		if (broadcastToFlxUI)
		{
			FlxUI.event(CLICK_EVENT, this, null, params);
		}
	}

	override private function onDownHandler():Void
	{
		super.onDownHandler();
		if (label != null)
		{
			var theLabel = fetchAndShowCorrectLabel();
			theLabel.visible = (toggled) ? down_toggle_visible : down_visible;
			var thecol:Null<FlxColor> = (toggled) ? down_toggle_color : down_color;
			if (thecol != null)
			{
				theLabel.color = thecol;
			}
		}
		if (broadcastToFlxUI)
		{
			FlxUI.event(DOWN_EVENT, this, null, params);
		}
	}

	override private function onOverHandler():Void
	{
		super.onOverHandler();
		inputOver.press();
		if (label != null)
		{
			var theLabel = fetchAndShowCorrectLabel();
			theLabel.visible = (toggled) ? over_toggle_visible : over_visible;
			var thecol:Null<FlxColor> = (toggled) ? over_toggle_color : over_color;
			if (thecol != null)
			{
				theLabel.color = thecol;
			}
		}
		if (broadcastToFlxUI)
		{
			FlxUI.event(OVER_EVENT, this, null, params);
		}
	}

	override private function onOutHandler():Void
	{
		super.onOutHandler();
		inputOver.release();
		if (label != null)
		{
			var theLabel = fetchAndShowCorrectLabel();
			theLabel.visible = (toggled) ? up_toggle_visible : up_visible;
			var thecol:Null<FlxColor> = (toggled) ? up_toggle_color : up_color;
			if (thecol != null)
			{
				theLabel.color = thecol;
			}
		}
		if (broadcastToFlxUI)
		{
			FlxUI.event(OUT_EVENT, this, null, params);
		}
	}

	private override function set_x(NewX:Float):Float
	{
		super.set_x(NewX);

		if (_spriteLabel != null)
		{
			_spriteLabel.x = x + _centerLabelOffset.x + labelOffsets[status].x;

			if (round_labels)
			{
				_spriteLabel.x = Std.int(_spriteLabel.x + 0.5);
			}
			if (has_toggle && toggle_label != null)
			{
				toggle_label.x = _spriteLabel.x;
			}
		}

		return NewX;
	}

	private override function set_y(NewY:Float):Float
	{
		super.set_y(NewY);

		if (label != null)
		{
			_spriteLabel.y = y + _centerLabelOffset.y + labelOffsets[status].y;

			if (round_labels)
			{
				_spriteLabel.y = Std.int(_spriteLabel.y + 0.5);
			}
			if (has_toggle && toggle_label != null)
			{
				toggle_label.y = _spriteLabel.y;
			}
		}
		return NewY;
	}

	/*********PRIVATE************/
	private var _autoCleanup:Bool = true;

	private var _assetsToCleanup:Array<String> = [];

	private var _no_graphic:Bool = false;

	private var _src_w:Int = 0; // frame size of the source image. If 0, make an inferred guess.

	private var _src_h:Int = 0;

	private var _frame_indeces:Array<Int>;

	// if you're doing 9-slice resizing:
	private var _slice9_arrays:Array<Array<Int>>; // the 9-slice scaling rules for the original assets

	private var _slice9_assets:Array<FlxGraphicAsset>; // the asset id's of the original 9-slice scale assets

	private var _centerLabelOffset:FlxPoint = null; // this is the offset necessary to center ALL the labels
}
