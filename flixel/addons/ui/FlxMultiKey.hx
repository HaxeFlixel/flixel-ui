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
	
	private override function checkJustPressed():Bool
	{
		if (FlxG.keys.checkStatus(input, JUST_PRESSED) == false)
		{
			return false;
		}
		return true;
	}
	
	private override function checkJustReleased():Bool
	{
		if (FlxG.keys.checkStatus(input, JUST_RELEASED) == false)
		{
			return false;
		}
		return true;
	}
	
	private override function checkPressed():Bool
	{
		if (FlxG.keys.checkStatus(input, PRESSED) == false)
		{
			return false;
		}
		return true;
	}
	
	private override function checkCombos(value:Bool):Bool
	{
		return FlxG.keys.anyPressed(combos) == value;
	}
	
	private override function checkForbiddens(value:Bool):Bool
	{
		return FlxG.keys.anyPressed(forbiddens) == value;
	}
}