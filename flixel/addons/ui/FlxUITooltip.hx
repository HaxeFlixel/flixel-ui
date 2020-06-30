package flixel.addons.ui;

import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.FlxObject;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import openfl.geom.Rectangle;
import openfl.display.BitmapData;
import openfl.geom.Matrix;
import openfl.text.TextFormat;

/**
 * ...
 * @author larsiusprime
 */
class FlxUITooltip extends FlxUIGroup
{
	public var style(default, set):FlxUITooltipStyle;
	public var anchor(default, set):Anchor;
	public var title(default, set):String;
	public var body(default, set):String;

	public function new(Width:Int, Height:Int, ?Anchor_:Anchor, ?Style:FlxUITooltipStyle)
	{
		super(0, 0);

		if (Anchor_ == null)
		{
			Anchor_ = new Anchor(0, 0, "left", "top", "right", "top"); // Default to appearing flush to the top-left of the object
		}

		Style = styleFix(Style);

		refresh(Width, Height, "", "", Anchor_, Style);
		setScrollFactor(0, 0);
	}

	public function show(obj:FlxObject, Title:String = "", Body:String = "", AutoSizeVertical:Bool = true, AutoSizeHorizontal:Bool = true,
			ShowArrow:Bool = true):Void
	{
		visible = true;
		active = true;

		// hard reset all the positions to 0,0
		x = 0;
		y = 0;
		_bkg.x = 0;
		_bkg.y = 0;
		_arrow.x = 0;
		_arrow.y = 0;
		_arrowBkg.x = 0;
		_arrowBkg.y = 0;

		_arrowBkg = makeArrowBkg(_arrowBkg);
		_arrow.color = style.background;

		_arrow.visible = _arrowBkg.visible = ShowArrow;

		if (style.titleWidth > 0)
		{
			_titleText.width = Std.int(_titleText.textField.width = style.titleWidth);
		}
		if (style.bodyWidth > 0)
		{
			_bodyText.width = Std.int(_bodyText.textField.width = style.bodyWidth);
		}

		if (style.titleFormat != null)
		{
			style.titleFormat.apply(_titleText);
		}
		if (style.bodyFormat != null)
		{
			style.bodyFormat.apply(_bodyText);
		}

		if (style.titleBorder != null)
		{
			style.titleBorder.apply(_titleText);
		}
		if (style.bodyBorder != null)
		{
			style.bodyBorder.apply(_bodyText);
		}

		_titleText.text = Title;
		_bodyText.text = Body;

		_titleText.update(0);
		_bodyText.update(0);

		var titleHeight = Std.int(_titleText.textField.textHeight + 4);

		if (style.titleOffset != null)
		{
			_titleText.x = Std.int(style.titleOffset.x);
			_titleText.y = Std.int(style.titleOffset.y);
		}
		if (style.bodyOffset != null)
		{
			_bodyText.x = Std.int(style.bodyOffset.x);
			_bodyText.y = Std.int(_titleText.y + titleHeight + style.bodyOffset.y);
		}

		var W:Int = Std.int(_bkg.width);
		var H:Int = Std.int(_bkg.height);

		if (AutoSizeHorizontal)
		{
			var tw = (_titleText.text != "" ? _titleText.x + _titleText.width : 0);
			var bw = (_bodyText.text != "" ? _bodyText.x + _bodyText.width : 0);
			W = Std.int(Math.max(tw, bw));
		}

		if (AutoSizeVertical)
		{
			var th = (_titleText.text != "" ? _titleText.y + _titleText.height : 0);
			var bh = (_bodyText.text != "" ? _bodyText.y + _bodyText.height : 0);
			H = Std.int(Math.max(th, bh));
			H = Std.int(Math.max(H, _arrowBkg.height));
		}

		if (style.leftPadding == null)
			style.leftPadding = 0;
		if (style.rightPadding == null)
			style.rightPadding = 0;
		if (style.topPadding == null)
			style.topPadding = 0;
		if (style.bottomPadding == null)
			style.bottomPadding = 0;

		// add padding to expand the background size
		W += style.leftPadding + style.rightPadding;
		H += style.topPadding + style.bottomPadding;

		W = Std.int(W);
		H = Std.int(H);

		refreshBkg(W, H, style);

		var oldOffX = Std.int(_anchorArrow.x.offset);
		var oldOffY = Std.int(_anchorArrow.y.offset);

		_anchorArrow.x.offset -= anchor.x.offset;
		_anchorArrow.y.offset += anchor.y.offset;

		_anchorArrow.x.offset = Std.int(_anchorArrow.x.offset);
		_anchorArrow.y.offset = Std.int(_anchorArrow.y.offset);

		_anchorArrow.anchorThing(_arrow, _bkg); // anchor arrow to background

		_anchorArrow.x.offset = oldOffX;
		_anchorArrow.y.offset = oldOffY;

		if (_arrow.x < 0)
		{
			var xx:Int = Std.int(Math.abs(_arrow.x));
			_bkg.x += xx;
			_titleText.x += xx;
			_bodyText.x += xx;
			_arrow.x = 0;
		}
		if (_arrow.y < 0)
		{
			var yy:Int = Std.int(Math.abs(_arrow.y));
			_bkg.y += yy;
			_titleText.y += yy;
			_bodyText.y += yy;
			_arrow.y = 0;
		}

		if (_titleText.text != "" && _bodyText.text == "")
		{
			// if title is the "only" text...
			// add additional offset for vertical centering
			// remove padding first here or it will result in a wrong placement
			var tempH = (H - (style.topPadding + style.bottomPadding));
			var titleOnlyOffset = Std.int((tempH - titleHeight) / 2);
			_titleText.y += titleOnlyOffset;
		}

		// offset text based on the background size
		_titleText.x += style.leftPadding;
		_bodyText.x += style.leftPadding;

		_titleText.y += style.topPadding;
		_bodyText.y += style.topPadding;

		// if either text field has no text, at the last minute make sure they don't throw off the size calculation

		if (_titleText.text == "")
		{
			_titleText.x = _bkg.x;
			_titleText.y = _bkg.y;
			_titleText.width = _bkg.width;
		}

		if (_bodyText.text == "")
		{
			_bodyText.x = _bkg.x;
			_bodyText.y = _bkg.y;
			_bodyText.width = _bkg.width;
		}

		anchor.anchorThing(this, obj); // anchor entire group to object

		x = Std.int(x);
		y = Std.int(y);

		_arrowBkg.x = Std.int(_arrow.x - style.borderSize);
		_arrowBkg.y = Std.int(_arrow.y - style.borderSize);

		_titleText.x = Std.int(_titleText.x);
		_bodyText.x = Std.int(_bodyText.x);
		_bkg.x = Std.int(_bkg.x);
		_bkg.y = Std.int(_bkg.y);
		_arrowBkg.x = Std.int(_arrowBkg.x);
		_arrowBkg.y = Std.int(_arrowBkg.y);
		_arrow.x = Std.int(_arrow.x);
		_arrow.y = Std.int(_arrow.y);
	}

