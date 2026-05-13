`timescale 1ns / 1ps

module add_sub(
    input [15:0] a,           
    input [15:0] b,           
    input m,
    output [15:0] sum,       
    output overflow,          
    output cout        
);
    
    wire [15:0] rev_b;
    
    assign rev_b =  (m==1)? ~b + 1'b1 : b;
    
    cla16 u0 (.a(a), .b(rev_b), .cin(1'b0), .sum(sum), .cout(cout));

    assign overflow = (m == 0) ? ((a[15] == b[15]) && (sum[15] != a[15])) :
                              ((a[15] == rev_b[15]) && (sum[15] != a[15]));
       
endmodule
