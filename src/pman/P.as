package pman
{
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.filters.BlurFilter;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;
    import flash.utils.ByteArray;

    /**
     * Basic particle
     *
     * @author David Wagner
     *
     */
    public final class P
    {
        public static const GFX_POINT:int = 0;
        public static const GFX_FILLED:int = 1;
        public static const GFX_POINTBLOCK:int = 2;
        public static const GFX_DISC:int = 3;
        public static const GFX_BLUR:int = 4;

        [Embed(source="s.jpg")]
        private var SIMONE : Class;

        /**
         * Maximum life a particle can have
         */
        public static const LIFE_MAX :int = 0xff;

        /**
         * X velocity
         */
        public var vx :Number;

        /**
         * Y Velocity
         */
        public var vy :Number;

        /**
         * How much life is left in the particle
         */
        public var life :int;

        private var scratch:Rectangle = new Rectangle(0,0,3,3);

        public var x:int;
        public var y:int;

        public var left:int;
        public var right:int;
        public var top:int;
        public var bottom:int;

        /**
         * Colour of the particle.
         */
        private var _colour :int;

        /**
         * Pixel array of a predrawn graphic.
         */
        private var _graphic :ByteArray;

        /**
         * Constructor
         *
         * @param p_colour
         *
         */
        public function P( p_colour :int, gfx:int )
        {
            _colour = 0x00ffffff & p_colour;

            x = 0;
            y = 0;

            vx = 0;
            vy = 0;

            life = LIFE_MAX;

            createSimone();
        }

        private function createSimone():void
        {
            var particleBD:BitmapData = new BitmapData(80, 80, false);

            scratch.width = 80;
            scratch.height = 80;

            particleBD.draw(new SIMONE());

            _graphic = particleBD.getPixels( scratch );

             particleBD.dispose();
        }

        public function draw( p_bd :BitmapData ) :void
        {
            scratch.x = x;
            scratch.y = y;
            _graphic.position = 0;
            p_bd.setPixels( scratch, _graphic );
        }
    }
}
