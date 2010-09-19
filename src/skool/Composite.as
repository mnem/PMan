package skool
{
    import flash.display.BitmapData;
    import flash.geom.Rectangle;
    /**
     * @author dave
     */
    public class Composite
    {
        protected static var COMPOSITE_COUNT:int = 0;
        protected var name:String;

        public var x:Number;
        public var y:Number;
        public var bounds:Rectangle;

        public var itemsDrawn:int;

        protected var compositor:Compositor;

        protected var colourARGB:uint;
        public var buffer:BitmapData;

        public function Composite(width:int, height:int, colourARGB:uint, compositor:Compositor, name:String = null)
        {
            x = 0;
            y = 0;

            this.colourARGB = colourARGB;

            bounds = new Rectangle(0, 0, width, height);
            buffer = new BitmapData(width, height, (0xff000000 & colourARGB) != 0, colourARGB);

            this.name = name;
            if(this.name == null)
            {
                this.name = "Untitled composite " + COMPOSITE_COUNT;
                COMPOSITE_COUNT++;
            }

            this.compositor = compositor;
        }

        public function renderStart():void
        {
            itemsDrawn = 0;
            buffer.lock();

            buffer.fillRect(bounds, colourARGB);
        }

        public function renderMain():void
        {
            // Do something exciting
        }

        public function renderEnd():void
        {
            buffer.unlock();
        }
    }
}
