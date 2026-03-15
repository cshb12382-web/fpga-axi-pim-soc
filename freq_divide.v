`timescale 1ns / 1ps

module freq_divide(    
    input clk_ref,   
    input rst,       
    output clk_div   
    );
    
    wire clk_1M, clk_10K, clk_100, clk_1;
    assign clk_1M = clk_ref;

    freq_div_100 u0 (.clk_ref(clk_1M),  .rst(rst), .clk_div(clk_10K));
    freq_div_100 u1 (.clk_ref(clk_10K), .rst(rst), .clk_div(clk_100));
    freq_div_100 u2 (.clk_ref(clk_100), .rst(rst), .clk_div(clk_1));
    
    assign clk_div = clk_1;
    // clk_div is clk_1 = 50hz
    
endmodule

