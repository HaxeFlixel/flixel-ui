package flixel.addons.ui.interfaces;

import flixel.math.FlxPoint;
import flixel.util.FlxDirectionFlags;

/**
 * ...
 * @author Lars Doucet
 */
interface IFlxUIWidget
{
	// IFlxUIWidget
	var name:String;
	var width(get, set):Float;
	var height(get, set):Float;

	/**
	 * If true, will issue FlxUI.event() and FlxUI.request() calls
	 */
	var broadcastToFlxUI:Bool;
	
	// FlxSprite
	var x(default, set):Float;
	var y(default, set):Float;
	var alpha(default, set):Float;
	var angle(default, set):Float;
	var facing(default, set):FlxDirectionFlags;
	var moves(default, set):Bool;
	var immovable(default, set):Bool;

	var offset(default, null):FlxPoint;
	var origin(default, null):FlxPoint;
	var scale(default, null):FlxPoint;
	var velocity(default, null):FlxPoint;
	var maxVelocity(default, null):FlxPoint;
	var acceleration(default, null):FlxPoint;
	var drag(default, null):FlxPoint;
	var scrollFactor(default, null):FlxPoint;

	function reset(X:Float, Y:Float):Void;
	function setPosition(X:Float = 0, Y:Float = 0):Void;
	
	// FlxBasic
	var ID:Int;
	var active(default, set):Bool;
	var visible(default, set):Bool;
	var alive(default, set):Bool;
	var exists(default, set):Bool;

	function draw():Void;
	function update(elapsed:Float):Void;
	function destroy():Void;

	function kill():Void;
	function revive():Void;

	function toString():String;
}
