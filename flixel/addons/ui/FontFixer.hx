package flixel.addons.ui;
import openfl.Assets;

/**
 * A really simple little class that solves an annoying problem with Flash font file names
 * @author larsiusprime
 */
class FontFixer
{
	private static var name2File:Map<String,String>;
	
	private static function init():Void
	{
		if (name2File == null)
		{
			name2File = new Map<String,String>();
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
	
	public static function add(file:String, name:String=""):String
	{
		init();
		if (name != "" && name2File.exists(name))
		{
			return name2File.get(name);
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
		name2File.set(name, file);
		return fix(file);
	}
}