	// dirty hack, but it makes tooltips work -- simply exclude FlxTexts from height calculations
	override private function get_height():Float
	{
		if (length == 0)
		{
			return 0;
		}

		var minY:Float = Math.POSITIVE_INFINITY;
		var maxY:Float = Math.NEGATIVE_INFINITY;

		for (member in _sprites)
		{
			if (member == null)
				continue;
			if ((member is FlxText))
				continue;
			var minMemberY:Float = member.y;
			var maxMemberY:Float = minMemberY + member.height;

			if (maxMemberY > maxY)
			{
				maxY = maxMemberY;
			}
			if (minMemberY < minY)
			{
				minY = minMemberY;
			}
		}
		return maxY - minY;
	}

	public function hide():Void
	{
		visible = false;
		active = false;
	}

	/***SETTERS***/
	public function set_anchor(a:Anchor):Anchor
	{
		anchor = a;
		_anchorArrow = getArrowAnchor(a, _anchorArrow);
		if (_arrowBkg != null)
		{
			makeArrowBkg(_arrowBkg);
		}
		return a;
	}

	public function set_style(s:FlxUITooltipStyle):FlxUITooltipStyle
	{
		style = s;
		return s;
	}

	public function set_title(t:String):String
	{
		title = t;
		return t;
	}

	public function set_body(b:String):String
	{
		body = b;
		return b;
	}

	/*************/
	private var _bkg:FlxSprite;

