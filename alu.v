module alu (
    output reg [7:0] o_alu_out,
    input [7:0] i_alu_in,
    input [7:0] i_accum_data,
    input [2:0] i_op_code
);

parameter NOP=3'b000,
          LDO=3'b001,
          LDA=3'b010,
          STO=3'b011,
          PRE=3'b100,
          ADD=3'b101,
          LDM=3'b110,
          HLT=3'b111;

always @(*) begin
    casez(i_op_code)
        NOP: o_alu_out = i_accum_data;
        HLT: o_alu_out = i_accum_data;
        LDO: o_alu_out = i_alu_in;
        LDA: o_alu_out = i_alu_in;
        STO: o_alu_out = i_accum_data;
        PRE: o_alu_out = i_alu_in;
        ADD: o_alu_out = i_accum_data + i_alu_in;
        LDM: o_alu_out = i_accum_data;
        default: o_alu_out = 8'bzzzz_zzzz;
    endcase
end	

endmodule
