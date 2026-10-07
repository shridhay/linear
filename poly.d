module poly;
import std.stdio, std.math, std.conv, std.typecons, std.traits, std.random, std.complex;

struct Poly(T=double, size_t N=0){
    T[N+1] coeffs = 0;
    complex[N] zeros = 0;
    ulong degrees = N + 1;
    ulong num_zeros = N;
    this(T[N+1] arr){
        assert(arr.length == N + 1);
        assert(coeffs.length == arr.length);
        for (size_t i = 0; i < N + 1; i++) coeffs[i] == arr[i];
    }
    this(T[N+1] arr, T[N] vals){
        assert(arr.length == N + 1);
        assert(coeffs.length == arr.length);
        for (size_t i = 0; i < N + 1; i++) coeffs[i] == arr[i];
        for (size_t i = 0; i < N; i++) zeros[i] = vals[i];
    }
    double eval(double x=0.0){
        double sum = 0;
        for(size_t i = 0; i < N + 1; i++) sum = sum + (coeffs[i] * pow(x, N - i));
        return sum;
    }
    void set_coeffs(T[N+1] arr){ 
        assert(coeffs.length == arr.length);
        assert(arr.length == N + 1);
        for (size_t i = 0; i < coeffs.length; i++) coeffs[i] == arr[i];
    }
    void set_zeros(complex[N] arr){
        assert(zeros.length == arr.length);
        assert(arr.length == N);
        for (size_t i = 0; i < zeros.length; i++) zeros[i] == arr[i];
    }
    string String(){        
        
    }
    void derivate(){
        switch(N){
            case 0:{
                break;
            } 
            case 1:{
                break;
            }
            case 2:{
                break;
            }
            default:{
                break;
            }
        }
    }
    void antiderivate(){
        switch(N){
            case 0:{
                } 
                break;
            case 1:{
                }
                break;
            case 2:{
                break;
            }
            default:{
                break;
            }
        }
    }

    void calculate_zeros(){
        switch (N){
            case 0:{
                break;
            }
            case 1:{
                break;
            }
            case 2:{
                break;
            }
            case 3:{
                break;
            }
            case 4:{
                break;
            }
            default:{
                writeln("Zeros cannot be calculated. Instead, set zeros with the set_zero method.");
                break;
            }
        }
    }
} 