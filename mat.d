// Design decisions, library is templated such that any type can be used.
// By default, all template arguments are floats. This makes the client interface
// more convenient otherwise to not have to litter the code.

/// Matrix module 
module mat;
import std.stdio, std.math, std.conv;
import vec, utility;

// Helpful template constraints
// TODO: Refactor this to be more neat.
auto IsMat3x3orMat4x4(T)(){
	return is(T==mat3) || 
         is(T==mat3i) ||
         is(T==mat3d) ||
         is(T==mat4) ||
         is(T==mat4i) ||
         is(T==mat4d);
}

// aliased type that the user is encouraged to use
// NOTE: The aliases are 'lowercase' to match what is in the glsl language.
//		 Otherwise type follows my usual convention of uppercase
alias mat3  = Mat3!float;
alias mat3i = Mat3!int;
alias mat3d = Mat3!double;

alias mat4  = Mat4!float;
alias mat4i = Mat4!int;
alias mat4d = Mat4!double;

/// matrix3x3
/// Note: The default constructed matrix is an identity matrix
struct Mat3(T=float){
	// e is short for 'elements'
	T[9] e = [
		1,0,0,
		0,1,0,
		0,0,1
	];

	/// Constructor which sets the diagonal of the matrix
	/// The default is for an identity matrix to be produced.
	this(T diagonal){
		e[0] = diagonal; 
		e[4] = diagonal;
		e[8] = diagonal;
	}

	/// Build a matrix from 3 column vectors
	this(Vec3!T col0, Vec3!T col1, Vec3!T col2){
		this[0] = col0; 
		this[1] = col1; 
		this[2] = col2; 
	}

	/// Build a matrix from 9 elements
	this(T e0,T e1, T e2, 
			T e3,T e4, T e5, 
			T e6,T e7, T e8){
		e[0] = e0;
		e[1] = e1;
		e[2] = e2;
		e[3] = e3;
		e[4] = e4;
		e[5] = e5;
		e[6] = e6;
		e[7] = e7;
		e[8] = e8;
	}

	/// Build a mat3 from a mat4 matrix (cuts off the last row and column)
	this(Mat4!T input){
		e[0] = input.e[0];
		e[1] = input.e[1];
		e[2] = input.e[2];

		e[3] = input.e[4];
		e[4] = input.e[5];
		e[5] = input.e[6];

		e[6] = input.e[8];
		e[7] = input.e[9];
		e[8] = input.e[10];
	}

	/// Retrieve the static array for data values.
	/// This is a 'D language array' where an array is a ptr and size.
	/// See 'DataPtr' if you want the raw pointer to the array data, which
	/// is useful to communicate with C-APIs.
	T[9] Data(){
		return this.e;
	}

	/// Retrieve the static array for data
	T* DataPtr(){
		return this.e.ptr;
	}

	// Index to get the column
	// NOTE: If you want a specific element, then use the notation
	//       for otherwise opIndex(size_t i, size_t j)
	// NOTE: Returning a float[3] versus a float* versus a Vec3f is
	//       something that may have to be later overloaded, or otherwise
	//		 to return a specific type a free function can be added.
	T[3] opIndex(size_t col){
		if(col==0){
			return [e[0],e[3],e[6]];
		}else	if(col==1){
			return [e[1],e[4],e[7]];
		}else if (col==2){
			return [e[2],e[5],e[8]];
		}else{
			assert(0,"illegal column specified, expected 0,1,2, received: "~col.to!string);
		}
	}

	/// Return the individual element
	/// Usage: mat3[i,j]
	ref T opIndex(size_t i, size_t j){
		return e[i*3 + j];
	}

	/// Assign to mat3 one value to all elements.
	/// e.g. mat3 m = 1.0f; // Populates every value with 1.0f
	void opAssign(T)(T value){
		e[] = value;
	}

