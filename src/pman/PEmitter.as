package pman
{
    import flash.display.BitmapData;
    import flash.geom.Rectangle;

    /**
     * Particle emitter.
     *
     * @author David Wagner
     *
     */
    public class PEmitter
    {
        private var _particles :Array;
        private var _x :Number;
        private var _y :Number;
        private var _bd :BitmapData;
        private var _r :Rectangle;
        private var _bounce :Boolean;

        /**
         * Constructor
         *
         * @param p_particleCount Total number of particles
         * @param p_x Emitter X position
         * @param p_y Emitter Y position
         * @param p_bd BitmapData object to draw the particles into
         * @param p_r Rect containing the particles
         * @param p_colours Colour array from which a particles colour is randomly chosen.
         * @param p_bounce Indicates if the particles should bounce until dead.
         *
         */
        public function PEmitter( p_particleCount :int, p_x :Number, p_y :Number, p_bd :BitmapData, p_r :Rectangle, p_colours :Vector.<int>, p_bounce :Boolean ) :void
        {
            _bounce = p_bounce;
            _bd = p_bd;
            _r = p_r.clone();
            _x = p_x;
            _y = p_y;
            _particles = new Array( p_particleCount );

            for( var i :int = 0; i < p_particleCount; i++ )
            {
                var p :P = new P(p_colours[Math.round((p_colours.length - 1) * Math.random())]);

                emitParticle( p );

                _particles[i] = p;
            }
        }

        /**
         * Emits the passed particle, resetting it to initial values.
         *
         * @param p_p
         *
         */
        private function emitParticle( p_p :P ) :void
        {
            p_p.x = _x + (-10 + (Math.random() * 20));
            p_p.y = _y + (-10 + (Math.random() * 20));

            if( p_p.x < _r.x ) p_p.x = _r.x;
            if( p_p.x >= _r.right ) p_p.x = _r.right - 1;

            if( p_p.y < _r.y ) p_p.y = _r.y;
            if( p_p.y >= _r.bottom ) p_p.y = _r.bottom - 1;

            p_p.vx = -10 + (Math.random() * 20);
            p_p.vy = -10 + (Math.random() * 20);

            p_p.life = P.LIFE_MAX * Math.random();
        }

        /**
         * Updates the specified particle.
         *
         * @param p_p
         * @param p_index
         * @param p_array
         *
         */
        private function forEach_updateParticle( p_p :P, p_index :int, p_array :Array ) :void
        {
            p_p.x += p_p.vx;
            p_p.y += p_p.vy;
            p_p.life -= 1;

            // Apply "Gravity"
            p_p.vy += 1;

            // Apply bounce and dampening
            if( _bounce )
            {
                if( p_p.x < _r.left || p_p.x > _r.right )
                {
                    p_p.x -= p_p.vx;
                    p_p.vx *= -0.9;
                }

                if( p_p.y < _r.top || p_p.y > _r.bottom )
                {
                    p_p.y -= p_p.vy;
                    p_p.vy *= -0.8;
                }
            }
            else
            {
                if( p_p.x < _r.left || p_p.x > _r.right || p_p.y < _r.top || p_p.y > _r.bottom ) p_p.life = 0;
            }

            if( p_p.life <= 0 )
            {
                // It's dead
                emitParticle( p_p );
            }
            else
            {
                // Draw it
                p_p.draw( _bd );
            }
        }

        /**
         * Updates all particles.
         *
         */
        public function update() :void
        {
            _particles.forEach( forEach_updateParticle );
        }
    }
}
