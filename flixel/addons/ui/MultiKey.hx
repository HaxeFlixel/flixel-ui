package flixel.addons.ui;
import flixel.FlxG;
import flixel.interfaces.IFlxDestroyable;
import flixel.util.FlxDestroyUtil;

/**
 * Makes it easier to check if, say, SHIFT+Tab is being pressed rather than just Tab by itself
 * @author 
 */
class MultiKey implements IFlxDestroyable
{
	public var key:Int;					//the keycode for the main key itself, ie, tab
	public var combos:Array<Int>;		//any other keys that must be pressed at the same time, ie, shift, alt, etc
	public var forbiddens:Array<Int>;	//any other keys, that if pressed at the same time, forbid the press
										//forbidden is useful so you can distinguish a "TAB" from a "SHIFT+TAB"
										//-- you add "SHIFT" to the first one's forbidden list
	
	public function new(Key:Int,?Combos:Array<Int>=null,?Forbiddens:Array<Int>=null) 
	{
		key = Key;
		combos = Combos;
		forbiddens = Forbiddens;
	}
	
	public function destroy():Void
	{
		U.clearArraySoft(combos);
		U.clearArraySoft(forbiddens);
		combos = null;
		forbiddens = null;
	}
	
	/**
	 * Was the main key JUST pressed, AND are all of the combo keys currently pressed? (and none of the forbiddens?)
	 * @return
	 */
	
	public function justPressed():Bool {
		if (FlxG.keys.justPressed.check(key) == false)
		{
			return false;
		}
		return passCombosAndForbiddens();
	}
	
	/**
	 * Was the main key JUST released, AND are no forbidden keys currently pressed? (Ignore whether combos were just released)
	 * @return
	 */
	
	public function justReleased():Bool {
		 if (FlxG.keys.justReleased.check(key) == false)
		{
			return false;
		}
		return checkForbiddens(false);
	}
	
	/**
	 * Is the main key and all of the combo keys currently pressed? (and none of the forbiddens?)
	 * @return
	 */
	
	public function pressed():Bool {
		if (FlxG.keys.pressed.check(key) == false)
		{
			return false;
		}
		return passCombosAndForbiddens();
	}
	
	public function equals(other:MultiKey):Bool {
		if (key != key)
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
		if(combos != null && other.combos != null){
			for (i in combos) {
				if (other.combos.indexOf(i) == -1) {
					return false;
				}
			}
		}
		if (forbiddens != null && other.forbiddens != null) {
			for (i in forbiddens) {
				if (other.forbiddens.indexOf(i) == -1) {
					return false;
				}
			}
		}
		return true;
	}
	
	/*********PRIVATE*********/
	
	private var _justReleased:Bool = false;
	
	/**
	 * Check Combo/Forbidden values. Default--are combos all pressed, AND are forbiddens all NOT pressed?
	 * @return
	 */
	
	private function passCombosAndForbiddens(comboValue:Bool=true,forbiddenValue:Bool=false):Bool
	{
		return checkCombos(comboValue) && checkForbiddens(forbiddenValue);
	}
	
	private function checkCombos(value:Bool):Bool {
		if (combos != null)
		{
			for (otherKey in combos) 
			{
				if (FlxG.keys.pressed.check(otherKey) != value)
				{
					return false;
				}
			}
		}
		return true;
	}
	
	private function checkForbiddens(value:Bool):Bool {
		if (forbiddens != null)
		{
			for (forbiddenKey in forbiddens)
			{
				if (FlxG.keys.pressed.check(forbiddenKey) != value)
				{
					return false;
				}
			}
		}
		return true;
	}
}