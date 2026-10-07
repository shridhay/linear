/// This library attempts to emulate the same
/// glsl datatypes and functions.
module test;
import linear;

import std.stdio, std.math;
/*
/// Demonstration of the 'swizzling technique' that can be used with 'opDispath' in D.
unittest{
vec2 v2 = vec2(1.0f,2.0f);
vec3 v3 = vec3(1.0f,2.0f,3.0f);
vec4 v4 = vec4(1.0f,2.0f,3.0f,4.0f);
assert(v4.xy() == v2, "swizzling works");
assert(v4.rg() == v2, "swizzling works");
assert(v4.xyz() == v3, "swizzling works");
assert(v4.rgb() == v3, "swizzling works");
}
 */

/// Demonstrating usage of magnitude.
/// Note: That we can use universal function call syntax to more nicely chain
///       together operations.
///       Generally speaking, I have tried to avoid 'member functions' within
///       math types for:
///       a.) compatibility with C
///       b.) keeps my code simpler, and easier to debug -- especially if we inline functions.
///       c.) Simpler structs for the math types
unittest{
	vec2 v2 = vec2(4.0f ,3.0f);
	vec3 v3 = vec3(0.0f, 0.0f, 5.0f);    
	vec4 v4 = vec4(2.0f, 6.0f, 3.0f, 0.0f );    

	assert(Magnitude(v2) == 5.0f); 
	assert(v2.Magnitude() == 5.0f);

	assert(v3.Magnitude() == 5.0f); 
	assert(Magnitude(v3) == 5.0f); 

	assert(v4.Magnitude() == 7.0f); 
	assert(Magnitude(v4) == 7.0f); 
}

/// Demonstration of normalizing a vector such that a unit vector is returned.
unittest{
	vec2 v2 = vec2(4.0f ,3.0f);
	vec3 v3 = vec3(1.0f, 2.0f, 3.0f);    
	vec4 v4 = vec4(1.0f, 2.0f, 3.0f, 0.0f );    

	assert(v2.Normalize.Magnitude.isClose(1.0f),"Expected 1.0f");
	assert(v3.Normalize.Magnitude.isClose(1.0f),"Expected 1.0f");
	assert(v4.Normalize.Magnitude.isClose(1.0f),"Exepcted 1.0f");
}

/// Demonstration of dot product
unittest{
	vec2 v2a = vec2(1.0f,2.0f);
	vec2 v2b = vec2(1.0f,3.0f);

	vec3 v3a = vec3(1.0f,2.0f,3.0f);
	vec3 v3b = vec3(2.0f,3.0f,4.0f);

	vec4 v4a = vec4(1.0f,2.0f,3.0f,4.0f);
	vec4 v4b = vec4(-1.0f,2.0f,3.0f,5.0f);

	assert(v2a.Dot(v2b) == 7.0f, "vec2 dot product check");
	assert(v3a.Dot(v3b) == 20.0f, "vec3 dot product check");
	assert(v4a.Dot(v4b) == 32.0f, "vec4 dot product check");
}

/// Calculator tests for cross product
/// https://www.wolframalpha.com/input?i=cross+product+calculator
unittest{
	vec3 v3a = vec3(1.0f,2.0f,3.0f);
	vec3 v3b = vec3(2.0f,3.0f,4.0f);

	assert(v3a.Cross(v3b) == vec3(-1.0f, 2.0f, -1.0f), "vec3 cross product test");
}

/// Distance calculations
unittest{
	vec2 v2a = vec2(1.0f,2.0f);
	vec2 v2b = vec2(1.0f,3.0f);

	vec3 v3a = vec3(5.0f,0.0f,0.0f);
	vec3 v3b = vec3(5.0f,-4.0f,0.0f);

	vec4 v4a = vec4(5.0f,0.0f,0.0f,3.0f);
	vec4 v4b = vec4(5.0f,-4.0f,0.0f,0.0f);

	assert(v2a.Distance(v2b) == 1.0f, "vec2 Distance check");
	assert(v3a.Distance(v3b) == 4.0f, "vec3 Distance check");
	assert(v4a.Distance(v4b) == 5.0f, "vec4 Distance check");
}


