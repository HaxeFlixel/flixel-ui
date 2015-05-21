package flixel.addons.ui;

import flixel.FlxG;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxDestroyUtil;

/**
 * Makes it easier to check if, say, SHIFT+Tab is being pressed rather than just Tab by itself
 */
class FlxMultiInput implements IFlxDestroyable
{
	/**
	 * The keycode for the main key itself, ie, tab
	 */
	public var key:Null<FlxKey>;
	
	/**
	 * The buttonID for the main key itself, ie, DPAD_LEFT
	 */
	public var gamepadBtn:Null<FlxGamepadInputID>;
	
	/**
	 * The gamepad object this key is using
	 */
	public var gamepad:FlxGamepad;
	
	/**
	 * Any other keys that must be pressed at the same time, ie, shift, alt, etc
	 */
	public var comboKeys:Array<FlxKey>;
	
	/**
	 * Any other gamepad buttons that must be pressed at the same time
	 */
	public var comboGamepadBtns:Array<FlxGamepadInputID>;
	
	/**
	 * Any other keys, that if pressed at the same time, forbid the press.
	 * (Forbidden is useful so you can distinguish a "TAB" from a "SHIFT+TAB"
	 * -- you add "SHIFT" to the first one's forbidden list)
	 */
	public var forbiddenKeys:Array<FlxKey>;
	
	/**
	 * Any other gamepad buttons, that if pressed at the same time, forbid the press.
	 */
	public var forbiddenGamepadBtns:Array<FlxGamepadInputID>;
	
	public static function fromKey(Key:FlxKey, ?Combos:Array<FlxKey>, ?Forbiddens:Array<FlxKey>)
	{
		return new FlxMultiInput(Key, Combos, Forbiddens, null, null, null, null);
	}
	
	public static function fromGamepad(Gamepad:FlxGamepad, ID:FlxGamepadInputID, ?Combos:Array<FlxGamepadInputID>, ?Forbiddens:Array<FlxGamepadInputID>)
	{
		return new FlxMultiInput(null, null, null, Gamepad, ID, Combos, Forbiddens);
	}
	
	private function new(Key:FlxKey, ComboKeys:Array<FlxKey>, ForbiddenKeys:Array<FlxKey>, Gamepad:FlxGamepad, GamepadBtn:FlxGamepadInputID, ComboGamepadBtns:Array<FlxGamepadInputID>, ForbiddenGamepadBtns:Array<FlxGamepadInputID>)
	{
		key = Key;
		comboKeys = ComboKeys;
		forbiddenKeys = ForbiddenKeys;
		
		gamepad = Gamepad;
		
		gamepadBtn = GamepadBtn;
		comboGamepadBtns = ComboGamepadBtns;
		forbiddenGamepadBtns = ForbiddenGamepadBtns;
	}
	
	public function destroy():Void
	{
		comboKeys = null;
		forbiddenKeys = null;
		comboGamepadBtns = null;
		forbiddenGamepadBtns = null;
		gamepad = null;
	}
	
	/**
	 * Was the main key JUST pressed, AND are all of the combo keys currently pressed? (and none of the forbiddens?)
	 */
	
	public function justPressed():Bool
	{
		if (key != null && FlxG.keys.checkStatus(key, JUST_PRESSED) == false)
		{
			return false;
		}
		if (gamepad != null && gamepadBtn != null)
		{
			if (gamepad.checkStatus(gamepadBtn, JUST_PRESSED) == false)
			{
				return false;
			}
		}
		return passCombosAndForbiddens();
	}
	
	/**
	 * Was the main key JUST released, AND are no forbidden keys currently pressed? (Ignore whether combos were just released)
	 */
	
	public function justReleased():Bool
	{
		if (key != null && FlxG.keys.checkStatus(key, JUST_RELEASED) == false)
		{
			return false;
		}
		if (gamepad != null && gamepadBtn != null)
		{
			if (gamepad.checkStatus(gamepadBtn, JUST_RELEASED) == false)
			{
				return false;
			}
		}
		return (forbiddenKeys == null && forbiddenGamepadBtns == null) || (checkForbiddenKeys(false) && checkForbiddenGamepadBtns(false));
	}
	
