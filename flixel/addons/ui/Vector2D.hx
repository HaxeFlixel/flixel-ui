/* 
Copyright 2008 Cheezeworld.com 

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.


THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

*/

package flixel.addons.ui;

import flash.geom.Point;

class Vector2D {
	public var length(get, never) : Float;
	public var lengthSq(get, never) : Float;

	public function get_length() : Float {
		//length = sqrt(x^2 + y^2)
		// ..Only calculate length if it has changed ...
		if(_oldX != x || _oldY != y)  {
			_oldX = x;
			_oldY = y;
			_length = Math.sqrt((x * x) + (y * y));
		}
		return _length;
	}

	public function get_lengthSq() : Float {
		return x * x + y * y;
	}

	public function isZero() : Bool {
		return (x == 0 || y == 0);
	}

	public var x : Float;
	public var y : Float;
	//Constructor -------------------------------------------------
		public function new(X : Float = 0, Y : Float = 0) {
		x = X;
		y = Y;
		//to avoid slowdowns when creating new Vectors, length
		//is calculated when requested rather than on creation
		_length = 0;
	}

	//--------------------------------------------------------------
		// -- STATIC --
		/**

 		 * Will determine if someone at <code>pos1st</code> who is facing <code>facing1st</code>

 		 * that has a FOV of <code>fov</code> can see an object at </code>pos2nd</code> 

 		 * @param pos1st The position of the "thing" looking

 		 * @param facing1st The unit length heading vector of which the "thing" is facing.

 		 * @param fov How wide the FOV of the "thing" is.

 		 * @param pos2nd The position of the object the "thing" is looking at.

 		 * @return returns true if the "thing" can see the object.

 		 * 

 		 */	static public function is2ndInFOVof1st(pos1st : Vector2D, facing1st : Vector2D, fov : Float, pos2nd : Vector2D) : Bool {
		var toTarget : Vector2D = pos2nd.copy();
		toTarget.subtract(pos1st);
		toTarget.normalize();
		return facing1st.dotOf(toTarget) >= Math.cos(fov / 2.0);
	}

	/**

 		 * Converts a Point object to a Vector 

 		 * @param point the Point object to convert

 		 * @return the newly constructed Vector

 		 * 

 		 */	static public function pointToVector(point : Point) : Vector2D {
		return new Vector2D(point.x, point.y);
	}

	/**

	 * Rotates the vector by angle

	 * @param radians the angle of rotation, in radians

	 */	public function rotateVector(radians : Float) : Void {
		var ca : Float = Math.cos(radians);
		var sa : Float = Math.sin(radians);
		var rx : Float = x * ca - y * sa;
		var ry : Float = x * sa + y * ca;
		x = rx;
		y = ry;
	}

	/**

 		 * This will convert a rotation to a heading vector 

 		 * @param rotInDegrees the rotation value to be converted (in degrees)

 		 * @return Returns a unit length vector of <code>rotInDegrees</code> heading

 		 * 

 		 */	static public function rotToHeading(a_rotInRadians : Float) : Vector2D {
		var xPart : Float = Math.cos(a_rotInRadians);
		var yPart : Float = Math.sin(a_rotInRadians);
		return new Vector2D(xPart, yPart);
	}

	// -- CONVERSIONS / UTILITIES --
		public function toString() : String {
		return ("( " + x + ", " + y + " )");
	}

	/**

 		 * Converts this Vector to a Point Object 

 		 * @return A Point Object

 		 * 

 		 */	public function toPoint() : Point {
		return new Point(x, y);
	}

	/**

 		 * Used to determine what angle this vector is from 0,0

 		 * @return The angle in radians

 		 * 

 		 */	public function toRotation() : Float {
		//calc the angle
		var ang : Float = Math.atan(y / x);
		//if it is in the first quadrant
		if(y < 0 && x > 0)  {
			return ang;
		}
		//if its in the 2nd or 3rd quadrant
		if((y < 0 && x < 0) || (y > 0 && x < 0))  {
			return ang + 3.141592653589793;
		}
		//it must be in the 4th quadrant so:
		return ang + 6.283185307179586;
	}

	/**

 		 * An easy way to "set" the x/y value of this Vector 

 		 * @param x

 		 * @param y

 		 * 

 		 */	public function Set(x : Float, y : Float) : Void {
		this.x = x;
		this.y = y;
	}

	/**

 		 * Easy way to make a copy of this Vector 

 		 * @return a New Vector object with the same properties as this Vector

 		 * 

 		 */	public function copy() : Vector2D {
		var newVector : Vector2D = new Vector2D(x, y);
		newVector._length = _length;
		newVector._oldX = x;
		newVector._oldY = y;
		return newVector;
	}

