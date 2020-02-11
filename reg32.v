module reg_32 (
    input [7:0] i_data, 
    output [7:0] o_data,
    input i_wen, 
    input i_ren,
    input [7:0] i_addr,
    input i_clk
);

reg [7:0] r_reg[31:0]; //32Byte
wire [4:0] n_addr;

assign n_addr = i_addr[4:0];
assign o_data = (i_ren)? r_reg[n_addr]:8'hzz;

always @(posedge i_clk) begin				//write, clk posedge
    if(i_wen) r_reg[n_addr] <= i_data;
end

endmodule
