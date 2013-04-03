import nme.Lib;
import org.flixel.FlxG;
import org.flixel.FlxGame;
import org.flixel.plugin.leveluplabs.example.State_Title;
	
class Main extends FlxGame
{	
	public function new()
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;
		var ratioX:Float = stageWidth / 800;
		var ratioY:Float = stageHeight / 600;
		var ratio:Float = Math.min(ratioX, ratioY);
		super(Math.floor(stageWidth / ratio), Math.floor(stageHeight / ratio), State_Title, ratio, 30, 30);
	}
}