// Projection unit test
unittest{
	vec2 u = vec2(4,3);
	vec2 v = vec2(2,8);

	// Project vector u onto vector v
	auto result = Project(u,v);

	writeln(result);
	assert(isClose(result.x, (16.0/17.0)) && isClose(result.y, (64.0/17.0)), "Expected ~.94117 and 3.7647");

}


// Compute the distance between two points 
unittest{
	// Manual point entry
	assert(Distance(3,5, 6,9) == 5, "5 expected"); 
	// Templated function
	assert(Distance(vec2i(3,5),vec2i(6,9)) == 5, "5 expected");

	assert(isClose(Distance(vec2(3.0f,5.0f),vec2(6.0f,9.0f)), 5.0f), "5.0f expected");
	// Testing alias
	assert(Distance(Point2i(3,5),Point2i(6,9)) == 5, "5 expected");
	assert(isClose(Distance(Point2f(3.0f,5.0f),Point2f(6.0f,9.0f)), 5.0f), "5.0f expected");
}

// Degrees and radians conversions
unittest{
	float initial = 47.0f;
	float rads = DegreesToRadians(initial);
	float result = RadiansToDegrees(rads);

	assert(isClose(result,47.0f), "Expected 47.0f");
}


// Test for instantiating different types
unittest{
	auto myVec1 = Vec2!float();
	auto myVec2 = Vec2!double();
	auto myVec4 = Vec2!int();
	auto myVec6 = Vec2!long();

	//  Note: Why are these types not available?
	//        In short, we don't need to support them.
	//        For our vector library otherwise, we need
	//        signed types.
	//auto myVec3 = Vec2!char();
	//auto myVec5 = Vec2!short();
	//auto myVec7 = Vec2!ushort();
	//auto myVec8 = Vec2!uint();
	//auto myVec9 = Vec2!ulong();
}

// Test alias of type
unittest{
	auto myVec1 = vec2(1.0f);
	auto myVec2 = Vec2!int(1);
}

// Test constructors
unittest{
	Vec2!float test0 = Vec2!float(7.4f,9.6f);
	vec2 test = Vec2!float();
	vec2i test2 = vec2i(1,2);
}

// Test size of the data type
unittest{
	static assert(float.sizeof == 4, "4 for size of float on this architecture");
	static assert(int.sizeof == 4, "4 for size of int on this architecture");
	assert(vec2.sizeof == float.sizeof*2, "8 expected");
}

// Test data layout within struct
unittest{
	auto myVec1 = vec2(); 

	assert((myVec1.x == myVec1.s) && (myVec1.i == myVec1[0]),"");
	assert((myVec1.y == myVec1.t) && (myVec1.j == myVec1[1]),"");
}

// Negation test
unittest{
	vec2i v1;
	v1.x = 5;
	v1.y = 6;
	v1 = -v1;

	writeln(v1);
	assert(v1.x == -5, "-5 expected");
	assert(v1.y == -6, "-6 expected");
}

// Test opUnary for ++ and --
// This tests both pre and post-increment and
// pre and post-decrement
unittest{
	vec2i v1;
	v1.x = 2;
	v1.y = 3;

	v1++;
	assert(v1.x == 3, "3 expected");
	assert(v1.y == 4, "4 expected");
	v1--;
	assert(v1.x == 2, "2 expected");
	assert(v1.y == 3, "3 expected");
	++v1;
	assert(v1.x == 3, "3 expected");
	assert(v1.y == 4, "4 expected");
	--v1;
	assert(v1.x == 2, "2 expected");
	assert(v1.y == 3, "3 expected");
}

// Test opBinary for addition and subtraction of vectors
unittest{
	vec2i v1;
	vec2i v2;

	v1.x = 5; v1.y = 7;
	v2.x = 5; v2.y = 7;

	v1 = v1 + v2;
	assert(v1.x ==10 && v1.y == 14, "10 and 14 expected");
	assert(v2.x ==5 && v2.y == 7, "5 and 7 expected");
	v1 = v1 - v2;
	assert(v1.x ==5 && v1.y == 7, "5 and 7 expected");
	v1 = v2 - v1;
	assert(v1.x ==0 && v1.y == 0, "0 and 0 expected");
}

// Test opBinary with opUnary operation
unittest{
	vec2i v1;
	vec2i v2;

	v1.x = 5; v1.y = 7;
	v2.x = 5; v2.y = 7;

	v1 = -v1 + -v2;

	assert(v1.x ==-10 && v1.y ==-14, "0 and 0 expected");
}

