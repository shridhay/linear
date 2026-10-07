/// This module contains several vec data types.
module vec;

import std.stdio, std.math, std.conv, std.traits;

// Common alias for types
// Note: Most commonly we use 'float' type for vec2, so I omit the suffix.
//		 This is consistent with the matrix data types. 
alias vec2 =  Vec2!float;
alias vec2i = Vec2!int;
alias vec2d = Vec2!double;	// TODO: Consider a better suffix for double
							// Alias 'Point2' for the 'Vec2' type.
alias Point2f = vec2;
alias Point2i = vec2i;
alias Point2d = vec2d;

alias vec3 =  Vec3!float;
alias vec3i = Vec3!int;
alias vec3d = Vec3!double;	// TODO: Consider a better suffix for double
							// Alias 'Point2' for the 'Vec2' type.
alias Point3f = vec3;
alias Point3i = vec3i;
alias Point3d = vec3d;

alias vec4 =  Vec4!float;
alias vec4i = Vec4!int;
alias vec4d = Vec4!double;	// TODO: Consider a better suffix for double
							// Alias 'Point2' for the 'Vec2' type.
alias Point4f = vec4;
alias Point4i = vec4i;
alias Point4d = vec4d;

// Create a Vector using primitive types of integral or floating point.
// The dimensions can also be specified
//
// Note: In many of the member functions, you will observe the return type
// 			 of either 'T' or 'typeof(this)'. Why? The reason why is because
//       we want to be able to 'chain' together operations with a vector
//       using the universal function call syntax.
struct Vec2(T=float)
	// Template Constraint esnures only integral types
	// are supplied as template arguments during creation.