	private var _titleText:FlxUIText;
	private var _bodyText:FlxUIText;
	private var _arrow:FlxSprite;
	private var _arrowBkg:FlxSprite;
	private var _anchorArrow:Anchor;

	private function refresh(Width:Int, Height:Int, Title:String, Body:String, Anchor_:Anchor, Style:FlxUITooltipStyle)
	{
		// create the stuff
		var newBkg = _bkg == null;
		var newArrow = _arrow == null;
		var newTitle = _titleText == null;
		var newBody = _bodyText == null;
		if (newBkg)
		{
			_bkg = new FlxSprite();
		}
		if (newArrow)
		{
			_arrow = new FlxSprite();
		}
		if (newTitle)
		{
			_titleText = new FlxUIText(0, 0, Width);
			if (Style.titleFormat != null)
			{
				Style.titleFormat.apply(_titleText);
			}
			if (Style.titleBorder != null)
			{
				Style.titleBorder.apply(_titleText);
			}
		}
		if (newBody)
		{
			_bodyText = new FlxUIText(0, 0, Width);
			if (Style.bodyFormat != null)
			{
				Style.bodyFormat.apply(_bodyText);
			}
			if (Style.bodyBorder != null)
			{
				Style.bodyBorder.apply(_bodyText);
			}
		}

		_titleText.text = Title;
		_bodyText.text = Body;

		// load the arrow
		_arrow.color = Style.background;
		var test = FlxG.bitmap.add(Style.arrow);
		if (Style.arrow == null)
		{
			Style.arrow = FlxUIAssets.IMG_TOOLTIP_ARROW;
			FlxG.bitmap.add(Style.arrow);
		}
		_arrow.loadGraphic(Style.arrow, true, test.height, test.height);

		if (newArrow)
		{
			_arrow.animation.add("right", [0], 0, false);
			_arrow.animation.add("down", [1], 0, false);
			_arrow.animation.add("left", [2], 0, false);
			_arrow.animation.add("up", [3], 0, false);
		}

		refreshBkg(Width, Height, Style);
		style = Style;

		if (newArrow && Style.borderSize > 0)
		{
			_arrowBkg = new FlxSprite();
			add(_arrowBkg);
		}

		anchor = Anchor_;

		if (newBkg)
		{
			add(_bkg);
		}

		if (newArrow)
		{
			add(_arrow);
		}

		if (newTitle)
		{
			add(_titleText);
		}

		if (newBody)
		{
			add(_bodyText);
		}
	}

	private function refreshBkg(Width:Int, Height:Int, Style:FlxUITooltipStyle):Void
	{
		// load the background
		var key = getStyleKey(Width, Height, Style);
		if (!FlxG.bitmap.checkCache(key))
		{
			var pix:BitmapData = null;
			if (Style.borderSize > 0)
			{
				pix = new BitmapData(Width, Height, false, Style.borderColor);
				pix.fillRect(new Rectangle(Style.borderSize, Style.borderSize, Width - (Style.borderSize * 2), Height - (Style.borderSize * 2)),
					Style.background);
			}
			else
			{
				pix = new BitmapData(Width, Height, false, Style.background);
			}
			FlxG.bitmap.add(pix, true, key);
		}
		_bkg.loadGraphic(key);
	}

	private function getStyleKey(W:Int, H:Int, Style:FlxUITooltipStyle):String
	{
		return W + "," + H + "," + Style.background.toHexString() + "," + Style.borderSize + "," + Style.borderColor.toHexString();
	}

	private function makeArrowBkg(b:FlxSprite):FlxSprite
	{
		if (b == null)
		{
			b = new FlxSprite();
		}
		var animName = _arrow == null ? "null" : (_arrow.animation.curAnim == null ? "null" : _arrow.animation.curAnim.name);

		var key = "arrowBkg:" + style.background + "," + style.borderSize + "," + style.borderColor + "," + animName;

		if (!FlxG.bitmap.checkCache(key))
		{
			var bs = style.borderSize;
			if (bs < 0 || bs == null)
			{
				bs = 0;
			}

			var W = Std.int(_arrow.width + (bs));
			var H = Std.int(_arrow.height + (bs));

			var bd:BitmapData = new BitmapData(W, H, true, FlxColor.TRANSPARENT);
			FlxG.bitmap.add(bd, false, key);
			b.loadGraphic(key);

			var oldColor = _arrow.color;

			_arrow.color = style.borderColor;

			var m:Matrix = new Matrix();
			m.identity();
			for (yy in 0...3)
			{
				for (xx in 0...3)
				{
					if (yy != 1 || xx != 1)
					{
						b.stamp(_arrow, xx * style.borderSize, yy * style.borderSize);
					}
				}
			}

			_arrow.color = oldColor;
		}

		b.loadGraphic(key);

		return b;
	}

