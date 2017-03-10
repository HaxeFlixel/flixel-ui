package flixel.addons.ui;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;

/**
 * ...
 * @author larsiusprime
 */
class FlxMultiGamepad extends FlxBaseMultiInput
{
	public var useFirstActive(default,set):Bool = false;
	public var gamepad:FlxGamepad;
	
	public function set_useFirstActive(b:Bool):Bool
	{
		useFirstActive = b;
		return useFirstActive;
	}
	
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
	
	private inline function checkGamepad():FlxGamepad
	{
		var gp = null;
		#if FLX_GAMEPAD
		var gp = useFirstActive ? FlxG.gamepads.firstActive : gamepad;
		if (gp == null) return gamepad;
		#end
		return gp;
	}
	
	private inline function checkStatus(Status:FlxInputState):Bool
	{
		var gp = checkGamepad();
		if (gp == null) return false;
		return gp.checkStatus(input, Status);
	}
	
	private inline function anyPressed(arr:Array<Int>):Bool
	{
		var gp = checkGamepad();
		if (gp == null) return false;
		return gp.anyPressed(arr);
	}
	
	private override function checkJustPressed():Bool
	{
		return checkStatus(JUST_PRESSED);
	}
	
	private override function checkJustReleased():Bool
	{
		return checkStatus(JUST_RELEASED);
	}
	
	private override function checkPressed():Bool
	{
		return checkStatus(PRESSED);
	}
	
	private override function checkCombos(value:Bool):Bool
	{
		return anyPressed(combos) == value;
	}
	
	private override function checkForbiddens(value:Bool):Bool
	{
		return anyPressed(forbiddens) == value;
	}
}