	/// Assign to another mat3
	void opAssign(typeof(this) input){
		e[0] = input.e[0];
		e[1] = input.e[1];
		e[2] = input.e[2];
		e[3] = input.e[3];
		e[4] = input.e[4];
		e[5] = input.e[5];
		e[6] = input.e[6];
		e[7] = input.e[7];
		e[8] = input.e[8];
	}

	/// Assign a mat3 from a larger mat4 matrix
	void opAssign(Mat4!T input){
		e[0] = input.e[0];
		e[1] = input.e[1];
		e[2] = input.e[2];
		e[3] = input.e[4];
		e[4] = input.e[5];
		e[5] = input.e[6];
		e[6] = input.e[8];
		e[7] = input.e[9];
		e[8] = input.e[10];
	}

	/// Assign matrix elements of matrix individually
	/// Usage: mat3[i] = value;
	void opIndexAssign(T value, size_t idx){
		if(idx >= e.length){
			assert(0,"Index out of bounds");
		} 
		e[idx] = value;
	}

	/// Assign matrix value using 2 dimensions
	/// Usage: mat3[i,j] = value;
	void opIndexAssign(T value, size_t i, size_t j){
		e[i*3 + j] = value;
	}

	/// Assign specific matrix column to a new column vector
	/// mat4 m;
	/// vec4 v;
	/// m[0] = v; // Sets first column of matrix to values of v.
	void opIndexAssign(Vec3!T v, size_t i){
		e[i]    = v[0];
		e[i+3]  = v[1];
		e[i+6]  = v[2];
	}
	/// Perform a binary operation (+,-,*,/) to each element of a matrix
	/// Usage: mat3[i] += value;
	void opIndexOpAssign(string op)(T value, size_t i){
		static if(op=="+"){
			e[i] += value;
		}
		static if(op=="-"){
			e[i] -= value;
		}
		static if(op=="*"){
			e[i] *= value;
		}
		static if(op=="/"){
			e[i] /= value;
		}
		assert(0,"op not implemented for opIndexOpAssign(float value, size_t i)");
	}
	/// Perform a binary operation (+,-,*,/) to each element of a matrix
	/// Usage: mat3[i,j] += value;
	void opIndexOpAssign(string op)(T value, size_t i, size_t j){
		static if(op=="+"){
			e[i*3 + j] += value;
		}
		static if(op=="-"){
			e[i*3 + j] -= value;
		}
		static if(op=="*"){
			e[i*3 + j] *= value;
		}
		static if(op=="/"){
			e[i*3 + j] /= value;
		}
		assert(0,"op not implemented for opIndexOpAssign(float value, size_t i, size_t j)");
	}

	/// Perform binary matrix operations like matrix multiplication, addition, subtraction
	typeof(this) opBinary(string op)(typeof(this) m){
		typeof(this) result;	
		/// Perform matrix multiplication
		static if(op=="*"){
			for(int i=0; i < 3; i++){
				for(int j=0; j < 3; j++){
					T sum=0;
					for(int k=0; k < 3; k++){
						sum	 +=  this[i,k] * m[k,j];	
					}	
					result[i,j] = sum;
				}
			}
			return result;	
		}
		/// Perform matrix addition and subtraction
		static if(op=="+" || op=="-"){
			for(int i=0; i < e.length; i++){
				mixin("result[i] = this[i]"~op~"m[i];");
			}
			return result;	
		}

		assert(0,"op not implemented for mat4 opBinary(mat4)");
	}

	/// Multiply a matrix by a vector
	/// e.g. For performing: m*v (where 'v' is on the right side)
	Vec3!T opBinary(string op)(Vec3!T v){
		static if(op=="*"){
			Vec3!T result;	

			result[0] = this.Row(0).Dot(v);
			result[1] = this.Row(1).Dot(v);
			result[2] = this.Row(2).Dot(v);

			return result;	
		}
		assert(0,"op not implemented for vec4 opBinary(vec4)");
	}

