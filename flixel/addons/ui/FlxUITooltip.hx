package flixel.addons.ui;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.FlxObject;
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
			Anchor_ = new Anchor(0, 0, "left", "top", "right", "top");	//Default to appearing flush to the top-left of the object
		}
		
		Style = styleFix(Style);
		
		refresh(Width, Height, "", "", Anchor_, Style);
		setScrollFactor(0, 0);
	}
	
	public function show(obj:FlxObject, Title:String = "", Body:String = "", AutoSizeVertical:Bool = true, AutoSizeHorizontal:Bool = true):Void
	{
		visible = true;
		active = true;
		
		//hard reset all the positions to 0,0
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
		
		if (style.titleWidth > 0)
		{
			_titleText.width = _titleText.textField.width = style.titleWidth;
		}
		if (style.bodyWidth > 0)
		{
			_bodyText.width  = _bodyText.textField.width  = style.bodyWidth;
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
		
		var titleHeight = _titleText.textField.textHeight + 4;
		var bodyHeight = _bodyText.textField.textHeight + 4;
		
		if (style.titleOffset != null)
		{
			_titleText.x = style.titleOffset.x;
			_titleText.y = style.titleOffset.y;
		}
		if (style.bodyOffset != null)
		{
			_bodyText.x = style.bodyOffset.x;
			_bodyText.y = _titleText.y + titleHeight + style.bodyOffset.y;
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
		
		if (style.leftPadding == null) style.leftPadding = 0;
		if (style.rightPadding == null) style.rightPadding = 0;
		if (style.topPadding == null) style.topPadding = 0;
		if (style.bottomPadding == null) style.bottomPadding = 0;
		
		//add padding to expand the background size
		W += style.leftPadding + style.rightPadding;
		H += style.topPadding + style.bottomPadding;
		
		refreshBkg(W, H, style);
		
		var oldOffX = _anchorArrow.x.offset;
		var oldOffY = _anchorArrow.y.offset;
		
		_anchorArrow.x.offset -= anchor.x.offset;
		_anchorArrow.y.offset += anchor.y.offset;
		
		_anchorArrow.anchorThing(_arrow, _bkg);	//anchor arrow to background
		
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
			//if title is the "only" text...
			//add additional offset for vertical centering
			var titleOnlyOffset = Std.int((H - titleHeight) / 2);
			_titleText.y += titleOnlyOffset;
		}
		
		//offset text based on the background size
		_titleText.x += style.leftPadding;
		_bodyText.x  += style.leftPadding;
		
		_titleText.y += style.topPadding;
		_bodyText.y  += style.topPadding;
		
		//if either text field has no text, at the last minute make sure they don't throw off the size calculation
		
		if (_titleText.text == "") 
		{
			_titleText.x = _bkg.x;
			_titleText.y = _bkg.y;
		}
		
		if (_bodyText.text == "")
		{
			_bodyText.x = _bkg.x;
			_bodyText.y = _bkg.y;
		}
		
		anchor.anchorThing(this, obj);			//anchor entire group to object
		
		_arrowBkg.x = _arrow.x - style.borderSize;
		_arrowBkg.y = _arrow.y - style.borderSize;
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
		//create the stuff
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
		
		//load the arrow
		_arrow.color = Style.background;
		var test = FlxG.bitmap.add(Style.arrow);
		_arrow.loadGraphic(Style.arrow, true, test.height, test.height);
		
		if (newArrow)
		{
			_arrow.animation.add("right", [0], 0, false);
			_arrow.animation.add("down",  [1], 0, false);
			_arrow.animation.add("left",  [2], 0, false);
			_arrow.animation.add("up",    [3], 0, false);
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
	
	private function refreshBkg(Width:Int,Height:Int,Style:FlxUITooltipStyle):Void
	{
		//load the background
		var key = getStyleKey(Width, Height, Style);
		if (!FlxG.bitmap.checkCache(key))
		{
			var pix:BitmapData = null;
			if (Style.borderSize > 0)
			{
				pix = new BitmapData(Width, Height, false, Style.borderColor);
				pix.fillRect(new Rectangle(Style.borderSize, Style.borderSize, Width - (Style.borderSize * 2), Height - (Style.borderSize * 2)), Style.background);
			}
			else
			{
				pix = new BitmapData(Width, Height, false, Style.background);
			}
			FlxG.bitmap.add(pix, true, key);
		}
		_bkg.loadGraphic(key);
	}
	
	private function getStyleKey(W:Int,H:Int,Style:FlxUITooltipStyle):String
	{
		return W + "," + H + "," + Style.background.toHexString() + "," + Style.borderSize +"," + Style.borderColor.toHexString();
	}
	
	private function makeArrowBkg(b:FlxSprite):FlxSprite
	{
		if (b == null)
		{
			b = new FlxSprite();
		}
		var animName = _arrow == null ? "null" : (_arrow.animation.curAnim == null ? "null" : _arrow.animation.curAnim.name);
		
		var key = "arrowBkg:" + style.background + "," + style.borderSize+"," + style.borderColor + ","+animName;
		
		if (!FlxG.bitmap.checkCache(key))
		{
			var bs = style.borderSize;
			if (bs < 0 || bs == null)
			{
				bs = 0;
			}
			
			var W = Std.int(_arrow.width  + (bs));
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
						b.stamp(_arrow, xx*style.borderSize, yy*style.borderSize);
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
		//figure out which side(s) is/are physically "touching" the object
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
	private static function styleFix(Style:FlxUITooltipStyle):FlxUITooltipStyle
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
		
		//Default style if none is supplied
		if (Style.titleFormat == null) { Style.titleFormat = new FontDef(null, null, null, new TextFormat(null, 8, FlxColor.BLACK), null); }
		if (Style.bodyFormat  == null) { Style.bodyFormat  = new FontDef(null, null, null, new TextFormat(null, 8, FlxColor.BLACK), null); }
		if (Style.titleBorder == null) { Style.titleBorder = new BorderDef(FlxTextBorderStyle.NONE, FlxColor.TRANSPARENT, 0, 1); }
		if (Style.bodyBorder  == null) { Style.bodyBorder  = new BorderDef(FlxTextBorderStyle.NONE, FlxColor.TRANSPARENT, 0, 1); }
		if (Style.titleOffset == null) { Style.titleOffset = new FlxPoint(0, 0); }
		if (Style.bodyOffset  == null) { Style.bodyOffset  = new FlxPoint(0, 0); }
		if (Style.background  == null) { Style.background  = 0xFFFFCA; }
		if (Style.borderColor == null) { Style.borderColor = FlxColor.BLACK; }
		if (Style.arrow       == null) { Style.arrow       = FlxUIAssets.IMG_TOOLTIP_ARROW; }
		
		if (Style.borderSize  == null || Style.borderSize  < 0)
		                               { Style.borderSize  = 1; }
		if (Style.titleWidth  == null || Style.titleWidth  < 0)
		                               { Style.titleWidth  = 100; }
		if (Style.bodyWidth   == null || Style.bodyWidth   < 0)
		                               { Style.bodyWidth   = 100; }
		if (Style.autoSizeHorizontal == null)
		                               { Style.autoSizeHorizontal = true; }
		if (Style.autoSizeVertical   == null)
		                               { Style.autoSizeVertical   = true; }
		
		if (Style.leftPadding == null  || Style.leftPadding    < 0)
		                                { Style.leftPadding    = 0; }
		if (Style.rightPadding == null || Style.rightPadding   < 0)
		                                { Style.rightPadding   = 0; }
		if (Style.topPadding == null   || Style.topPadding     < 0)
		                                { Style.topPadding     = 0; }
		if (Style.leftPadding == null  || Style.bottomPadding  < 0)
		                                { Style.bottomPadding  = 0; }
		
		return Style;
	}
	
	public static function cloneStyle(s:FlxUITooltipStyle):FlxUITooltipStyle
	{
		return {
			titleFormat : s.titleFormat != null ? s.titleFormat.clone() : null,
			bodyFormat  : s.bodyFormat != null ? s.bodyFormat.clone() : null,
			borderSize  : s.borderSize,
			titleWidth  : s.titleWidth,
			bodyWidth   : s.bodyWidth,
			background  : s.background,
			borderColor : s.borderColor,
			arrow       : s.arrow,
			titleOffset : s.titleOffset.copyTo(),
			bodyOffset  : s.bodyOffset.copyTo(),
			titleBorder : s.titleBorder.clone(),
			bodyBorder  : s.bodyBorder.clone(),
			autoSizeVertical  : s.autoSizeVertical,
			autoSizeHorizontal: s.autoSizeHorizontal,
			leftPadding  : s.leftPadding,
			rightPadding : s.rightPadding,
			topPadding   : s.topPadding,
			bottomPadding: s.bottomPadding
		}
	}
}

typedef FlxUITooltipStyle = {
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