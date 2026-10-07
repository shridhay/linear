module fft;

import std.stdio, std.complex, std.numeric, std.array, std.math, std.conv, std.traits;

// Complex!double[] fft1d(Complex!double[] mat){
//     return fft(mat).array;
// }

// Complex!double[] ifft1d(Complex!double[] mat){
//     return inverseFft(mat).array;
// }

// Complex!double[][] fft2d(Complex!double[][] mat){
//     ulong rows = mat.length;
//     ulong cols = mat[0].length;
//     Complex!(double)[][] res = new Complex!(double)[][](rows, cols);

// }

// Complex!(double)[][] ifft2d(Complex!(double)[][] mat){
//     ulong rows = mat.length;
//     ulong cols = mat[0].length;
// }

// Complex!(double)[][][] fft3d(Complex!(double)[][][] mat){
//     ulong rows = mat.length;
//     ulong cols = mat[0].length;
//     ulong blocks = mat[0][0].length; 
//     Complex!(double)[][][] res = new Complex!(double)[][][](rows, cols, blocks);

// }

// Complex!(double)[][][] ifft3d(Complex!(double)[][][] mat){
//     ulong rows = mat.length;
//     ulong cols = mat[0].length;
//     ulong blocks = mat[0][0].length; 
//     Complex!(double)[][][] res = new Complex!(double)[][][](rows, cols, blocks);

// }

// Complex!(double)[][][][] fft4d(Complex!(double)[][][][] mat){
//     ulong blocks = mat.length;
//     ulong tables = mat[0].length;
//     ulong rows = mat[0][0].length; 
//     ulong cols = mat[0][0][0].length;
//     Complex!(double)[][][][] res = new Complex!(double)[][][][](blocks, tables, rows, cols);
// }

// Complex!(double)[][][][] ifft4d(Complex!(double)[][][][] mat){
//     ulong blocks = mat.length;
//     ulong tables = mat[0].length;
//     ulong rows = mat[0][0].length; 
//     ulong cols = mat[0][0][0].length;
//     Complex!(double)[][][][] res = new Complex!(double)[][][][](blocks, tables, rows, cols);
// }