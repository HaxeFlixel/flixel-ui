package flixel.addons.ui;

#if FLX_MOUSE
import openfl.display.Sprite;
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
	override function update():Void
	{
		#if (flixel < version("5.9.0"))
		final oldScreenX = _globalScreenX;
		final oldScreenY = _globalScreenY;
		#else
		final oldRawX = _rawX;
		final oldRawY = _rawY;
		#end
		
		super.update();

		if (!updateGlobalScreenPosition)
		{
			#if (flixel < version("5.9.0"))
			_globalScreenX = oldScreenX;
			_globalScreenY = oldScreenY;
			#else
			_rawX = oldRawX;
			_rawY = oldRawY;
			#end
			updatePositions();
		}
	}
}
#end
