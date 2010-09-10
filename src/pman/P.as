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
         * The current draw method of the particle. Of the form, function(p_dest :BitmapData) :void
         */
        public var draw :Function;

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

            if(gfx == GFX_DISC || gfx == GFX_BLUR)
            {
                draw = drawGraphic;
                if(gfx == GFX_DISC)
                {
                    createGraphicDisc();
                }
                else
                {
                    createGraphicBlur();
                }
            }
            else if(gfx == GFX_POINTBLOCK)
            {
                draw = drawPointCube;
            }
            else if(gfx == GFX_FILLED)
            {
                draw = drawFillRect;
            }
            else
            {
                draw = drawPoint;
            }
        }

        /**
         * Creates a graphic used to represent this particle
         *
         */
        private function createGraphicDisc() :void
        {
            var particle :Sprite = new Sprite();
            var particleBD :BitmapData;
            particle.graphics.lineStyle( 1, _colour, 1.0, true );
            particle.graphics.beginFill( _colour, 1.0 );
            particle.graphics.drawCircle( 0, 0, 3 );
            particle.graphics.endFill();

            particleBD = new BitmapData( particle.width, particle.height, true, 0x00000000 );
            var pb :Rectangle = particle.getBounds(particle);
            var m :Matrix = new Matrix();
            m.translate( -pb.left, -pb.top );
            particleBD.draw( particle, m, null, null, null, true );

            scratch.width = particleBD.width;
            scratch.height = particleBD.height;

            _graphic = particleBD.getPixels( scratch );

            particleBD.dispose();
        }

        private function createGraphicBlur() :void
        {
            var particle :Sprite = new Sprite();
            var particleBD :BitmapData;
            particle.graphics.lineStyle( 1, _colour, 1.0, true );
            particle.graphics.beginFill( _colour, 1.0 );
            particle.graphics.drawRect( 0, 0, 2, 2);
            particle.graphics.endFill();
            particle.filters = [ new BlurFilter( 4, 4, 1 ) ];

            particleBD = new BitmapData( particle.width, particle.height, true, 0x00000000 );
            var pb :Rectangle = particle.getBounds(particle);
            var m :Matrix = new Matrix();
            m.translate( -pb.left, -pb.top );
            particleBD.draw( particle, m, null, null, null, true );

            scratch.width = particleBD.width;
            scratch.height = particleBD.height;

            _graphic = particleBD.getPixels( scratch );

            particleBD.dispose();
        }

        /**
         * Draws a point for this particle.
         *
         * @param p_bd
         *
         */
        public function drawPoint( p_bd :BitmapData ) :void
        {
            p_bd.setPixel32(x,y, _colour| (life << 24));
        }

        /**
         * Draws 4 points for this particle.
         *
         * @param p_bd
         *
         */
        public function drawPointCube( p_bd :BitmapData ) :void
        {
            var c:int = _colour | (life << 24);
            var xx:int=x+1;
            var yy:int=y+1;
            p_bd.setPixel32(x ,y ,c);
            p_bd.setPixel32(xx,y ,c);
            p_bd.setPixel32(xx,yy,c);
            p_bd.setPixel32(x ,yy,c);
        }

        /**
         * Draws a filled rect for this particle.
         *
         * @param p_bd
         *
         */
        public function drawFillRect( p_bd :BitmapData ) :void
        {
            scratch.x = x;
            scratch.y = y;
            p_bd.fillRect( scratch, _colour | (life << 24) );
        }

        /**
         * Draws a graphic for this particle.
         *
         * @param p_bd
         *
         */
        public function drawGraphic( p_bd :BitmapData ) :void
        {
            scratch.x = x;
            scratch.y = y;
            _graphic.position = 0;
            p_bd.setPixels( scratch, _graphic );
        }
    }
}
