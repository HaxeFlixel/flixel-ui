package flixel.addons.ui;

import flash.geom.Rectangle;
import flixel.addons.ui.FlxUIColorSwatchSelecter.SwatchGraphic;
import flixel.addons.ui.interfaces.IFlxUIClickable;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.system.FlxAssets.FlxGraphicAsset;

/**
 * ...
 * @author larsiusprime
 */
class FlxUIColorSwatchSelecter extends FlxUIGroup implements IFlxUIClickable
{
	public static inline var CLICK_EVENT:String = "click_color_swatch_selecter";

	public var spacingH(default, set):Float;
	public var spacingV(default, set):Float;
	public var maxColumns(default, set):Float;

	var _previewSwatch:FlxUIColorSwatch;

	private function set_spacingH(f:Float):Float
	{
		spacingH = f;
		_dirtyLayout = true;
		return f;
	}

	private function set_spacingV(f:Float):Float
	{
		spacingV = f;
		_dirtyLayout = true;
		return f;
	}

	private function set_maxColumns(f:Float):Float
	{
		maxColumns = f;
		_dirtyLayout = true;
		return f;
	}

	public var skipButtonUpdate(default, set):Bool;

	private function set_skipButtonUpdate(b:Bool):Bool
	{
		skipButtonUpdate = b;
		for (thing in members)
		{
			if (thing != _selectionSprite)
			{
				var swatch:FlxUIColorSwatch = cast thing;
				swatch.skipButtonUpdate = b;
			}
		}
		return b;
	}

	public var numSwatches(get, never):Int;

	private function get_numSwatches()
	{
		return members.length - 2;
	}

	/**
	 * A handy little group for selecting color swatches from
	 * @param	X					X location
	 * @param	Y					Y location
	 * @param	SelectionSprite	The selection box sprite (optional, auto-generated if not supplied)
	 * @param	list_colors		A list of single-colors to generate swatches from. 1st of 3 alternatives.
	 * @param	list_data			A list of swatch data to generate swatches from. 2nd of 3 alternatives.
	 * @param	list_swatches		A list of the actual swatch widgets themselves. 3rd of 3 alternatives.
	 * @param	SpacingH			Horizontal spacing between swatches
	 * @param	SpacingV			Vertical spacing between swatches
	 * @param	MaxColumns			Number of horizontal swatches in a row before a line break
	 * @param	Preview				Graphic information for the preview swatch
	 * @param	Swatch				Graphic information for the regular swatches
	 */
	public function new(X:Float, Y:Float, ?SelectionSprite:FlxSprite, ?list_colors:Array<Int>, ?list_data:Array<SwatchData>,
			?list_swatches:Array<FlxUIColorSwatch>, SpacingH:Int = 2, SpacingV:Int = 2, MaxColumns:Int = -1, ?Preview:SwatchGraphic = null,
			?Swatch:SwatchGraphic = null)
	{
		super(X, Y);

		_previewGraphic = Preview;
		_swatchGraphic = Swatch;

		if (_previewGraphic == null)
		{
			_previewGraphic = {asset: null, width: -1, height: -1};
		}
		if (_swatchGraphic == null)
		{
			_swatchGraphic = {asset: null, width: -1, height: -1};
		}

		if (SelectionSprite != null)
		{
			_selectionSprite = SelectionSprite;
		}

		var i:Int = 0;
		var swatch:FlxUIColorSwatch;

		if (list_data != null)
		{
			for (data in list_data)
			{
				swatch = new FlxUIColorSwatch(0, 0, null, data, _swatchGraphic.asset, null, _swatchGraphic.width, _swatchGraphic.height);
				swatch.callback = selectCallback.bind(i);
				swatch.broadcastToFlxUI = false;
				swatch.name = data.name;
				add(swatch);
				i++;
			}
		}
		else if (list_colors != null)
		{
			for (color in list_colors)
			{
				swatch = new FlxUIColorSwatch(0, 0, color, null, _swatchGraphic.asset, null, _swatchGraphic.width, _swatchGraphic.height);
				swatch.callback = selectCallback.bind(i);
				swatch.broadcastToFlxUI = false;
				swatch.name = "0x" + StringTools.hex(color, 6);
				add(swatch);
				i++;
			}
		}
		else if (list_swatches != null)
		{
			for (swatch in list_swatches)
			{
				swatch.name = "swatch_" + i;
				swatch.callback = selectCallback.bind(i);
				swatch.broadcastToFlxUI = false;
				add(swatch);
				i++;
			}
		}

		spacingH = SpacingH;
		spacingV = SpacingV;
		maxColumns = MaxColumns;

		if (_selectionSprite == null)
		{
			if (members.length >= 1)
			{
				var ww:Int = Std.int(members[0].width);
				var hh:Int = Std.int(members[0].height);

				_selectionSprite = new FlxSprite();
				_selectionSprite.makeGraphic(ww + 4, hh + 4, 0xFFFFFFFF, false, "selection_sprite_" + ww + "x" + hh + "0xFFFFFFFF");

				if (_flashRect == null)
				{
					_flashRect = new Rectangle();
				}

				_flashRect.x = 2;
				_flashRect.y = 2;
				_flashRect.width = ww;
				_flashRect.height = hh;
				_selectionSprite.pixels.fillRect(_flashRect, 0x00000000);
				add(_selectionSprite);
			}
		}

		_previewSwatch = new FlxUIColorSwatch(0, 0, null, new SwatchData("dummy", [0xffffffff, 0xff888888, 0xff444444, 0xff000000]), _previewGraphic.asset,
			null, _previewGraphic.width, _previewGraphic.height);
		_previewSwatch.broadcastToFlxUI = false;
		add(_previewSwatch);

		updateLayout();

		selectByIndex(0);
	}

