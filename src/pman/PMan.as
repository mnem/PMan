package pman
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    /**
     * Particle manager.
     *
     * @author David Wagner
     *
     */
    public class PMan extends Sprite
    {
        private var _emitters :Vector.<PEmitter>;
        private var _bd :BitmapData;
        private var _b :Bitmap;
        private var _r :Rectangle;
        private var _zeroPoint :Point;
        public var particleCount:int;

        /**
         * Constructor.
         *
         * @param p_width Width of the particle area.
         * @param p_height Height of the particle area.
         *
         */
        public function PMan( p_width :int, p_height :int )
        {
            super();

            _zeroPoint = new Point();

            _r = new Rectangle( 0, 0, p_width, p_height );
            _bd = new BitmapData(_r.width, _r.height, false, 0x00000000);
            _b = new Bitmap(_bd, "never", false);

            addChild(_b);

            _emitters = new Vector.<PEmitter>;
        }

        /**
         * Adds a new particle emitter.
         *
         * @param p_particleCount Number of particles
         * @param p_x Emitter X
         * @param p_y Emitter Y
         * @param p_colours Array of colours the particles are randomly chosen from
         * @param p_bouncy Indicates if the particles should bouncy at the edge of the area, or die.
         * @param p_boundingArea Indicates a constraining box the particles must appear in. If null, the full size of the area is used.
         *
         */
        public function addEmitter( p_particleCount :Number, p_x :Number, p_y :Number, p_colours :Vector.<int>, p_bouncy :Boolean, gfx:int, p_boundingArea :Rectangle = null ) :void
        {
            if( p_boundingArea == null )
            {
                p_boundingArea = _r;
            }
            _emitters.push( new PEmitter( p_particleCount, p_x, p_y, _bd, p_boundingArea, p_colours, p_bouncy, gfx ) );
        }

        /**
         * Updates all the emitters.
         *
         */
        public function update() :void
        {
            _bd.lock();
            _bd.fillRect(_r, 0x000000);

            particleCount = 0;
            var i:int = _emitters.length;
            while(i--)
            {
                _emitters[i].update();
                particleCount += _emitters[i].particleCount;
            }

            _bd.unlock();
        }
    }
}
