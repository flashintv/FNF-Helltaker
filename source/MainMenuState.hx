package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.addons.display.FlxBackdrop;
import helltakerUtils.HelltakerMenuItem;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.5.1'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;
	public static var scrollX:Float = 0;

	var bg:FlxBackdrop;
	var menuItems:FlxTypedGroup<HelltakerMenuItem>;
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		'credits',
		'options'
	];

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		FlxG.mouse.useSystemCursor = true;
		FlxG.mouse.visible = true;

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		bg = new FlxBackdrop(Paths.image('mainmenu/abyss', 'preload'), 1, 0, true, false);
		bg.x = scrollX;
		bg.y = FlxG.height * 0.1;
		bg.velocity.x = 50;
		add(bg);

		menuItems = new FlxTypedGroup<HelltakerMenuItem>();
		add(menuItems);

		var baseY:Int = (FlxG.height - (optionShit.length * 60) - 35);
		for (i in 0...optionShit.length)
		{
			var optionText:String = optionShit[i].replace('_', ' ').replace('-', ' ').toUpperCase();
			var menuItem:HelltakerMenuItem = new HelltakerMenuItem(0, baseY + (i * 60), optionText);
			menuItem.ID = i;
			menuItem.sprScreenCenter(X);
			menuItem.setAntialiasing(ClientPrefs.globalAntialiasing);
			menuItems.add(menuItem);
		}

		changeItem();
		super.create();
	}

	var selectedSomethin:Bool = false;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8) {
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (FlxG.mouse.justMoved) {
			for (option in menuItems) {
				if (FlxG.mouse.overlaps(option) && !selectedSomethin) {
					curSelected = option.ID;
					changeItem();
				}
			}
		}

		if (!selectedSomethin)
		{
			if (FlxG.keys.justPressed.SEVEN) {
				FlxG.switchState(new editors.MasterEditorMenu());
			}

			if (controls.UI_UP_P || FlxG.mouse.wheel == 1)
			{
				FlxG.sound.play(Paths.sound('MENU_BUTTON'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P || FlxG.mouse.wheel == -1)
			{
				FlxG.sound.play(Paths.sound('MENU_BUTTON'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('MENU_BUTTON'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT || FlxG.mouse.justPressed)
			{
				var mouseOverlaps:Bool = false;
				for (option in menuItems) {
					if (FlxG.mouse.overlaps(option)) mouseOverlaps = true;
				}

				if (controls.ACCEPT || (mouseOverlaps && FlxG.mouse.pressed)) {
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('MENU_BUTTON_CONFIRM'));

					var daChoice:String = optionShit[curSelected];

					switch (daChoice)
					{
						case 'story_mode':
							MusicBeatState.switchState(new StoryMenuState());
						case 'freeplay':
							MusicBeatState.switchState(new FreeplayState());
						case 'credits':
							MusicBeatState.switchState(new CreditsState());
						case 'options':
							MusicBeatState.switchState(new options.OptionsState());
					}
				}
			}
		}

		super.update(elapsed);

		scrollX = bg.x;
		menuItems.forEach(function(spr:HelltakerMenuItem)
		{
			spr.sprScreenCenter(X);
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:HelltakerMenuItem)
		{
			if (spr.ID == curSelected) {
				spr.selected = true;
			} else {
				spr.selected = false;
			}
		});
	}
}
