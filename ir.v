// instruction register
module ins_reg (
    input [7:0] i_data,
    input [1:0] i_fetch_mode,
    input i_clk,
    input i_rst,
    output [2:0] o_ins_func,
    output [4:0] o_addr_1,
    output [7:0] o_addr_2
);

reg [7:0] r_ins_p1, r_ins_p2;
reg [2:0] r_state;

assign o_ins_func = r_ins_p1[7:5]; // hign 3 bits, instructions
assign o_addr_1   = r_ins_p1[4:0]; // low 5 bits, register address
assign o_addr_2   = r_ins_p2;

always @(posedge i_clk or negedge i_rst) begin
    if(!i_rst) begin
        r_ins_p1 <= 8'd0;
        r_ins_p2 <= 8'd0;
    end
    else begin
        if(i_fetch_mode == 2'b01) begin			//fetch==2'b01 operation1, to fetch data from REG
            r_ins_p1 <= i_data;
            r_ins_p2 <= r_ins_p2;
        end
        else if(i_fetch_mode == 2'b10) begin		//fetch==2'b10 operation2, to fetch data from RAM/ROM
            r_ins_p1 <= r_ins_p1;
            r_ins_p2 <= i_data;
        end
        else begin
            r_ins_p1 <= r_ins_p1;
            r_ins_p2 <= r_ins_p2;
        end
    end
end
endmodule
