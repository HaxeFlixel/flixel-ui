package flixel.addons.ui;

import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.FlxG.IDestroyable;
import flixel.FlxSprite;

/**
 * Cheap extension of FlxSprite
 * @author Lars Doucet
 */
class FlxUISprite extends FlxSprite implements IDestroyable implements IFlxUIWidget 
{
	//simple string ID, handy for identification, etc
	public var id:String;
	
	//pointer to the thing that "owns" it
	public var ptr_owner:Dynamic = null;
	
	//whether it has ever been recycled or not (useful for object pooling)
	public var recycled:Bool = false;
	
	public function new(X:Float=0,Y:Float=0,SimpleGraphic:Dynamic=null) 
	{
		super(X, Y, SimpleGraphic);
	}
	
	public function recycle(data:Dynamic):Void {
		recycled = true;
		//override per subclass
	}
	
	public override function destroy():Void {
		ptr_owner = null;
		super.destroy();
	}
}