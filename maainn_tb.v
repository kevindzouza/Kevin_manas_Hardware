module maainn_tb();

reg A,B,sel; 
wire Y;
mainn DUT(A,B,sel,Y);

initial begin

$dumpfile("dum.vcd");
$dumpvars(0,maainn_tb);

 A=0;B=1;
 sel = 0;
 #20;

 sel = 1;
 #20;

 sel = 0;
 #20;   

 $display("Test Complete");
 $finish;

end

endmodule