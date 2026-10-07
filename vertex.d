module vertex;
import std.stdio, std.conv, std.string, std.array, std.file, std.typecons, std.range, std.algorithm;
import bindbc.opengl;

// Pixel struct from HW #2.
struct Pixel {
    private uint R;
    private uint G;
    private uint B;
    this(uint R, uint G, uint B){
        this.R = R;
        this.G = G;
        this.B = B;
    }
    uint getR(){
        return this.R;
    }
    uint getG(){
        return this.G;
    }
    uint getB(){
        return this.B;
    }
    Tuple!(uint, uint, uint) getPixel(){
        return tuple(this.R, this.G, this.B);
    }
    Tuple!(ubyte, ubyte, ubyte) getPixelUbyte(){
        return tuple(to!ubyte(this.R), to!ubyte(this.G), to!ubyte(this.B));
    }
    Tuple!(ulong, ulong, ulong) getPixelUlong(){
        return tuple(to!ulong(this.R), to!ulong(this.G), to!ulong(this.B));
    }
    void setR(uint r){
        this.R = r;
    }
    void setG(uint g){
        this.G = g;
    }
    void setB(uint b){
        this.B = b;
    }
    string toString(){
      return "R("~this.R.to!string~") G("~this.G.to!string~") B("~this.B.to!string~")";
    }
}

// Vertex struct from HW #3.  Added a Tuple for texture in addition for a Tuple for position and normal, respectively.
struct Vertex {
    Tuple!(GLfloat, GLfloat, GLfloat) position;
    Tuple!(GLfloat, GLfloat) texture;
    Tuple!(GLfloat, GLfloat, GLfloat) normal;
    this(Tuple!(GLfloat, GLfloat, GLfloat) X, Tuple!(GLfloat, GLfloat) Y, Tuple!(GLfloat, GLfloat, GLfloat) Z){
        setPosition(X.expand);
        setTexture(Y.expand);
        setNormal(Z.expand);
    }
    void setPosition(GLfloat x, GLfloat y, GLfloat z){ 
        position = tuple(x, y, z);
    }
    void setTexture(GLfloat s, GLfloat t){
        texture = tuple(s, t);
    }
    void setNormal(GLfloat x, GLfloat y, GLfloat z){
        normal = tuple(x, y, z);
    }
    Tuple!(GLfloat, GLfloat, GLfloat) getPosition(){
        return position;
    }
    Tuple!(GLfloat, GLfloat, GLfloat) getNormal(){
        return normal;
    }
    Tuple!(GLfloat, GLfloat) getTexture(){
        return texture;
    }
}

// PPM struct from HW #2.
struct PPM {
    // Store the raw pixel data here
    // Data is R,G,B format
    // Note: You can replace the underlying data structure with whatever you choose.
    //       You may choose to use a dynamic array or a regular pointer.
    //       You can even add a 'pixel' struct if you feel that is better than individual bytes.
    private Pixel[] mPixelData;

    // Store image dimensions
    private int mWidth = -1;
    private int mHeight = -1;
    private int maxVal;
    string ftitle;

    // Constructor loads a filename with the .ppm extension
    this(string fileName){
        // TODO:    Load and parse a ppm to get its pixel
        //          data stored properly.
        File f = File(fileName, "r");
        string line;
        int n = 0;
        int[] components;
        while ((line = f.readln()) !is null){
            if (line[0] == '#'){
                continue;
            }
            switch(n){
                case 0:
                    auto a = line.strip(' ').split('#');
                    auto k = a[0];
                    a = k.split;
                    ftitle = a[0];
                    if (a.length == 4){
                        mWidth = to!int(a[1]);
                        mHeight = to!int(a[2]);
                        maxVal = to!int(a[3]);
                        n = 2;
                    }
                    break;
                case 1:
                    auto a = line.strip(' ').split('#');
                    auto k = a[0];
                    a = k.split;
                    if (a.length == 2){
                        mWidth = to!int(a[0]);
                        mHeight = to!int(a[1]);
                    } else if (a.length == 1 && mWidth == -1 && mHeight == -1){
                        mWidth = to!int(a[0]);
                        n = 0;
                    } else if (a.length == 1 && mHeight == -1){
                        mHeight = to!int(a[0]);
                    }
                    break;
                case 2:
                    auto a = line.strip(' ').split('#');
                    auto k = a[0];
                    a = k.split;
                    maxVal = to!int(a[0]);
                    break;
                default:
                    auto a = line.strip(' ').split('#');
                    auto k = a[0];
                    a = k.split;
                    for (int idx = 0; idx < a.length; idx++){
                        components ~= to!int(a[idx]);
                    }   
                    break;
            }
            n++;
        }
        for (int idx = 0; idx < components.length; idx += 3){
            mPixelData ~= Pixel(to!int(components[idx]), to!int(components[idx+1]), to!int(components[idx+2]));
        }
        f.close();
    }

    // Destructor deletes(i.e. free(memory); ) any memory that has been allocated
    // or otherwise calls any 'shutdown' or 'destroy' routines for this deletion
    // to occur if necessary.
    ~this(){
        // TODO: Reclaim any allocated memory or other resources 
    }

