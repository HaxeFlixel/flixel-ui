package flixel.addons.ui;
import flash.geom.Rectangle;
import flixel.addons.ui.interfaces.IFlxUIButton;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

/**
 * ...
 * @author larsiusprime
 */
class FlxUIColorSwatchSelecter extends FlxUIGroup implements IFlxUIButton
{
	public static inline var CLICK_EVENT:String = "click_color_swatch_selecter";
	
	public var skipButtonUpdate(default, set):Bool;
	public function set_skipButtonUpdate(b:Bool):Bool {
		skipButtonUpdate = b;
		for (thing in members) {
			if (thing != _selectionSprite) {
				var swatch:FlxUIColorSwatch = cast thing;
				swatch.skipButtonUpdate = b;
			}
		}
		return b;
	}
	
	/**
	 * A handy little group for selecting color swatches from
	 * @param	X					X location
	 * @param	Y					Y location
	 * @param	?SelectionSprite	The selection box sprite (optional, auto-generated if not supplied)
	 * @param	?list_colors		A list of single-colors to generate swatches from. 1st of 3 alternatives.
	 * @param	?list_data			A list of swatch data to generate swatches from. 2nd of 3 alternatives.
	 * @param	?list_swatches		A list of the actual swatch widgets themselves. 3rd of 3 alternatives.
	 * @param	SpacingH			Horizontal spacing between swatches
	 * @param	SpacingV			Vertical spacing between swatches
	 * @param	MaxColumns			Number of horizontal swatches in a row before a line break
	 */
	
	public function new(X:Float,Y:Float,?SelectionSprite:FlxSprite,?list_colors:Array<Int>,?list_data:Array<SwatchData>,?list_swatches:Array<FlxUIColorSwatch>,SpacingH:Int=2, SpacingV:Int=2, MaxColumns:Int=-1) 
	{
		super(X, Y);
		
		if (SelectionSprite != null) {
			_selectionSprite = SelectionSprite;
		}
		
		var i:Int = 0;
		var swatch:FlxUIColorSwatch;
		if (list_data != null) {
			for (data in list_data) {
				swatch = new FlxUIColorSwatch(0, 0, data);
				swatch.callback = selectCallback.bind(i);
				swatch.broadcastToFlxUI = false;
				swatch.id = data.name;
				add(swatch);
				i++;
			}
		}else if (list_colors != null) {
			for (color in list_colors) {
				swatch = new FlxUIColorSwatch(0, 0, color);
				swatch.callback = selectCallback.bind(i);
				swatch.broadcastToFlxUI = false;
				swatch.id = "0x"+StringTools.hex(color, 6);
				add(swatch);
				i++;
			}
		}else if (list_swatches != null) {
			for (swatch in list_swatches) {
				swatch.id = "swatch_" + i;
				swatch.callback = selectCallback.bind(i);
				swatch.broadcastToFlxUI = false;
				add(swatch);
				i++;
			}
		}
		
		var xx:Float = X;
		var yy:Float = Y;
		
		var i:Int = 0;
		
		if(_selectionSprite == null){
			if (members.length >= 1) {
				var ww:Int = Std.int(members[0].width);
				var hh:Int = Std.int(members[0].height);
				_selectionSprite = new FlxSprite();
				_selectionSprite.makeGraphic(ww+4, hh+4, 0xFFFFFFFF, false, "selection_sprite_" + ww + "x" + hh + "0xFFFFFFFF");
				if (_flashRect == null) { _flashRect = new Rectangle();}
				_flashRect.x = 2;
				_flashRect.y = 2;
				_flashRect.width = ww;
				_flashRect.height = hh;
				_selectionSprite.pixels.fillRect(_flashRect, 0x00000000);
				add(_selectionSprite);
			}
		}
		
		for (sprite in members) {
			if(sprite != null){
				sprite.x = xx;
				sprite.y = yy;
				xx += sprite.width + SpacingH;
				i++;
				if (MaxColumns != -1 && i >= MaxColumns) {
					i = 0;
					xx = X;
					yy += sprite.height + SpacingV;
				}
			}
		}
		
		selectByIndex(0);
	}
	