	// -- MODIFY FUNCTIONS -- These functions will perform modifications on THIS vector --
		/**

 		 * Shortens this Vector down to unit length. 

 		 * 

 		 */	public function normalize() : Void {
		if(length != 0)  {
			x /= _length;
			y /= _length;
		}
	}

	/**

 		 * Will reflect this vector upon the supplied vector. 

 		 * (like the path of a ball bouncing off a wall) 

 		 * @param norm The unit length "normal" vector to reflect upon.

 		 * 

 		 */	public function reflect(norm : Vector2D) : Void {
		//this += 2.0 * this.dot(norm) * norm.getReverse();
		v1 = norm.getReverse();
		v1.multiply(2.0 * dotOf(norm));
		addTo(v1);
	}

	/**

 		 * Will add two Vectors together

 		 * @param vector The Vector to add to this one.

 		 * 

 		 */	public function addTo(vector : Vector2D) : Void {
		x += vector.x;
		y += vector.y;
	}

	/**

 		 * Will subtract two Vectors together 

 		 * @param vector The Vector to subtract from this one.

 		 * 

 		 */	public function subtract(vector : Vector2D) : Void {
		x -= vector.x;
		y -= vector.y;
	}

	/**

 		 * Will multiply by a scalar number 

 		 * @param scalar The Number to multiply by.

 		 * 

 		 */	public function multiply(scalar : Float) : Void {
		x *= scalar;
		y *= scalar;
	}

	/**

 		 * Will Divide by a scalar number

 		 * @param scalar The Number to divide by.

 		 * 

 		 */	public function divide(scalar : Float) : Void {
		//#if debug
		if (scalar == 0)  {
			#if debug
				trace("Vector::dividedBy() - Illegal Divide by Zero!");
			#end
		}

		else  {
			x /= scalar;
			y /= scalar;
		}
		//#end

	}

	/**

 		 * Will keep this vector no longer than the max value supplied 

 		 * @param max The max length of this vector.

 		 * 

 		 */	public function truncate(max : Float) : Void {
		if(lengthSq > max * max)  {
			normalize();
			multiply(max);
		}
	}

	/**

 		 * Will keep this Vector inside a region by wrapping it around the sides

 		 * (This is considering the vector is being used as a position) 

 		 * @param topLeft The top left point of the 'region' to wrap around

 		 * @param bottomRight The bottom right point of the 'region' to wrap around

 		 * 

 		 */	public function wrapAround(topLeft : Vector2D, botRight : Vector2D) : Void {
		if(x > botRight.x)  {
			x = topLeft.x + (x - botRight.x);
		}

		else if(x < topLeft.x)  {
			x = botRight.x + x;
		}
		if(y < topLeft.y)  {
			y = botRight.y + y;
		}

		else if(y > botRight.y)  {
			y = topLeft.y + (y - botRight.y);
		}
	}

	// -- RETURN / GETTER FUNCTIONS -- These functions return a calculation but do not modify this Vector
		/**

 		 * Will return the result of this Vector added to another. 

 		 * @param vector Vector to add to.

 		 * @return The result of the addition.

 		 * 

 		 */	public function addedTo(vector : Vector2D) : Vector2D {
		return new Vector2D(x + vector.x, y + vector.y);
	}

	/**

 		 * Will return the result of this Vector subtracted by another. 

 		 * @param vector Vector to subtract by

 		 * @return  The result of the subtraction.

 		 * 

 		 */	public function subtractedBy(vector : Vector2D) : Vector2D {
		return new Vector2D(x - vector.x, y - vector.y);
	}

	/**

 		 * Will return the result of this Vector multiplied by another. 

 		 * @param scalar Number to multiply by

 		 * @return  The result of the multiplication.

 		 * 

 		 */	public function multipliedBy(scalar : Float) : Vector2D {
		return new Vector2D(x * scalar, y * scalar);
	}

	/**

 		 * Will return the result of this Vector divided by another. 

 		 * @param scalar Number to divide by

 		 * @return  The result of the division.

 		 * 

 		 */	public function dividedBy(scalar : Float) : Vector2D {
		if (scalar == 0)  {
			#if debug
				trace("Vector::dividedBy() - Illegal Divide by Zero!");
			#end
			return new Vector2D();
		}

		else  {
			return new Vector2D(x / scalar, y / scalar);
		}

	}

	/**

 		 * Will give the normalized version of this Vector. 

 		 * @return The normalized version of this Vector.

 		 * 

 		 */	public function getNormalized() : Vector2D {
		if(length == 0)  {
			return new Vector2D();
		}
		return new Vector2D(x / _length, y / _length);
	}

