package org.flixel.plugin.leveluplabs;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFormat;
import org.flixel.FlxG;
import org.flixel.FlxText;

/**
 * Simple extension to the basic text field class. Basically, 
 * this lets me stick drop-shadows on things :)
 * @author Lars Doucet
 */

class FlxTextX extends FlxText
{

	public var dropShadow(get_dropShadow, set_dropShadow):Bool;	
	private var _dropShadow:Bool = false;
	public var bold(default, set_bold):Bool;
	
	public function new(X:Float, Y:Float, Width:Int, Text:String = null, EmbeddedFont:Bool = true)	
	{
		super(X, Y, Width, Text, EmbeddedFont);
	}
	
	public function textWidth():Float {	return _textField.textWidth; }
	public function textHeight():Float { return _textField.textHeight; }
	
	public function get_dropShadow():Bool {
		return _dropShadow;
	}
	
	public function set_dropShadow(b:Bool):Bool {
		_dropShadow = b;
		
		if (_dropShadow) 
		{
			#if flash
				addFilter(new GlowFilter(_shadow, 1, 2, 2, 2, 1, false, false));
				addFilter(new DropShadowFilter(1, 45, _shadow, 1, 1, 1, 0.25));
			#else
				//filters currently broken in NME. Wait for a fix.
			#end
		} 
		else
		{
			removeAllFilters();
		}
		
		return _dropShadow;
	}	
	
	function set_bold(b:Bool):Bool
	{
		var format:TextFormat = _format;
		format.bold = b;
		_textField.setTextFormat(format);
		return b;
	}
	
}