if(__traits(isIntegral,T) || __traits(isFloating,T)) {
	// Internal Data
	// Note: It's convenient to be able to access 
	//       in different ways to provide context to the user
	//       about what problem you're trying to solve.
	// Note: It's important to initialize these values. 
	//       If you have a float type that initializes to NaN,
	//       you will indeed get lots of assertion errors.
	// Note: When you print out a union, or data structure with a union,
	//       D will show you all of the union, but again remember, that
	//       the size of the type is not what you see.
	union{
		T[2] e = [0,0]; // Vectors are zero-initialized by default.
		struct{
			T x,y;
		}
		struct{
			T s,t;
		}
		struct{
			T i,j;
		}
		struct{
			T u,v;
		}
		struct{
			T[2] data;
		}
	}
	/// Constructor for a vec2 type
	/// Repeats every value
	this(T value){
		this.x = value;
		this.y = value;
	}
	/// Constructor for a vec2 tpe with a Vec2
	this(Vec2!T v){
		this.x = v.x;
		this.y = v.y;
	}
	/// Constructor for a vec2 type
	this(T x, T y){
		this.x = x;
		this.y = y;
	}

	// Convert an array to the vec2 type.
	// This 'copies' the data into the fields.
	// TODO: Will need a unittest on a custom object to see if this works
	//       -- however template constraints on integral and floating point
	//          types otherwise disallow this anyway.
	typeof(this) opCast(T[2] f){
		x = f[0];
		y = f[1];
		return this;
	}
	/// Retrieve data as a float array
	T[2] Data(){
		return this.data;
	}
	/// Retrieve pointer to raw data
	T* DataPtr(){
		return this.data.ptr;
	}
	// Support for indexing into the vector
	T opIndex(size_t i){
		return data[i];
	}
	// Assignment
	void opAssign(typeof(this) v){
		data = v.data;
	}
	void opIndexAssign(T value,size_t i){
		data[i] = value;
	}

	// Support negation
	// This 'flips' the direction of the vector.
	// Additional support for 'increment' and 'decrement' operators.
	typeof(this) opUnary(string op)() {
    typeof(this) result;
		static if(op=="-" || op=="++" || op=="--"){
			mixin("result.x="~op~"x;");
			mixin("result.y="~op~"y;");
		}
		return result;
	}	

	// Support binary overloads for + and -
	// Note: Why use 'typeof(this)' instead of just writing out 'Vec2!T'?
	//       What if we later decide to change the type?
	typeof(this) opBinary(string op)(typeof(this) rhs){
    typeof(this) result;
		static if(op=="+" || op=="-"){
			mixin("result.x = this.x"~op~"cast(T)rhs.x;");	
			mixin("result.y = this.y"~op~"cast(T)rhs.y;");	
		}
		return result;
	}

	// Support binary overloads for * and / 
	// Note: This is for 'scalar multiplication/division'
	typeof(this) opBinary(string op)(T scalar){
    typeof(this) result;
		static if(op=="*" || op=="/"){
			mixin("result.x = this.x"~op~"scalar;");	
			mixin("result.y = this.y"~op~"scalar;");	
		}
		return result;
	}
	// Support binary overloads for += and -=
	// Note: Why use 'typeof(this)' instead of just writing out 'Vec2!T'?
	//       What if we later decide to change the type?
    // Note: Currently, we 'cast' to the type of the right-hand side.
	ref typeof(this) opOpAssign(string op)(typeof(this) rhs){
		static if(op=="+" || op=="-"){
			mixin("x "~op~"= cast(T)rhs.x;");	
			mixin("y "~op~"= cast(T)rhs.y;");	
		}
		return this;
	}

	// Support binary overloads for *= and /= by a scalar
	// Note: This is for 'scalar multiplication/division', a cast is otherwise performed
    //       prior to adding the components of the right-hand side.
	ref typeof(this) opOpAssign(string op)(double scalar){
		static if(op=="*" || op=="/"){
			mixin("x "~op~"= cast(T)scalar;");	
			mixin("y "~op~"= cast(T)scalar;");	
		}
		return this;
	}

	// Magnitude of vector
	// Intuitively, this is the 'distance' from the origin that the vector
	// reaches.
    // Note: Because of the sqrt operation, we have opted to treat this as a double.
	double Magnitude(){
		double xx = x*x;
		double yy = y*y;
		return sqrt(xx + yy);
	}

	// Normalize vector
	// i.e. Convert to a unit vector
	// Note: It doesn't really make sense to normalize a 
	//       integer-based type, so we restrict to floating-point for now.
	// Note: Returns unnormlized vector if length is 0.
	typeof(this) Normalize() {
		// Cache value of magnitude to maybe save some time
		static if(__traits(isFloating,T)){
		double length = Magnitude();
			if(!isClose(length,0.0)){
				x = cast(T)(cast(double)x / length);	
				y = cast(T)(cast(double)y / length);
			}
			return this;
		}else{
			assert(0,"Can only normalize floating point values. Normalize Vec2!float, and then cast to Vec2!int");
		}
	}


	// Return the slope of the vector
	// If x is zero, return 0.0
	double GetSlope(){
		if(isClose(x,0.0f)){
			return 0.0f;
		}	
		return cast(double)y/cast(double)x;
	}

	// Returns the normal.
	// Note: The returned vector is not normalized.
	// Note: A nice explanation for the 'geometric' interpretation of effectively
	//       rotating the normal is provided.
	//       You may use this source below:
	//       https://stackoverflow.com/questions/1243614/how-do-i-calculate-the-normal-vector-of-a-line-segment
	// Note: A better explanation in point-slope form is  here:
	//       https://math.stackexchange.com/questions/943995/find-a-normal-vector-onto-the-line
	// Note: If a division could result in 0, a 'zero vector' is returned.
	typeof(this) GetNormal(){
		typeof(this) result;
		if(!isClose(y,0.0)){
			result.x =  -y;
			result.y = cast(T)((x));
		}
		return result;
	}

	/// Built-in to retrieve vector in 'writeln'
	/// e.g. writeln(vec2(1.0f,1.0f));
	string toString(){
		return "<"~x.to!string~","~y.to!string~">";
	}
}

