package flixel.addons.ui;

import openfl.Assets;
#if (openfl >= "4.0.0")
import openfl.utils.AssetType;
#end

/**
 * A really simple little class that solves an annoying problem with Flash font file names
 * @author larsiusprime
 */
class FontFixer
{
	private static var name2File:Map<String, String>;

	private static function init():Void
	{
		if (name2File == null)
		{
			name2File = new Map<String, String>();
		}
	}

	public static function fix(font:String):String
	{
		init();
		if (font.indexOf(".ttf") == -1)
		{
			if (name2File.exists(font))
			{
				font = name2File.get(font);
			}
		}
		return font;
	}

	public static function add(file:String, name:String = ""):String
	{
		init();
		if (name != "" && name2File.exists(name))
		{
			return name2File.get(name);
		}

		if (!Assets.exists(file, AssetType.FONT))
		{
			return file;
		}

		var font = Assets.getFont(file);
		if (font == null)
		{
			return file;
		}

		if (name == "")
		{
			name = font.fontName;
		}
		#if flash
		// edge case for flash: if we've got a mangled font file like "assets/fonts/Verdana Bold.ttf", strip it down to "Verdana Bold" and look up
		// the correct font file name
		if (name == null && (file.indexOf("/") != -1 || file.indexOf(".ttf") != -1 || file.indexOf(".otf") != -1))
		{
			var lastSlash = file.lastIndexOf("/");
			var tempf = file.substr(lastSlash + 1, file.length - (lastSlash + 1));
			tempf = StringTools.replace(tempf, ".ttf", "");
			tempf = StringTools.replace(tempf, ".otf", "");
			if (name2File.exists(tempf))
			{
				return name2File.get(tempf);
			}
		}
		#end
		name2File.set(name, file);
		return fix(file);
	}
}
