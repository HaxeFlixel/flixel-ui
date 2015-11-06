package flixel.addons.ui;
import flixel.addons.ui.FlxUILine.LineAxis;
import flixel.addons.ui.interfaces.IResizable;
import flixel.util.FlxColor;

/**
 * ...
 * @author larsiusprime
 */
class FlxUILine extends FlxUISprite implements IResizable
{
	public var axis(default, set):LineAxis=HORIZONTAL;
	public var length(default, set):Float=10;
	public var thickness(default, set):Float=1;
	
	public function new(X:Int,Y:Int,Axis:LineAxis,Length:Float,Thickness:Float,Color:FlxColor) 
	{
		super(X, Y);
		makeGraphic(1, 1, FlxColor.WHITE);
		color = Color;
		axis = Axis;
		length = length;
	}
	
	private function set_axis(a:LineAxis):LineAxis
	{
		axis = a;
		refresh();
		return a;
	}
	
	private function set_length(l:Float):Float
	{
		length = l;
		refresh();
		return l;
	}
	
	private function set_thickness(t:Float):Float
	{
		thickness = t;
		refresh();
		return t;
	}
	
	private function refresh():Void {
		if (axis == HORIZONTAL)
		{
			scale.set(length, thickness);
		}
		else
		{
			scale.set(thickness, length);
		}
		updateHitbox();
	}
	
	public override function resize(width:Float, height:Float):Void {
		if (axis == HORIZONTAL)
		{
			length = width;
			thickness = height;
		}
		else
		{
			length = height;
			thickness = width;
		}
	}
}

enum LineAxis {
	HORIZONTAL;
	VERTICAL;
}