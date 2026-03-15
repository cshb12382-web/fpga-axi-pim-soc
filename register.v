`timescale 1ns / 1ps

module register(

input clk,rst,
input [2:0] bus_sel,    
    input [3:0] alu_op,   
    input ld_pc, inc_pc, clr_pc,
    input ld_ar, inc_ar, clr_ar, 
    input ld_ir,              
    input ld_dr, inc_dr, clr_dr, 
    input ld_ac, clr_ac,       
    input mem_write,        
    input [15:0] mem_in,    

    output [11:0] mem_addr,   
    output [15:0] mem_out,    
    output [15:0] ir_out,    
    output [15:0] ac_out,       
    output [15:0] dr_out,
    output e_out,             
    output reg OV
    );

    reg [11:0] PC, AR;
    reg [15:0] IR, DR, AC;
    reg E;

    reg [15:0] common_bus;

    wire [15:0] alu_result;
    wire alu_ov;
    wire e_new;

 alu alu1(.ALU_Op(alu_op), .ALU1(AC), .ALU2(DR), .IR_data(IR[11:0]), .E(E), .ALU_Result(alu_result), .ov_result(alu_ov),.E_out(e_new));
always@(*) begin
case(bus_sel)
    3'b001 : common_bus = {4'b0000,AR};
    3'b010 : common_bus = {4'b0000,PC};
    3'b011 : common_bus = IR;
    3'b100 : common_bus = DR;
    3'b101 : common_bus = AC;
    3'b110 : common_bus = mem_in;
    default : common_bus = 16'b0;
endcase
end

always @ (posedge clk or negedge rst) begin
if(!rst)begin
    PC <= 0; AR <= 0; AC <=0; IR <=0; DR<=0; E<=0;
end
else begin
    if(ld_pc==1)
        PC <= common_bus[11:0];
    else if(inc_pc==1)
        PC <= PC+1;
    else if(clr_pc==1)
        PC <= 12'b0;
    else
        PC <= PC;
    if(ld_ar==1)      
         AR <= common_bus[11:0];
    else if(inc_ar==1) 
        AR <= AR + 1;
    else if(clr_ar==1) 
        AR <= 12'b0;
    else
        AR <= AR;
    if(ld_dr==1)
        DR <= common_bus;
    else if(inc_dr==1)
        DR <= DR+1;
    else if(clr_dr==1)
        DR <= 16'b0;
    else
        DR <= DR;
    if(ld_ac==1)begin
        AC <= alu_result;
        E <= e_new;
        OV <= alu_ov;
    end
    else
        AC <= AC;
    if(ld_ir)
        IR <= common_bus;
    else
        IR <= IR;
end
end
    assign mem_addr = AR;      
    assign mem_out  = common_bus; 
    assign ir_out   = IR;
    assign ac_out   = AC;
    assign dr_out = DR;
    assign e_out    = E;
endmodule