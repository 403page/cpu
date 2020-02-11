module accum (
    input [7:0] i_data,
    output reg [7:0] o_data,
    input i_cen,
    input i_clk,
    input i_rst
); 

always @(posedge i_clk or negedge i_rst) begin	
    if(!i_rst) o_data <= 8'd0;
    else begin
        if(i_cen) o_data <= i_data;
        else o_data <= o_data;
    end
end

endmodule
