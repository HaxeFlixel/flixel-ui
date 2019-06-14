package flixel.addons.ui;

#if FLX_MOUSE
import flash.display.Sprite;
import flixel.FlxG;
import flixel.input.mouse.FlxMouse;

/**
 * A customized extension to FlxMouse that lets us add in accessibility stuff
 * like using the keyboard to control mouse moving/clicking
 */
class FlxUIMouse extends FlxMouse
{
	// Set this to STOP tracking the mouse position from actual mouse input
	public var updateGlobalScreenPosition:Bool = true;

	public function new(CursorContainer:Sprite)
	{
		super(CursorContainer);
	}

	/**
	 * Called by the internal game loop to update the mouse pointer's position in the game world.
	 * Also updates the just pressed/just released flags.
	 */
	private override function update():Void
	{
		var oldScreenX:Int = _globalScreenX;
		var oldScreenY:Int = _globalScreenY;

		super.update();

		if (!updateGlobalScreenPosition)
		{
			_globalScreenX = oldScreenX;
			_globalScreenY = oldScreenY;
		}
	}
}
#end
