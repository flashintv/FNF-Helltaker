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

class HelltakerChapterItem extends FlxGroup
{
    public static inline final SELECTEDTEXTCOLOR:FlxColor = 0xFFE6E6E8;
    public static inline final UNSELECTEDTEXTCOLOR:FlxColor = 0xFFC9AfB6;

    public var selected:Bool = false;
    public var text:String = 'Sample Text'; // mlg
    public var textSpr:FlxText;
    public var outSpr:FlxSprite;
    public var inSpr:FlxSprite;

	public function new(_x:Float, _y:Float, _text:String = 'Sample Text')
    {
        text = _text;
        super();

        outSpr = new FlxSprite(_x, _y).loadGraphic(Paths.image('menuassets/chapterOut', 'preload'));
        outSpr.scale.set(0.6, 0.6);
        outSpr.updateHitbox();
        add(outSpr);

        inSpr = new FlxSprite(_x, _y).loadGraphic(Paths.image('menuassets/chapterIn', 'preload'));
        inSpr.setPosition(_x + (outSpr.width/2) - (inSpr.width/2), _y + (outSpr.height/2) - (inSpr.height/2));
        inSpr.scale.set(0.6, 0.6);
        inSpr.updateHitbox();
        inSpr.alpha = 0;
        add(inSpr);

        textSpr = new FlxText(_x, _y, 0, _text, 12);
        textSpr.setPosition(_x + (outSpr.width/2) - (textSpr.width/2), _y + (outSpr.height/2) - (textSpr.height/2));
        textSpr.setFormat(Paths.font('crimsonpro-light'), 16, UNSELECTEDTEXTCOLOR, 'center');
        add(textSpr);
    }

    private var focused:Bool = true;
    override function update(elapsed:Float)
    {
        if (!focused) return;

        if (selected) {
            textSpr.color = SELECTEDTEXTCOLOR;
            inSpr.alpha = 0.45;
            outSpr.alpha = 1;
        } else if (!selected) {
            textSpr.color = UNSELECTEDTEXTCOLOR;
            inSpr.alpha = 0;
            outSpr.alpha = 0.6;
        }

        super.update(elapsed);
    }

    public function updatePositions(x_:Float = 0, y_:Float= 0)
    {
        outSpr.setPosition(x_, y_);
        inSpr.setPosition(outSpr.x + (outSpr.width/2) - (inSpr.width/2), outSpr.y + (outSpr.height/2) - (inSpr.height/2));
        textSpr.setPosition(inSpr.x + (inSpr.width/2) - (textSpr.width/2), inSpr.y + (inSpr.height/2) - (textSpr.height/2));
    }

    public function focus() { focused = true; outSpr.alpha += 0.5; inSpr.alpha += 0.5; textSpr.alpha += 0.5; }
    public function unfocus() { focused = false; outSpr.alpha -= 0.5; inSpr.alpha -= 0.5; textSpr.alpha -= 0.5; }

    public function setAntialiasing(buttonAA:Bool = false, textAA:Bool = false)
    {
        outSpr.antialiasing = buttonAA;
        inSpr.antialiasing = buttonAA;
        textSpr.antialiasing = textAA;
    }

    public function sprScreenCenter(axes:FlxAxes = XY)
    {
        outSpr.screenCenter(axes);
        inSpr.screenCenter(axes);
        textSpr.setPosition(inSpr.x + (inSpr.width/2) - (textSpr.width/2), inSpr.y + (inSpr.height/2) - (textSpr.height/2));
    }
}
