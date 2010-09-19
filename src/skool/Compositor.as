package skool
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.PixelSnapping;
    import flash.events.Event;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;
    import flash.utils.getTimer;
    /**
     * @author dave
     */
    public class Compositor
    {
        protected static var COMPOSITOR_COUNT:int = 0;
        protected var name:String;

        protected var composites:Vector.<Composite>;
        protected var compositeToIndex:Dictionary;

        protected var colourARGB:uint;
        protected var buffer:BitmapData;
        protected var bounds:Rectangle;

        protected var blendFrames:Boolean;
        protected var blendBuffer:BitmapData;

        protected var zeroPoint:Point = new Point();

        public var lastUpdate:int;
        public var now:int;
        public var elapsed:int;

        protected var _displayObject:Bitmap;

        protected var _loggingFunction : Function;

        public function Compositor(width:int, height:int, colourARGB:uint, blendFrames:Boolean, blendColourARGB:uint, name:String = null)
        {
            this.colourARGB = colourARGB;

            bounds = new Rectangle(0, 0, width, height);
            buffer = new BitmapData(width, height, (0xff000000 & colourARGB) != 0, colourARGB);

            this.blendFrames = blendFrames;
            if(this.blendFrames)
            {
                blendBuffer = new BitmapData(width, height, (0xff000000 & blendColourARGB) != 0, blendColourARGB);
            }

            _displayObject = new Bitmap(buffer, PixelSnapping.NEVER, false);
            _displayObject.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
            _displayObject.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);

            composites = new Vector.<Composite>();
            compositeToIndex = new Dictionary();

            this.name = name;
            if(this.name == null)
            {
                this.name = "Untitled compositor " + COMPOSITOR_COUNT;
                COMPOSITOR_COUNT++;
            }
        }

        protected function removedFromStage(event : Event) : void
        {
            _displayObject.removeEventListener(Event.ENTER_FRAME, enterFrame);
        }

        protected function addedToStage(event : Event) : void
        {
            _displayObject.addEventListener(Event.ENTER_FRAME, enterFrame);
            lastUpdate = getTimer();
        }

        protected function enterFrame(event : Event) : void
        {
            var item : int = composites.length;
            var c:Composite;
            var p:Point = new Point();
            var itemsDrawn :int = 0;

            now = getTimer();
            elapsed = now - lastUpdate;

            buffer.lock();

            if(blendFrames)
            {
                buffer.copyPixels(blendBuffer, bounds, zeroPoint);
            }
            else
            {
                buffer.fillRect(bounds, colourARGB);
            }

            while(item--)
            {
                c = composites[item];

                p.x = int(c.x);
                p.y = int(c.y);

                c.renderStart();
                c.renderMain();
                c.renderEnd();

                buffer.copyPixels(c.buffer, c.bounds, p);

                itemsDrawn += c.itemsDrawn;
            }

            buffer.unlock();

            lastUpdate = now;
        }

        public function log(message:String):void
        {
            if(_loggingFunction != null)
            {
                _loggingFunction(message);
            }
        }

        public function pushComposite(composite:Composite):void
        {
            if(composite == null)
            {
               throw new ArgumentError("Cannot add a null composite, silly.");
            }

            if(compositeToIndex[composite] != null)
            {
                log("Ignoring composite " + composite + " because it has already been added to the compositor.");
                return;
            }

            composites.push(composite);
            compositeToIndex[composite] = composites.length - 1;

            log("Pushed composite: " + describeComposite(composite));
        }

        public function describeComposite(composite:Composite):String
        {
            if(compositeToIndex[composite] == null)
            {
                return "";
            }

            return "Composite description -" + "" +
                   " index: " + compositeToIndex[composite] +
                   ", toString: " + safeString(composite);

        }

        protected function safeString(thing:Object):String
        {
            return new String(thing);
        }

        public function removeComposite(composite:Composite):void
        {
            if(compositeToIndex[composite] == null)
            {
                log("Could not remove composite because it doesn't seem to exist: " + composite);
                return;
            }

            log("Removing composite: " + describeComposite(composite));
            composites.splice(compositeToIndex[composite], 1);

            compositeToIndex[composite] = null;
            delete compositeToIndex[composite];
        }

        public function get displayObject() : DisplayObject
        {
            return _displayObject;
        }

        public function set loggingFunction(fn : Function) : void
        {
            if(fn != null)
            {
                try
                {
                    fn("Switching to this logging function for compositor " + this);
                }
                catch(e:Error)
                {
                    log("Tried to replace logging function with something that doesn't have the function signature: function(message:String)");
                    fn = _loggingFunction;
                }
            }
            _loggingFunction = fn;
        }

        public function toString():String
        {
            return "[Compositor name: '" + name + "']";
        }

    }
}
