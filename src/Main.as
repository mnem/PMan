package
{
    import pman.PMan;

    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.utils.getTimer;

    /**
     * @author dave
     */
    [SWF(backgroundColor="#000000", frameRate="61", width="512", height="512")]
    public class Main extends Sprite
    {
        private static var COLOURS_1:Vector.<int> = Vector.<int>([0x001F11, 0x204709, 0x0C8558, 0xFFD96A, 0xFF4533]);

        protected var system:PMan;

        protected var updates:int = 0;

        public function Main() :void
        {
            addEventListener(Event.ADDED_TO_STAGE, addedToStage);
            addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);

            system = new PMan(512, 512);
            addChild(system);
        }

        protected function addedToStage(event:Event):void
        {
            stage.addEventListener(MouseEvent.CLICK, mouseClick);
            stage.addEventListener(Event.ENTER_FRAME, enterFrame);
        }

        protected function removedFromStage(event:Event):void
        {
            stage.removeEventListener(MouseEvent.CLICK, mouseClick);
            stage.removeEventListener(Event.ENTER_FRAME, enterFrame);
        }

        protected function mouseClick(event : MouseEvent) : void
        {
            system.addEmitter(100, event.stageX, event.stageY, COLOURS_1, true);
        }

        protected function enterFrame(event : Event) : void
        {
            updates++;
            system.update();

            trace(getTimer()/updates);
        }
    }
}