	/// Handy function for printing out the string representation of a matrix
	string toString(){
		string result = 
			this.Row(0).toString ~ "\n" ~
			this.Row(1).toString ~ "\n" ~
			this.Row(2).toString;
		return result;
	}
}

/// matrix4x4
/// Note: The default constructed matrix is an identity matrix
struct Mat4(T=float){
	// e is short for 'elements'
	T[16] e = [
		1,0,0,0,
		0,1,0,0,
		0,0,1,0,
		0,0,0,1
	];


	/// Constructor which sets the diagonal of the matrix
	/// The default is for an identity matrix to be produced.
	this(T diagonal){
		e[0] = diagonal; 
		e[5] = diagonal;
		e[10] = diagonal;
		e[15] = diagonal;
	}

	/// Build a matrix from 4 column vectors
	this(Vec4!T col0, Vec4!T col1, Vec4!T col2, Vec4!T col3){
		this[0] = col0; 
		this[1] = col1; 
		this[2] = col2; 
		this[3] = col3; 
	}
	/// Build a matrix from 16 elements
	this(T e0,T e1, T e2, T e3,
			T e4,T e5, T e6, T e7,
			T e8,T e9, T e10, T e11,
			T e12,T e13, T e14, T e15){
		e[0] = e0;
		e[1] = e1;
		e[2] = e2;
		e[3] = e3;
		e[4] = e4;
		e[5] = e5;
		e[6] = e6;
		e[7] = e7;
		e[8] = e8;
		e[9] = e9;
		e[10] = e10;
		e[11] = e11;
		e[12] = e12;
		e[13] = e13;
		e[14] = e14;
		e[15] = e15;
	}
	/// Retrieve the static array for data values
	T[16] Data(){
		return this.e;
	}

	/// Retrieve the static array for data
	T* DataPtr(){
		return this.e.ptr;
	}

	/// Return the column
	/// Usage: mat4[i]
	T[4] opIndex(size_t col){
		if(col==0){
			return [e[0],e[4],e[8],e[12]];
		} else if(col==1){
			return [e[1],e[5],e[9],e[13]];
		} else if (col==2){
			return [e[2],e[6],e[10],e[14]];
		} else if (col==3){
			return [e[3],e[7],e[11],e[15]];
		} else {
			assert(0,"illegal column specified, expected 0,1,2,3 received: "~col.to!string);
		}
	}
	/// Return the individual element
	/// Usage: mat4[i,j]
	ref T opIndex(size_t i, size_t j){
		return e[i*4 + j];
	}

	/// Assign to mat4 one value to all elements.
	// e.g. mat4 m = 1.0f; // Populates every value with 1.0f
	void opAssign(T input){
		e[] = input;
	}

	/// Assign to another mat4
	void opAssign(typeof(this) input){
		e[0] = input.e[0];
		e[1] = input.e[1];
		e[2] = input.e[2];
		e[3] = input.e[3];
		e[4] = input.e[4];
		e[5] = input.e[5];
		e[6] = input.e[6];
		e[7] = input.e[7];
		e[8] = input.e[8];
		e[9] = input.e[9];
		e[10] = input.e[10];
		e[11] = input.e[11];
		e[12] = input.e[12];
		e[13] = input.e[13];
		e[14] = input.e[14];
		e[15] = input.e[15];
	}
	/// Assign matrix elements of matrix individually
	/// Usage: mat4[i] = value;
	void opIndexAssign(T value, size_t idx){
		if(idx >= e.length){
			assert(0,"Index out of bounds");
		} 
		e[idx] = value;
	}
	/// Assign matrix value using 2 dimensions
	/// Usage: mat4[i,j] = value;
	void opIndexAssign(T value, size_t i, size_t j){
		e[i*4 + j] = value;
	}
	/// Assign specific matrix column to a new column vector
	/// mat4 m;
	/// vec4 v;
	/// m[0] = v; // Sets first column of matrix to values of v.
	void opIndexAssign(Vec4!T v, size_t i){
		e[i]    = v[0];
		e[i+4]  = v[1];
		e[i+8]  = v[2];
		e[i+12] = v[3];
	}
	/// Perform a binary operation (+,-,*,/) to each element of a matrix
	/// Usage: mat4[i] += value;
	void opIndexOpAssign(string op)(T value, size_t i){
		static if(op=="+"){
			e[i] += value;
		}
		static if(op=="-"){
			e[i] -= value;
		}
		static if(op=="*"){
			e[i] *= value;
		}
		static if(op=="/"){
			e[i] /= value;
		}
		assert(0,"op not implemented for opIndexOpAssign(T value, size_t i)");
	}

