module ctmc;
import std.stdio, std.math, std.conv, std.typecons, std.traits, std.random;
import bindbc.opengl;
import vec, utility, mat;

class CTMC(T=GLfloat, size_t N=0, size_t length=0, size_t width=0){
    T[N][N] mat;   
    ulong[length][width] grid = 0;
    ulong curr_state = 1;
    ulong prev_state; 
    MinstdRand0 rng;
    ulong[string] state_map;
    this(){    
        // Since no prior is provided, it is assumed to be perfectly uniform i.e. 1 / N.
        rng = MinstdRand0(unpredictableSeed);
        for(ulong i = 0; i < N; i++){
            for(ulong j = 0; j < N; j++){
                mat[i][j] = to!float(1.0f / N);
            }
        }
        for (ulong i = 0; i < length; i++){
            for (ulong j = 0; j < width; j++){
                grid[i][j] = get_next_state();
            }
        }
    } 
    this(T[N*N] arr){
        // The prior is provided as a one-dimensional array.
        rng = MinstdRand0(unpredictableSeed);
        for(ulong i = 0; i < N; i++){
            for(ulong j = 0; j < N; j++){
                mat[i][j] = arr[i * N + j];
            }
        }
        for (ulong i = 0; i < length; i++){
            for (ulong j = 0; j < width; j++){
                grid[i][j] = get_next_state();
            }
        }
    }
    this(T[N][N] arr){
        // The prior is provided as a two-dimensional array.
        rng = MinstdRand0(unpredictableSeed);
        for(ulong i = 0; i < N; i++){
            for(ulong j = 0; j < N; j++){
                mat[i][j] = arr[i][j];
            }
        }
        for (ulong i = 0; i < length; i++){
            for (ulong j = 0; j < width; j++){
                grid[i][j] = get_next_state();
            }
        }
    }
    T get(ulong i, ulong j){
        if (i < 0  || j < 0 || i > length || j > width) return 0;
        else return grid[i][j];
    }
    ulong get_prev_state(){
        return prev_state;
    }
    ulong get_curr_state(){
        return curr_state;
    }
    ulong get_next_state(){
        prev_state = curr_state; 
        curr_state = 1 + rng.dice(mat[prev_state - 1]);
        return curr_state;
    }
    invariant{
        assert(N >= 0);
        assert(length >= 0);
        assert(width >= 0);
        assert(prev_state < N + 1);
        assert(curr_state < N + 1);
        for (ulong i = 0; i < N; i++){
            float s = 0;
            for (ulong j = 0; j < N; j++){
                assert(mat[i][j] >= 0);
                assert(mat[i][j] <= 1);
                s = s + to!float(mat[i][j]);
            }
            assert(isClose(s, 1.0));
        }
    }
}
