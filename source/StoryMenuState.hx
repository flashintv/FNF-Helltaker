package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.graphics.FlxGraphic;
import flixel.addons.display.FlxBackdrop;
import helltakerUtils.HelltakerChapterItem;
import WeekData;

using StringTools;

class StoryMenuState extends MusicBeatState
{
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	var scoreText:FlxText;

	private static var lastDifficultyName:String = '';
	var curDifficulty:Int = 1;

	var txtWeekTitle:FlxText;
	var bgSprite:FlxSprite;

	private static var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<HelltakerChapterItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;
	var borders:FlxTypedGroup<FlxSprite>;
	var grpLocks:FlxTypedGroup<FlxSprite>;
	var difficultySelectors:FlxTypedGroup<FlxSprite>;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var bg:FlxBackdrop;

	var ydiffpos:Float = 0;
	
	override function create()
	{
		#if MODS_ALLOWED
		Paths.destroyLoadedImages();
		#end

		PlayState.isStoryMode = true;
		WeekData.reloadWeekFiles(true);
		if(curWeek >= WeekData.weeksList.length) curWeek = 0;
		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		var bgYellow:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 386, 0xFFF9CF51);
		bgSprite = new FlxSprite(0, 56);
		bgSprite.antialiasing = ClientPrefs.globalAntialiasing;

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		borders = new FlxTypedGroup<FlxSprite>();
		add(borders);

		var chapterBorder1:FlxSprite = new FlxSprite(0, FlxG.height * 0.65).loadGraphic(Paths.image('menuassets/chapterBorder'));
		chapterBorder1.scale.set(0.6, 0.6);
		chapterBorder1.updateHitbox();
		chapterBorder1.screenCenter(X);
		borders.add(chapterBorder1);

		var chapterBorder2:FlxSprite = new FlxSprite(0, FlxG.height * 0.75).loadGraphic(Paths.image('menuassets/chapterBorder'));
		chapterBorder2.scale.set(0.6, 0.6);
		chapterBorder2.flipY = true;
		chapterBorder2.updateHitbox();
		chapterBorder2.screenCenter(X);
		borders.add(chapterBorder2);

		grpWeekText = new FlxTypedGroup<HelltakerChapterItem>();
		add(grpWeekText);

		for (i in 0...WeekData.weeksList.length)
		{
			WeekData.setDirectoryFromWeek(WeekData.weeksLoaded.get(WeekData.weeksList[i]));
			var yCalcs:Float = ((chapterBorder1.y + chapterBorder1.height) + (chapterBorder2.y - (chapterBorder1.y + chapterBorder1.height))/2);
			var weekThing:HelltakerChapterItem = new HelltakerChapterItem(chapterBorder1.x + 60, 0, WeekData.weeksList[i]);
			weekThing.updatePositions(((chapterBorder1.x + 90) + (weekThing.outSpr.width + 20)*i), (yCalcs - weekThing.outSpr.height/2));
			weekThing.ID = i;
			grpWeekText.add(weekThing);

			if (weekIsLocked(i))
			{
				var lock:FlxSprite = new FlxSprite(weekThing.outSpr.width + 10 + weekThing.outSpr.x);
				lock.frames = ui_tex;
				lock.animation.addByPrefix('lock', 'lock');
				lock.animation.play('lock');
				lock.ID = i;
				lock.antialiasing = ClientPrefs.globalAntialiasing;
				grpLocks.add(lock);
			}
		}

