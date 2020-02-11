module ir_counter (
    input i_clk,
    input i_rst,
    input i_cnt_en,
    output reg [7:0] o_ir_addr
);

always @(posedge i_clk or negedge i_rst) begin
    if(!i_rst) o_ir_addr <= 8'd0;
    else begin
        if(i_cnt_en) o_ir_addr <= o_ir_addr + 1;
        else o_ir_addr <= o_ir_addr;
    end
end

endmodule