// Test opBinary with * and / for scalar multiplication and division
unittest{
	vec2 v1;
	double scalar = 2.0;

	v1.x = 5; v1.y = 7;

	v1 = v1 * scalar;
	writeln(v1);

	assert(v1.x ==10 && v1.y ==14, "10 and 14 expected");
}


// Test opBinary with * and / for scalar multiplication and division
unittest{
	vec2 v1 = vec2(1.5f,2.5f);
	vec2 result = v1 * 2.0f;

	assert(result.x == 3.0f && result.y == 5.0f, "3.0f and 5.0f expected");
}


// Test opOpAssign for assignment and an operation
unittest{
	vec2 v1 = vec2(1.0,1.0);
	vec2 v2 = vec2(2.0f,2.0);

	v1 += v2;
	v1 -= v2;

	v1 *=5;
	v1 /=5;

	v1 += v2;

	assert(v1.x ==3.0 && v1.y ==3.0, "3 and 3 expected");

	v1 *= 3;

	assert(v1.x ==9.0 && v1.y ==9.0, "9 and 9 expected");
}

// Test magnitude operation
unittest{
	vec2 v1;
	v1.x = 3.0f;
	v1.y = 4.0f;

	assert(isClose(v1.Magnitude(),5.0), "Expected 5.0 or close");
}

// Test if normalized function is working
unittest{
	vec2 v1;
	v1.x = 3.0f;
	v1.y = 4.0f;

	v1.Normalize();

	assert(isClose(v1.Magnitude(),1.0,1e-2, 1e-5), "Expected 1.0 or close");
}

// Test if normalized function is working with negatives
unittest{
	vec2 v1 = vec2(-3.0f,-4.0f);

	v1.Normalize();

	assert(isClose(v1.Magnitude(),1.0,1e-2, 1e-5), "Expected 1.0 or close");
}

// Take the dot product of two vectors
unittest{
	vec2i v1;
	vec2i v2;

	v1.x = 0;	v1.y = 1;
	v2.x = 1;	v2.y = 0;

	assert(v1.Dot(v2) == 0, "Expected 0.0 or close");

	vec2 v3;
	vec2 v4;

	v3.x = -1;	v3.y = 0;
	v4.x = 1;	v4.y = 0;
	assert(v3.Dot(v4) == -1, "Expected -1 or close");
}

// Retrieve the normal
unittest{
	vec2 v1;
	v1.x = 8;	v1.y = 4;

	vec2 normal = v1.GetNormal();
	writeln(normal);
	assert(normal.x == -4.0f && normal.y ==8.0f, "");
}


// Take the dot product of two vectors
unittest{
	vec2 v1;
	v1.x = 8;	v1.y = 4;

	assert(v1.GetSlope()==0.5, "Expected 0.5 or close");
	v1.x = 4;	v1.y = 8;

	assert(v1.GetSlope()==2.0, "Expected 0.5 or close");
}


// GetSlope test
unittest{
	vec2 v1 = vec2(5.0f,1.0f);
	vec2 v2 = vec2(0.0,10.0f);

	assert(v1.GetSlope() == 0.2f,"0.2f expected");
	assert(v2.GetSlope() == 0.0f,"0.0f expected -- infinite slope effectively");
}

// Reflection Test
unittest{
	// Draw some line along x-axis
	vec2 v1 = vec2(2.0,1.0f);
	// Creating an incoming vector
	vec2 i  = vec2(-1.0f,-1.0f);

	auto reflectedVector = Reflect(i,v1.GetNormal());

	writeln("reflectedVector",reflectedVector);
}


/// vec2 addition
unittest{
	vec2 v2a = vec2(1.0f,2.0f);
	vec2 v2b = vec2(1.0f,3.0f);
	assert(v2a+v2b == vec2(2.0f,5.0f), "vec2 addition check");
}
/// vec2 subtraction 
unittest{
	vec2 v2a = vec2(1.0f,2.0f);
	vec2 v2b = vec2(1.0f,3.0f);
	assert(v2a-v2b == vec2(0.0f,-1.0f), "vec2 subtraction check");
}
/// vec2 scalar multiplication
unittest{
	vec2 v2a = vec2(1.0f,2.0f);
	float k = 3.0f;
	assert(v2a * k == vec2(3.0f,6.0f), "vec2 scalar multiplication");
}
/// vec2 scalar division 
unittest{
	vec2 v2a = vec2(3.0f,6.0f);
	float k = 3.0f;
	assert(v2a / k == vec2(1.0f,2.0f), "vec2 scalar division");
}