	/// Perform a binary operation (+,-,*,/) to each element of a matrix
	/// Usage: mat4[i,j] += value;
	void opIndexOpAssign(string op)(T value, size_t i, size_t j){
		static if(op=="+"){
			e[i*4 + j] += value;
		}
		static if(op=="-"){
			e[i*4 + j] -= value;
		}
		static if(op=="*"){
			e[i*4 + j] *= value;
		}
		static if(op=="/"){
			e[i*4 + j] /= value;
		}
		assert(0,"op not implemented for opIndexOpAssign(T value, size_t i, size_t j)");
	}

	/// Perform matrix binary operations 
	typeof(this) opBinary(string op)(typeof(this) m){
		typeof(this) result;	
		// Perform matrix multiplication
		static if(op=="*"){
			for(int i=0; i < 4; i++){
				for(int j=0; j < 4; j++){
					float sum=0.0f;
					for(int k=0; k < 4; k++){
						sum	 +=  this[i,k] * m[k,j];	
					}	
					result[i,j] = sum;
				}
			}
			return result;	
		}
		// Perform matrix addition and subtraction
		static if(op=="+" || op=="-"){
			for(int i=0; i < e.length; i++){
				mixin("result[i] = this[i]"~op~"m[i];");
			}
			return result;
		}
		assert(0,"op not implemented for mat4 opBinary(mat4)");
	}

	/// Multiply a matrix by a vector
	/// e.g. For performing: m*v (where 'v' is on the right side)
	Vec4!T opBinary(string op)(Vec4!T v){
		static if(op=="*"){
			Vec4!T result;	

			result[0] = this.Row(0).Dot(v);
			result[1] = this.Row(1).Dot(v);
			result[2] = this.Row(2).Dot(v);
			result[3] = this.Row(3).Dot(v);

			return result;	
		}
		assert(0,"op not implemented for vec4 opBinary(vec4)");
	}

	/// Handy function for printing out the string representation of a matrix
	string toString(){
		string result = 
			this.Row(0).toString ~ "\n" ~
			this.Row(1).toString ~ "\n" ~
			this.Row(2).toString ~ "\n" ~
			this.Row(3).toString;
		return result;
	}
}


/// Return the row vector
Vec3!T Row(T=float)(Mat3!T m, size_t row){
	size_t offset = row*3;
	return Vec3!T(m.e[0+offset],m.e[1+offset],m.e[2+offset]);	
}

/// Return the row vector
Vec4!T Row(T=float)(Mat4!T m, size_t row){
	size_t offset = row*4;
	return Vec4!T(m.e[0+offset],m.e[1+offset],m.e[2+offset],m.e[3+offset]);	
}

/// Return the cololumn vecoltor
Vec3!T Col(T=float)(Mat3!T m, size_t col){
	return Vec3!T(m.e[0+col],m.e[3+col],m.e[6+col]);	
}

/// Return the cololumn vecoltor
Vec4!T Col(T=float)(Mat4!T m, size_t col){
	return Vec4!T(m.e[0+col],m.e[4+col],m.e[8+col],m.e[12+col]);	
}

