/**
 * @fileoverview
 * Allow connections between entities and sending/receiving signals
 */

/**
 * Pin
 * @constructor
 * @class Wrapper class for JMXPin instances.
 * Connections between {@link Entity} instances happen through pins.
 * Only pins of the same type and opposite 
 * @see Entity
 */
function Pin()
{
    /**
     * The type of the pin.
     * @type int
     */
    this.type = 0;
    /**
     * The name of the pin.
     * @type string
     */
    this.name = "";
    /**
     * A boolean flag indicating if multiple connections are allowed
     * @type boolean
     */
    this.miltple = 0;
    /**
     * A boolean flag indicating if value must be sent at each tick or only at connection time
     * @type boolean
     */
    this.continuous = 0;
    /**
     * The minimum value allowed for this pin
     * @type float
     */
    this.minValue = 0.0;
    /**
     * The maximum value allowed for this pin
     * @type float
     */
    this.maxValue = 0.0;
    /**
     * Readonly boolean field which indicates if this pin has at least one connection or not
     * @type boolean
     */
    this.connected = false;

    /**
     * Connect this pin the destination pin
     * @param {Pin} pin The pin we want to connect to
     */
    this.connect = function(pin) {
        // ...
    }

    /**
     * Export this pin making it available on the board
     */
    this.export = function() {
        // ...
    }

    // ...
}

