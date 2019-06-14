package flixel.addons.ui;

import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;

/**
 * ...
 * @author larsiusprime
 */
class FlxMultiGamepad extends FlxBaseMultiInput
{
	public var gamepad:FlxGamepad;

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
		if (gamepad == null)
			return false;
		return gamepad.checkStatus(input, JUST_PRESSED);
	}

	private override function checkJustReleased():Bool
	{
		if (gamepad == null)
			return false;
		return gamepad.checkStatus(input, JUST_RELEASED);
	}

	private override function checkPressed():Bool
	{
		if (gamepad == null)
			return false;
		return gamepad.checkStatus(input, PRESSED);
	}

	private override function checkCombos(value:Bool):Bool
	{
		if (gamepad == null)
			return false;
		return gamepad.anyPressed(combos) == value;
	}

	private override function checkForbiddens(value:Bool):Bool
	{
		if (gamepad == null)
			return false;
		return gamepad.anyPressed(forbiddens) == value;
	}
}
