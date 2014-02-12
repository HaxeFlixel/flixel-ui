package flixel.addons.ui;

import flash.geom.Rectangle;
import flixel.addons.ui.interfaces.IFlxUIButton;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.interfaces.IHasParams;
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
class FlxUIDropDownMenu extends FlxUIGroup implements IFlxUIWidget implements IFlxUIButton implements IHasParams
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
	 * The list of items that is shown when the toggle button is clicked.
	 */
	public var list:Array<FlxUIButton>;
	/**
	 * The background for the list.
	 */
	public var dropPanel:FlxUI9SliceSprite;
	
	public var params(default, set):Array<Dynamic>;
	public function set_params(p:Array <Dynamic>):Array<Dynamic>{
		params = p;
		return params;
	}
	
	public static inline var CLICK_EVENT:String = "click_dropdown";
	
	public var callback:String->Void;
	
	private var _ui_control_callback:Bool->FlxUIDropDownMenu->Void;
	
	/**
	 * This creates a new dropdown menu.
	 * 
	 * @param	X					x position of the dropdown menu
	 * @param	Y					y position of the dropdown menu
	 * @param	DataList			The data to be displayed
	 * @param	Callback			Optional Callback
	 * @param	Header				The header of this dropdown menu
	 * @param	DropPanel			Optional 9-slice-background for actual drop down menu 
	 * @param	ButtonList			Optional list of buttons to be used for the corresponding entry in DataList
	 * @param	UIControlCallback	Used internally by FlxUI
	 */
	public function new(X:Float = 0, Y:Float = 0, DataList:Array<StrIdLabel>, ?Callback:String->Void, ?Header:FlxUIDropDownHeader, ?DropPanel:FlxUI9SliceSprite, ?ButtonList:Array<FlxUIButton>, ?UIControlCallback:Bool->FlxUIDropDownMenu->Void) 
	{
		super(X, Y);
		callback = Callback;
		
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
				var t:FlxUIButton = makeListButton(i, data.label, data.id);
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
				btn.x = 1;
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
	
	/**
	 * Change the contents with a new data list
	 * Replaces the old content with the new content
	 * @param	DataList
	 */
	
	public function setData(DataList:Array<StrIdLabel>):Void {
		var i:Int = 0;
		
		var yoff:Int = Std.int((y - header.background.y) + header.background.height);
		
		if (DataList != null) {
			for (data in DataList) {
				var recycled:Bool = false;
				if (list != null) {
					if (i <= list.length - 1) {								//If buttons exist, try to re-use them
						
						var btn:FlxUIButton = list[i];
						if(btn != null){
							btn.label.text = data.label;					//Set the label
							var old_id:String = list[i].id;
							list[i].id = data.id;							//Replace the id
							recycled = true;								//we successfully recycled it
							yoff += Std.int(header.background.height);
						}
					}
				}else {
					list = [];
				}
				if (!recycled) {											//If we couldn't recycle a button, make a fresh one
					var t:FlxUIButton = makeListButton(i, data.label, data.id);
					list.push(t);
					t.y = yoff;
					add(t);
					t.visible = false;
					yoff += Std.int(header.background.height);
				}
				i++;
			}
			
			//Remove excess buttons:
			if (list.length > DataList.length) {				//we have more entries in the original set
				for (j in DataList.length...list.length) {	//start counting from end of list
					var b:FlxUIButton = list.pop();				//remove last button on list
					b.visible = false;
					b.active = false;
					remove(b, true);							//remove from widget
					b.destroy();								//destroy it
					b = null;
				}
			}
			
			header.text.text = DataList[0].label;
		}
		
		dropPanel.resize(header.background.width, yoff);
	}
	
	private function makeListButton(i:Int,Label:String,Name:String):FlxUIButton {
		var t:FlxUIButton = new FlxUIButton(0, 0, Label);
		t.broadcastToFlxUI = false;
		t.onUp.callback = onClickItem.bind(i);
		
		t.id = Name;
		
		t.loadGraphicSlice9([FlxUIAssets.IMG_INVIS, FlxUIAssets.IMG_HILIGHT, FlxUIAssets.IMG_HILIGHT], Std.int(header.background.width),
							 Std.int(header.background.height),[[1,1,3,3],[1,1,3,3],[1,1,3,3]], FlxUI9SliceSprite.TILE_NONE);
		t.labelOffsets[FlxButton.PRESSED].y -= 1;	// turn off the 1-pixel depress on click
		
		t.up_color = FlxColor.BLACK;
		t.over_color = FlxColor.WHITE;
		t.down_color = FlxColor.WHITE;
		
		t.resize(header.background.width - 2, header.background.height - 1);
		
		t.label.alignment = "left";
		t.autoCenterLabel();
		t.x = 1;
		
		for (offset in t.labelOffsets)
		{
			offset.x += 2;
		}
		
		return t;
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
		_ui_control_callback = null;
		callback = null;
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
		
		if(broadcastToFlxUI){
			FlxUI.event(CLICK_EVENT, this, item.id, params);
		}
	}
	
	/**
	 * Helper function to easily create a data list for a dropdown menu from an array of strings.
	 * 
	 * @param	StringArray		The strings to use as data - used for both label and string ID.
	 * @param	UseIndexID		Whether to use the integer index of the current string as ID.
	 * @return	The StrIDLabel array ready to be used in FlxUIDropDownMenu's constructor
	 */
	public static function makeStrIdLabelArray(StringArray:Array<String>, UseIndexID:Bool = false):Array<StrIdLabel>
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