	private function getArrowAnchor(a:Anchor, ?result:Anchor):Anchor
	{
		// figure out which side(s) is/are physically "touching" the object
		var touchHorz = ((a.x.side == Anchor.LEFT && a.x.flush == Anchor.RIGHT) || (a.x.side == Anchor.RIGHT && a.x.flush == Anchor.LEFT));
		var touchVert = ((a.y.side == Anchor.TOP && a.y.flush == Anchor.BOTTOM) || (a.y.side == Anchor.BOTTOM && a.y.flush == Anchor.TOP));

		var matchHorz = ((a.x.side == Anchor.LEFT && a.x.flush == Anchor.LEFT) || (a.x.side == Anchor.RIGHT && a.x.flush == Anchor.RIGHT));
		var matchVert = ((a.y.side == Anchor.TOP && a.y.flush == Anchor.TOP) || (a.y.side == Anchor.BOTTOM && a.y.flush == Anchor.BOTTOM));

		var touchBoth = (touchHorz && touchVert);
		var matchBoth = (matchHorz && matchVert);

		var off:Int = style.borderSize;

		if (!touchBoth)
		{
			if (touchHorz)
			{
				result = a.getFlipped(true, false, result);
				if (result.x.flush == Anchor.LEFT)
				{
					result.x.offset -= off;
					_arrow.animation.play("right");
				}
				if (result.x.flush == Anchor.RIGHT)
				{
					result.x.offset += off;
					_arrow.animation.play("left");
				}
			}
			if (touchVert)
			{
				result = a.getFlipped(false, true, result);
				if (result.y.flush == Anchor.TOP)
				{
					result.y.offset -= off;
					_arrow.animation.play("down");
				}
				if (result.y.flush == Anchor.BOTTOM)
				{
					result.y.offset += off;
					_arrow.animation.play("up");
				}
			}
		}

		if (!matchBoth)
		{
			if (matchHorz)
			{
				if (result.x.flush == Anchor.LEFT)
				{
					result.x.offset += off;
				}
				if (result.x.flush == Anchor.RIGHT)
				{
					result.x.offset -= off;
				}
			}
			if (matchVert)
			{
				if (result.y.flush == Anchor.TOP)
				{
					result.y.offset += off;
				}
				if (result.y.flush == Anchor.BOTTOM)
				{
					result.y.offset -= off;
				}
			}
		}

		if (result != null)
		{
			return result;
		}

		return a;
	}

