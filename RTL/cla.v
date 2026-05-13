`timescale 1ns / 1ps

module cla(
    input       [ 3: 0] x,
    input       [ 3: 0] y,
    input               cin,
    output              cout,
    output      [ 3: 0] sum
    );
    
    wire [3:0] a,b;
    wire [4:0] c;

    assign c[0] = cin;
    assign cout = c[4];

    assign a = x&y; //carry check
    assign b = x^y;
    
    assign sum= c[3:0] ^ b;

    assign c[1] = a[0] | (b[0] & c[0]); //a==1 : carry happen, a==0 but if agree? because of c
    assign c[2] = a[1] | (b[1] & a[0]) | (b[1] & b[0] & c[0]); //if at [0], x=1,y=1? at least 1 hap
    //and if at c[1] second condition, at least 1 (already carry at last stage
    // = a[1] | (b[1] & c[1])
    assign c[3] = a[2] | (b[2] & a[1]) | (b[2] & b[1] & a[0]) | (b[2] & b[1] & b[0] & c[0]);
    assign c[4] = a[3] | (b[3] & a[2]) | (b[3] & b[2] & a[1]) | (b[3] & b[2] & b[1] & a[0]) |
    (b[3] & b[2] & b[1] & b[0] & c[0]); // = cout
/*
    fa_1    u0      (.a(x[0]), .b(y[0]), .cin(cin), .cout(c1),   .sum(sum[0]));
    fa_1    u1      (.a(x[1]), .b(y[1]), .cin(c1),  .cout(c2),   .sum(sum[1]));
    fa_1    u2      (.a(x[2]), .b(y[2]), .cin(c2),  .cout(c3),   .sum(sum[2]));
    fa_1    u3      (.a(x[3]), .b(y[3]), .cin(c3),  .cout(cout), .sum(sum[3]));
   */ 
endmodule