package flixel.addons.ui.interfaces;

import flixel.addons.ui.FlxUIText;
import flixel.text.FlxText;

/**
 * ...
 * @author Lars Doucet
 */
interface ILabeled
{
	function getLabel():FlxUIText;
	function setLabel(t:FlxUIText):FlxUIText;
}
