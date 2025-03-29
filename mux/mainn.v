module mainn(A,B,sel,Y);

input A,B,sel;
output Y;
assign Y = sel ? A:B;

endmodule