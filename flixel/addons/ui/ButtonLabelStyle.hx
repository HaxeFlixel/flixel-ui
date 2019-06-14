package flixel.addons.ui;

import flixel.text.FlxText;

class ButtonLabelStyle
{
	public var font:FontDef = null;
	public var border:BorderDef = null;
	public var color:Null<Int> = null;
	public var align:FlxTextAlign = null;

	public function new(?Font:FontDef, ?Align:FlxTextAlign, ?Color:Int, ?Border:BorderDef)
	{
		font = Font;
		border = Border;
		color = Color;
		align = Align;
	}

	public function apply(f:FlxText):Void
	{
		if (font != null)
		{
			font.apply(f);
		}
		if (border != null)
		{
			border.apply(f);
		}
		if (color != null)
		{
			f.color = color;
		}
		if (align != null)
		{
			f.alignment = align;
		}
	}
}
