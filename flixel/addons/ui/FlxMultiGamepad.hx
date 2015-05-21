package flixel.addons.ui;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;

/**
 * ...
 * @author larsiusprime
 */
class FlxMultiGamepad extends FlxBaseMultiInput
{
	private var gamepad:FlxGamepad;
	
	public function new(Gamepad:FlxGamepad, Input:FlxGamepadInputID, ?Combos:Array<FlxGamepadInputID>, ?Forbiddens:Array<FlxGamepadInputID>) 
	{
		super();
		input = Input;
		gamepad = Gamepad;
		combos = Combos;
		forbiddens = Forbiddens;
	}

	override public function destroy():Void 
	{
		super.destroy();
		gamepad = null;
	}
	
	private override function checkJustPressed():Bool
	{
		if (gamepad.checkStatus(input, JUST_PRESSED) == false)
		{
			return false;
		}
		return true;
	}
	
	private override function checkJustReleased():Bool
	{
		if (gamepad.checkStatus(input, JUST_RELEASED) == false)
		{
			return false;
		}
		return true;
	}
	
	private override function checkPressed():Bool
	{
		if (gamepad.checkStatus(input, PRESSED) == false)
		{
			return false;
		}
		return true;
	}
	
	private override function checkCombos(value:Bool):Bool
	{
		return gamepad.anyPressed(combos) == value;
	}
	
	private override function checkForbiddens(value:Bool):Bool
	{
		return gamepad.anyPressed(forbiddens) == value;
	}
}