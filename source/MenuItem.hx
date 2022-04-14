package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxAxes;

class MenuItem extends FlxSprite
{
	public var targetAxis:FlxAxes = FlxAxes.Y;
	public var targetX:Float = 0;
	public var targetY:Float = 0;
	public var flashingInt:Int = 0;

	public function new(x:Float, y:Float, weekName:String = '', axis:FlxAxes = FlxAxes.Y)
	{
		super(x, y);
		loadGraphic(Paths.image('storymenu/' + weekName));
		//trace('Test added: ' + WeekData.getWeekNumber(weekNum) + ' (' + weekNum + ')');
		antialiasing = ClientPrefs.globalAntialiasing;
		targetAxis = axis;
	}

	private var isFlashing:Bool = false;
	public function startFlashing():Void
	{
		isFlashing = true;
	}

	var fakeFramerate:Int = Math.round((1 / FlxG.elapsed) / 10);
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		switch (targetAxis) {
			case FlxAxes.X:
				x = FlxMath.lerp(x, (targetX * 120) + 480, CoolUtil.boundTo(elapsed * 10.2, 0, 1));
			case FlxAxes.Y:
				y = FlxMath.lerp(y, (targetY * 120) + 480, CoolUtil.boundTo(elapsed * 10.2, 0, 1));
			case FlxAxes.XY:
				x = FlxMath.lerp(x, (targetX * 120) + 480, CoolUtil.boundTo(elapsed * 10.2, 0, 1));
				y = FlxMath.lerp(y, (targetY * 120) + 480, CoolUtil.boundTo(elapsed * 10.2, 0, 1));
		}

		if (isFlashing)
			flashingInt += 1;

		if (flashingInt % fakeFramerate >= Math.floor(fakeFramerate / 2))
			color = 0xFF33ffff;
		else
			color = FlxColor.WHITE;
	}
}
