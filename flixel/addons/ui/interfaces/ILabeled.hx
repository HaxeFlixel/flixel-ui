package flixel.addons.ui.interfaces;

import flixel.addons.ui.FlxUIText;
import flixel.text.FlxText;

/**
 * ...
 * @author Lars Doucet
 */
 interface ILabeled {
	function get_label():FlxUIText;
	function set_label(t:FlxUIText):FlxUIText;
}

