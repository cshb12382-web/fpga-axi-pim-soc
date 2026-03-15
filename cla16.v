`timescale 1ns / 1ps

module cla16(a,b,cin,sum,cout);

input [15:0] a,b;
input cin;
output [15:0] sum;
output cout;

wire c1,c2,c3;

cla cla1(.x(a[3:0]), .y(b[3:0]), .cin(cin), .cout(c1), .sum(sum[3:0]));
cla cla2(.x(a[7:4]), .y(b[7:4]), .cin(c1), .cout(c2), .sum(sum[7:4]));
cla cla3(.x(a[11:8]), .y(b[11:8]), .cin(c2), .cout(c3), .sum(sum[11:8]));
cla cla4(.x(a[15:12]), .y(b[15:12]), .cin(c3), .cout(cout), .sum(sum[15:12]));

endmodule
