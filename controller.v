module controller(
    input [2:0] i_ins,
    input i_clk, i_rst,
    output reg o_write_r, o_read_r, o_pc_en, o_accu_cen, o_ram_cen, o_rom_cen, o_ram_wen, o_ram_ren, o_rom_ren, o_addr_sel,
    output reg [1:0] o_fetch_mode
);

reg [3:0] r_current_state;	// current state
reg [3:0] r_next_state; 	// next state


// instruction code
parameter NOP=3'b000, // no operation
          LDO=3'b001, // load ROM to register
          LDA=3'b010, // load RAM to register
          STO=3'b011, // Store intermediate results to accumulator
          PRE=3'b100, // Prefetch Data from Address
          ADD=3'b101, // Adds the contents of the memory address or integer to the accumulator
          LDM=3'b110, // Load Multiple
          HLT=3'b111; // Halt

// state code			 
parameter Sidle=4'hf,
          S0=4'd0,
          S1=4'd1,
          S2=4'd2,
          S3=4'd3,
          S4=4'd4,
          S5=4'd5,
          S6=4'd6,
          S7=4'd7,
          S8=4'd8,
          S9=4'd9,
          S10=4'd10,
          S11=4'd11,
          S12=4'd12;
			 
//PART A: D flip latch; State register
always @(posedge i_clk or negedge i_rst) begin
    if(!i_rst) r_current_state <= Sidle; //current_state <= Sidle;
    else r_current_state <= r_next_state; //current_state <= next_state;	
end

//PART B: Next-state combinational logic
always @* begin
    case(r_current_state)
        S1: begin
            if (i_ins==NOP) r_next_state=S0;
            else if (i_ins==HLT) r_next_state=S2;
            else if (i_ins==PRE | i_ins==ADD) r_next_state=S9;
            else if (i_ins==LDM) r_next_state=S11;
            else r_next_state=S3;
        end
        S4: begin
            if (i_ins==LDA | i_ins==LDO) r_next_state=S5; //else if (i_ins==STO) r_next_state=S7; 
            else r_next_state=S7; // ---Note: there are only 3 long i_instrucions. So, all the cases included. if (counter_A==2*b11)
        end
        Sidle:   r_next_state=S0;
        S0:      r_next_state=S1;
        S2:      r_next_state=S2;
        S3:      r_next_state=S4;
        S5:      r_next_state=S6;
        S6:      r_next_state=S0;
        S7:      r_next_state=S8;
        S8:      r_next_state=S0;
        S9:      r_next_state=S10;
        S10:     r_next_state=S0;
        S11:     r_next_state=S12;
        S12:     r_next_state=S0;
        default: r_next_state=Sidle;
    endcase
end

