module cpu_core (
    input i_clk,
    input i_rst
);	

wire n_accu_cen; // accum en
                 // n_accu_cen=1 then accu_out <= accu_in
                 // n_accu_cen=0 then accu
wire n_pc_en;    // ir counter en
                 // n_pc_en=1 then move next command
wire n_ram_wen, n_ram_cen, n_ram_ren, n_rom_cen, n_rom_ren;
wire n_reg_wen, n_reg_ren;
wire [7:0] n_data; // general data bus
                   // driven by rom, ram and reg32
                   // to ram, ir and alu.
wire [7:0] n_addr; // general address from addr_mux
wire n_addr_sel;           // address sel from controller to addr_mux
wire [1:0] n_fetch_mode;   // command mode from controller to ir
                           // n_fetch_mode==01 command+reg_addr short command mode
                           // n_fetch_mode==10 rom/ram data_addr long command mode
wire [7:0] n_accum_data, n_alu_data; // n_nata -> n_alu_data -> n_accum_data
wire [7:0] n_ir_addr, n_pc_addr;     // ir output long addr or ir counter+1 addr
wire [4:0] n_reg_addr;               // ir output short reg addr
wire [2:0] n_ins;                    // ir output ins command

ram ram_inst ( .b_data(n_data),
               .i_addr(n_addr), 
               .i_cen(n_ram_cen), 
               .i_ren(n_ram_ren),
               .i_wen(n_ram_wen)
);

rom rom_inst ( .o_data(n_data), 
               .i_addr(n_addr), 
               .i_cen(n_rom_cen), 
               .i_ren(n_rom_ren)
);

addr_mux addr_mux_inst ( .o_addr(n_addr), 
                         .i_sel(n_addr_sel), 
                         .i_ir_addr(n_ir_addr),
                         .i_pc_addr(n_pc_addr)
);

ir_counter ir_counter_inst ( .o_ir_addr(n_pc_addr), 
                             .i_clk(i_clk), 
                             .i_rst(i_rst), 
                             .i_cnt_en(n_pc_en)
);

accum accum_inst ( .o_data(n_accum_data),
                   .i_data(n_alu_data), 
                   .i_cen(n_accu_cen),
                   .i_clk(i_clk), 
                   .i_rst(i_rst)
);

alu alu_inst ( .o_alu_out(n_alu_data), 
               .i_alu_in(n_data), 
               .i_accum_data(n_accum_data), 
               .i_op_code(n_ins)
);

reg_32 reg_inst ( .i_data(n_alu_data), 
                  .o_data(n_data), 
                  .i_wen(n_reg_wen), 
                  .i_ren(n_reg_ren),
                  .i_addr({n_ins, n_reg_addr}), 
                  .i_clk(i_clk)
);	

ins_reg ir_inst ( .i_data(n_data), 
                  .i_fetch_mode(n_fetch_mode),
                  .i_clk(i_clk), 
                  .i_rst(i_rst), 
                  .o_ins_func(n_ins), 
                  .o_addr_1(n_reg_addr), 
                  .o_addr_2(n_ir_addr)
);

controller controller_ins ( .i_ins(n_ins), 
                            .i_clk(i_clk), 
                            .i_rst(i_rst), 
                            .o_write_r(n_reg_wen), 
                            .o_read_r(n_reg_ren), 
                            .o_pc_en(n_pc_en), 
                            .o_fetch_mode(n_fetch_mode),
                            .o_accu_cen(n_accu_cen), 
                            .o_ram_cen(n_ram_cen), 
                            .o_rom_cen(n_rom_cen),
                            .o_ram_wen(n_ram_wen), 
                            .o_ram_ren(n_ram_ren), 
                            .o_rom_ren(n_rom_ren), 
                            .o_addr_sel(n_addr_sel)
);

endmodule
