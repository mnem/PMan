package {
	import pman.P;
	import pman.PMan;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.getTimer;

    /**
     * @author dave
     */
    [SWF(backgroundColor="#000000", frameRate="100", width="800", height="600")]
    public class Main extends Sprite
    {
        private static const NO_PARTICLES_MESSAGE:String = "Click somewhere to add a particle emitter.";
        private static const SAMPLES:int = 60;
        private static const PARTICLES_PER_EMITTER:int = 500;
        private static const COLOURS:Array = [
            Vector.<int>([0x001F11, 0x204709, 0x0C8558, 0xFFD96A, 0xFF4533]),
            Vector.<int>([0xFFFFFF, 0xFFEA47, 0xFFB921, 0x2B777F, 0x151836]),
            Vector.<int>([0x760008, 0xBE0B02, 0xFF7525, 0x8D6F39, 0x492F5E]),
            Vector.<int>([0x173C40, 0x1F5955, 0x3A9177, 0x78CF88, 0xE0FFA4]),
            Vector.<int>([0x494A4C, 0x656573, 0x8A7C99, 0xC38ACC, 0xFF81FF]),
        ];

		[Embed(source="blur.pbj", mimeType="application/octet-stream")]
		private var BlurKernel :Class;		

        // Hackily position the fullscreen command. This will break in some cases. So there.
        private static const CM_FULLSCREEN :int = 0;

        protected var system:PMan;

        protected var stats:TextField;

        // To vary the particles a little
        protected var c:int = 0;

        // Stat stuff
        protected var frameDrawTimes:Vector.<int> = new Vector.<int>(SAMPLES,true);
        protected var sample:int = SAMPLES-1;
        protected var last:int = getTimer();

        public function Main() :void
        {
            addEventListener(Event.ADDED_TO_STAGE, addedToStage);
            addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);

            addParticleSystem();

            addStatsTextField();

            setupContextMenu();
        }

        protected function addParticleSystem():void
        {
//			Yeek - filter kernel so slow... Must look into why.        	
//        	var f:Array = [new ShaderFilter(new Shader(new BlurKernel()))];
        	var f:Array = [new BlurFilter(3,3,1)];
        	
            system = new PMan(800, 600, f);
            
            addChild(system);
        }

        protected function addStatsTextField():void
        {
            stats = new TextField();
            var tf:TextFormat = stats.defaultTextFormat;
            tf.color = 0xffffff;
            tf.font = "Arial";
            tf.size = 12;
            stats.defaultTextFormat = tf;

            stats.width = 800;
            stats.height = 20;

            stats.text = NO_PARTICLES_MESSAGE;

            addChild(stats);
        }

        protected function addedToStage(event:Event):void
        {
            stage.addEventListener(MouseEvent.CLICK, mouseClick);
            stage.addEventListener(Event.ENTER_FRAME, enterFrame);
            setupStage();
        }

        protected function setupStage():void
        {
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.quality = StageQuality.LOW;
            stage.fullScreenSourceRect = new Rectangle(0,0,800,600);
        }

        protected function removedFromStage(event:Event):void
        {
            stage.removeEventListener(MouseEvent.CLICK, mouseClick);
            stage.removeEventListener(Event.ENTER_FRAME, enterFrame);
        }

        protected function mouseClick(event : MouseEvent) : void
        {
            var gfx : int = P.GFX_POINT;
            if(event.altKey)
            {
                gfx = P.GFX_FILLED;
            }

            system.addEmitter(PARTICLES_PER_EMITTER, event.stageX, event.stageY, COLOURS[c++], event.ctrlKey, gfx);
            if(c >= COLOURS.length) c = 0;
        }

        protected function updateStats():void
        {
            var message:String = NO_PARTICLES_MESSAGE;

            var total:int = 0;
            for(var i:int = 0; i < frameDrawTimes.length; i++)
            {
                total += frameDrawTimes[i];
            }
            var fps:int=1000.0/(total/frameDrawTimes.length);

            if(system.particleCount > 0)
            {
                message = "FPS: " + fps + ", particle count: " + system.particleCount;
            }

            stats.text = message;
        }

        protected function enterFrame(event : Event) : void
        {
            system.update();

            var now:int = getTimer();
            frameDrawTimes[sample] = now - last;
            last = now;
            sample--;
            if(sample < 0)
            {
                sample = frameDrawTimes.length - 1;
                updateStats();
            }
        }

        private function onFullScreenMenuClick(p_event :ContextMenuEvent) :void
        {
            if (stage.displayState == StageDisplayState.NORMAL)
            {
                stage.displayState = StageDisplayState.FULL_SCREEN;
            }
            else
            {
                stage.displayState = StageDisplayState.NORMAL;
            }
        }

        protected function menuHandler(p_event :ContextMenuEvent) :void
        {
            var cm :ContextMenu = ContextMenu(p_event.target);

            if (stage.displayState == StageDisplayState.NORMAL)
            {
                ContextMenuItem(cm.customItems[CM_FULLSCREEN]).caption = "Enter Fullscreen";
            }
            else
            {
                ContextMenuItem(cm.customItems[CM_FULLSCREEN]).caption = "Exit Fullscreen";
            }
        }

        private function setupContextMenu() :void
        {
            var customContextMenu :ContextMenu = new ContextMenu();
            customContextMenu.addEventListener(ContextMenuEvent.MENU_SELECT, menuHandler);
            customContextMenu.hideBuiltInItems();

            var fs :ContextMenuItem = new ContextMenuItem("Enter Fullscreen");
            fs.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onFullScreenMenuClick);
            customContextMenu.customItems[CM_FULLSCREEN] = fs;

            this.contextMenu = customContextMenu;
        }
    }
}
