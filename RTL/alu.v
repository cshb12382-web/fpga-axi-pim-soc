`timescale 1ns / 1ps

module alu(                                    
    input [3:0] ALU_Op,        
    input [15:0] ALU1,        
    input [15:0] ALU2,     
    input [11:0] IR_data,
    input E,

    output [15:0] ALU_Result,   
    output       ov_result,
    output reg E_out
    );
    
    reg m;
    reg [15:0] tmp;           
    wire [15:0] sum;       
    wire ov;            
    wire cout_wire;
    
    always @(*)            
    begin
    tmp = ALU1;
    E_out = E;
    m=0;
        case(ALU_Op)  
            0: tmp = ALU1&ALU2;            // AND
            1: begin
                m=0;
                E_out = cout_wire;
                end           // ADD
            2: tmp = ALU2;           // LDA
            3: tmp = ALU1;           // STA
            15: begin 
                m=1;
                E_out = cout_wire;
                end // SUB
            7 : begin
                if(IR_data==12'h800)
                    tmp = 16'b0; //CLA
                else if(IR_data == 12'h400)
                    E_out = 1'b0; //CLE
                else if(IR_data == 12'h200)
                    tmp = ~ALU1; //CMA
                else if(IR_data == 12'h100)
                    E_out = ~E; //CME
                else if(IR_data == 12'h080)begin
                    tmp = {E,ALU1[15:1]};
                    E_out = ALU1[0]; end //CIR
                else if(IR_data == 12'h040)begin
                    tmp = {ALU1[14:0], E};
                    E_out = ALU1[15]; end // CIL
                else if(IR_data == 12'h020)
                    tmp = ALU1+1; // INC
                else
                    tmp = ALU1; // SPA,SNA,SZA,SZE,MOV   
                end
            default : tmp = tmp;
        endcase
    end
    
    add_sub u0(.a(ALU1), .b(ALU2), .m(m), .sum(sum), .overflow(ov), .cout(cout_wire) );
    assign ALU_Result = ((ALU_Op == 4'd0) || ((ALU_Op <= 4'd14) && (ALU_Op >= 4'd2))) ? tmp : (ov) ? 16'b0 : sum;
            
    assign ov_result = ov && ((ALU_Op == 4'd1) || (ALU_Op == 4'd15));                                                // when ov is 0, tmp is sum or diff.
endmodule