	@:allow(flixel.addons.ui.FlxUITooltipManager)
	private static function styleFix(Style:FlxUITooltipStyle, ?DefaultStyle:FlxUITooltipStyle):FlxUITooltipStyle
	{
		if (Style == null)
		{
			Style = {
				titleFormat: null,
				bodyFormat: null,
				titleBorder: null,
				bodyBorder: null,
				titleOffset: null,
				bodyOffset: null,
				background: null,
				borderSize: -1,
				borderColor: null,
				arrow: null,
				titleWidth: -1,
				bodyWidth: -1,
				autoSizeHorizontal: null,
				autoSizeVertical: null,
				leftPadding: -1,
				rightPadding: -1,
				topPadding: -1,
				bottomPadding: -1
			};
		}

		// If a Default style exists, replace null values with that

		if (DefaultStyle != null)
		{
			if (Style.titleFormat == null)
			{
				Style.titleFormat = DefaultStyle.titleFormat;
			}
			if (Style.bodyFormat == null)
			{
				Style.bodyFormat = DefaultStyle.bodyFormat;
			}
			if (Style.titleBorder == null)
			{
				Style.titleBorder = DefaultStyle.titleBorder;
			}
			if (Style.bodyBorder == null)
			{
				Style.bodyBorder = DefaultStyle.bodyBorder;
			}
			if (Style.titleOffset == null)
			{
				Style.titleOffset = DefaultStyle.titleOffset;
			}
			if (Style.bodyOffset == null)
			{
				Style.bodyOffset = DefaultStyle.bodyOffset;
			}
			if (Style.background == null)
			{
				Style.background = DefaultStyle.background;
			}
			if (Style.borderColor == null)
			{
				Style.borderColor = DefaultStyle.borderColor;
			}
			if (Style.arrow == null)
			{
				Style.arrow = DefaultStyle.arrow;
			}

			if (Style.borderSize == null || Style.borderSize < 0)
			{
				Style.borderSize = DefaultStyle.borderSize;
			}
			if (Style.titleWidth == null || Style.titleWidth < 0)
			{
				Style.titleWidth = DefaultStyle.titleWidth;
			}
			if (Style.bodyWidth == null || Style.bodyWidth < 0)
			{
				Style.bodyWidth = DefaultStyle.bodyWidth;
			}
			if (Style.autoSizeHorizontal == null)
			{
				Style.autoSizeHorizontal = DefaultStyle.autoSizeHorizontal;
			}
			if (Style.autoSizeVertical == null)
			{
				Style.autoSizeVertical = DefaultStyle.autoSizeVertical;
			}

			if (Style.leftPadding == null || Style.leftPadding < 0)
			{
				Style.leftPadding = DefaultStyle.leftPadding;
			}
			if (Style.rightPadding == null || Style.rightPadding < 0)
			{
				Style.rightPadding = DefaultStyle.rightPadding;
			}
			if (Style.topPadding == null || Style.topPadding < 0)
			{
				Style.topPadding = DefaultStyle.topPadding;
			}
			if (Style.leftPadding == null || Style.bottomPadding < 0)
			{
				Style.bottomPadding = DefaultStyle.bottomPadding;
			}
		}

		// Fill any null gaps in the Style.titleFormat with the DefaultStyle.titleFormat
		if (DefaultStyle != null)
		{
			if (Style.titleFormat != null)
			{
				fillFontDefNulls(Style.titleFormat, DefaultStyle.titleFormat);
				if (Style.titleFormat.format != null && DefaultStyle.titleFormat.format != null)
				{
					fillFormatNulls(Style.titleFormat.format, DefaultStyle.titleFormat.format);
				}
			}
			if (Style.bodyFormat != null)
			{
				fillFontDefNulls(Style.bodyFormat, DefaultStyle.bodyFormat);
				if (Style.bodyFormat.format != null && DefaultStyle.bodyFormat.format != null)
				{
					fillFormatNulls(Style.bodyFormat.format, DefaultStyle.bodyFormat.format);
				}
			}
		}

		// Any remaining nulls are replaced by these standard always-safe values
		if (Style.titleFormat == null)
		{
			Style.titleFormat = new FontDef(null, null, null, new TextFormat(null, 8, FlxColor.BLACK), null);
		}
		if (Style.bodyFormat == null)
		{
			Style.bodyFormat = new FontDef(null, null, null, new TextFormat(null, 8, FlxColor.BLACK), null);
		}

		if (Style.titleBorder == null)
		{
			Style.titleBorder = new BorderDef(FlxTextBorderStyle.NONE, FlxColor.TRANSPARENT, 0, 1);
		}
		if (Style.bodyBorder == null)
		{
			Style.bodyBorder = new BorderDef(FlxTextBorderStyle.NONE, FlxColor.TRANSPARENT, 0, 1);
		}
		if (Style.titleOffset == null)
		{
			Style.titleOffset = new FlxPoint(0, 0);
		}
		if (Style.bodyOffset == null)
		{
			Style.bodyOffset = new FlxPoint(0, 0);
		}
		if (Style.background == null)
		{
			Style.background = 0xFFFFCA;
		}
		if (Style.borderColor == null)
		{
			Style.borderColor = FlxColor.BLACK;
		}
		if (Style.arrow == null)
		{
			Style.arrow = FlxUIAssets.IMG_TOOLTIP_ARROW;
		}

		if (Style.borderSize == null || Style.borderSize < 0)
		{
			Style.borderSize = 1;
		}
		if (Style.titleWidth == null || Style.titleWidth < 0)
		{
			Style.titleWidth = 100;
		}
		if (Style.bodyWidth == null || Style.bodyWidth < 0)
		{
			Style.bodyWidth = 100;
		}
		if (Style.autoSizeHorizontal == null)
		{
			Style.autoSizeHorizontal = true;
		}
		if (Style.autoSizeVertical == null)
		{
			Style.autoSizeVertical = true;
		}

		if (Style.leftPadding == null || Style.leftPadding < 0)
		{
			Style.leftPadding = 0;
		}
		if (Style.rightPadding == null || Style.rightPadding < 0)
		{
			Style.rightPadding = 0;
		}
		if (Style.topPadding == null || Style.topPadding < 0)
		{
			Style.topPadding = 0;
		}
		if (Style.leftPadding == null || Style.bottomPadding < 0)
		{
			Style.bottomPadding = 0;
		}

		return Style;
	}

