package flixel.addons.ui;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxClickArea;
import flixel.util.FlxPoint;

/**
 * larsiusprime
 * @author 
 */
class FlxUIDropdownMenu extends FlxUIGroup implements IFlxUIWidget
{

	public function new(X:Float=0, Y:Float=0, Back:FlxSprite=null,DropPanel:FlxUI9SliceSprite=null,?Asset_list:Array<FlxUIButton>,?Data_list:Array<StrIdLabel>,?Text:FlxUIText,?Button:FlxUISpriteButton,?Callback:String->Void) 
	{
		super();
		
		x = X;
		y = Y;
		
		_mPoint = new FlxPoint();
		
		var rect:Rectangle = null;
				
		if (Back == null) {
			rect = new Rectangle(0, 0, 120, 20);
			Back = new FlxUI9SliceSprite(0, 0, FlxUIAssets.IMG_BOX, rect, "1,1,14,14");
		}
		rect.width = Back.width;
		rect.height = Back.height;

		if (Button == null) {
			Button = new FlxUISpriteButton(0, 0, new FlxSprite(0, 0, FlxUIAssets.IMG_DROPDOWN), onDropdown);
			Button.loadGraphicSlice9([FlxUIAssets.IMG_BUTTON_THIN],[FlxUIAssets.SLICE9_BUTTON]);
		}
		Button.resize(Back.height, Back.height);
		Button.x = Back.x + Back.width - Button.width;
		
		_text = Text;		
		if (_text == null) {
			_text = new FlxUIText(0, 0, Std.int(Back.width - Back.height), "Item 1");			
		}
		_text.y = Back.y + (Back.height - _text.height);
		_text.color = 0x000000;
		_text.borderStyle = FlxText.BORDER_NONE;
		
		var yoff:Int = cast Back.y + Back.height;
		
		_list = new Array<FlxUIButton>();
		
		var i:Int = 0;
		if (Data_list != null) { 
			for (data in Data_list) {
				var t:FlxUIButton = new FlxUIButton(0, 0, data.label);
				t.setOnUpCallback(onClickItem, [i]);
				
				t.id = data.id;
				
				t.loadGraphicSlice9([FlxUIAssets.IMG_INVIS, FlxUIAssets.IMG_HILIGHT, FlxUIAssets.IMG_HILIGHT],Std.int(Back.width),Std.int(Back.height),["1,1,3,3","1,1,3,3","1,1,3,3"], FlxUI9SliceSprite.TILE_NONE);
				t.depressOnClick = false;
				
				t.up_color = 0x000000;
				t.over_color = 0xffffff;
				t.down_color = 0xffffff;
				t.label.borderStyle = FlxText.BORDER_NONE;
				
				t.resize(Back.width, Back.height);
				
				t.label.alignment = "left";
				t.autoCenterLabel();
				t.label.x = 2;
				
				_list.push(t);
				t.y = yoff;
				yoff += Std.int(Back.height);
				
				i++;
			}
		}else if (Asset_list != null) {
			for (btn in Asset_list) {				
				_list.push(btn);
				btn.resize(Back.width, Back.height);				
				btn.y = yoff;
				yoff += Std.int(Back.height);
				
				i++;
			}
		}
		
		_dropPanel = DropPanel;
		if (_dropPanel == null) {
			_dropPanel = new FlxUI9SliceSprite(0, 0, FlxUIAssets.IMG_BOX, rect, "1,1,14,14");
		}
		
		_dropPanel.y = Back.y;
		_dropPanel.resize(Back.width, yoff);
		_dropPanel.visible = false;
		
		add(_dropPanel);		
		add(Back);
		add(Button);
		add(_text);
		
		for (btn in _list) {
			add(btn);
			btn.visible = false;
		}
		
		_callback = Callback;
	}
	
	public override function update():Void {
		super.update();
		if (_dropdown_active) {
			_mPoint.x = FlxG.mouse.x;
			_mPoint.y = FlxG.mouse.y;
			if (!_dropPanel.overlapsPoint(_mPoint)) {
				_dropdown_active = false;
				showList(false);
			}
		}
	}	
	
	private var _callback:String->Void;
	private var _list:Array<FlxUIButton>;
	private var _text:FlxUIText;
	private var _dropPanel:FlxUI9SliceSprite;
	private var _dropdown_active:Bool = false;
	private var _mPoint:FlxPoint = null;
	
	private function showList(b:Bool):Void {
		for (button in _list) {
			button.visible = b;
			button.active = b;
		}
		_dropPanel.visible = b;
	}
	
	private function onDropdown(?params:Array<Dynamic>):Void {
		showList(true);
		_dropdown_active = true;
	}	
	
	private function onClickItem(i:Int):Void {
		var item:FlxUIButton = _list[i];
		_text.text = item.label.text;
		showList(false);
		if (_callback != null) {
			_callback(item.id);
		}
	}
	
	
	
	//public function new(back_:FlxSprite,?tabs_:Array<FlxUIButton>,?tab_ids_and_labels_:Array<{id:String,label:String}>,stretch_tabs:Bool=false) 
	
}