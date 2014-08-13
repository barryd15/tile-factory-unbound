// Main.as
//
// Entry point from the flash code. Also keeps track of which main
// menu and/or the game the player is interacting with.

package
{
  import flash.display.DisplayObjectContainer;
  import flash.display.Stage;
  import flash.display.StageAlign;
  import flash.display.StageScaleMode;
  import flash.events.Event;
  import flash.events.FullScreenEvent;
  import lib.Point;
  import lib.ui.Keyboard;
  import ui.RegionList;
  import ui.Sound;
  import ui.TilePixel;
  import ui.menu.TestMenu;
  import flash.net.URLLoader;
  import flash.net.URLRequest;

  public class Main
  {
    public static var WIDTH = 800;
    public static var HEIGHT = 600;

    public static function init(parent : DisplayObjectContainer) : void
    {
      var url = parent.stage.loaderInfo.url.split("/")[2];
//      if (url == "jayisgames.com" || url == "casualgameplay.com"
//          || url == "cgdc8.fizzlebot.com")
//      if (url.indexOf("armorgames.com") != -1)
//      if (url.indexOf("kongregate.com") != -1)
      {
        var stage = parent.stage;
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;
        stage.addEventListener(FullScreenEvent.FULL_SCREEN,
                               fullScreenHandler);
        stage.addEventListener(Event.RESIZE,
                               resizeHandler);
        Campaign.init();
        Sound.playMusic();
        root = parent;
        keyboard = new lib.ui.Keyboard(root.stage);
        ui.TilePixel.setupRegions();
        ui.RegionList.setupRegions();
        settings = new GameSettings(new lib.Point(25, 25));
        state = new MainMenu(root, settings, beginGame, keyboard);
        resize();
        
        processQueryString(parent.loaderInfo.parameters);
      }
    }
    
    static function processQueryStringCode(code : String, params) : void
    {
      settings.setMap(code, SaveLoad.LOAD_ALL);
      state.cleanup();
      var game = new Game(root, keyboard, settings, endGame);
      state = game;
      resize();
      switch (params.action.toLowerCase()) {
        case "play":
          game.view.testMenu.click(TestMenu.PLAY);
          break;
        case "fast":
          game.view.testMenu.click(TestMenu.FAST);
          break;
        case "turbo":
          game.view.testMenu.click(TestMenu.TURBO);
          break;
      }
    }
    
    static function processQueryString(params) : void
    {
      //params.code = "eNqVkFFy5DAIRAEhhABZOzUZT/Yae5dU7phLJu18pWq/oq5XILttNWKi14PeH0nxd1H8IYpFK4qqinhWgsVz8IrBBQhwjAP1QA3UQC3UuvbwBXx1gf64qKgsr1V+5Iq9VtjsZjPVKM1ILGKOMYc0VmndUd3CDcD3nNq6iq0clvgmp8VDe5za7dnGeGlCexnvMhvS8SNxFnMRy5JuBY81CR/AZUriSDIWhn903mTT0uYMs4Q/4K8h3wEKZ+DIyD4iDePh9TI8790eyOZttC3SbuB+gfx3wx5ss7ZV6F93vqSs/RK6JwZ8tl174TaqKwsGZHZBKCFJQIRgCyR3z2Lf1S90oY/JGgi9FztGcHcwurqxbuoXvom9cKGFy8NY372jB+4ItxWSLTfofkkhu9sN2iCxK5B6w7hA+aGvQXr2085xOv1Ybx/03/rE+s0zpf35BdajH0Y=";
      //params.action = "play";
      if (params.code != undefined) {
        processQueryStringCode(params.code, params);
      }
      else if (params.codeurl != undefined) {
        var myLoader:URLLoader = new URLLoader();
        myLoader.addEventListener(Event.COMPLETE, function(e:Event) {
          var code:String = String(e.currentTarget.data);
          processQueryStringCode(code, params);
        });
        myLoader.load(new URLRequest(params.codeurl));
      }
    }
    
    static function beginGame() : void
    {
      state.cleanup();
      state = new Game(root, keyboard, settings, endGame);
      resize();
    }

    static function endGame(shouldSelectLevel : Boolean) : void
    {
      state.cleanup();
      settings = new GameSettings(new lib.Point(25, 25));
      var menu = new MainMenu(root, settings, beginGame, keyboard);
      state = menu;
      if (shouldSelectLevel)
      {
        menu.selectLevel();
      }
      resize();
    }

    static function fullScreenHandler(event : FullScreenEvent) : void
    {
      resize();
    }

    static function resizeHandler(event : Event) : void
    {
      resize();
    }

    static function resize() : void
    {
      state.resize();
    }

    public static function getStage() : Stage
    {
      return root.stage;
    }

    static var root : DisplayObjectContainer;
    static var state : MainState;
    static var keyboard : lib.ui.Keyboard;
    static var settings : GameSettings;

    public static var kongregate : * = null;
  }
}