/// Vector with 3-dimensions
struct Vec3(T=float)
	if(__traits(isIntegral,T) || __traits(isFloating,T)){
	union{
		T[3] e=[0,0,0]; // Vectors are zero-initialized by default.
		struct{
			T x,y,z;
		}
		struct{
			T r,g,b;
		}
		struct{
			T u,v,w;
		}
		struct{
			T[3] data;
		}
	}
	/// Constructor for a vec3 type
	/// Repeats every value
	this(T value){
		this.x = value;
		this.y = value;
		this.z = value;
	}
	/// Constructor for a vec3 type from a Vec2
	this(Vec2!T v, T z){
		this.x = v.x;
		this.y = v.y;
		this.z = z;
	}
	/// Constructor for a vec3 type from a Vec3
	this(Vec3!T v){
		this.x = v.x;
		this.y = v.y;
		this.z = v.z;
	}
	/// Constructor for a vec3 type
	this(T x, T y, T z){
		this.x = x;
		this.y = y;
		this.z = z;
	}

	typeof(this) opCast(T[3] f){
		x = f[0];
		y = f[1];
		w = f[2];
		return this;
	}
	/// Retrieve floating point data
	T[3] Data(){
		return this.data;
	}
	/// Retrieve pointer to underlying data
	T* DataPtr(){
		return this.data.ptr;
	}
	/// Retrieve individual data 
	T opIndex(size_t i){
		return data[i];
	}
	void opAssign(typeof(this) v){
		data = v.data;
	}
	/// Assign new value to index
	void opIndexAssign(T value,size_t i){
		data[i] = value;
	}

	/// opUnary for negation operations
	typeof(this) opUnary(string op)() {
    typeof(this) result;
		static if(op=="-" || op=="++" || op=="--"){
			mixin("result.x="~op~"x;");
			mixin("result.y="~op~"y;");
			mixin("result.z="~op~"z;");
		}
		return result;
	}	

	/// Binary operations on a vector
	typeof(this) opBinary(string op)(typeof(this) rhs){
    typeof(this) result;
		static if(op=="+" || op=="-"){
			mixin("result.x = this.x"~op~"cast(T)rhs.x;");	
			mixin("result.y = this.y"~op~"cast(T)rhs.y;");	
			mixin("result.z = this.z"~op~"cast(T)rhs.z;");	
		}
		return result;
	}

	/// Scalar operations with a scalar
	typeof(this) opBinary(string op)(double scalar){
    typeof(this) result;
		static if(op=="*" || op=="/"){
			mixin("result.x = this.x"~op~"scalar;");	
			mixin("result.y = this.y"~op~"scalar;");	
			mixin("result.z = this.z"~op~"scalar;");	
		}
		return result;
	}
	// Support binary overloads for += and -=
	ref typeof(this) opOpAssign(string op)(typeof(this) rhs){
		static if(op=="+" || op=="-"){
			mixin("x "~op~"= cast(T)rhs.x;");	
			mixin("y "~op~"= cast(T)rhs.y;");	
			mixin("z "~op~"= cast(T)rhs.z;");	
		}
		return this;
	}
	// Support binary overloads for *= and /= by a scalar
	ref typeof(this) opOpAssign(string op)(double scalar){
		static if(op=="*" || op=="/"){
			mixin("x "~op~"= cast(T)scalar;");	
			mixin("y "~op~"= cast(T)scalar;");	
			mixin("z "~op~"= cast(T)scalar;");	
		}
		return this;
	}

	// Magnitude of vector
	double Magnitude(){
		double xx = x*x;
		double yy = y*y;
		double zz = z*z;
		return sqrt(xx + yy +zz);
	}

	// Normalize vector
	typeof(this) Normalize() {
		// Cache value of magnitude to maybe save some time
		static if(__traits(isFloating,T)){
			double length = Magnitude();
			if(!isClose(length,0.0)){
				x = cast(T)(cast(double)x / length);	
				y = cast(T)(cast(double)y / length);
				z = cast(T)(cast(double)z / length);
			}
			return this;
		} else {
			assert(0,"Can only normalize floating point values. Normalize Vec2!float, and then cast to Vec2!int");
		}
	}

	// Return the slope of the vector
	double GetSlope(){
		assert(0,"Not yet implemented");
	}
	// Returns the normal.
	// Note: The returned vector is not normalized.
	typeof(this) GetNormal(){
		assert(0,"Not yet implemented");
	}

	/// Built-in to retrieve vector in 'writeln'
	/// e.g. writeln(vec3(1.0f,1.0f,1.0f));
	string toString(){
		return "<"~x.to!string~","~y.to!string~","~z.to!string~">";
	}
}

