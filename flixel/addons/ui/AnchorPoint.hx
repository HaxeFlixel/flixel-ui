package flixel.addons.ui;

class AnchorPoint
{
	public var offset:Float = 0; // Manual offset from the anchor point
	public var side:String = Anchor.CENTER; // Which side of thing B is the anchor? Anchor.LEFT/RIGHT/TOP/BOTTOM/CENTER
	public var flush:String = Anchor.CENTER; // Which side of thing A is flush against the anchor? Anchor.LEFT/RIGHT/TOP/BOTTOM/CENTER

	public function new(Offset:Float, Side:String, Flush:String)
	{
		offset = Offset;
		side = Side;
		flush = Flush;
	}
}
