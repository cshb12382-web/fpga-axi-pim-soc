`timescale 1ns / 1ps

module ascii_to_hex (
    input  wire [7:0] ascii_code, 
    output reg  [3:0] hex_value  
);

    always @(*) begin
        case (ascii_code)
            8'h30: hex_value = 4'h0;  
            8'h31: hex_value = 4'h1;  
            8'h32: hex_value = 4'h2;  
            8'h33: hex_value = 4'h3; 
            8'h34: hex_value = 4'h4;  
            8'h35: hex_value = 4'h5;
            8'h36: hex_value = 4'h6; 
            8'h37: hex_value = 4'h7; 
            8'h38: hex_value = 4'h8; 
            8'h39: hex_value = 4'h9; 

            8'h41: hex_value = 4'hA;  
            8'h42: hex_value = 4'hB;  
            8'h43: hex_value = 4'hC; 
            8'h44: hex_value = 4'hD; 
            8'h45: hex_value = 4'hE;  
            8'h46: hex_value = 4'hF;  

            8'h61: hex_value = 4'hA;  
            8'h62: hex_value = 4'hB; 
            8'h63: hex_value = 4'hC;  
            8'h64: hex_value = 4'hD;  
            8'h65: hex_value = 4'hE; 
            8'h66: hex_value = 4'hF; 

            default: hex_value = 4'h0; 
        endcase
    end

endmodule