/// Vector with 4-dimensions
struct Vec4(T=float)
	if(__traits(isIntegral,T) || __traits(isFloating,T)){
	/// Union structure is used so that you can access the data using
	/// two 'different' ways.
	union{
		T[4] e=[0,0,0,0]; // Vectors are zero-initialized by default.
		struct{
			T x,y,z,w;
		}
		struct{
			T r,g,b,a;
		}
		struct{
			T[4] data;
		}
	}

	/// Constructor for a vec4 type
	/// Repeats every value
	this(T value){
		this.x = value;
		this.y = value;
		this.z = value;
		this.w = value;
	}

	/// Constructor for a vec4 type with a Vec2
	this(Vec2!T v, T z, T w){
		this.x = v.x;
		this.y = v.y;
		this.z = z;
		this.w = w;
	}
	/// Constructor for a vec4 type with a Vec3
	this(Vec3!T v, T w){
		this.x = v.x;
		this.y = v.y;
		this.z = v.z;
		this.w = w;
	}
	/// Constructor for a vec4 type with a Vec4
	this(Vec4!T v){
		this.x = v.x;
		this.y = v.y;
		this.z = v.z;
		this.w = v.w;
	}
	/// Constructor for a vec4 type
	this(T x, T y, T z, T w){
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}

	/// Retrieve the static array for data values
	T[4] Data(){
		return this.data;
	}

	/// Retrieve the static array for data
	T* DataPtr(){
		return this.data.ptr;
	}

	T opIndex(size_t i){
		return data[i];
	}
	void opAssign(typeof(this) v){
		data = v.data;
	}
	void opIndexAssign(T value,size_t i){
		data[i] = value;
	}

	/// opUnary for negation operations
	typeof(this) opUnary(string op)(){
    typeof(this) result;
		static if(op=="-" || op=="++" || op=="--"){
			mixin("result.x="~op~"x;");
			mixin("result.y="~op~"y;");
			mixin("result.z="~op~"z;");
			mixin("result.w="~op~"w;");
		}
		return result;
	}	

	/// opBinary operations with vectors
	typeof(this) opBinary(string op)(typeof(this) rhs){
    typeof(this) result;
		static if(op=="+" || op=="-"){
			mixin("result.x = this.x"~op~"cast(T)rhs.x;");	
			mixin("result.y = this.y"~op~"cast(T)rhs.y;");	
			mixin("result.z = this.z"~op~"cast(T)rhs.z;");	
			mixin("result.w = this.w"~op~"cast(T)rhs.w;");	
		}
		return result;
	}

	/// opBinary operations with scalar values.
	typeof(this) opBinary(string op)(T scalar){
    typeof(this) result;
		static if(op=="*" || op=="/"){
			mixin("result.x = this.x"~op~"scalar;");	
			mixin("result.y = this.y"~op~"scalar;");	
			mixin("result.z = this.z"~op~"scalar;");	
			mixin("result.w = this.w"~op~"scalar;");	
		}
		return result;
	}

	// Support binary overloads for += and -=
	ref typeof(this) opOpAssign(string op)(typeof(this) rhs){
		static if(op=="+" || op=="-"){
			mixin("x "~op~"= cast(T)rhs.x;");	
			mixin("y "~op~"= cast(T)rhs.y;");	
			mixin("z "~op~"= cast(T)rhs.z;");	
			mixin("w "~op~"= cast(T)rhs.w;");	
		}
		return this;
	}
	// Support binary overloads for *= and /= by a scalar
	ref typeof(this) opOpAssign(string op)(double scalar){
		static if(op=="*" || op=="/"){
			mixin("x "~op~"= cast(T)scalar;");	
			mixin("y "~op~"= cast(T)scalar;");	
			mixin("z "~op~"= cast(T)scalar;");	
			mixin("w "~op~"= cast(T)scalar;");	
		}
		return this;
	}

	// Magnitude of vector
	double Magnitude(){
		double xx = x*x;
		double yy = y*y;
		double zz = z*z;
		double ww = w*w;
		return sqrt(xx + yy + zz +ww);
	}

	// Normalize vector
	typeof(this) Normalize(){
		// Cache value of magnitude to maybe save some time
		static if(__traits(isFloating,T)){
			double length = Magnitude();
			if(!isClose(length,0.0)){
				x = cast(T)(cast(double)x / length);	
				y = cast(T)(cast(double)y / length);
				z = cast(T)(cast(double)z / length);
				w = cast(T)(cast(double)w / length);
			}
			return this;
		} else {
			assert(0,"Can only normalize floating point values. Normalize Vec2!float, and then cast to Vec2!int");
		}
	}

	// Return the slope of the vector
	double GetSlope(){
		assert(0,"Not yet implemented");
	}
	// Returns the normal.
	// Note: The returned vector is not normalized.
	typeof(this) GetNormal(){
		assert(0,"Not yet implemented");
	}

	/// Special function in D to work with 'writeln' for example.
	/// This is the function that will be called to write the vector as a string.
	/// NOTE: Writing this function can be improved using interpolated string sequences
	///       if you are using a later version of D.
	/// e.g. writeln(vec4(1.0f,1.0f,1.0f,1.0f));
	string toString(){
		return "<"~x.to!string~","~y.to!string~","~z.to!string~","~w.to!string~">";
	}

	/// Optional to implement
	/*
	/// Handle various layouts for accessing variables.
	/// Note: You can use various 'accessors'
	///       and can consider the 'permutation' library to otherwise
	///       generate all possible combinations at compile-time.
	float opDispatch(string name)(){
	if(name =="r") {	return x;               }
	assert(0);
	}
	vec2 opDispatch(string name)(){
	if(name == "rg")    {	return vec2(x,y);	    }
	assert(0);
	}
	vec3 opDispatch(string name)(){
	if(name == "rgb")   {   return vec3(x,y,z);	    }
	assert(0);
	}
	vec4 opDispatch(string name)(){
	if(name == "rgba")  {	return vec4(x,y,z,w);	}
	}
	 */
}