/// Return an identity matrix.
Mat3!T MakeMatrix3Identity(T=float)(){
	Mat3!T result;
	// 0 out the matrix. This is important because
	// for floating point values the default type is NaN.
	// TODO: Getting rid of loop which doubles work would be more optimal.
  //       For now for supporting generic code, we "trust" the optimizer
  //       could potentially unroll this loop.
	for(int i=0; i < result.e.length; i++){
		result[i] = 0.0f;
	}
	// Set diaganaol of matrix to 1
	result[0]  = 1.0f;
	result[4]  = 1.0f;
	result[8] = 1.0f;
	return result;
}
/// Return an identity matrix.
Mat4!T MakeMatrix4Identity(T=float)(){
	Mat4!T result;
	// 0 out the matrix. This is important because
	// for floating point values the default type is NaN.
	// TODO: Get rid of loop which doubles work
	for(int i=0; i < result.e.length; i++){
		result[i] = 0.0f;
	}
	// Set diaganaol of matrix to 1
	result[0]  = 1.0f;
	result[5]  = 1.0f;
	result[10] = 1.0f;
	result[15] = 1.0f;

	return result;
}

/// Checks if this is an identity matrix
/// TODO: This will have to be specialized for 
///       floating point and integral types.
bool IsIdentityMatrix3(T=float)(Mat3!T m){

	return (m.e[0] == 1.0f &&
			m.e[1] == 0.0f && 
			m.e[2] == 0.0f && 
			m.e[3] == 0.0f && 
			m.e[4] == 1.0f && 
			m.e[5] == 0.0f && 
			m.e[6] == 0.0f && 
			m.e[7] == 0.0f && 
			m.e[8] == 1.0f); 
}

/// Checks if this is an identity matrix
/// TODO: Consider different check for floating point
bool IsIdentityMatrix4(T=float)(Mat4!T m){

	return (m.e[0] == 1 &&
			m.e[1] == 0 && 
			m.e[2] == 0 && 
			m.e[3] == 0 && 
			m.e[4] == 0 && 
			m.e[5] == 1 && 
			m.e[6] == 0 && 
			m.e[7] == 0 && 
			m.e[8] == 0 && 
			m.e[9] == 0 && 
			m.e[10] == 1 &&
			m.e[11] == 0 &&
			m.e[12] == 0 &&
			m.e[13] == 0 &&
			m.e[14] == 0 &&
			m.e[15] == 1);
}

// Retrieve the position of the x and y
// translation values.
Vec2!T FromMat3GetTranslation(T=float)(Mat3!T m){
	Vec2!T result = vec2(0,0);
	result.x = m.e[0][2];
	result.y = m.e[1][2];
	return result;
}

Vec3!T FromMat4GetTranslation(T=float)(Mat4!T m){
	return vec3(m.e[3], m.e[7], m.e[11]);	
}



// How to extract angle from rotation matrix
// https://zpl.fi/converting-rotation-matrices-to-angles/
T FromMat3GetRotation(T=float)(Mat3!T m){
	// Pick an axis, and see how much it's offset
	Vec2!T col0 = Vec2!T(m.e[0][0],m.e[0][1]);
	return atan2(col0.y, col0.x);				
}

// The 'scale' of x and y axis is the 'length' of each axis
Vec2!T FromMat3GetScale(T=float)(Mat3!T m){
	Vec2!T xAxis = Vec2!T(0,0);
	xAxis.x = m.e[0][0];
	xAxis.y = m.e[1][0];

	vec2 yAxis = vec2(0,0);
	yAxis.x = m.e[0][1];
	yAxis.y = m.e[1][1]; 

	vec2 result;
	result.x = sqrt(xAxis.x * xAxis.x + xAxis.y * xAxis.y);
	result.y = sqrt(yAxis.x * yAxis.x + yAxis.y * yAxis.y);

	return result;
}

/// Helper function for performing translation
/// on a transform object.
/// Returns a transform, so that we can compose transformations
/// easily using Universal Function Call Syntax (UFCS)
Mat3!T Matrix3Translate(T=float)(Mat3!T m, T x, T y){
	m = MakeMatrix3Translation(x,y);
	return m;
}

