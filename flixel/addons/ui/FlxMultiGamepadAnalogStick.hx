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
		sInput = null;
	}

	/**
	 * Given a string of the form "left_analog_stick_x_plus", returns a StickInput object with the corresponding values
	 * @param	str
	 * @return
	 */
	public static function getStickInput(str:String):StickInput
	{
		str = str.toLowerCase();
		switch (str)
		{
			case "left_analog_stick_x_minus":
				return {id: LEFT_ANALOG_STICK, axis: X, positive: false};
			case "left_analog_stick_x_plus":
				return {id: LEFT_ANALOG_STICK, axis: X, positive: true};
			case "left_analog_stick_y_minus":
				return {id: LEFT_ANALOG_STICK, axis: Y, positive: false};
			case "left_analog_stick_y_plus":
				return {id: LEFT_ANALOG_STICK, axis: Y, positive: true};
			case "right_analog_stick_x_minus":
				return {id: RIGHT_ANALOG_STICK, axis: X, positive: false};
			case "right_analog_stick_x_plus":
				return {id: RIGHT_ANALOG_STICK, axis: X, positive: true};
			case "right_analog_stick_y_minus":
				return {id: RIGHT_ANALOG_STICK, axis: Y, positive: false};
			case "right_analog_stick_y_plus":
				return {id: RIGHT_ANALOG_STICK, axis: Y, positive: true};
		}
		return null;
	}

	private override function checkJustPressed():Bool
	{
		if (gamepad == null)
			return false;
		var dz = gamepad.deadZone;
		return switch (sInput.id)
		{
			case LEFT_ANALOG_STICK:
				if (sInput.axis == X)
				{
					if (gamepad.analog.justMoved.LEFT_STICK_X)
					{
						sInput.positive ? gamepad.analog.value.LEFT_STICK_X > dz : gamepad.analog.value.LEFT_STICK_X < -dz;
					}
					else
					{
						false;
					}
				}
				else
				{
					if (gamepad.analog.justMoved.LEFT_STICK_Y)
					{
						sInput.positive ? gamepad.analog.value.LEFT_STICK_Y > dz : gamepad.analog.value.LEFT_STICK_Y < -dz;
					}
					else
					{
						false;
					}
				}
			case RIGHT_ANALOG_STICK:
				if (sInput.axis == X)
				{
					if (gamepad.analog.justMoved.RIGHT_STICK_X)
					{
						sInput.positive ? gamepad.analog.value.RIGHT_STICK_X > dz : gamepad.analog.value.RIGHT_STICK_X < -dz;
					}
					else
					{
						false;
					}
				}
				else
				{
					if (gamepad.analog.justMoved.RIGHT_STICK_Y)
					{
						sInput.positive ? gamepad.analog.value.RIGHT_STICK_Y > dz : gamepad.analog.value.RIGHT_STICK_Y < -dz;
					}
					else
					{
						false;
					}
				}
			default: false;
		}
	}

	private override function checkJustReleased():Bool
	{
		if (gamepad == null)
			return false;
		return switch (sInput.id)
		{
			case LEFT_ANALOG_STICK:
				sInput.axis == X ? gamepad.analog.justReleased.LEFT_STICK_X : gamepad.analog.justReleased.LEFT_STICK_Y;
			case RIGHT_ANALOG_STICK:
				sInput.axis == X ? gamepad.analog.justReleased.RIGHT_STICK_X : gamepad.analog.justReleased.RIGHT_STICK_Y;
			default: false;
		}
	}

	private override function checkPressed():Bool
	{
		if (gamepad == null)
			return false;
		var value = false;
		var dz = gamepad.deadZone;
		return switch (sInput.id)
		{
			case LEFT_ANALOG_STICK:
				if (sInput.axis == X)
				{
					sInput.positive ? gamepad.analog.value.LEFT_STICK_X > dz : gamepad.analog.value.LEFT_STICK_X < -dz;
				}
				else
				{
					sInput.positive ? gamepad.analog.value.LEFT_STICK_Y > dz : gamepad.analog.value.LEFT_STICK_Y < -dz;
				}
			case RIGHT_ANALOG_STICK:
				if (sInput.axis == X)
				{
					sInput.positive ? gamepad.analog.value.RIGHT_STICK_X > dz : gamepad.analog.value.RIGHT_STICK_X < -dz;
				}
				else
				{
					sInput.positive ? gamepad.analog.value.RIGHT_STICK_Y > dz : gamepad.analog.value.RIGHT_STICK_Y < -dz;
				}
			default: value = false;
		}
		return value;
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

enum XY
{
	X;
	Y;
}

typedef StickInput =
{
	var id:FlxGamepadInputID;
	var axis:XY;
	var positive:Bool;
}
