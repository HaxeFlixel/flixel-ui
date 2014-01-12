package flixel.addons.ui;

import flixel.FlxSprite;

/**
 * This class extends FlxUISpriteButton and has a Sprite "label"
 * 
 * Like all FlxUITypedButton's, it can work as a toggle button, and load
 * 9-slice sprites for its button images, and be dynamically resized 
 * accordingly.
 * 
 * Furthermore, you have the ability to
 */
class FlxUISpriteButton extends FlxUITypedButton<FlxSprite>
{
	public function new(X:Float = 0, Y:Float = 0, ?Asset:FlxSprite, ?OnClick:Dynamic) {
		super(X, Y, null, OnClick);		
	
		//Instead of "Label" we have "Asset" which is the id of the asset you want to load
		//If you're trying to push in a raw BitmapData object, add that to the cache first and pass in the key
		
		up_color = over_color = down_color = up_toggle_color = over_toggle_color = down_toggle_color = 0xffffff;	
		
		if (Asset != null) {
			label = Asset;	
		}
	}	
	
	/**For IResizable:**/
	
	public override function resize(W:Float, H:Float):Void {
		super.resize(W, H);
		autoCenterLabel();
	}	
}