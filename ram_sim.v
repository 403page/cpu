module ram (
    inout [7:0] b_data, 
    input [7:0] i_addr, 
    input i_cen, 
    input i_ren, 
    input i_wen
);

reg [7:0] r_ram[255:0];

assign b_data = (i_ren&&i_cen)? r_ram[i_addr]:8'hzz;

always @(posedge i_wen) begin	// write data to RAM
	r_ram[i_addr] <= b_data;
end

endmodule
