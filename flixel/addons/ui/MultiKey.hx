package flixel.addons.ui;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxDestroyUtil;

/**
 * Makes it easier to check if, say, SHIFT+Tab is being pressed rather than just Tab by itself
 */
class MultiKey implements IFlxDestroyable
{
	/**
	 * The keycode for the main key itself, ie, tab
	 */
	public var key:FlxKey;
	/**
	 * Any other keys that must be pressed at the same time, ie, shift, alt, etc
	 */
	public var combos:Array<FlxKey>;
	/**
	 * Any other keys, that if pressed at the same time, forbid the press.
	 * (Forbidden is useful so you can distinguish a "TAB" from a "SHIFT+TAB"
	 * -- you add "SHIFT" to the first one's forbidden list)
	 */
	public var forbiddens:Array<FlxKey>;
	
	public function new(Key:FlxKey, ?Combos:Array<FlxKey>, ?Forbiddens:Array<FlxKey>) 
	{
		key = Key;
		combos = Combos;
		forbiddens = Forbiddens;
	}
	
	public function destroy():Void
	{
		combos = null;
		forbiddens = null;
	}
	
	/**
	 * Was the main key JUST pressed, AND are all of the combo keys currently pressed? (and none of the forbiddens?)
	 */
	
	public function justPressed():Bool
	{
		if (FlxG.keys.checkStatus(key, JUST_PRESSED) == false)
		{
			return false;
		}
		return passCombosAndForbiddens();
	}
	
	/**
	 * Was the main key JUST released, AND are no forbidden keys currently pressed? (Ignore whether combos were just released)
	 */
	
	public function justReleased():Bool
	{
		if (FlxG.keys.checkStatus(key, JUST_RELEASED) == false)
		{
			return false;
		}
		return forbiddens == null || checkForbiddens(false);
	}
	
	/**
	 * Is the main key and all of the combo keys currently pressed? (and none of the forbiddens?)
	 */
	
	public function pressed():Bool
	{
		if (FlxG.keys.checkStatus(key, PRESSED) == false)
		{
			return false;
		}
		return passCombosAndForbiddens();
	}
	
	public function equals(other:MultiKey):Bool
	{
		if (key != other.key)
		{
			return false;
		}
		if ((combos == null) != (other.combos == null)) 
		{
			return false;
		}
		if ((forbiddens == null) != (other.forbiddens == null))
		{
			return false;
		}
		if (combos != null && other.combos != null)
		{
			for (i in combos)
			{
				if (other.combos.indexOf(i) == -1)
				{
					return false;
				}
			}
		}
		if (forbiddens != null && other.forbiddens != null)
		{
			for (i in forbiddens)
			{
				if (other.forbiddens.indexOf(i) == -1)
				{
					return false;
				}
			}
		}
		return true;
	}
	
	/*********PRIVATE*********/
	
	/**
	 * Check Combo/Forbidden values. Default--are combos all pressed, AND are forbiddens all NOT pressed?
	 */
	
	private function passCombosAndForbiddens(comboValue:Bool=true,forbiddenValue:Bool=false):Bool
	{
		//Pass if combos don't exist, or if ALL of them match the specified boolean value
		var passCombos = combos == null || checkCombos(comboValue);
		
		//Pass if forbiddens don't exist, or if ALL of them match the specified boolean value
		var passForbids = forbiddens == null || checkForbiddens(forbiddenValue);
		
		//Both must pass!
		return passCombos && passForbids;
	}
	
	private function checkCombos(value:Bool):Bool
	{
		return FlxG.keys.anyPressed(combos) == value;
	}
	
	private function checkForbiddens(value:Bool):Bool
	{
		return FlxG.keys.anyPressed(forbiddens) == value;
	}
}