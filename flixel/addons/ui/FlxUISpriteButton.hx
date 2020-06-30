package flixel.addons.ui;

import flixel.addons.ui.interfaces.IFlxUIButton;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;

/**
 * This class extends FlxUISpriteButton and has a Sprite "label"
 *
 * Like all FlxUITypedButton's, it can work as a toggle button, and load
 * 9-slice sprites for its button images, and be dynamically resized
 * accordingly.
 */
class FlxUISpriteButton extends FlxUITypedButton<FlxSprite> implements IFlxUIButton
{
	/**
	 * Creates a new FlxUISpriteButton.
	 *
	 * @param	X				The X position of the button.
	 * @param	Y				The Y position of the button.
	 * @param	Label			The text that you want to appear on the button.
	 * @param	OnClick			The function to call whenever the button is clicked.
	 */
	public function new(X:Float = 0, Y:Float = 0, ?Asset:FlxSprite, ?OnClick:Void->Void)
	{
		super(X, Y, OnClick);

		// Instead of "Label" we have "Asset" which is the id of the asset you want to load
		// If you're trying to push in a raw BitmapData object, add that to the cache first and pass in the key

		up_color = over_color = down_color = up_toggle_color = over_toggle_color = down_toggle_color = FlxColor.WHITE;

		if (Asset != null)
		{
			label = Asset;
		}
	}

	/**For IResizable:**/
	public override function resize(W:Float, H:Float):Void
	{
		super.resize(W, H);
		autoCenterLabel();
	}

	public override function autoCenterLabel():Void
	{
		if (label != null)
		{
			if ((label is FlxSpriteGroup))
			{
				var g:FlxSpriteGroup = cast label;
				for (sprite in g.group.members)
				{ // line up all their center points at 0,0
					sprite.x = (-sprite.width / 2);
					sprite.y = (-sprite.height / 2);
				}

				// Now we should have a stable width/height for the group

				var W:Float = g.width;
				var H:Float = g.height;

				for (sprite in g.members)
				{ // center them all based on the stable width/height of group
					sprite.x = (W - sprite.width) / 2;
					sprite.y = (H - sprite.height) / 2;
				}
			}
			super.autoCenterLabel(); // center the label object itself
		}
	}
}