	public override function update(elapsed:Float):Void
	{
		if (_dirtyLayout)
		{
			updateLayout();
			updateSelected(); // FIX - update selected sprite position
		}
		super.update(elapsed);
	}

	public function updateLayout():Void
	{
		if (members == null || members.length == 0)
		{
			return;
		}

		var firstSprite:FlxSprite = members[0];
		var firstX:Float = x;
		var firstY:Float = y;
		if (firstSprite != null)
		{
			firstX = firstSprite.x;
			firstY = firstSprite.y;
		}

		var xx:Float = firstX;
		var yy:Float = firstY;
		var columns:Int = 0;

		for (sprite in members)
		{
			if (sprite != null && sprite != _selectionSprite)
			{
				sprite.x = xx;
				sprite.y = yy;
				xx += (sprite.width + spacingH);
				columns++;
				if (maxColumns != -1 && columns >= maxColumns)
				{
					columns = 0;
					xx = firstX;
					yy += sprite.height + spacingV;
				}
			}
		}

		_previewSwatch.x = firstX - _previewSwatch.width - spacingH - 5;

		_dirtyLayout = false;
	}

	public function changeColors(list:Array<SwatchData>):Void
	{
		remove(_previewSwatch);
		var swatchForSelect:SwatchData = null;

		if (_selectedSwatch != null)
		{
			swatchForSelect = selectedSwatch.colors;
		}

		for (thing in members)
		{
			if (thing != _selectionSprite)
			{
				thing.visible = false;
				thing.active = false;
			}
			else
			{
				remove(_selectionSprite, true);
			}
		}

		for (i in 0...list.length)
		{
			var fuics:FlxUIColorSwatch = null;

			if (i < members.length)
			{
				var sprite = members[i];
				if (sprite != null)
				{
					if ((sprite is FlxUIColorSwatch))
					{
						fuics = cast sprite;
						if (fuics.equalsSwatch(list[i]) == false)
						{
							fuics.colors = list[i];
						}
					}
				}
			}

			if (fuics == null)
			{
				fuics = new FlxUIColorSwatch(0, 0, null, list[i], _swatchGraphic.asset, null, _swatchGraphic.width, _swatchGraphic.height);
				fuics.name = list[i].name;
				fuics.broadcastToFlxUI = false;
				fuics.callback = selectCallback.bind(i);
				add(fuics);
			}

			fuics.visible = true;
			fuics.active = true;
		}

		var length:Int = members.length;
		for (i in 0...length)
		{
			var j:Int = (length - 1) - i;
			var thing:FlxSprite = members[j];
			if (thing != _selectionSprite)
			{
				if (thing == null)
				{
					members.splice(j, 1);
				}
				else if (thing.visible == false && thing.active == false)
				{
					thing.destroy();
					remove(thing, true);
					thing = null;
				}
			}
		}

		_dirtyLayout = true;

		add(_selectionSprite);
		add(_previewSwatch);

		if (swatchForSelect != null)
		{
			selectByColors(swatchForSelect, true);
		}
		else
		{
			unselect();
		}
	}