/// vec3 addition
unittest{
	vec3 v3a = vec3(1.0f,2.0f,1.0f);
	vec3 v3b = vec3(1.0f,3.0f,2.0f);
	assert(v3a+v3b == vec3(2.0f,5.0f,3.0f), "vec3 addition check");
}
/// vec3 subtraction 
unittest{
	vec3 v3a = vec3(1.0f,2.0f,5.0f);
	vec3 v3b = vec3(1.0f,3.0f,2.0f);
	assert(v3a-v3b == vec3(0.0f,-1.0f,3.0f), "vec3 subtraction check");
}
/// vec3 scalar multiplication
unittest{
	vec3 v3a = vec3(1.0f,2.0f,-7.0);
	float k = 3.0f;
	assert(v3a * k == vec3(3.0f,6.0f,-21.0f), "vec3 scalar multiplication");
}
/// vec3 scalar division 
unittest{
	vec3 v3a = vec3(3.0f,6.0f,9.0);
	float k = 3.0f;
	assert(v3a / k == vec3(1.0f,2.0f,3.0f), "vec3 scalar division");
}

/// vec4 addition
unittest{
	vec4 v4a = vec4(1.0f,2.0f,1.0f,0.5f);
	vec4 v4b = vec4(1.0f,3.0f,2.0f,0.5f);
	assert(v4a+v4b == vec4(2.0f,5.0f,3.0f,1.0f), "vec4 addition check");
}
/// vec4 subtraction 
unittest{
	vec4 v4a = vec4(1.0f,2.0f,5.0f,0.2f);
	vec4 v4b = vec4(1.0f,3.0f,2.0f,0.2f);
	assert(v4a-v4b == vec4(0.0f,-1.0f,3.0f,0.0f), "vec4 subtraction check");
}
/// vec4 scalar multiplication
unittest{
	vec4 v4a = vec4(1.0f,2.0f,-7.0,3.0f);
	float k = 3.0f;
	assert(v4a * k == vec4(3.0f,6.0f,-21.0f,9.0f), "vec4 scalar multiplication");
}
/// vec4 scalar division 
unittest{
	vec4 v4a = vec4(3.0f,6.0f,9.0,3.0f);
	float k = 3.0f;
	assert(v4a / k == vec4(1.0f,2.0f,3.0f,1.0f), "vec4 scalar division");
}


/// Example of matrix identity 1
unittest{
	writeln("====== Matrix Identity 1 =====");
	mat4 mat1;
	mat4 mat2 = mat4(1.0f);

	MatrixDebugPrint("mat1", mat1, "mat2", mat2);


	writeln("---------------------------------");
}
/// Example of matrix identity 2
unittest{
	writeln("====== Matrix Identity 2 =====");
	mat4 mat1;
	mat4 mat2 = mat4(1);

	MatrixDebugPrint("mat1", mat1, "mat2", mat2);

	writeln("---------------------------------");
}

/// Some of the basic types can be used with their
/// multiple constructors in creative ways to
/// otherwise build a matrix or vector.
unittest{
	writeln("=========== World space ========");
	vec4 position = vec4(vec3(1.0f,2.0f,3.0f),1.0f);
	mat4 modelMatrix = mat4(1.0f);
	//    modelMatrix[3] = vec4(1.0,1.0,1.0,1.0);
	writeln(modelMatrix);

	writeln;
	vec4 worldSpace = modelMatrix*position;
	writeln(worldSpace);
	writeln("---------------------------------");
}

/// Matrix construction can be done by specifying
/// either the single diagonal value, or by using
/// 4 column vectors.
unittest{
	writeln("====== Matrix Constructors =====");
	mat4 matrix1 = mat4(3.0f);

	mat4 matrix2 = mat4(matrix1.Col(0),
			matrix1.Col(1),
			matrix1.Col(2),
			matrix1.Col(3));

	MatrixDebugPrint("matrix1",matrix1,"matrix2",matrix2);

	assert(matrix1 == matrix2, "equivalent matrices"); 

	writeln("---------------------------------");
}

