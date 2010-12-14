/**
 * Movie
 * @addon
 * @constructor
 * @base ThreadedEntity
 * @class
 * <h3>InputPins:</h3>
 *  <ul>
 *  <li>brightness {Number}</li>
 *  <li>saturation {Number}</li>
 *  <li>contrast {Number}</li>
 *  <li>alpha {Number}</li>
 *  <li>rotation {Number}</li>
 *  <li>origin {Point}</li>
 *  </ul>
 * <h3>OutputPins:</h3>
 *  <ul>
 *  <li>frame {Image}</li>
 *  <li>frameSize {Size}</li>
 *  </ul>
 *
 */
function VideoEntity()
{
    /**
     * The brightness of the output frame.
     * @type float
     */
    this.brightness = 0;
    /**
     * The saturation of the output frame.
     * @type float
     */
    this.saturation = 0;
    /**
     * The contrast of the output frame.
     * @type float
     */
    this.contrast = 0;
    /**
     * The alpha of the output frame.
     * @type float
     */
    this.alpha = 0;
    /**
     * The rotation degrees of the output frame.
     * @type float
     */
    this.rotation = 0;
    /**
     * The origin of the output frame.
     * @type Point
     */
    this.origin = 0;
}