	public var selectedSwatch(get, never):FlxUIColorSwatch;

	private function get_selectedSwatch():FlxUIColorSwatch
	{
		return _selectedSwatch;
	}

	private var destroyed:Bool = false;

	public override function destroy():Void
	{
		destroyed = true;
		_selectedSwatch = null;
		_selectionSprite = null;
		super.destroy();
	}

	private function selectCallback(i:Int):Void
	{
		selectByIndex(i);
		if (broadcastToFlxUI)
		{
			if (_selectedSwatch != null)
			{
				if (_selectedSwatch.multiColored)
				{
					FlxUI.event(CLICK_EVENT, this, _selectedSwatch.colors);
				}
				else
				{
					FlxUI.event(CLICK_EVENT, this, _selectedSwatch.color);
				}
			}
		}
	}

	public function selectByIndex(i:Int):Void
	{
		_selectedSwatch = cast members[i];
		updateSelected();
	}

	public function selectByColor(Color:Int):Void
	{
		_selectedSwatch = null;

		for (sprite in members)
		{
			if (sprite != _selectedSwatch && (sprite is FlxUIColorSwatch))
			{
				var swatch:FlxUIColorSwatch = cast sprite;
				if (swatch.color == Color)
				{
					_selectedSwatch = swatch;
					break;
				}
			}
		}
		updateSelected();
	}

	public function selectByColors(Data:SwatchData, PickClosest:Bool = true, IgnoreInvisible:Bool = true):Void
	{
		var best_delta:Int = 99999999;
		var curr_delta:Int = 0;
		var best_swatch:FlxUIColorSwatch = null;

		_selectedSwatch = null;
		for (sprite in members)
		{
			if (sprite != _selectionSprite && sprite != _selectedSwatch && sprite.visible == true && sprite.active == true)
			{
				var swatch:FlxUIColorSwatch = cast sprite;
				var swatchData:SwatchData = swatch.colors;
				if (PickClosest)
				{
					// Ignore the "dummy" swatch
					if (swatch.colors.name == "dummy" && Data.name == "dummy")
					{
						continue;
					}

					curr_delta = Data.getRawDifference(swatchData, IgnoreInvisible);
					if (curr_delta < best_delta)
					{
						best_swatch = swatch;
						best_delta = curr_delta;
					}
				}
				else
				{
					if (Data.doColorsEqual(swatchData))
					{
						best_swatch = swatch;
						break;
					}
				}
			}
		}

		_selectedSwatch = best_swatch;

		updateSelected();
	}

	public function selectByName(Name:String):Void
	{
		_selectedSwatch = null;

		for (sprite in members)
		{
			if (sprite != _selectedSwatch)
			{
				var swatch:FlxUIColorSwatch = cast sprite;
				if (swatch.name == Name)
				{
					_selectedSwatch = swatch;
					break;
				}
			}
		}
		updateSelected();
	}

	public function unselect():Void
	{
		_selectedSwatch = null;
		updateSelected();
	}

	public function updateSelected():Void
	{
		if (_selectedSwatch != null)
		{
			_selectionSprite.visible = true;
			_selectionSprite.x = _selectedSwatch.x + ((_selectedSwatch.width - _selectionSprite.width) / 2);
			_selectionSprite.y = _selectedSwatch.y + ((_selectedSwatch.height - _selectionSprite.height) / 2);
			_previewSwatch.colors = _selectedSwatch.colors;
		}
		else
		{
			_selectionSprite.visible = false;
		}
	}

	private var _previewGraphic:SwatchGraphic;
	private var _swatchGraphic:SwatchGraphic;
	private var _selectedSwatch:FlxUIColorSwatch;
	private var _selectionSprite:FlxSprite;
	private var _dirtyLayout:Bool = false;
}

typedef SwatchGraphic =
{
	var width:Int;
	var height:Int;
	var asset:FlxGraphicAsset;
}
