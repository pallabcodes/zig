// A simple C function to demonstrate Zig's zero-cost FFI.
int add_in_c(int a, int b) {
    return a + b;
}

// A function using a struct to show ABI compatibility.
typedef struct {
    int x;
    int y;
} CPoint;

int sum_point(CPoint p) {
    return p.x + p.y;
}
