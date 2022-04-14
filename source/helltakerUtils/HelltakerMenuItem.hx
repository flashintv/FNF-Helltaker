package helltakerUtils;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxAxes;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.group.FlxGroup;

using StringTools;

class HelltakerMenuItem extends FlxGroup
{
    // stole helltaker option colors using color picker
    public static inline final MENUTEXT:FlxColor = 0xFFC9AFB6;
    public static inline final SELECTEDCOLOR:FlxColor = 0xFFE64D51;
    public static inline final SELECTEDTEXTCOLOR:FlxColor = 0xFFE6E6E8;
    public static inline final UNSELECTEDCOLOR:FlxColor = 0xFF653D48;
    public static inline final UNSELECTEDTEXTCOLOR:FlxColor = 0xFFC9AfB6;

    public var selected:Bool = false;
    public var text:String = 'Sample Text'; // mlg
    public var menuSprite:FlxSprite;
    public var menuText:FlxText;

    private var colorButtonTween:FlxTween;
    private var colorTextTween:FlxTween;
    private var scaleButtonTween:FlxTween;

	public function new(_x:Float, _y:Float, _text:String = 'Sample Text')
    {
        text = _text;
        super();

        // stole the helltaker menu options using UABE (unity asset bundle extractor)
        menuSprite = new FlxSprite(_x, _y);
        menuSprite.frames = Paths.getSparrowAtlas('menuassets/button', 'preload');
        menuSprite.animation.addByPrefix('idle', 'button white', 1, false);
        menuSprite.animation.addByPrefix('selected', 'button selected', 1, false);
        menuSprite.animation.play('idle');
        menuSprite.color = UNSELECTEDCOLOR;
        menuSprite.scale.set(0.80, 0.75);
        menuSprite.updateHitbox();
        add(menuSprite);

        menuText = new FlxText(_x, _y, 0, text, 16);
        menuText.setPosition(_x + (menuSprite.width/2) - (menuText.width/2), _y + (menuSprite.height/2) - (menuText.height/2));
        menuText.setFormat(Paths.font('crimsonpro-light'), 16, UNSELECTEDTEXTCOLOR, 'center');
        add(menuText);
    }

    override function update(elapsed:Float)
    {
        if (selected && menuSprite.animation.name != 'selected') {
            colorButtonTween = FlxTween.color(menuSprite, 0.1, menuSprite.color, SELECTEDCOLOR, {ease:FlxEase.linear});
            colorTextTween = FlxTween.color(menuText, 0.1, menuText.color, SELECTEDTEXTCOLOR, {ease:FlxEase.linear});
            scaleButtonTween = FlxTween.tween(menuSprite.scale, {x:0.85, y:0.8}, 0.1, {ease:FlxEase.linear});
            menuSprite.animation.play('selected', true);
            menuSprite.centerOffsets();
        } else if (!selected && menuSprite.animation.name != 'idle') {
            colorButtonTween = FlxTween.color(menuSprite, 0.1, menuSprite.color, UNSELECTEDCOLOR, {ease:FlxEase.linear});
            colorTextTween = FlxTween.color(menuText, 0.1, menuText.color, UNSELECTEDTEXTCOLOR, {ease:FlxEase.linear});
            scaleButtonTween = FlxTween.tween(menuSprite.scale, {x:0.80, y:0.75}, 0.1, {ease:FlxEase.linear});
            menuSprite.animation.play('idle', true);
            menuSprite.centerOffsets();
        }

        super.update(elapsed);
    }

    public function setAntialiasing(buttonAA:Bool = false, textAA:Bool = false)
    {
        menuSprite.antialiasing = buttonAA;
        menuText.antialiasing = textAA;
    }

    public function getAlpha():Float
    {
        return menuSprite.alpha;
    }

    public function setAlpha(allAlpha:Float = 1)
    {
        menuSprite.alpha = allAlpha;
        menuText.alpha = allAlpha;
    }

    public function sprScreenCenter(axes:FlxAxes = XY)
    {
        menuSprite.screenCenter(axes);
        menuText.setPosition(menuSprite.x + (menuSprite.width/2) - (menuText.width/2), menuSprite.y + (menuSprite.height/2) - (menuText.height/2));
    }
}
