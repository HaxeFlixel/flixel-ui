package flixel.addons.ui;

import flash.geom.Rectangle;
import flixel.addons.ui.interfaces.IFlxUIButton;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxColor;
import flixel.util.FlxPoint;
import flixel.util.FlxRect;
import flixel.util.FlxStringUtil;

/**
 * larsiusprime
 * @author 
 */
class FlxUIDropDownMenu extends FlxUIGroup implements IFlxUIWidget implements IFlxUIButton
{
	public var skipButtonUpdate(default, set):Bool;
	public function set_skipButtonUpdate(b:Bool):Bool {
		header.button.skipButtonUpdate = b;
		return b;
	}
	
	/**
	 * The header of this dropdown menu.
	 */
	public var header:FlxUIDropDownHeader;
	/**
	 * Function to be called when of of the entries of the list was clicked.
	 */
	public var callback:String->Void;
	/**
	 * The list of items that is shown when the toggle button is clicked.
	 */
	public var list:Array<FlxUIButton>;
	/**
	 * The background for the list.
	 */
	public var dropPanel:FlxUI9SliceSprite;
	
	private var _ui_control_callback:Bool->FlxUIDropDownMenu->Void;

	/**
	 * This creates a new dropdown menu.
	 * 
	 * @param	X					x position of the dropdown menu
	 * @param	Y					y position of the dropdown menu
	 * @param	DataList			The data to be displayed
	 * @param	Header				The header of this dropdown menu
	 * @param	DropPanel			Optional 9-slice-background for actual drop down menu 
	 * @param	ButtonList			Optional list of buttons to be used for the corresponding entry in DataList
	 * @param	UIControlCallback	Used internally by FlxUI
	 */
	public function new(X:Float = 0, Y:Float = 0, DataList:Array<StrIdLabel>, ?Header:FlxUIDropDownHeader, ?DropPanel:FlxUI9SliceSprite, ?ButtonList:Array<FlxUIButton>, ?UIControlCallback:Bool->FlxUIDropDownMenu->Void) 
	{
		super(X, Y);
		
		header = Header;
		if (header == null)
		{
			header = new FlxUIDropDownHeader();
		}
		
		var yoff:Int = Std.int(header.background.y + header.background.height);
		
		list = [];
		
		var i:Int = 0;
		if (DataList != null) 
		{ 
			for (data in DataList) 
			{
				var t:FlxUIButton = new FlxUIButton(0, 0, data.label);
				t.onUp.callback = onClickItem.bind(i);
				
				t.id = data.id;
				
				t.loadGraphicSlice9([FlxUIAssets.IMG_INVIS, FlxUIAssets.IMG_HILIGHT, FlxUIAssets.IMG_HILIGHT], Std.int(header.background.width),
									Std.int(header.background.height),[[1,1,3,3],[1,1,3,3],[1,1,3,3]], FlxUI9SliceSprite.TILE_NONE);
				t.labelOffsets[FlxButton.PRESSED].y -= 1;	// turn off the 1-pixel depress on click
				
				t.up_color = FlxColor.BLACK;
				t.over_color = FlxColor.WHITE;
				t.down_color = FlxColor.WHITE;
				
				t.resize(header.background.width - 2, header.background.height - 1);
				t.x = 1;
				
				t.label.alignment = "left";
				t.autoCenterLabel();
				
				for (offset in t.labelOffsets)
				{
					offset.x += 2;
				}
				
				list.push(t);
				t.y = yoff;
				yoff += Std.int(header.background.height);
				
				i++;
			}
			header.text.text = DataList[0].label;
		} 
		else if (ButtonList != null) 
		{
			for (btn in ButtonList) 
			{
				list.push(btn);
				btn.resize(header.background.width, header.background.height);
				btn.y = yoff;
				yoff += Std.int(header.background.height);
				
				i++;
			}
		}
		
		dropPanel = DropPanel;
		if (dropPanel == null) {
			var rect = new Rectangle(0 , 0, header.background.width, header.background.height);
			dropPanel = new FlxUI9SliceSprite(0, 0, FlxUIAssets.IMG_BOX, rect, [1,1,14,14]);
		}
		
		dropPanel.y = header.background.y;
		dropPanel.resize(header.background.width, yoff);
		dropPanel.visible = false;
		add(dropPanel);
		
		for (btn in list) {
			add(btn);
			btn.visible = false;
		}
		
		_ui_control_callback = UIControlCallback;
		header.button.onUp.callback = onDropdown;
		
		add(header);
	}
	
	public function setUIControlCallback(UIControlCallback:Bool->FlxUIDropDownMenu->Void):Void {
		_ui_control_callback = UIControlCallback;
	}
	
	public function changeLabelByIndex(i:Int, NewLabel:String):Void {
		var btn:FlxUIButton = getBtnByIndex(i);
		if (btn != null && btn.label != null) {
			btn.label.text = NewLabel;
		}
	}
	
	public function changeLabelById(id:String, NewLabel:String):Void {
		var btn:FlxUIButton = getBtnById(id);
		if (btn != null && btn.label != null) {
			btn.label.text = NewLabel;
		}
	}
	
