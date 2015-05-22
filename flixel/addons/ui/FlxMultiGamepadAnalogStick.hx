package flixel.addons.ui;
import flixel.addons.ui.FlxMultiGamepadAnalogStick.StickInput;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;

/**
 * ...
 * @author larsiusprime
 */
class FlxMultiGamepadAnalogStick extends FlxMultiGamepad
{
	private var sInput:StickInput;
	
	public function new(Gamepad:FlxGamepad, Input:StickInput, ?Combos:Array<FlxGamepadInputID>, ?Forbiddens:Array<FlxGamepadInputID>) 
	{
		sInput = Input;
		super(Gamepad, Input.id, Combos, Forbiddens);
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		gamepad = null;
	}
	
	private override function checkJustPressed():Bool
	{
		var value = false;
		var dz = gamepad.deadZone;
		switch(sInput.id)
		{
			case LEFT_ANALOG_STICK: 
				if (sInput.axis == X)
				{
					if (gamepad.analog.justMoved.LEFT_STICK_X)
					{
						value = (sInput.positive ? gamepad.analog.value.LEFT_STICK_X > dz : gamepad.analog.value.LEFT_STICK_X < -dz);
					}
				}
				else if (sInput.axis == Y)
				{
					if (gamepad.analog.justMoved.LEFT_STICK_Y)
					{
						value = (sInput.positive ? gamepad.analog.value.LEFT_STICK_Y > dz : gamepad.analog.value.LEFT_STICK_Y < -dz);
					}
				}
			case RIGHT_ANALOG_STICK:
				if (sInput.axis == X)
				{
					if (gamepad.analog.justMoved.RIGHT_STICK_X)
					{
						value = (sInput.positive ? gamepad.analog.value.RIGHT_STICK_X > dz : gamepad.analog.value.RIGHT_STICK_X < -dz);
					}
				}
				else if (sInput.axis == Y)
				{
					if (gamepad.analog.justMoved.RIGHT_STICK_Y)
					{
							value = (sInput.positive ? gamepad.analog.value.RIGHT_STICK_Y > dz : gamepad.analog.value.RIGHT_STICK_Y < -dz);
					}
				}
			default: value = false;
		}
		return value;
	}
	
	private override function checkJustReleased():Bool
	{
		return switch(sInput.id)
		{
			case LEFT_ANALOG_STICK:  sInput.axis == X ? gamepad.analog.justReleased.LEFT_STICK_X  : gamepad.analog.justReleased.LEFT_STICK_Y;
			case RIGHT_ANALOG_STICK: sInput.axis == X ? gamepad.analog.justReleased.RIGHT_STICK_X : gamepad.analog.justMoved.RIGHT_STICK_Y;
			default: false;
		}
	}
	
	private override function checkPressed():Bool
	{
		var value = false;
		var dz = gamepad.deadZone;
		switch(sInput.id)
		{
			case LEFT_ANALOG_STICK: 
				if (sInput.axis == X)
				{
					value = (sInput.positive ? gamepad.analog.value.LEFT_STICK_X > dz : gamepad.analog.value.LEFT_STICK_X  < -dz);
				}
				else if (sInput.axis == Y)
				{
					value = (sInput.positive ? gamepad.analog.value.LEFT_STICK_Y > dz : gamepad.analog.value.LEFT_STICK_Y  < -dz);
				}
			case RIGHT_ANALOG_STICK:
				if (sInput.axis == X)
				{
					value = (sInput.positive ? gamepad.analog.value.RIGHT_STICK_X > dz : gamepad.analog.value.RIGHT_STICK_X  < -dz);
				}
				else if (sInput.axis == Y)
				{
					value = (sInput.positive ? gamepad.analog.value.RIGHT_STICK_Y > dz : gamepad.analog.value.RIGHT_STICK_Y  < -dz);
				}
			default: value = false;
		}
		return value;
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

enum XY
{
	X;
	Y;
}

typedef StickInput = {
	var id:FlxGamepadInputID;
	var axis:XY;
	var positive:Bool;
}