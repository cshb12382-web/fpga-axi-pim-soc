`timescale 1ns / 1ps

module memory (
    input clk,
    input [11:0] addr,
    input [15:0] din,
    input we,
    output [15:0] dout
);
    reg [15:0] RAM [0:4095]; 

    assign dout = RAM[addr];

    always @(posedge clk) begin
        if (we) RAM[addr] <= din;
    end
    
    initial begin

        RAM[0] = 16'h200A; 

        RAM[1] = 16'h100B;

        RAM[2] = 16'h300C;

        RAM[3] = 16'h7001;

        RAM[10] = 16'd10;
        RAM[11] = 16'd20;
        RAM[12] = 16'd0; 
    end
endmodule