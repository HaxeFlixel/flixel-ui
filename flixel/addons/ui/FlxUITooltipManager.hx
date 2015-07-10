package flixel.addons.ui;
import flixel.addons.ui.FlxUITooltip.ToolTipStyle;
import flixel.addons.ui.interfaces.IFlxUIButton;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

/**
 * ...
 * @author larsiusprime
 */
class FlxUITooltipManager implements IFlxDestroyable
{
	private var listBtns:Array<IFlxUIButton>;
	private var listCounts:Array<Float>;
	private var listData:Array<ToolTipData>;
	
	private var tooltip:FlxUITooltip;
	private var current:Int = -1;
	
	private var state:FlxUIState;
	private var subState:FlxUISubState;
	
	/**
	 * Turn on flipping the anchor position around in order to keep a tooltip on screen
	 */
	public var autoFlipAnchor:Bool = true;
	
	/**
	 * Default anchor position for tooltips where no anchor is defined
	 */
	public var defaultAnchor:Anchor = null;
	
	/**
	 * Default style for tooltips where no style is defined
	 */
	public var defaultStyle:ToolTipStyle = null;
	public var showOnClick:Bool = false;
	public var delay:Float = 0.1;
	
	public function new(?State:FlxUIState,?SubState:FlxUISubState) 
	{
		state = State;
		subState = SubState;
		listBtns = [];
		listCounts = [];
		listData = [];
		tooltip = new FlxUITooltip(100, 50);
		defaultAnchor = tooltip.anchor.clone();
		defaultStyle = FlxUITooltip.cloneStyle(tooltip.style);
	}
	
	public function destroy()
	{
		for (data in listData)
		{
			data.anchor = null;
			data.style = null;
		}
		FlxArrayUtil.clearArray(listBtns);
		FlxArrayUtil.clearArray(listData);
	}
	
	/**
	 * Adds a tooltip for this button, using the specified data.
	 * @param	thing	The button you want to add a tooltip to
	 * @param	data
	 */
	
	public function add(thing:IFlxUIButton, data:ToolTipData)
	{
		if (listBtns.indexOf(thing) == -1)
		{
			listBtns.push(thing);
			data.style = FlxUITooltip.styleFix(data.style);		//replace null values with sensible defaults
			listData.push(data);
			listCounts.push(0);
		}
	}
	
	public function update(elapsed:Float):Void
	{
		//iterate over all our buttons and watch their states
		for (i in 0...listBtns.length)
		{
			var btn = listBtns[i];
			
			if (btn.justMousedOver || btn.mouseIsOver)
			{
				listCounts[i] += elapsed;
			}
			else if(listCounts[i] > 0)
			{
				listCounts[i] = 0;
				hide(i);
			}
			if (listCounts[i] > delay)
			{
				if (current != i)
				{
					show(i);
				}
			}
		}
	}
	
	private function hide(i:Int):Void
	{
		if (current == i)
		{
			tooltip.hide();
			if (state != null)
			{
				state.remove(tooltip, true);
			}
			if (subState != null)
			{
				subState.remove(tooltip, true);
			}
		}
		current = -1;
	}
	
	private function show(i:Int):Void
	{
		current = i;
		var thing = listBtns[i];
		var data = listData[i];
		var autoSizeVertical = true;
		var autoSizeHorizontal = true;
		if (data.style != null)
		{
			tooltip.style = data.style;
			autoSizeVertical = data.style.autoSizeVertical;
			autoSizeHorizontal = data.style.autoSizeHorizontal;
		}
		
		if (data.anchor != null)
		{
			tooltip.anchor = data.anchor;
		}
		else if(defaultAnchor != null)
		{
			tooltip.anchor = defaultAnchor;
		}
		
		if (state != null)
		{
			state.add(tooltip);
		}
		if (subState != null)
		{
			subState.add(tooltip);
		}
		
		tooltip.show(cast thing, data.title, data.body, autoSizeVertical, autoSizeHorizontal);
		
		if (autoFlipAnchor)
		{
			if (checkAutoFlip(thing, tooltip))
			{
				tooltip.show(cast thing, data.title, data.body, autoSizeVertical, autoSizeHorizontal);
			}
		}
	}
	
	private function checkAutoFlip(thing:IFlxUIButton, tooltip:FlxUITooltip):Bool
	{
		var flipX = (tooltip.x < 0 || (tooltip.x + tooltip.width  > FlxG.width));
		var flipY = (tooltip.y < 0 || (tooltip.y + tooltip.height > FlxG.height));
		
		if (flipX || flipY)
		{
			tooltip.anchor = tooltip.anchor.getFlipped(flipX, flipY);
			return true;
		}
		
		return false;
	}
}

typedef ToolTipData = {
	title:String,
	body:String,
	?anchor:Anchor,
	?style:ToolTipStyle
}