/// Example of matrix multiplication
unittest{
	writeln("========= Matrix Mutiply ========");

	mat4 m1 = mat4(1,0,2,0,
			0,3,0,4,
			0,0,5,0,
			6,0,0,7);
	mat4 m2 = mat4(1,2,3,4,
			5,6,7,8,
			9,10,11,12,
			13,14,15,16);

	vec4 v1 = vec4(2,5,1,8);

	assert(m1*v1 == vec4(4,47,5,68), "mat4 * vec4 passed");
	writeln(m1*m2);
	assert(m1*m2 == mat4(19,22,25,28,67,74,81,88,45,50,55,60,97,110,123,136), "mat4 * mat4 passed");

	writeln("---------------------------------");
}

/// Example of matrix translation 
/// Check with: https://www.wolframalpha.com/input?i=matrix+multiplication+calculator
unittest{
	writeln("====== Matrix Translation =====");
	vec4 position  = vec4(vec3(1.0),1.0f);
	mat4 translate = MakeMatrix4Translation(vec3(4.0f,3.0f,1.0f));

	vec4 worldSpace = translate * position;

	MatrixVectorDebugPrint("translate",translate,"position",position);
	VectorDebugPrint("before",position,"after",worldSpace);

	writeln("---------------------------------");
}

/// Example of matrix scale
/// Check with: https://www.wolframalpha.com/input?i=matrix+multiplication+calculator
unittest{
	writeln("====== Matrix Scale =====");
	vec4 position   = vec4(vec3(1.0,2.0,3.0),1.0f);
	mat4 scale      = MakeMatrix4Scale(vec3(2.0f,3.0f,4.0f));

	vec4 worldSpace = scale * position;

	MatrixVectorDebugPrint("scale",scale,"position",position);
	VectorDebugPrint("before",position,"after",worldSpace);

	writeln("---------------------------------");
}

/// Example of matrix X rotation
/// Check with: https://www.wolframalpha.com/input?i=matrix+multiplication+calculator
unittest{
	writeln("====== Matrix X Rotation=====");
	vec4 position   = vec4(vec3(1.0,2.0,3.0),1.0f);
	mat4 rotX       = MakeMatrix4RotationX(90.ToRadians);


	vec4 worldSpace = rotX * position;

	MatrixVectorDebugPrint("rotX",rotX,"position",position);
	VectorDebugPrint("before",position,"after",worldSpace);

	writeln("---------------------------------");
}

/// Example of matrix Y rotation
/// Check with: https://www.wolframalpha.com/input?i=matrix+multiplication+calculator
unittest{
	writeln("====== Matrix Y Rotation=====");
	vec4 position   = vec4(vec3(1.0,2.0,3.0),1.0f);
	mat4 rotY       = MakeMatrix4RotationY(90.ToRadians);


	vec4 worldSpace = rotY * position;

	MatrixVectorDebugPrint("rotY",rotY,"position",position);
	VectorDebugPrint("before",position,"after",worldSpace);

	writeln("---------------------------------");
}

/// Example of matrix Z rotation
/// Check with: https://www.wolframalpha.com/input?i=matrix+multiplication+calculator
unittest{
	writeln("====== Matrix Z Rotation=====");
	vec4 position   = vec4(vec3(1.0,2.0,3.0),1.0f);
	mat4 rotZ       = MakeMatrix4RotationZ(90.ToRadians);


	vec4 worldSpace = rotZ * position;

	MatrixVectorDebugPrint("rotZ",rotZ,"position",position);
	VectorDebugPrint("before",position,"after",worldSpace);

	writeln("---------------------------------");
}

/// Example of retrieving values from a matrix or vector
/// This can be useful for otherwise for passing the vector or matrix
/// into uniform.
unittest{
	writeln("=========== Data Pointers ======");
	vec2 v2;
	vec3 v3;
	vec4 v4;
	mat4 m4;

	writeln("Data:",v2.Data," at address: ",v2.DataPtr());
	writeln("Data:",v3.Data," at address: ",v3.DataPtr());
	writeln("Data:",v4.Data," at address: ",v4.DataPtr());
	writeln("Data:",m4.Data," at address: ",m4.DataPtr());

	writeln("---------------------------------");
}