	public static function cloneStyle(s:FlxUITooltipStyle):FlxUITooltipStyle
	{
		var tf = ((s.titleFormat != null) ? s.titleFormat.clone() : null);
		var bf = ((s.bodyFormat != null) ? s.bodyFormat.clone() : null);
		// SOMETHING IS GOING WRONG HERE
		var obj = {
			titleFormat: tf,
			bodyFormat: bf,
			borderSize: s.borderSize,
			titleWidth: s.titleWidth,
			bodyWidth: s.bodyWidth,
			background: s.background,
			borderColor: s.borderColor,
			arrow: s.arrow,
			titleOffset: s.titleOffset.copyTo(),
			bodyOffset: s.bodyOffset.copyTo(),
			titleBorder: s.titleBorder.clone(),
			bodyBorder: s.bodyBorder.clone(),
			autoSizeVertical: s.autoSizeVertical,
			autoSizeHorizontal: s.autoSizeHorizontal,
			leftPadding: s.leftPadding,
			rightPadding: s.rightPadding,
			topPadding: s.topPadding,
			bottomPadding: s.bottomPadding
		}
		return obj;
	}

	private static function fillFontDefNulls(a:FontDef, b:FontDef):Void
	{
		if (a.size == 0)
			a.size = b.size;
		if (a.name == null || a.name == "")
			a.name = b.name;
		if (a.file == null || a.file == "")
			a.file = b.file;
		if (a.extension == null || a.extension == "")
			a.extension = b.extension;
		if (a.border == null)
			a.border = (b.border != null) ? b.border.clone() : null;
	}

	private static function fillFormatNulls(a:TextFormat, b:TextFormat):Void
	{
		if (a.align == null)
			a.align = b.align;
		if (a.blockIndent == null)
			a.blockIndent = b.blockIndent;
		if (a.bold == null)
			a.bold = b.bold;
		if (a.bullet == null)
			a.bullet = b.bullet;
		if (a.color == null)
			a.color = b.color;
		if (a.font == null)
			a.font = b.font;
		if (a.indent == null)
			a.indent = b.indent;
		if (a.italic == null)
			a.italic = b.italic;
		if (a.kerning == null)
			a.kerning = b.kerning;
		if (a.leading == null)
			a.leading = b.leading;
		if (a.leftMargin == null)
			a.leftMargin = b.leftMargin;
		if (a.letterSpacing == null)
			a.letterSpacing = b.letterSpacing;
		if (a.rightMargin == null)
			a.rightMargin = b.rightMargin;
		if (a.size == null)
			a.size = b.size;
		if (a.tabStops == null)
			a.tabStops = b.tabStops;
		if (a.target == null)
			a.target = b.target;
		if (a.underline == null)
			a.underline = b.underline;
		if (a.url == null)
			a.url = b.url;
	}
}

typedef FlxUITooltipStyle =
{
	?titleFormat:FontDef,
	?bodyFormat:FontDef,
	?borderSize:Int,
	?titleWidth:Int,
	?bodyWidth:Int,
	?background:Null<FlxColor>,
	?borderColor:Null<FlxColor>,
	?arrow:FlxGraphicAsset,
	?titleOffset:FlxPoint,
	?bodyOffset:FlxPoint,
	?titleBorder:BorderDef,
	?bodyBorder:BorderDef,
	?autoSizeVertical:Bool,
	?autoSizeHorizontal:Bool,
	?leftPadding:Int,
	?rightPadding:Int,
	?bottomPadding:Int,
	?topPadding:Int
}
