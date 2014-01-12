package flixel.addons.ui;

import flash.geom.Rectangle;
import flixel.addons.ui.interfaces.IFlxUIButton;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxPoint;

/**
 * larsiusprime
 * @author 
 */
class FlxUIDropdownMenu extends FlxUIGroup implements IFlxUIWidget implements IFlxUIButton
{
	public var skipButtonUpdate(default, set):Bool;
	public function set_skipButtonUpdate(b:Bool):Bool {
		_button.skipButtonUpdate = b;
		return b;
	}
	
	private var _button:FlxUISpriteButton = null;
	private var _ui_control_callback:Bool->FlxUIDropdownMenu->Void;
	private var _callback:Array<Dynamic>->Void;
	private var _list:Array<FlxUIButton>;
	private var _text:FlxUIText;
	private var _dropPanel:FlxUI9SliceSprite;
	private var _dropdown_active:Bool = false;

	/**
	 * This creates a new dropdown menu.
	 * @param	X					x position of the dropdown menu
	 * @param	Y					y position of the dropdown menu
	 * @param	DataList			The data to be displayed
	 * @param	Callback			Function to be called when of of the entries of the list was clicked
	 * @param	Back				Optional sprite to be placed in the background
	 * @param	DropPanel			Optional 9-slice-background for actual drop down menu 
	 * @param	ButtonList			Optional list of buttons to be used for the corresponding entry in DataList
	 * @param	Text				Optional text that displays the current value
	 * @param	ToggleButton		Optional button that toggles the dropdown list
	 * @param	UIControlCallback	Used internally by FlxUI
	 */
	public function new(X:Float = 0, Y:Float = 0, DataList:Array<StrIdLabel>, ?Callback:Array<Dynamic>->Void, ?Back:FlxSprite, ?DropPanel:FlxUI9SliceSprite, ?ButtonList:Array<FlxUIButton>, ?Text:FlxUIText, ?ToggleButton:FlxUISpriteButton, ?UIControlCallback:Bool->FlxUIDropdownMenu->Void) 
	{
		super(X, Y);
		
		var rect:Rectangle = null;
		
		if (Back == null) {
			rect = new Rectangle(0, 0, 120, 20);
			Back = new FlxUI9SliceSprite(0, 0, FlxUIAssets.IMG_BOX, rect, "1,1,14,14");
		}
		rect.width = Back.width;
		rect.height = Back.height;

		if (ToggleButton == null) {
			ToggleButton = new FlxUISpriteButton(0, 0, new FlxSprite(0, 0, FlxUIAssets.IMG_DROPDOWN), onDropdown);
			ToggleButton.loadGraphicSlice9([FlxUIAssets.IMG_BUTTON_THIN], 80, 20, [FlxUIAssets.SLICE9_BUTTON],
									FlxUI9SliceSprite.TILE_NONE,-1,false,FlxUIAssets.IMG_BUTTON_SIZE,FlxUIAssets.IMG_BUTTON_SIZE);
		}
		ToggleButton.resize(Back.height, Back.height);
		ToggleButton.x = Back.x + Back.width - ToggleButton.width;
		
		_text = Text;
		if (_text == null) {
			_text = new FlxUIText(0, 0, Std.int(Back.width - Back.height), "Item 1");
		}
		_text.y = Back.y + (Back.height - _text.height - 2);
		_text.color = FlxColor.BLACK;
		_text.borderStyle = FlxText.BORDER_NONE;
		_text.x = 2;
		
		var yoff:Int = Std.int(Back.y + Back.height);
		
		_list = new Array<FlxUIButton>();
		
		var i:Int = 0;
		if (DataList != null) { 
			for (data in DataList) {
				var t:FlxUIButton = new FlxUIButton(0, 0, data.label);
				t.onUp.setCallback(onClickItem, [i]);
				
				t.id = data.id;
				
				t.loadGraphicSlice9([FlxUIAssets.IMG_INVIS, FlxUIAssets.IMG_HILIGHT, FlxUIAssets.IMG_HILIGHT], Std.int(Back.width),
									Std.int(Back.height),["1,1,3,3","1,1,3,3","1,1,3,3"], FlxUI9SliceSprite.TILE_NONE);
				t.labelOffsets[FlxButton.PRESSED].y -= 1;	//turn off the 1-pixel depress on click
				
				t.up_color = FlxColor.BLACK;
				t.over_color = FlxColor.WHITE;
				t.down_color = FlxColor.WHITE;
				t.label.borderStyle = FlxText.BORDER_NONE;
				
				t.resize(Back.width - 2, Back.height - 1);
				t.x = 1;
				
				t.label.alignment = "left";
				t.autoCenterLabel();
				
				for (offset in t.labelOffsets)
				{
					offset.x += 2;
				}
				
				_list.push(t);
				t.y = yoff;
				yoff += Std.int(Back.height);
				
				i++;
			}
			_text.text = DataList[0].label;
		} else if (ButtonList != null) {
			for (btn in ButtonList) {
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
		add(ToggleButton);
		add(_text);
		
		for (btn in _list) {
			add(btn);
			btn.visible = false;
		}
		
		_callback = Callback;
		_ui_control_callback = UIControlCallback;
		_button = ToggleButton;
	}
	
	public override function update():Void {
		super.update();
		if (_dropdown_active && FlxG.mouse.justPressed) {
			if (!_dropPanel.overlapsPoint(FlxG.mouse)) {
				showList(false);
			}
		}
	}	
	
	override public function destroy():Void
	{
		super.destroy();
		
		_button = FlxG.safeDestroy(_button);
		_text = FlxG.safeDestroy(_text);
		_dropPanel = FlxG.safeDestroy(_dropPanel);
		
		for (button in _list)
		{
			button = FlxG.safeDestroy(button);
		}
		
		_list = null;
		_callback = null;
		_ui_control_callback = null;
	}
	
	private function showList(b:Bool):Void {
		_dropdown_active = b;
		
		for (button in _list) {
			button.visible = b;
			button.active = b;
		}
		
		_dropPanel.visible = b;
		
		if(_ui_control_callback != null){
			_ui_control_callback(b, this);
		}
	}
	
	private function onDropdown(?params:Array<Dynamic>):Void {
		(_dropPanel.visible) ? showList(false) : showList(true);
	}
	
	private function onClickItem(i:Int):Void {
		var item:FlxUIButton = _list[i];
		_text.text = item.label.text;
		showList(false);
		if (_callback != null) {
			_callback([item.id]);
		}
	}
}