// Perform a rotation
Mat3!T Matrix3Rotate(T=float)(Mat3!T m, double angle){
	m = MakeMatrix3Rotation(angle);
	return m;
}

// Perform a scale
Mat3!T Matrix3Scale(T=float)(Mat3!T m, double sx, double sy){
	m = MakeMatrix3Scale(sx,sy);
	return m;
}



/// Given a matrix, return the transposed version of the matrix
Mat3!T Matrix3Transpose(T=float)(Mat3!T m){
	Mat3!T result;
	for(int i=0; i < 3;i++){
		auto row = m.Row(i);
		result[i] = row; // opAssign does 'column' assignment
	}
	return result;
}

/// Given a matrix, return the transposed version of the matrix
Mat4!T Matrix4Transpose(T=float)(Mat4!T m){
	Mat4!T result;
	for(int i=0; i < 4;i++){
		auto row = m.Row(i);
		result[i] = row; // opAssign does 'column' assignment
	}
	return result;
}


/// Makes  rotation.
/// Need to provide in radians
Mat3!T MakeMatrix3Rotation(T=float)(double angle_in_radians){
	import std.math;

	// Nice optimization to only compute sin/cos one time
	float c = cos(angle_in_radians);
	float s = sin(angle_in_radians);

	Mat3!T result = Mat3!T(	c   ,  -s,0.0f,
			s   ,   c,0.0f,
			0.0f,0.0f,1.0f);
	return result;	
}

/// Rotates a matrix about an arbitrary axis (specified by the vector)
/// a specifed number of radians
/// TODO: Verify this is correct
Mat4!T MakeMatrix4Rotation(T=float)(float radians, Vec3!T vector){
	Vec3!T v = vector.Normalize();
	Mat4!T result = Mat4!T(1.0f);

	float cosa = cos(radians);
	float sina = sin(radians);

	Vec3!T temp = v * (1 - cosa);

	result[0,0] = (cosa + temp.x * v.x);
	result[0,1] = (       temp.x * v.y + sina * v.z);
	result[0,2] = (       temp.x * v.z - sina * v.y);
	result[1,0] = (       temp.y * v.x - sina * v.z);
	result[1,1] = (cosa + temp.y * v.y);
	result[1,2] = (       temp.y * v.z + sina * v.x);
	result[2,0] = (       temp.z * v.x + sina * v.y);
	result[2,1] = (       temp.z * v.y - sina * v.x);
	result[2,2] = (cosa + temp.z * v.z);

	return result;
}

/// Make X-Axis Rotation Matrix with the 'angle' that you want
/// to rotate about
Mat4!T MakeMatrix4RotationX(T=float)(double radians){
	// Always ensure identity matrix
	Mat4!T result = MakeMatrix4Identity!T();

	float s = sin(radians);
	float c = cos(radians);

	result[5] = c;
	result[6] = -s;

	result[9]  = s;
	result[10] = c;

	return result;
}

/// Make Y-Axis Rotation Matrix with the 'angle' that you want
/// to rotate about
Mat4!T MakeMatrix4RotationY(T=float)(double radians){
	// Always ensure identity matrix
	Mat4!T result = MakeMatrix4Identity!T();

	float s = sin(radians);
	float c = cos(radians);

	result[0] = c;
	result[2] = s;

	result[8]  = -s;
	result[10] = c;

	return result;
}

/// Make Z-Axis Rotation Matrix with the 'angle' that you want
/// to rotate about
Mat4!T MakeMatrix4RotationZ(T=float)(double radians){
	// Always ensure identity matrix
	Mat4!T result = MakeMatrix4Identity!T();

	float s = sin(radians);
	float c = cos(radians);

	result[0] = c;
	result[1] = -s;

	result[4]  = s;
	result[5] = c;

	return result;
}