		WeekData.setDirectoryFromWeek(WeekData.weeksLoaded.get(WeekData.weeksList[0]));
		var charArray:Array<String> = WeekData.weeksLoaded.get(WeekData.weeksList[0]).weekCharacters;
		for (char in 0...3)
		{
			var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.25) * (1 + char) - 150, charArray[char]);
			weekCharacterThing.y += 70;
			grpWeekCharacters.add(weekCharacterThing);
		}

		difficultySelectors = new FlxTypedGroup<FlxSprite>();
		add(difficultySelectors);

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		if(lastDifficultyName == '') {
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));

		ydiffpos = chapterBorder2.y + 105;
		sprDifficulty = new FlxSprite(0, chapterBorder2.y + 85);
		sprDifficulty.screenCenter(X);
		sprDifficulty.antialiasing = ClientPrefs.globalAntialiasing;
		changeDifficulty();

		difficultySelectors.add(sprDifficulty);

		leftArrow = new FlxSprite(sprDifficulty.x - 50, sprDifficulty.y + 15);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.antialiasing = ClientPrefs.globalAntialiasing;
		difficultySelectors.add(leftArrow);
		leftArrow.x -= leftArrow.width;

		rightArrow = new FlxSprite(sprDifficulty.x + sprDifficulty.width + 50, sprDifficulty.y + 15);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.antialiasing = ClientPrefs.globalAntialiasing;
		difficultySelectors.add(rightArrow);

		//add(bgYellow);
		bg = new FlxBackdrop(Paths.image('mainmenu/abyss', 'preload'), 1, 0, true, false);
		bg.x = MainMenuState.scrollX;
		bg.y = FlxG.height * 0.1;
		bg.velocity.x = 50;
		add(bg);
		//add(bgSprite);
		//add(grpWeekCharacters);

		var tracksSprite:FlxSprite = new FlxSprite((FlxG.width * 0.07) - 45, 134).loadGraphic(Paths.image('Menu_Tracks'));
		tracksSprite.antialiasing = ClientPrefs.globalAntialiasing;
		add(tracksSprite);

		txtTracklist = new FlxText((FlxG.width * 0.05) - 45, tracksSprite.y + 60, 0, "", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);
		// add(rankText);
		add(scoreText);
		add(txtWeekTitle);

		changeWeek();
		refreshObjects();

		super.create();
	}

	override function closeSubState() {
		persistentUpdate = true;
		changeWeek();
		super.closeSubState();
	}

	private function refreshObjects():Void {
		if (difficultyChoosing) {
			difficultySelectors.forEach(function(obj){ obj.alpha = 1; });
			borders.forEach(function(obj){ obj.alpha = 0.5; });
			grpWeekText.forEach(function(obj){ obj.unfocus(); });
		} else {
			difficultySelectors.forEach(function(obj){ obj.alpha = 0.5; });
			borders.forEach(function(obj){ obj.alpha = 1; });
			grpWeekText.forEach(function(obj){ obj.focus(); });
		}
	}

	var difficultyChoosing:Bool = false;
	override function update(elapsed:Float)
	{
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 30, 0, 1)));
		if(Math.abs(intendedScore - lerpScore) < 10) lerpScore = intendedScore;
		scoreText.text = "WEEK SCORE:" + lerpScore;

		difficultySelectors.visible = !weekIsLocked(curWeek);

		if (!movedBack && !selectedWeek)
		{
			if (controls.UI_UP_P || controls.UI_DOWN_P) {
				difficultyChoosing = !difficultyChoosing;
				FlxG.sound.play(Paths.sound('scrollMenu'));
				refreshObjects();
			}

			if (difficultyChoosing) {
				if (controls.UI_RIGHT)
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');

				if (controls.UI_LEFT)
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');

				if (controls.UI_RIGHT_P)
					changeDifficulty(1);
				else if (controls.UI_LEFT_P)
					changeDifficulty(-1);
			} else {
				if (controls.UI_LEFT_P) {
					changeWeek(-1);
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeDifficulty();
				}
	
				if (controls.UI_RIGHT_P) {
					changeWeek(1);
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeDifficulty();
				}
			}			

			if(FlxG.keys.justPressed.CONTROL)
			{
				persistentUpdate = false;
				openSubState(new GameplayChangersSubstate());
			}
			else if(controls.RESET)
			{
				persistentUpdate = false;
				openSubState(new ResetScoreSubState('', curDifficulty, '', curWeek));
				//FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			else if (controls.ACCEPT)
			{
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			MusicBeatState.switchState(new MainMenuState());
		}

		super.update(elapsed);

		MainMenuState.scrollX = bg.x;
		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].outSpr.y;
		});
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (!weekIsLocked(curWeek))
		{
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('WEEK_CONFIRM'));

				//grpWeekText.outSpr.members[curWeek].startFlashing();
				if(grpWeekCharacters.members[1].character != '') grpWeekCharacters.members[1].animation.play('confirm');
				stopspamming = true;
			}

			// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]).songs;
			for (i in 0...leWeek.length) {
				songArray.push(leWeek[i][0]);
			}

			// Nevermind that's stupid lmao
			PlayState.storyPlaylist = songArray;
			PlayState.isStoryMode = true;
			selectedWeek = true;

			var diffic = CoolUtil.getDifficultyFilePath(curDifficulty);
			if(diffic == null) diffic = '';

			PlayState.storyDifficulty = curDifficulty;

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
				FreeplayState.destroyFreeplayVocals();
			});
		} else {
			FlxG.sound.play(Paths.sound('MENU_BUTTON'));
		}
	}

	var tweenDifficulty:FlxTween;
	var lastImagePath:String;
	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length-1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		var image:Dynamic = Paths.image('menudifficulties/' + Paths.formatToSongPath(CoolUtil.difficulties[curDifficulty]));
		var newImagePath:String = '';
		if(Std.isOfType(image, FlxGraphic))
		{
			var graphic:FlxGraphic = image;
			newImagePath = graphic.assetsKey;
		}
		else
			newImagePath = image;

		if(newImagePath != lastImagePath)
		{
			sprDifficulty.loadGraphic(image);
			sprDifficulty.screenCenter(X);
			sprDifficulty.alpha = 0;
			sprDifficulty.y = ydiffpos - 60;

			if(tweenDifficulty != null) tweenDifficulty.cancel();
			tweenDifficulty = FlxTween.tween(sprDifficulty, {y: ydiffpos - 30, alpha: 1}, 0.07, {onComplete: function(twn:FlxTween) {
				tweenDifficulty = null;
			}});
		}
		lastImagePath = newImagePath;
		lastDifficultyName = CoolUtil.difficulties[curDifficulty];

		#if !switch
		intendedScore = Highscore.getWeekScore(WeekData.weeksList[curWeek], curDifficulty);
		#end
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= WeekData.weeksList.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = WeekData.weeksList.length - 1;

		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]);
		WeekData.setDirectoryFromWeek(leWeek);

		var leName:String = leWeek.storyName;
		txtWeekTitle.text = leName.toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.selected = false;
			if (item.ID == curWeek) item.selected = true;
			bullShit++;
		}

		bgSprite.visible = true;
		var assetName:String = leWeek.weekBackground;
		if(assetName == null || assetName.length < 1) {
			bgSprite.visible = false;
		} else {
			bgSprite.loadGraphic(Paths.image('menubackgrounds/menu_' + assetName));
		}

		PlayState.storyWeek = curWeek;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5

		if(diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
		}

		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty)));
		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		if(newPos > -1) {
			curDifficulty = newPos;
		}
		updateText();
	}

	function weekIsLocked(weekNum:Int) {
		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[weekNum]);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}

	function updateText()
	{
		var weekArray:Array<String> = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]).weekCharacters;
		for (i in 0...grpWeekCharacters.length) {
			grpWeekCharacters.members[i].changeCharacter(weekArray[i]);
		}

		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]);
		var stringThing:Array<String> = [];
		for (i in 0...leWeek.songs.length) {
			stringThing.push(leWeek.songs[i][0]);
		}

		txtTracklist.text = '';
		for (i in 0...stringThing.length)
		{
			txtTracklist.text += stringThing[i] + '\n';
		}

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= (FlxG.width * 0.35) + 45;

		#if !switch
		intendedScore = Highscore.getWeekScore(WeekData.weeksList[curWeek], curDifficulty);
		#end
	}
}