	/**
	 * Is the main key and all of the combo keys currently pressed? (and none of the forbiddens?)
	 */
	
	public function pressed():Bool
	{
		if (key != null && FlxG.keys.checkStatus(key, PRESSED) == false)
		{
			return false;
		}
		if (gamepad != null && gamepadBtn != null)
		{
			if (gamepad.checkStatus(gamepadBtn, PRESSED) == false)
			{
				return false;
			}
		}
		return passCombosAndForbiddens();
	}
	
	public function equals(other:FlxMultiInput):Bool
	{
		if (key != other.key)
		{
			return false;
		}
		if (gamepadBtn != other.gamepadBtn)
		{
			return false;
		}
		if ((comboKeys == null) != (other.comboKeys == null)) 
		{
			return false;
		}
		if ((comboGamepadBtns == null) != (other.comboGamepadBtns == null))
		{
			return false;
		}
		if ((forbiddenKeys == null) != (other.forbiddenKeys == null))
		{
			return false;
		}
		if ((forbiddenGamepadBtns == null) != (other.forbiddenGamepadBtns == null))
		{
			return false;
		}
		if (comboKeys != null && other.comboKeys != null)
		{
			for (i in comboKeys)
			{
				if (other.comboKeys.indexOf(i) == -1)
				{
					return false;
				}
			}
		}
		if (forbiddenKeys != null && other.forbiddenKeys != null)
		{
			for (i in forbiddenKeys)
			{
				if (other.forbiddenKeys.indexOf(i) == -1)
				{
					return false;
				}
			}
		}
		if (comboGamepadBtns != null && other.comboGamepadBtns != null)
		{
			for (i in comboGamepadBtns)
			{
				if (other.comboGamepadBtns.indexOf(i) == -1)
				{
					return false;
				}
			}
		}
		if (forbiddenGamepadBtns != null && other.forbiddenGamepadBtns != null)
		{
			for (i in forbiddenGamepadBtns)
			{
				if (other.forbiddenGamepadBtns.indexOf(i) == -1)
				{
					return false;
				}
			}
		}
		return true;
	}
	
	/**
	 * Check Combo/Forbidden values. Default--are combos all pressed, AND are forbiddens all NOT pressed?
	 */
	
	private function passCombosAndForbiddens(comboValue:Bool=true, forbiddenValue:Bool=false):Bool
	{
		//Pass if combos don't exist, or if ALL of them match the specified boolean value
		var passComboKeys       = (comboKeys == null)        || checkComboKeys(comboValue);
		var passComboGamepadBns = (comboGamepadBtns == null) || checkComboGamepadBtns(comboValue);
		
		//Pass if forbiddens don't exist, or if ALL of them match the specified boolean value
		var passForbiddenKeys        = (forbiddenKeys == null)        || checkForbiddenKeys(forbiddenValue);
		var passForbiddenGamepadBtns = (forbiddenGamepadBtns == null) || checkForbiddenGamepadBtns(forbiddenValue);
		
		//All must pass!
		return passComboKeys && passComboGamepadBns && passForbiddenKeys && passForbiddenGamepadBtns;
	}
	
	private function checkComboKeys(value:Bool):Bool
	{
		return FlxG.keys.anyPressed(comboKeys) == value;
	}
	
	private function checkForbiddenKeys(value:Bool):Bool
	{
		return FlxG.keys.anyPressed(forbiddenKeys) == value;
	}
	
	private function checkComboGamepadBtns(value:Bool):Bool
	{
		return gamepad.anyPressed(comboGamepadBtns) == value;
	}
	
	private function checkForbiddenGamepadBtns(value:Bool):Bool
	{
		return gamepad.anyPressed(forbiddenGamepadBtns) == value;
	}
}