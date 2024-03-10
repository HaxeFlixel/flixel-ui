package flixel.addons.ui.system.macros;

#if macro
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr.Position;

// private enum UserAddonDefines {}
// private enum HelperAddonDefines {}

/**
 * The purpose of these "defines" classes is mainly to properly communicate version compatibility
 * among flixel libs, we shouldn't be overly concerned with backwards compatibility, but we do want
 * to know when a change breaks compatibility between Flixel-UI and Flixel.
 * 
 * @since 2.6.0
 */
@:allow(flixel.system.macros.FlxDefines)
@:access(flixel.system.macros.FlxDefines)
class FlxUIDefines
{
	/**
	 * Called from `flixel.system.macros.FlxDefines` on versions 5.6.0 or later
	 */
	public static function run()
	{
		#if !display
		checkCompatibility();
		#end
	}

	static function checkCompatibility()
	{
		#if (flixel < version("5.3.1"))
		FlxDefines.abortVersion("Flixel", "5.3.1 or newer", "flixel", (macro null).pos);
		#end
	}

	static function isValidUserDefine(define:Any)
	{
		return false;
	}

	static function abortVersion(dependency:String, supported:String, found:String, pos:Position)
	{
		abort('Flixel-UI: Unsupported $dependency version! Supported versions are $supported (found ${Context.definedValue(found)}).', pos);
	}

	static function abort(message:String, pos:Position)
	{
		Context.fatalError(message, pos);
	}
}
#end