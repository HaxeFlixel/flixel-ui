package flixel.addons.ui;

import flixel.FlxSprite;
import flixel.util.FlxColor;

/**
 * This class extends FlxUISpriteButton and has a Sprite "label"
 * 
 * Like all FlxUITypedButton's, it can work as a toggle button, and load
 * 9-slice sprites for its button images, and be dynamically resized 
 * accordingly.
 */
class FlxUISpriteButton extends FlxUITypedButton<FlxSprite>
{	
	/**
	 * Creates a new <code>FlxUISpriteButton</code>.
	 * 
	 * @param	X				The X position of the button.
	 * @param	Y				The Y position of the button.
	 * @param	Label			The text that you want to appear on the button.
	 * @param	OnClick			The function to call whenever the button is clicked.
	 * @param	OnClickParams	The params to call the onClick function with.
	 */
	public function new(X:Float = 0, Y:Float = 0, ?Asset:FlxSprite, ?OnClick:Dynamic, ?OnClickParams:Array<Dynamic>) 
	{
		super(X, Y, null, OnClick, OnClickParams);		
		
		//Instead of "Label" we have "Asset" which is the id of the asset you want to load
		//If you're trying to push in a raw BitmapData object, add that to the cache first and pass in the key
		
		up_color = over_color = down_color = up_toggle_color = over_toggle_color = down_toggle_color = FlxColor.WHITE;	
		
		if (Asset != null) {
			label = Asset;	
		}
	}	
	
	/**For IResizable:**/
	
	public override function resize(W:Float, H:Float):Void 
	{
		super.resize(W, H);
		autoCenterLabel();
	}	
}