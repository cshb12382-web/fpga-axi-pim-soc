`timescale 1ns / 1ps

module io(
    input clk,             
    input rst,       
    input [15:0] number_in,
    output reg [3:0] anode, 
    output [6:0] seg     
    );

    reg [19:0] scan_cnt; 
    
    always @(posedge clk or negedge rst) begin
        if(!rst) scan_cnt <= 0;
        else scan_cnt <= scan_cnt + 1;
    end

    wire [1:0] digit_sel = scan_cnt[19:18];


    reg [3:0] hex_digit;

    always @(*) begin
        case(digit_sel)
            2'b00: begin 
                anode = 4'b1110;    
                hex_digit = number_in[3:0]; 
            end
            2'b01: begin 
                anode = 4'b1101;     
                hex_digit = number_in[7:4]; 
            end
            2'b10: begin 
                anode = 4'b1011;  
                hex_digit = number_in[11:8]; 
            end
            2'b11: begin 
                anode = 4'b0111;  
                hex_digit = number_in[15:12]; 
            end
            default: begin anode = 4'b1111; hex_digit = 4'h0; end
        endcase
    end

    hex2ssd u_decoder(
        .hex(hex_digit),
        .seg(seg)
    );

endmodule