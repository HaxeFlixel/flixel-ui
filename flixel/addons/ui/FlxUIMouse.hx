package flixel.addons.ui;

import flash.display.Sprite;
import flixel.FlxG;
import flixel.input.mouse.FlxMouse;

/**
 * A customized extension to FlxMouse that lets us add in accessibility stuff
 * like using the keyboard to control mouse moving/clicking
 * @author 
 */
class FlxUIMouse extends FlxMouse
{
	//Set this to STOP tracking the mouse position from actual mouse input
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
		if (updateGlobalScreenPosition)
		{
			_globalScreenPosition.x = Math.floor(FlxG.game.mouseX);
			_globalScreenPosition.y = Math.floor(FlxG.game.mouseY);
		}
		
		//actually position the flixel mouse cursor graphic
		if (visible)
		{
			cursorContainer.x = _globalScreenPosition.x;
			cursorContainer.y = _globalScreenPosition.y;
		}
		updateCursor();
		
		// Update the buttons
		_leftButton.update();
		#if !FLX_NO_MOUSE_ADVANCED
		_middleButton.update();
		_rightButton.update();
		#end
		
		// Update the wheel
		if (!_wheelUsed)
		{
			wheel = 0;
		}
		_wheelUsed = false;
	}
}
