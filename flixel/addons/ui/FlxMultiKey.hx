package flixel.addons.ui;

import flixel.input.keyboard.FlxKey;

/**
 * ...
 * @author larsiusprime
 */
class FlxMultiKey extends FlxBaseMultiInput
{
	public function new(Input:FlxKey, ?Combos:Array<FlxKey>, ?Forbiddens:Array<FlxKey>)
	{
		super();
		input = Input;
		combos = Combos;
		forbiddens = Forbiddens;
	}

	#if FLX_KEYBOARD
	private override function checkJustPressed():Bool
	{
		return FlxG.keys.checkStatus(input, JUST_PRESSED);
	}

	private override function checkJustReleased():Bool
	{
		return FlxG.keys.checkStatus(input, JUST_RELEASED);
	}

	private override function checkPressed():Bool
	{
		return FlxG.keys.checkStatus(input, PRESSED);
	}

	private override function checkCombos(value:Bool):Bool
	{
		return FlxG.keys.anyPressed(combos) == value;
	}

	private override function checkForbiddens(value:Bool):Bool
	{
		return FlxG.keys.anyPressed(forbiddens) == value;
	}
	#end
}