    // Saves a PPM Image to a new file.
    void SavePPM(string outputFileName) const {
        // TODO: Save a PPM image to disk
        auto f = File(outputFileName, "w");
        f.writeln(ftitle ~ " " ~ to!string(mWidth) ~ " " ~ to!string(mHeight) ~ " " ~ to!string(maxVal));
        for (int i = 0; i < mHeight; i++){
            for (int j = 0; j < mWidth; j++){
                int idx = (i * mWidth) + j;
                f.write(to!string(mPixelData[idx].R) ~ "  " ~ to!string(mPixelData[idx].G) ~ "  " ~ to!string(mPixelData[idx].B));
                f.write("    ");
            }
            f.writeln();
        }
        f.close();
    }

    // Sets a pixel to a specific R,G,B value 
    // Note: You do not *have* to use setPixel in your implementation, but
    //       it may be useful to implement.
    void SetPixel(int x, int y, ubyte R, ubyte G, ubyte B){
        // TODO: Optional to implement.
    }
    // Returns the raw pixel data in an array.
    // You may research what 'inline' does.
    // You may also want to research what 'const' does on a function.
    // In brief, 'const' gaureentees that we are not modifying 
    // any member variables in a class, and this is useful if we are
    // returning private member variables.
    ubyte* PixelData() const { 
        return cast(ubyte*)mPixelData.ptr; 
    }
    // Returns image width
    int GetWidth() const { 
        return mWidth; 
    }
    // Returns image height
    int GetHeight() const { 
        return mHeight; 
    }
    // Returns pixel data as an uint
    uint[] getPixelData(){
        uint[] arr;   
        foreach(Pixel pixel ; mPixelData){
            arr ~= [pixel.getPixel.expand];
        }
        return arr;
    }
    // Returns pixel data as an ubyte
    ubyte[] getPixelDataUbyte(){
        ubyte[] arr;
        foreach(Pixel pixel ; mPixelData){
            arr ~= [pixel.getPixelUbyte.expand];
        }
        return arr;
    }
}

// Mesh struct from previous HW assignments.
struct Mesh {
    GLuint mTexID;  // Texture ID
    GLuint mVAO;
    GLuint mVBO;
    GLuint mIBO;
    GLfloat[] mVertexData;
    GLuint[] mIndexData;
    Tuple!(GLfloat, GLfloat, GLfloat)[] vertex_map;
    Tuple!(GLfloat, GLfloat)[] texture_map;
    Tuple!(GLfloat, GLfloat, GLfloat)[] normal_map;
    // Specially named function that is automatically called when printing.
    string toString(){
      return "VAO("~mVAO.to!string~") VBO("~mVBO.to!string~") mIBO("~mIBO.to!string~")";
    }
}

// The LoatMTLFile function finds the *.ppm file that is alluded to by "map_Kd".
string LoadMTLFile(string filename){
    string ppmfilename = "";
    File f = File(filename, "r");
    string line, k;
    while((line = f.readln()) !is null){
        if (line.length == 0){
            continue;
        }else if (line[0] == '#'){
            continue;
        }
        string[] a = line.strip(' ').split;
        if (a.length == 0){
            continue;
        } else {
            k = a[0];
        }
        if (k == "#"){
            continue;
        } else if (k == "map_Kd"){
            ppmfilename = a[1];
            break;
        } else {
			continue;
		}
    }
    f.close();
    return ppmfilename; 
}

// LoadOBJFile function from HW #3. Added a map for textures and position.
Mesh LoadOBJFile(string filename){
    Mesh m;
    File f = File(filename, "r");
    string line, k;
    GLuint index = 0;
    int first, second, third;
    string[] s;
    while((line = f.readln()) !is null){
        if (line.length == 0){
            continue;
        } else if (line[0] == '#'){
            continue;
        }
        string[] a = line.strip(' ').split;
        if (a.length == 0){
            continue;
        } else {
            k = a[0];
        }
        if (k == "#"){
            continue;
        } else if (k == "v"){
            m.vertex_map ~= tuple(to!GLfloat(a[1]), to!GLfloat(a[2]), to!GLfloat(a[3]));
        } else if (k == "vt"){
            m.texture_map ~= tuple(to!GLfloat(a[1]), to!GLfloat(a[2]));
        } else if (k == "vn"){
            m.normal_map ~= tuple(to!GLfloat(a[1]), to!GLfloat(a[2]), to!GLfloat(a[3]));
        } else if (k == "f"){
            s = a[1].split('/');
            first = to!int(s[0]) - 1;
            second = to!int(s[1]) - 1;
            third = to!int(s[2]) - 1;
            m.mVertexData ~= [m.vertex_map[first].expand];
            m.mVertexData ~= [m.texture_map[second].expand];
            s = a[2].split('/');
            first = to!int(s[0]) - 1;
            second = to!int(s[1]) - 1;
            third = to!int(s[2]) - 1;
            m.mVertexData ~= [m.vertex_map[first].expand];
            m.mVertexData ~= [m.texture_map[second].expand];
            s = a[3].split('/');
            first = to!int(s[0]) - 1;
            second = to!int(s[1]) - 1;
            third = to!int(s[2]) - 1;
            m.mVertexData ~= [m.vertex_map[first].expand];
            m.mVertexData ~= [m.texture_map[second].expand];
        } else {
			continue;
		    }
    }
    f.close();
    return m;
}