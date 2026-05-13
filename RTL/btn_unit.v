`timescale 1ns / 1ps

module btn_unit(clk,rst,btn,btn_addr,btn_run);

input clk,rst;
input [1:0] btn;
output btn_addr,btn_run;

wire [1:0]s_btn;
wire [1:0]d_btn;
wire clk_div;

freq_divide freq0(.clk_ref(clk),.rst(rst),.clk_div(clk_div));

synchronizer sync0(.clk(clk_div), .async_in(btn[0]),.sync_out(s_btn[0])); 
synchronizer sync1(.clk(clk_div), .async_in(btn[1]),.sync_out(s_btn[1])); 

debouncer d0(.clk(clk_div), .noisy(s_btn[0]), .debounced(d_btn[0]));
debouncer d1(.clk(clk_div), .noisy(s_btn[1]), .debounced(d_btn[1])); 

/*debouncer d0(.clk(clk_div), .noisy(s_btn[0]), .debounced(btn[0]));
debouncer d1(.clk(clk_div), .noisy(s_btn[1]), .debounced(btn[1])); */

assign btn_addr = btn[0];
assign btn_run = btn[1];

endmodule