/// Example of accessing matrix
unittest{
	writeln("=========== Matrix access ======");
	mat4 m4 = mat4(1,2,3,4,
			5,6,7,8,
			9,10,11,12,
			13,14,15,16);
	writeln("Given this matrix:");
	writeln(m4,"\n");

	writeln("element at zero-position:",m4[0]);
	writeln("First column:",m4.Col(0));
	writeln("First row:",m4.Row(0));
	writeln;

	writeln("element at second position:",m4[1]);
	writeln("Second column:",m4.Col(1));
	writeln("Second row:",m4.Row(1));
	writeln;

	writefln("m[0]=%s",m4[0]);
	writefln("m[1]=%s",m4[1]);
	writefln("m[2]=%s",m4[2]);
	writefln("m[3]=%s",m4[3]);

	writefln("m4[0,0]=%f",m4[0,0]);
	writefln("m4[1,0]=%f",m4[1,0]);
	writefln("m4[1,1]=%f",m4[1,1]);
	writefln("m4[1,2]=%f",m4[1,2]);

	writeln("Given 0th row = index 1, 1st row = index 2, etc.");
	writeln("Third Row, first element: ",m4[2,0]);
	writeln("Third Row, first element: ",m4.Row(2).x);
	writeln("Third Col, second element: ",m4[1,2]);
	writeln("Third Col, second element: ",m4.Col(2)[1]);

	writeln("---------------------------------");
}


unittest{
	import std.stdio;
	mat3 identity;
	// Access each row
	writeln("col 0:",identity[0]);
	writeln("col 1:",identity[1]);
	writeln("col 2:",identity[2]);
	writeln;
	writeln("row 0:",identity.e[0]);
	writeln("row 1:",identity.e[1]);
	writeln("row 2:",identity.e[2]);

	writeln;

	mat3 m = mat3(1,2,3,4,5,6,7,8,9);
	// Access each row
	writeln("col 0:",m[0]);
	writeln("col 1:",m[1]);
	writeln("col 2:",m[2]);
	writeln;
	writeln("row 0:",m.e[0]);
	writeln("row 1:",m.e[1]);
	writeln("row 2:",m.e[2]);

	// Construct a new translation matrix
	mat3 transform1 = MakeMatrix3Translation(10.0f,10.0f);
	// apply a rotation operation
	//		transform1 = transform1 * Rotate(45.0f) * Scale(2.0f,2.0f) * Translate(5.0f,5.0f);

	mat3 transform2 = MakeMatrix3Translation(10.0f,10.0f);
	// apply a rotation operation
	//	transform2 = transform2 * Scale(2.0f,2.0f) * Translate(5.0f,5.0f) * Rotate(45.0f);

	writeln(transform1);
	writeln(transform2);
}


unittest{
	import std.stdio;
	// Always default initialized to identity matrix
	mat3 matrix;

	// Top-Left
	matrix[0,0] = 7.0f;;
	// 1st row, 0th column
	matrix[1,0] = 42.0f;;
	// 2nd row, 2nd column
	matrix[1,2] = 100.0f;

	// Test syntax for assignment
	matrix[1,2] = matrix[1,2];

	// Print matrix out as we are use to it
	writeln(matrix);
	// Visualize flat matrix in memory
	writeln(matrix.e);
	// Test access to matrix

	// Create matching matrix to above with other constructor
	mat3 match = mat3(7.0f,0.0f,0.0f,42.0f,1.0f,100.0f,0.0f,0.0f,1.0f);
	writeln(match);	
	writeln(match.e);
}


// Test Translation make functioin
unittest{
	import std.stdio;
	writeln(" ======= Translate test ===== ");
	mat3 mat = MakeMatrix3Translation(7.0f,5.0f);
	writeln(mat);
}

// Make sure correct rows/columns are set
unittest{
	import std.stdio;
	writeln(" ======= Translate test ===== ");
	mat3 mat;
	mat = mat * MakeMatrix3Translation(7.0f,5.0f);
	writeln(mat);
}

// Matrix multiplciation
unittest {
	import std.stdio;
	writeln(" ======= mat3 multiply test ===== ");

	mat3 mat1 = mat3(1,2,3,
			4,5,6,
			7,8,9);

	mat3 mat2 = mat3(1,2,1,
			2,4,6,
			7,2,5);

	mat3 result = mat3(0.0f);
	result =  mat1 * mat2;
	writeln(result);
}

