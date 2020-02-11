module addr_mux(
    output [7:0] o_addr,
    input i_sel,
    input [7:0] i_ir_addr,
    input [7:0] i_pc_addr
);

assign o_addr = (i_sel)? i_ir_addr:i_pc_addr;

endmodule