	public var selectedSwatch(get, null):FlxUIColorSwatch;
	public function get_selectedSwatch():FlxUIColorSwatch {
		return _selectedSwatch;
	}
	private var destroyed:Bool = false;
	public override function destroy():Void {
		destroyed = true;
		_selectedSwatch = null;
		_selectionSprite = null;
		super.destroy();
	}
	
	private function selectCallback(i:Int):Void {
		selectByIndex(i);
		if (broadcastToFlxUI) {
			if (_selectedSwatch != null) {
				if(_selectedSwatch.multiColored){
					FlxUI.event(CLICK_EVENT, this, _selectedSwatch.colors);
				}else {
					FlxUI.event(CLICK_EVENT, this, _selectedSwatch.color);
				}
			}
		}
	}
	
	public function selectByIndex(i:Int):Void {
		_selectedSwatch = cast members[i];
		updateSelected();
	}
	
	public function selectByColor(Color:Int):Void {
		
		_selectedSwatch = null;
		
		for (sprite in members) {
			if (sprite != _selectedSwatch) {
				var swatch:FlxUIColorSwatch = cast sprite;
				if (swatch.color == Color) {
					_selectedSwatch = swatch;
					break;
				}
			}
		}
		updateSelected();
	}
	
	public function selectByColors(Data:SwatchData, PickClosest:Bool=true):Void {
		var best_delta:Int = 99999999;
		var curr_delta:Int = 0;
		var best_swatch:FlxUIColorSwatch = null;
		
		_selectedSwatch = null;
		
		for (sprite in members) {
			if (sprite != _selectedSwatch) {
				var swatch:FlxUIColorSwatch = cast sprite;
				var swatchData:SwatchData = swatch.colors;
				if (PickClosest) {
					curr_delta = 0;
					
					curr_delta += getRGBdelta(Data.hilight, swatchData.hilight);
					curr_delta += getRGBdelta(Data.midtone, swatchData.midtone);
					curr_delta += getRGBdelta(Data.shadowMid, swatchData.shadowMid);
					curr_delta += getRGBdelta(Data.shadowDark, swatchData.shadowDark);
					
					if (curr_delta < best_delta) {
						best_swatch = swatch;
					}
				}else {
					if ((Data.hilight == swatchData.hilight) && (Data.midtone == swatchData.midtone) &&
						(Data.shadowMid == swatchData.shadowMid) && (Data.shadowDark == swatchData.shadowDark))
					{
						_selectedSwatch = swatch;
						break;
					}
				}
			}
		}
		
		if (best_swatch != null) {
			_selectedSwatch = best_swatch;
		}
		
		updateSelected();
	}
	
	public function selectByName(Name:String):Void {
		
		_selectedSwatch = null;
		
		for (sprite in members) {
			if (sprite != _selectedSwatch) {
				var swatch:FlxUIColorSwatch = cast sprite;
				if (swatch.id == Name) {
					_selectedSwatch = swatch;
					break;
				}
			}
		}
		updateSelected();
	}
	
	public function unselect():Void {
		_selectedSwatch = null;
		updateSelected();
	}
	
	private function updateSelected():Void {
		if (_selectedSwatch != null) {
			_selectionSprite.visible = true;
			_selectionSprite.x = _selectedSwatch.x + ((_selectedSwatch.width  - _selectionSprite.width) / 2);
			_selectionSprite.y = _selectedSwatch.y + ((_selectedSwatch.height - _selectionSprite.height) / 2);
		}else {
			_selectionSprite.visible = false;
		}
	}
	
	private function getRGBdelta(a:Int, b:Int):Int{
		var ra:Int = a >> 16 & 0xFF;
		var ga:Int = a >> 8 & 0xFF;
		var ba:Int = a & 0xFF;
		var rb:Int = b >> 16 & 0xFF;
		var gb:Int = b >> 8 & 0xFF;
		var bb:Int = b & 0xFF;
		var diff:Int = 0;
		var delta:Int = 0;
		
		diff = ra - rb; if (diff < 0) { diff *= -1; };
		delta += diff;
		
		diff = ga - gb; if (diff < 0) { diff *= -1; };
		delta += diff;
		
		diff = ba - bb; if (diff < 0) { diff *= -1; };
		delta += diff;
		
		return delta;
	}
	
	private var _selectedSwatch:FlxUIColorSwatch;
	private var _selectionSprite:FlxSprite;
}