/// Identity matrix creation and identity matrix test
unittest{
	mat4 m;
	m[0] = 1.0f;
	m[1,2] = 9.0f;
	m = MakeMatrix4Identity();
	assert(m.e[0] == 1.0f, "Identity check");
	assert(m.e[1] == 0.0f, "Identity check");
	assert(m.e[2] == 0.0f, "Identity check");
	assert(m.e[3] == 0.0f, "Identity check");
	assert(m.e[4] == 0.0f, "Identity check");
	assert(m.e[5] == 1.0f, "Identity check");
	assert(m.e[6] == 0.0f, "Identity check");
	assert(m.e[7] == 0.0f, "Identity check");
	assert(m.e[8] == 0.0f, "Identity check");
	assert(m.e[9] == 0.0f, "Identity check");
	assert(m.e[10] == 1.0f, "Identity check");
	assert(m.e[11] == 0.0f, "Identity check");
	assert(m.e[12] == 0.0f, "Identity check");
	assert(m.e[13] == 0.0f, "Identity check");
	assert(m.e[14] == 0.0f, "Identity check");
	assert(m.e[15] == 1.0f, "Identity check");

	assert(m.IsIdentityMatrix4() == true, "Identity function check");
}

/// Printing of row vectors
unittest{
	writeln("Row vectors");
	mat4 m;
	writeln(m);

	writeln(m.Row(0));
	writeln(m.Row(1));
	writeln(m.Row(2));
	writeln(m.Row(3));
}

/// Printing of column vectors
unittest{
	writeln("Column vectors");
	mat4 m;
	writeln(m);

	writeln(m.Col(0));
	writeln(m.Col(1));
	writeln(m.Col(2));
	writeln(m.Col(3));
}

/// Assign a new column to matrix
unittest{
	writeln("New column vector assignment");
	mat4 m;
	vec4 v = vec4(5,5,5,5);
	m[2] = v;
	writeln(m);
}

/// Transpose
unittest{
	writeln("Transpose test");
	mat4 m = mat4(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16);
	writeln(m.Matrix4Transpose());
}

/// Matrix multiplication
unittest{
	writeln("matrix multiplication");
	mat4 m1;
	mat4 m2;
	mat4 m3 = m1*m2;

	writeln(m3);
	assert(m3.IsIdentityMatrix4(), "Matrix should be identity");
}

unittest{
	writeln("matrix by vector multiplication test"); 
	mat4 m;
	vec4 v = vec4(1,2,3,0);

	writeln(m*v);
}


// Matrix construction with 3 vectors
unittest{
  vec3 v1 = vec3(1.0,0.0,0.0);
  vec3 v2 = vec3(0.0,1.0,0.0);
  vec3 v3 = vec3(0.0,0.0,1.0);

  mat3 m = mat3(v1,v2,v3);
  assert(m.IsIdentityMatrix3(), "Matrix should be an identity matrix, but is not");
}

// Construct a mat3 from a mat4
unittest{
  mat4 m4;
  mat3 m3 = mat3(m4);
  assert(m3.IsIdentityMatrix3(), "Matrix3 generated from Matrix4 should be an identity matrix, but is not");
}

// Construct a mat3 from a mat4
unittest{
  mat4 m4;
  mat3 m3 = mat3(m4);
  assert(m3.IsIdentityMatrix3(), "Matrix3 generated from Matrix4 should be an identity matrix, but is not");
}

// Assign a mat3 from a mat4
unittest{
  mat4 m4;
  mat3 m3;
  m3 = m4;
  assert(m3.IsIdentityMatrix3(), "Matrix3 generated from Matrix4 should be an identity matrix, but is not");
}

unittest{
  mat3 m3;
  m3 = 1.0f;
  writeln ("matrix assignment shorthand test");
  writeln(m3);

  for(size_t i=0; i < 3; i++){
    for(size_t j=0; j < 3; j++){
      assert(m3[i,j] == 1.0f, "All mat3 values expected to be equal to 1");
    }
  }

  mat4 m4;
  m4  = 1.0f;
  for(size_t i=0; i < 4; i++){
    for(size_t j=0; j < 4; j++){
      assert(m4[i,j] == 1.0f, "All mat4 values expected to be equal to 1");
    }
  }

}