	/**

 		 * Will give the reverse of this Vector. 

 		 * @return The reversed version of this Vector.

 		 * 

 		 */	public function getReverse() : Vector2D {
		return new Vector2D(-x, -y);
	}

	/**

 		 * Will give the sign of this vector in relation to another.

 		 * (Useful for certain calculations) 

 		 * @param vector The Vector to test again.

 		 * @return -1 if vector is counterclockwise, else 1 if clockwise.

 		 * 

 		 */	public function sign(vector : Vector2D) : Int {
		if(y * vector.x > x * vector.y)  {
			return -1;
		}

		else  {
			return 1;
		}

	}

	/**

 		 * Determines if this Vector is parallel to another. 

 		 * @param vector The Vector to test again.

 		 * @return true if these Vectors are parallel

 		 * 

 		 */	public function isParallelTo(vector : Vector2D) : Bool {
		v1 = copy();
		v1.normalize();
		v2 = vector.copy();
		v2.normalize();
		return ((v1.x == v2.x && v1.y == v2.y) || (v1.x == -v2.x && v1.y == -v2.y));
	}

	/**

 		 * Determines the perpendicular Vector to this.

 		 * (otherwise known as the right hand normal) 

 		 * @return A perpendicular Vector to this one. 

 		 * 

 		 */	public function getPerp() : Vector2D {
		return new Vector2D(-y, x);
	}

	/**

 		 * Calculates the dot to another Vector.

 		 * |V1| . |V2| 

 		 * @param vector The Vector to calculate with.

 		 * @return The resulting dot product.

 		 * 

 		 */	public function dotOf(vector : Vector2D) : Float {
		return (x * vector.x) + (y * vector.y);
	}

	/**

 		 * Determines the cross product of this Vector and another.

 		 * This is the dame as the dot product of this and the

 		 * lefthand normal of the other. 

 		 * @param vector Vector to calculate against.

 		 * @return The resulting cross product.

 		 * 

 		 */	public function crossOf(vector : Vector2D) : Float {
		return (x * vector.y) - (y * vector.x);
	}

	/**

 		 * Use to determine the angle between this and another Vector. 

 		 * @param vector The Vector to test against.

 		 * @return The resulting angle between these two Vectors in radians

 		 * 

 		 */	public function angleTo(vector : Vector2D) : Float {
		return Math.acos(dotOf(vector) / (length * vector.length));
	}

	/**

 		 * Use to find the dot prod of another Vector's perpendicular Vector. 

 		 * @param vector The Vector to test against.

 		 * @return The resulting dot product.

 		 * 

 		 */	public function perpDotOf(vector : Vector2D) : Float {
		return getPerp().dotOf(vector);
	}

	/**

 		 * Use to find the projection of this onto another Vector. 

 		 * @param vector The vector to project upon

 		 * @return The resulting projected Vector.

 		 * 

 		 */	public function projectionOn(vector : Vector2D) : Vector2D {
		v1 = vector.copy();
		v1.multiply(this.dotOf(vector) / vector.dotOf(vector));
		return v1;
	}

	/**

 		 * Use to find the distance to another Vector.

 		 * @param vector The Vector to test distance with.

 		 * @return The distance between these two Vectors.

 		 * 

 		 */	public function distanceTo(vector : Vector2D) : Float {
		var xSep : Float = vector.x - x;
		var ySep : Float = vector.y - y;
		return Math.sqrt(ySep * ySep + xSep * xSep);
	}

	/**

 		 * Same as <code>distanceTo</code> but avoids the square root.

 		 * Use this any time the exact distance isn't exactly required. 

 		 * @param vector The Vector to test distance with.

 		 * @return The resulting distance * distance

 		 * 

 		 */	public function distanceSqTo(vector : Vector2D) : Float {
		var xSep : Float = vector.y - y;
		var ySep : Float = vector.x - x;
		return ySep * ySep + xSep * xSep;
	}

	/**

 		 * Use to determine if this Vector is within a bounds

 		 * (considering it is actually a point)  

 		 * @param topLeft top left 'point' of the region.

 		 * @param botRight bot right 'point' of the region.

 		 * @return 

 		 * 

 		 */	public function isInsideRegion(topLeft : Vector2D, botRight : Vector2D) : Bool {
		return !((x < topLeft.x) || (x > topLeft.x + botRight.x) || (y < topLeft.y) || (y > topLeft.y + botRight.y));
	}

	// -- PRIVATE --
		var _length : Float;
	//temporary vars so there is no mass object creation
		var v1 : Vector2D;
	var v2 : Vector2D;
	//used to save time on length calculation
		var _oldX : Float;
	var _oldY : Float;
	//used in some calculations
	static var RAD_TO_DEG : Float = (180 / Math.PI);
	static var DEG_TO_RAD : Float = (Math.PI / 180);
}

