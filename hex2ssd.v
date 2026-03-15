`timescale 1ns / 1ps

module hex2ssd(            
    input       [3:0] hex,    
    output reg  [6:0] seg       
    );
    
    always @(*)           
    begin
        case(hex)          
            4'h0 : seg = 7'h40;     // when HEX is 0
            4'h1 : seg = 7'h79;     // when HEX is 1
            4'h2 : seg = 7'h24;     // when HEX is 2
            4'h3 : seg = 7'h30;     // when HEX is 3
            4'h4 : seg = 7'h19;     // when HEX is 4
            4'h5 : seg = 7'h12;     // when HEX is 5
            4'h6 : seg = 7'h02;     // when HEX is 6
            4'h7 : seg = 7'h78;     // when HEX is 7
            4'h8 : seg = 7'h00;     // when HEX is 8
            4'h9 : seg = 7'h10;     // when HEX is 9
            4'ha : seg = 7'h08;     // when HEX is a
            4'hb : seg = 7'h03;     // when HEX is b
            4'hc : seg = 7'h46;     // when HEX is c
            4'hd : seg = 7'h21;     // when HEX is d
            4'he : seg = 7'h06;     // when HEX is e
            4'hf : seg = 7'h0e;     // when HEX is f
            //5'd16 : seg = 7'h41;  //v
           // 5'd17 : seg = 7'h0f;  //r
           default : seg = 7'h7f;
        endcase
    end
    
endmodule

