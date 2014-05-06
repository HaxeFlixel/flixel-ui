package flixel.addons.ui;
import flash.text.TextField;
import flash.text.TextFormat;
import flixel.addons.ui.BorderDef;
import flixel.text.FlxText;
import openfl.Assets;

/**
 * ...
 * @author larsiusprime
 */
class FontDef
{
	public var name:String;			//the actual NAME of the font, say, "Verdana"
	public var size:Int;
	public var extension:String;	//the extension of the font, usuall ".ttf"
	public var file:String;			//the actual full path to the FILE of the font, say, "assets/fonts/verdana.ttf"
	public var format:TextFormat;	//any necessary formatting information
	public var border:BorderDef;
	
	private static var EXTENSIONS:Array<String> = [".ttf", ".otf"];	//supported font file extensions
	
	public function new(Name:String, Extension:String=".ttf",File:String="",?Format:TextFormat,?Border:BorderDef)
	{
		name = Name;
		extension = Extension;
		file = File;
		format = Format;
		if (format == null) {
			format = new TextFormat();
		}
		border = Border;
		if (border == null) {
			border = new BorderDef(FlxText.BORDER_NONE, 0x000000);
		}
	}
	
	public static function copyFromTextField(t:TextField):FontDef{
		var dtf:TextFormat = t.defaultTextFormat;
		var fd = new FontDef("");
		fd.fromStr(dtf.font);
		fd.format.font = dtf.font;
		fd.format.size = dtf.size;
		fd.format.color = dtf.color;
		fd.format.bold = dtf.bold;
		fd.format.italic = dtf.italic;
		fd.format.underline = dtf.underline;
		fd.format.url = dtf.url;
		fd.format.target = dtf.target;
		fd.format.align = dtf.align;
		return fd;
	}
	
	public static function copyFromFlxText(t:FlxText):FontDef{
		var fd = copyFromTextField(t.textField);
		fd.fromStr(t.font);
		fd.border.style = t.borderStyle;
		fd.border.color = t.borderColor;
		fd.border.quality = t.borderQuality;
		fd.border.size = t.borderSize;
		return fd;
	}
	
	public function apply(?textField:TextField, ?flxText:FlxText):Void {
		if (textField != null) {
			textField.setTextFormat(format);
		}
		if (flxText != null) {
			if (file == "" || file == null) {
				flxText.setFormat(null, format.size, format.color, cast format.align, border.style, border.color);	//default font
			}else {
				flxText.setFormat(file, format.size, format.color, cast format.align, border.style, border.color);
			}
		}
	}
	
	/**
	 * Given a str like "verdanab.ttf", reverse-engineer the basic font properties
	 * @param	str	a string name of a font, such as "verdanab.ttf"
	 */
	
	public function fromStr(str:String,recursion:Int=0):Void
	{
		if (recursion > 3) {
			return;						//no infinite loops, please
		}
		
		var style = getFontStyle(str);
		setFontStyle(style);
		
		var extension:String = "";
		var exists:Bool = false;
		
		for (ext in EXTENSIONS) {
			if (str.indexOf(ext) != -1) {	//if it has a particular extension
				if(Assets.exists(str + extension, AssetType.FONT)){
					name = StringTools.replace(str, extension, "");
					file = str;
					extension = ext;
					break;
				}
			}
		}
		
		//can't find the font entry
		if (extension == "") {		//...because there was no extension?
			for (ext in EXTENSIONS) {
				if (Assets.exists(str + ext, AssetType.FONT)) {	//try adding each extension on and seeing if it works
					extension = ext;							//if that works, we'll go with that extension
					name = str;
					file = str + extension;
					extension = ext;
					break;
				}
			}
		}
		else 
		{	//there was an extension, but we had another problem
			str = stripFontExtensions(str);
			var fontStyle = getFontStyle(str);
			if (fontStyle != "") {							//it had a style character
				str = str.substr(str.length - 1, 1);		//strip off the style char
				fromStr(str,recursion+1);								//try again with this
			}
			else {											//it had no style character
				fromStr(str,recursion+1);								//try again with this
			}
		}
		
		setFontStyle(style);
		
		//I give up
		return null;
	}
	
	/**
	 * If a recognized font extension exists, remove it from the font str
	 * @param	str font + extension, ie "verdanab.ttf"
	 * @return	font - extension, ie "verdanab"
	 */
	
	private function stripFontExtensions(str:String):String {
		for (ext in EXTENSIONS) {
			if(str.indexOf(ext) != -1){
				str = StringTools.replace(str, ext, "");
			}
		}
		return str;
	}
	
	/**
	 * See if a style is "baked" into the font str, and if so return it
	 * @param	str font string, ie, "verdanab", "verdanai", "verdanaz"
	 * @return	"b" for bold, "i" for italic, "z" for bold-italic, "" for normal
	 */
	
	private function getFontStyle(str:String):String {
		str = stripFontExtensions(str);
		var lastChar:String = str.substr(str.length - 1, 1);
		if (lastChar != "" && lastChar != null) {
			lastChar = lastChar.toLowerCase();
			switch(lastChar) {
				case "b": return "b";
				case "i": return "i";
				case "z": return "z";
				default: return "";
			}
		}
		return "";
	}
	
	public function setFontStyle(str:String):Void {
		str = str.toLowerCase();
		switch(str) {
			case "b","bold":
				format.bold = true;
				format.italic = false;
			case "i","italic":
				format.bold = false;
				format.italic = true;
			case "z","bi","ib","bold-italic","bolditalic","italicbold","all","both":
				format.bold = true;
				format.italic = true;
			default:
				format.bold = false;
				format.italic = false;
		}
	}
}