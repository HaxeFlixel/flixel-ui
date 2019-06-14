package flixel.addons.ui;

import flixel.text.FlxText;
import flixel.util.FlxColor;

class BorderDef
{
	public var style:FlxTextBorderStyle;
	public var color:FlxColor;
	public var size:Float;
	public var quality:Float;

	public function new(Style:FlxTextBorderStyle, Color:FlxColor, Size:Float = 1, Quality:Float = 1)
	{
		style = Style;
		color = Color;
		size = Size;
		quality = Quality;
	}

	public function clone():BorderDef
	{
		return new BorderDef(style, color, size, quality);
	}

	public function apply(f:FlxText):FlxText
	{
		f.setBorderStyle(style, color, size, quality);
		return f;
	}

	public static function fromXML(data:Xml):BorderDef
	{
		var border_str:String = U.xml_str(data, "border");
		var border_style:FlxTextBorderStyle = NONE;
		var border_color:Int = U.xml_color(data, "border_color", true, FlxColor.TRANSPARENT);
		var border_size:Float = U.xml_f(data, "border_size", 1);
		var border_quality:Float = U.xml_f(data, "border_quality", 0);

		var borderDef = new BorderDef(border_style, border_color, border_size, border_quality);

		switch (border_str)
		{
			case "false", "none":
				borderDef.style = NONE;
			case "shadow":
				borderDef.style = SHADOW;
			case "outline":
				borderDef.style = OUTLINE;
			case "outline_fast":
				borderDef.style = OUTLINE_FAST;
			case "":
				// no "border" value, check for shortcuts:
				// try "outline"
				border_str = U.xml_str(data, "shadow", true, "");
				if (border_str != "" && border_str != "false" && border_str != "none")
				{
					borderDef.style = SHADOW;
					borderDef.color = U.parseHex(border_str, false, true);
				}
				else
				{
					border_str = U.xml_str(data, "outline", true, "");
					if (border_str != "" && border_str != "false" && border_str != "none")
					{
						borderDef.style = OUTLINE;
						borderDef.color = U.parseHex(border_str, false, true);
					}
					else
					{
						border_str = U.xml_str(data, "outline_fast");
						if (border_str != "" && border_str != "false" && border_str != "none")
						{
							borderDef.style = OUTLINE_FAST;
							borderDef.color = U.parseHex(border_str, false, true);
						}
					}
				}
		}
		return borderDef;
	}
}