// another style
//PART C: Output combinational logic
always @* begin 
    case(r_current_state)
        Sidle: begin // idle
            o_write_r=1'b0;
            o_read_r=1'b0;
            o_pc_en=1'b0; 
            o_accu_cen=1'b0;
            o_ram_cen=1'b0;
            o_rom_cen=1'b0;
            o_ram_wen=1'b0;
            o_ram_ren=1'b0;
            o_rom_ren=1'b0;
            o_addr_sel=1'b0;
            o_fetch_mode=2'b00;
        end
        S0: begin // load part1 command, load rom, address from counter, counter disable
                  // update command and reg addr
                  // next S1 only
            o_write_r=0;
            o_read_r=0;
            o_pc_en=0;
            o_accu_cen=0;
            o_ram_cen=0;
            o_rom_cen=1;
            o_ram_wen=0;
            o_ram_ren=0;
            o_rom_ren=1;
            o_addr_sel=0;
            o_fetch_mode=2'b01;
        end
        S1: begin // translate part1 command, load rom, address from counter, counter enable
                  // no addr update
                  // if NOP go back S0, start next command with counter+1
                  // if HLT go to S2, stop
                  // if PRE or ADD go to S9, access reg->accu
                  // if LDM go to S11, write accu->reg
                  // other go to S3, load next ir address for long command
            o_write_r=0;
            o_read_r=0;
            o_pc_en=1; 
            o_accu_cen=0;
            o_ram_cen=0;
            o_ram_wen=0;
            o_ram_ren=0;
            o_rom_cen=1;
            o_rom_ren=1; 
            o_addr_sel=0;
            o_fetch_mode=2'b00;
        end
        S2: begin // next S2 loop
            o_write_r=0;
            o_read_r=0;
            o_pc_en=0;
            o_accu_cen=0;
            o_ram_cen=0;
            o_rom_cen=0;
            o_ram_wen=0;
            o_ram_ren=0;
            o_rom_ren=0;
            o_addr_sel=0;
            o_fetch_mode=2'b00;
        end
        S3: begin // load part2 command, load rom, address from counter, counter disable
                  // next S4 only
                  // update rom/ram addr
            o_write_r=0;
            o_read_r=0;
            o_pc_en=0;
            o_accu_cen=0;
            o_ram_cen=0;
            o_rom_cen=1;
            o_ram_wen=0;
            o_ram_ren=0;
            o_rom_ren=1;
            o_addr_sel=0;
            o_fetch_mode=2'b10; 
        end
        S4: begin // translate part2 command, load rom, address from counter, counter enable
                  // if LDA/LDO go to S5, access rom/ram to reg
                  // if STO go to S7, access reg to ram
            o_write_r=0;
            o_read_r=0;
            o_pc_en=1;
            o_accu_cen=0;
            o_ram_cen=0;
            o_ram_wen=0;
            o_ram_ren=0;
            o_rom_cen=1; 
            o_rom_ren=1;
            o_addr_sel=0;
            o_fetch_mode=2'b00; 
        end
        S5: begin // exec read rom/ram command from S4, data to reg, reg addr from part1
                  // next S6
            if (i_ins==LDO) begin
                o_write_r=1;
                o_read_r=0;
                o_pc_en=0;
                o_accu_cen=1;
                o_ram_cen=0;
                o_ram_wen=0;
                o_ram_ren=0;
                o_rom_cen=1;
                o_rom_ren=1;
                o_addr_sel=1;
                o_fetch_mode=2'b00; 		 
            end
            else begin
                o_write_r=1;
                o_read_r=0;
                o_pc_en=0;
                o_accu_cen=1;
                o_ram_cen=1;
                o_ram_wen=0;
                o_ram_ren=1;
                o_rom_cen=0;
                o_rom_ren=0;
                o_addr_sel=1;
                o_fetch_mode=2'b00;
            end	 
        end
        S6: begin // idle, next S0
            o_write_r=1'b0;
            o_read_r=1'b0;
            o_pc_en=1'b0;
            o_accu_cen=1'b0;
            o_ram_cen=1'b0;
            o_rom_cen=1'b0;
            o_ram_wen=1'b0;
            o_ram_ren=1'b0;
            o_rom_ren=1'b0;
            o_addr_sel=1'b0;
            o_fetch_mode=2'b00;
	end
        S7: begin // exec STO reg->ram. step1. read reg, ram disable
                  // next S8
            o_write_r=0;
            o_read_r=1;
            o_pc_en=0;
            o_accu_cen=0;
            o_ram_cen=0;
            o_rom_cen=0;
            o_ram_wen=0;
            o_ram_ren=0;
            o_rom_ren=0;
            o_addr_sel=0;
            o_fetch_mode=2'b00;
        end
        S8: begin // exec STO, step2. read reg, ram enable
                  // next S0
            o_write_r=0;
            o_read_r=1;
            o_pc_en=0;
            o_accu_cen=0;
            o_rom_ren=0;
            o_rom_cen=0;
            o_ram_cen=1;
            o_ram_wen=1;
            o_ram_ren=0;
            o_addr_sel=1;
            o_fetch_mode=2'b00;
        end
        S9: begin // exec PRE/ADD, step1. reg->accu
                  // next S10
            if (i_ins==PRE) begin
                o_write_r=0;
                o_read_r=1;
                o_pc_en=0;
                o_accu_cen=1;
                o_ram_cen=0;
                o_rom_cen=0;
                o_ram_wen=0;
                o_ram_ren=0;
                o_rom_ren=0;
                o_addr_sel=0;
                o_fetch_mode=2'b00;
            end
            else begin 
                o_write_r=0;
                o_read_r=1;
                o_pc_en=0;
                o_accu_cen=1;
                o_ram_cen=0;
                o_rom_cen=0;
                o_ram_wen=0;
                o_ram_ren=0;
                o_rom_ren=0;
                o_addr_sel=0;
                o_fetch_mode=2'b00;		 
            end 
        end
        S10: begin // exec PRE/ADD, step2. reg->accu
                   // next S0
            o_write_r=0;
            o_read_r=1;
            o_pc_en=0;
            o_accu_cen=0;
            o_ram_cen=0;
            o_rom_cen=0;
            o_ram_wen=0;
            o_ram_ren=0;
            o_rom_ren=0;
            o_addr_sel=0;
            o_fetch_mode=2'b00;
        end
        S11: begin // exec LDM, step1. accu->reg
                   // next S12
            o_write_r=1;
            o_read_r=0;
            o_pc_en=0;
            o_accu_cen=1;
            o_ram_cen=0;
            o_ram_wen=0;
            o_ram_ren=0;
            o_rom_cen=0;
            o_rom_ren=0;
            o_addr_sel=0;
            o_fetch_mode=2'b00;
            		
        end
        S12: begin // idle next S0
            o_write_r=0;
            o_read_r=0;
            o_pc_en=0;
            o_accu_cen=1;
            o_ram_cen=0;
            o_rom_cen=0;
            o_ram_wen=0;
            o_ram_ren=0;
            o_rom_ren=0;
            o_addr_sel=0;
            o_fetch_mode=2'b00;	 
        end
        default: begin
            o_write_r=0;
            o_read_r=0;
            o_pc_en=0;
            o_accu_cen=0;
            o_ram_cen=0;
            o_rom_cen=0;
            o_ram_wen=0;
            o_ram_ren=0;
            o_rom_ren=0;
            o_addr_sel=0;
            o_fetch_mode=2'b00;		 
        end
    endcase
end

endmodule
