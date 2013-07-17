package flixel.addons.ui;
import haxe.xml.Fast;
import flash.geom.ColorTransform;
import flixel.group.FlxGroup;
import flixel.FlxSprite;

/**
 * Cheap extension of FlxSprite
 * @author Lars Doucet
 */

class FlxSpriteX extends FlxSprite implements IDestroyable
{
	//simple string ID, handy for identification, etc
	public var str_id:String;			
	
	//pointer to the thing that "owns" it
	public var ptr_owner:Dynamic = null;
	
	//whether it has ever been recycled or not (useful for object pooling)
	public var recycled:Bool = false;	
		
	/*private var _invert:Bool = false;	
	public var invert(get_invert, set_invert):Bool;	
	public function get_invert():Bool {	return _invert; }
	public function set_invert(b:Bool):Bool{
		_invert = b;
		if((alpha != 1) || b){
			_colorTransform = new ColorTransform(-1, -1, -1, 1, 255, 255, 255);
		}else {
			_colorTransform = null;
		}
		dirty = true;
		return b;
	}*/
	
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