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
    public class P
    {
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

        /**
         * The bounds of the particle
         */
        public var bounds :Rectangle;

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
        public function P( p_colour :int )
        {
            _colour = 0x00ffffff & p_colour;
            bounds = new Rectangle( 0, 0, 3, 3 );

            vx = 0;
            vy = 0;

            life = LIFE_MAX;

            draw = drawPointCube;

            if( draw == drawGraphic )
            {
                //createGraphicDisc();
                createGraphicBlur();
            }
        }

        /**
         * X location
         */
        public function get x() :Number
        {
            return bounds.x;
        }

        /**
         * @private
         */
        public function set x( p_value :Number ) :void
        {
            bounds.x = p_value;
        }

        /**
         * Y location
         */
        public function get y() :Number
        {
            return bounds.y;
        }

        /**
         * @private
         */
        public function set y( p_value :Number ) :void
        {
            bounds.y = p_value;
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

            bounds.width = particleBD.width;
            bounds.height = particleBD.height;

            _graphic = particleBD.getPixels( bounds );

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
            particle.filters = [ new BlurFilter( 10, 10, 1 ) ];

            particleBD = new BitmapData( particle.width, particle.height, true, 0x00000000 );
            var pb :Rectangle = particle.getBounds(particle);
            var m :Matrix = new Matrix();
            m.translate( -pb.left, -pb.top );
            particleBD.draw( particle, m, null, null, null, true );

            bounds.width = particleBD.width;
            bounds.height = particleBD.height;

            _graphic = particleBD.getPixels( bounds );

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
            p_bd.setPixel32(bounds.x,bounds.y, _colour| (life << 24));
        }

        /**
         * Draws 4 points for this particle.
         *
         * @param p_bd
         *
         */
        public function drawPointCube( p_bd :BitmapData ) :void
        {
            p_bd.setPixel32(bounds.x,bounds.y, _colour | (life << 24));
            p_bd.setPixel32(bounds.x+1,bounds.y, _colour | (life << 24));
            p_bd.setPixel32(bounds.x+1,bounds.y+1, _colour | (life << 24));
            p_bd.setPixel32(bounds.x,bounds.y+1, _colour | (life << 24));
        }

        /**
         * Draws a filled rect for this particle.
         *
         * @param p_bd
         *
         */
        public function drawFillRect( p_bd :BitmapData ) :void
        {
            p_bd.fillRect( bounds, _colour | (life << 24) );
        }

        /**
         * Draws a graphic for this particle.
         *
         * @param p_bd
         *
         */
        public function drawGraphic( p_bd :BitmapData ) :void
        {
            _graphic.position = 0;
            p_bd.setPixels( bounds, _graphic );
        }
    }
}
