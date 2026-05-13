`timescale 1ns / 1ps

module synchronizer(     
    input clk,         
    input async_in,      
    output reg sync_out   
    );

    reg tmp;           

    always @ (posedge clk)  
    begin
        tmp <= async_in;  
        sync_out <= tmp;   
    end

endmodule