/// Helper function to generate a scale matrix
Mat3!T MakeMatrix3Scale(T=float)(T sx, T sy){
	// Always ensure identity matrix
	Mat3!T result = MakeMatrix3Identity!T();
	result = Mat3!T(	sx  	,0,
			0,  sy	,0,
			0,	0	,1);
	return result;	
}
/// Make Scale Matrix with the x,y,z dimensions you want.
Mat4!T MakeMatrix4Scale(T=float)(Vec3!T v){
	// Always ensure identity matrix
	Mat4!T result = MakeMatrix4Identity!T();

	result[0]  = v[0];
	result[5]  = v[1];
	result[10] = v[2];
	result[15] = 1;

	return result;
}

/// Helper function to generate a Translation matrix
Mat3!T MakeMatrix3Translation(T=float)(Vec2!T v){
	// Always ensure identity matrix
	Mat3!T result = MakeMatrix3Identity!T();
	result[2]  = v[0];
	result[5]  = v[1];
	return result;	
}
/// Helper function to generate a Translation matrix
Mat3!T MakeMatrix3Translation(T=float)(T xt, T yt){
	// Always ensure identity matrix
	Mat3!T result = MakeMatrix3Identity!T();
	result[2]  = xt;
	result[5]  = yt;
	return result;	
}

/// Make Translation Matrix to translate the x,y,z coordinates.
Mat4!T MakeMatrix4Translation(T=float)(Vec3!T v){
	// Always ensure identity matrix
	Mat4!T result = MakeMatrix4Identity!T();

	result[3]  = v[0];
	result[7]  = v[1];
	result[11] = v[2];
	// Note: result[15] is already set to 1 from identity function

	return result;
}
/// Make Translation Matrix to translate the x,y,z coordinates.
Mat4!T MakeMatrix4Translation(T=float)(T xt, T yt, T zt){
	// Always ensure identity matrix
	Mat4!T result = MakeMatrix4Identity!T();

	result[3]  = xt;
	result[7]  = yt;
	result[11] = zt;
	// Note: result[15] is already set to 1 from identity function

	return result;
}

/// fovy is the 'vertical' field of view angle in radians
/// Note: Sources:
///      - https://unspecified.wordpress.com/2012/06/21/calculating-the-gluperspective-matrix-and-other-opengl-matrix-maths/
///    	 - https://github.com/arkanis/single-header-file-c-libs/blob/master/math_3d.h
Mat4!T MakeMatrix4Perspective(T=float)(T fovy, T aspect_ratio, T zNear, T zFar) {
	float f = 1.0f / tan(fovy / 2.0f);
	float ar = aspect_ratio;
	float nd = zNear;
	float fd = zFar;

	return Mat4!T(
			f / ar,           0,                0,                0,
			0,                f,                0,                0,
			0,                0,               (fd+nd)/(nd-fd),  (2*fd*nd)/(nd-fd),
			0,                0,               -1,                0
			);
}

/// Helper function that will print two matrices side by side
void MatrixDebugPrint(T=float)(string name1, Mat3!T m1, string name2, Mat3!T m2){
	writeln(name1,"\t\t",name2);
	for(int i=0; i < 3; i++){
		writeln(m1.Row(i),"\t",m2.Row(i));
	}
}
/// Helper function that will print two matrices side by side
void MatrixDebugPrint(T=float)(string name1, Mat4!T m1, string name2, Mat4!T m2){
	writeln(name1,"\t\t",name2);
	for(int i=0; i < 4; i++){
		writeln(m1.Row(i),"\t",m2.Row(i));
	}
}

/// Helper function to visualize mat4 * vec4
void MatrixVectorDebugPrint(T=float)(string name1, Mat4!T m, string name2, Vec4!T v){
	writeln(name1,"\t\t",name2);
	for(int i=0; i < 4; i++){
		if(i!=2){
			writeln(m.Row(i),"\t",v[i]);
		}else{
			writeln(m.Row(i)," (op)\t",v[i]);
		}
	}
}