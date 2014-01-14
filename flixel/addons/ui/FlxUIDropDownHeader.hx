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
import flixel.util.FlxRect;

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
			background = new FlxUI9SliceSprite(0, 0, FlxUIAssets.IMG_BOX, new Rectangle(0, 0, Width, 20), "1,1,14,14");
		}

		// Button
		if (button == null) {
			button = new FlxUISpriteButton(0, 0, new FlxSprite(0, 0, FlxUIAssets.IMG_DROPDOWN));
			button.loadGraphicSlice9([FlxUIAssets.IMG_BUTTON_THIN], 80, 20, [FlxUIAssets.SLICE9_BUTTON],
									FlxUI9SliceSprite.TILE_NONE,-1, false, FlxUIAssets.IMG_BUTTON_SIZE, FlxUIAssets.IMG_BUTTON_SIZE);
		}
		button.resize(background.height, background.height);
		button.x = background.x + background.width - button.width;
		
		// Reposition and resize the button hitbox so the whole header is clickable
		button.width = Width;
		button.offset.x -= (Width - button.frameWidth);
		button.x = offset.x;
		button.label.offset.x = button.offset.x;
		
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