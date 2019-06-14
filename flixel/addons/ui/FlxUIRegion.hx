package flixel.addons.ui;

import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.interfaces.IResizable;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.util.FlxColor;

/**
 * A scalable object with width and height that isn't used for display purposes
 */
class FlxUIRegion extends FlxSprite implements IFlxUIWidget implements IResizable
{
	public var broadcastToFlxUI:Bool = true;

	public var name:String;

	public function new(X:Float = 0, Y:Float = 0, W:Float = 16, H:Float = 16)
	{
		super(X, Y);
		makeGraphic(1, 1, FlxColor.TRANSPARENT);
		if (H < 1)
		{
			H = 1;
		}
		if (W < 1)
		{
			W = 1;
		}
		resize(W, H);
	}

	public function resize(w:Float, h:Float):Void
	{
		width = w;
		height = h;

		#if FLX_DEBUG
		debugBoundingBoxColor = FlxG.random.color().to24Bit();
		#end
	}

	#if FLX_DEBUG
	override public function drawDebugOnCamera(camera:FlxCamera)
	{
		var rect = getBoundingBox(camera);
		var gfx = beginDrawDebug(camera);

		gfx.beginFill(debugBoundingBoxColor, 0.5);
		gfx.drawRect(rect.x, rect.y, rect.width, rect.height);

		endDrawDebug(camera);
	}
	#end
}