	public function getBtnByIndex(i:Int):FlxUIButton {
		if (i >= 0 && i < list.length) {
			return list[i];
		}
		return null;
	}
	
	public function getBtnById(id:String):FlxUIButton{
		for (btn in list) {
			if (btn.id == id) {
				return btn;
			}
		}
		return null;
	}
	
	public override function update():Void 
	{
		super.update();
		
		#if (!FLX_NO_MOUSE && !FLX_NO_TOUCH)
		if (dropPanel.visible && FlxG.mouse.justPressed) 
		{
			if (!dropPanel.overlapsPoint(FlxG.mouse)) 
			{
				showList(false);
			}
		}
		#end
	}	
	
	override public function destroy():Void
	{
		super.destroy();
		
		dropPanel = FlxG.safeDestroy(dropPanel);
		
		for (button in list)
		{
			button = FlxG.safeDestroy(button);
		}
		
		list = null;
		callback = null;
		_ui_control_callback = null;
	}
	
	private function showList(b:Bool):Void 
	{
		for (button in list) {
			button.visible = b;
			button.active = b;
		}
		
		dropPanel.visible = b;
		
		if(_ui_control_callback != null){
			_ui_control_callback(b, this);
		}
	}
	
	private function onDropdown():Void 
	{
		(dropPanel.visible) ? showList(false) : showList(true);
	}
	
	private function onClickItem(i:Int):Void 
	{
		var item:FlxUIButton = list[i];
		header.text.text = item.label.text;
		showList(false);
		
		if (callback != null) {
			callback(item.id);
		}
	}
	
	/**
	 * Helper function to easily create a data list for a dropdown menu from an array of strings.
	 * 
	 * @param	StringArray		The strings to use as data - used for both label and string ID.
	 * @param	UseIndexID		Whether to use the integer index of the current string as ID.
	 * @return	The StrIDLabel array ready to be used in FlxUIDropDownMenu's constructor
	 */
	static public function makeStrIdLabelArray(StringArray:Array<String>, UseIndexID:Bool = false):Array<StrIdLabel>
	{
		var strIdArray:Array<StrIdLabel> = [];
		for (i in 0...StringArray.length)
		{
			var ID:String = StringArray[i];
			if (UseIndexID)
			{
				ID = Std.string(i);
			}
			strIdArray[i] = new StrIdLabel(ID, StringArray[i]);
		}
		return strIdArray;
	}
}

/**
 * Header for a FlxUIDropDownMenu
 */
class FlxUIDropDownHeader extends FlxUIGroup
{
	/**
	 * The background of the header.
	 */
	public var background:FlxSprite;
	/**
	 * The text that displays the currently selected item.
	 */
	public var text:FlxUIText;
	/**
	 * The button that toggles the visibility of the dropdown panel.
	 */
	public var button:FlxUISpriteButton;
	
	/**
	 * Creates a new dropdown header to be used in a FlxUIDropDownMenu.
	 * 
	 * @param	Width	Width of the dropdown - only relevant when no back sprite was specified
	 * @param	Back	Optional sprite to be placed in the background
	 * @param 	Text	Optional text that displays the current value
	 * @param	Button	Optional button that toggles the dropdown list
	 */
	public function new(Width:Int = 120, ?Background:FlxSprite, ?Text:FlxUIText, ?Button:FlxUISpriteButton)
	{
		super();
		
		background = Background;
		text = Text;
		button = Button;
		
		// Background
		if (background == null) {
			background = new FlxUI9SliceSprite(0, 0, FlxUIAssets.IMG_BOX, new Rectangle(0, 0, Width, 20), [1,1,14,14]);
		}

		// Button
		if (button == null) {
			button = new FlxUISpriteButton(0, 0, new FlxSprite(0, 0, FlxUIAssets.IMG_DROPDOWN));
			button.loadGraphicSlice9([FlxUIAssets.IMG_BUTTON_THIN], 80, 20, 
									[FlxStringUtil.toIntArray(FlxUIAssets.SLICE9_BUTTON)],
									FlxUI9SliceSprite.TILE_NONE, -1, false, FlxUIAssets.IMG_BUTTON_SIZE, FlxUIAssets.IMG_BUTTON_SIZE);
		}
		button.resize(background.height, background.height);
		button.x = background.x + background.width - button.width;
		
		// Reposition and resize the button hitbox so the whole header is clickable
		button.width = Width;
		button.offset.x -= (Width - button.frameWidth);
		button.x = offset.x;
		button.label.offset.x += button.offset.x;
		
		// Text
		if (text == null) {
			text = new FlxUIText(0, 0, Std.int(background.width));
		}
		text.setPosition(2, 4);
		text.color = FlxColor.BLACK;
		
		add(background);
		add(button);
		add(text);
	}
	
	override public function destroy():Void
	{
		super.destroy();
		
		background = FlxG.safeDestroy(background);
		text = FlxG.safeDestroy(text);
		button = FlxG.safeDestroy(button);
	}
}