/// Helper function that will print two vectors side by side
void VectorDebugPrint(T=float)(string name1, vec4 v1, string name2, Vec4!T v2){
	writeln(name1,"\t\t",name2);
	writeln(v1,"\t",v2);
}

/// Return the Magnitude of a vector
T Magnitude(T=float)(Vec2!T v){
	return sqrt(v.x*v.x + v.y*v.y);
}
/// Return the Magnitude of a vector
T Magnitude(T=float)(Vec3!T v){
	return sqrt(v.x*v.x + v.y*v.y + v.z*v.z);
}
/// Return the Magnitude of a vector
T Magnitude(T=float)(Vec4!T v){
	if(v.w  != 0){
		assert(0,"WARNING: May be illegally computing the length of a point");
	}
	return sqrt(v.x*v.x + v.y*v.y + v.z*v.z + v.w*v.w);
}

/// Returns a unit vector
Vec2!T Normalize(T=float)(Vec2!T v){
	T length = Magnitude(v);
	if(length == 0){
		writeln("WARNING: retrieved a zero value for magnitude");
		return vec2(0.0f,0.0f);
	}
	float length_reciprocal = 1.0f / length;

	return vec2(v.x * length_reciprocal, v.y *length_reciprocal); 
}

/// Returns a unit vector
Vec3!T Normalize(T=float)(Vec3!T v){
	T length = v.Magnitude();
	if(length == 0){
		writeln("WARNING: retrieved a zero value for magnitude");
		return Vec3!T(0.0f,0.0f,0.0f);
	}
	float length_reciprocal = 1.0f / length;

	return vec3(v.x * length_reciprocal, v.y *length_reciprocal, v.z * length_reciprocal); 
}

/// Returns a unit vector
Vec4!T Normalize(T=float)(Vec4!T v){
	T length = v.Magnitude();
	if(length == 0){
		writeln("WARNING: retrieved a zero value for magnitude");
		return Vec4!T(0.0f,0.0f,0.0f,0.0f);
	}
	float length_reciprocal = 1.0f / length;

	return Vec4!T(v.x * length_reciprocal, v.y * length_reciprocal, v.z * length_reciprocal, v.w * length_reciprocal); 
}


