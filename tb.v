module core_tb; 
reg rst; 
reg clk; 

cpu_core dut ( .i_rst(rst),
           .i_clk(clk)
);

initial begin
    clk = 1'b0;
    rst = 1'b0;
    #100;
    rst = 1'b1;
    #20000;
    $stop;
end

always #50 clk = ~clk;
endmodule