// Return the scalar dot product to determine how
// similar two vectors are.
T Dot(T=float)(Vec2!T a, Vec2!T b){
	return a.x*b.x + a.y*b.y;
}
T Dot(T=float)(Vec3!T a, Vec3!T b){
	return a.x*b.x + a.y*b.y + a.z*b.z;
}
T Dot(T=float)(Vec4!T a, Vec4!T b){
	if(a.w.isClose(1.0f) || b.w.isClose(1.0f)){
		//        writeln("Warning, may be operating on a point");
	}
	return a.x*b.x + a.y*b.y + a.z*b.z + a.w*b.w;
}

Vec2!T Cross(T=float)(Vec2!T a, Vec2!T b){
	Vec2!T result;

	assert(0,"Not yet implemented");

	return result;
}
Vec3!T Cross(T=float)(Vec3!T a, Vec3!T b){
	Vec3!T result;

	result[0] = a.y*b.z - b.y*a.z;
	result[1] = a.z*b.x - b.z*a.x;
	result[2] = a.x*b.y - b.x*a.y;

	return result;
}

// Reflect a vector across a surface normal.
// 'v' is the incoming (incident) vector
// 'n' is the surface normal of 'v' 
// *Hint* Normalizing the vectors makes this easier
// Helpful chapter: https://immersivemath.com/ila/ch03_dotproduct/ch03.html
// Another pragmatic resource: https://www.sunshine2k.de/articles/coding/vectorreflection/vectorreflection.html
// I used this formula for my implementation at the top:
// https://www.contemporarycalculus.com/dh/Calculus_all/CC11_7_VectorReflections.pdf
Vec2!T Reflect(T=float)(Vec2!T v, Vec2!T n){
	Vec2!T result;

	result = v -  (Project(v,n) * 2);

	return result;
}
Vec3!T Reflect(T=float)(Vec3!T v, Vec3!T n){
	Vec3!T result;

	result = v -  (Project(v,n) * 2);

	return result;
}

// Projects vector 'u' onto vector 'v' and returns the
// new vector.
Vec2!T Project(T=float)(Vec2!T u, Vec2!T v){
	Vec2!T result;

	double uDotV = u.Dot(v);
	result = v * ((uDotV) / (v.Magnitude()*v.Magnitude()));

	return result;
}
// Projects vector 'u' onto vector 'v' and returns the
// new vector.
Vec3!T Project(T=float)(Vec3!T u, Vec3!T v){
	Vec3!T result;

	double uDotV = u.Dot(v);
	result = v * ((uDotV) / (v.Magnitude()*v.Magnitude()));

	return result;
}


/// Distance between two points with each component
double Distance(double x1, double y1, double x2, double y2){
	double xx = x2-x1;
	double yy = y2-y1;
	return sqrt(xx*xx + yy*yy);
}
/// Distance between two points with each component
double Distance(double x1, double y1,double z1, double x2, double y2, double z2){
	double xx = x2-x1;
	double yy = y2-y1;
	double zz = z2-z1;
	return sqrt(xx*xx + yy*yy + zz*zz);
}
/// Distance between two Vec2!T where the vectors are treated 'as points'
T Distance(T=float)(Vec2!T a, Vec2!T b){
	return cast(T)sqrt(cast(double)((a.x - b.x)*(a.x-b.x) + (a.y - b.y)*(a.y-b.y)));
}
/// Distance between two Vec3!T where the vectors are treated 'as points'
T Distance(T=float)(Vec3!T a, Vec3!T b){
	return cast(T)sqrt(cast(double)((a.x - b.x)*(a.x-b.x) +	(a.y - b.y)*(a.y-b.y) +	(a.z - b.z)*(a.z-b.z)));
}
/// Distance between two Vec4!T where the vectors are treated 'as points'
T Distance(T=float)(Vec4!T a, Vec4!T b){
	return cast(T)sqrt( cast(double)(
			(a.x - b.x)*(a.x-b.x) +
			(a.y - b.y)*(a.y-b.y) +
			(a.z - b.z)*(a.z-b.z) +
			(a.w - b.w)*(a.w-b.w)));
}


 
// Other functions

float DegreesToRadians(float degree){
	return degree * ( PI / 180.0f);
}
float RadiansToDegrees(float rad){
	return rad * ( 180.0f / PI);
}

//vec2 project(vec3