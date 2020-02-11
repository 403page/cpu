module rom (
    output [7:0] o_data,
    input [7:0] i_addr,
    input i_ren, 
    input i_cen
);

reg [7:0] r_memory[255:0];
int i;

//initial begin
//    for (i = 0; i<=255; i++)
//        r_memory[i] = 8'b000_0000;
//end

// note: Decimal number in the bracket
initial begin
    r_memory[0] = 8'b000_00000;	//NOP
    r_memory[1] = 8'b001_00001;	//LDO reg 00001
    r_memory[2] = 8'b010_00001;	//rom(65) 0100_0001   //end, reg[1]<-rom[65]
    r_memory[3] = 8'b001_00010;	//LDO reg 00010
    r_memory[4] = 8'b010_00010;	//rom(66) 0100_0010   //end, reg[2]<-rom[66]
    r_memory[5] = 8'b001_00011;	//LDO reg 00011
    r_memory[6] = 8'b010_00011;	//rom(67) 0100_0011   //end, reg[3]<-rom[67] 
    r_memory[7] = 8'b100_00001;	//PRE 00001
    r_memory[8] = 8'b101_00010;	//ADD 00010
    r_memory[9] = 8'b110_00001;	//LDM 00001  // REG[1] <- REG[1]+REG[2]	
    r_memory[10] = 8'b011_00001;	//STO s1
    r_memory[11] = 8'b000_00001;	//ram(1)  // RAM[1] <- REG[1]
    r_memory[12] = 8'b010_00010;	//LDA s2
    r_memory[13] = 8'b000_00001;	//ram(1)  // REG[2] <- RAM[1]	
    r_memory[14] = 8'b100_00011;	//PRE s3
    r_memory[15] = 8'b101_00010;	//ADD s2
    r_memory[16] = 8'b110_00011;	//LDM s3  // REG[3] <- REG[2]+REG[3]	
    r_memory[17] = 8'b011_00011;	//STO s3
    r_memory[18] = 8'b000_00010;	//ram(2)   //REG[3] -> ram[2]
    r_memory[19] = 8'b111_00000;	//HLT   	
    r_memory[65] = 8'b1111_0000;	//
    r_memory[66] = 8'b0000_1111;	//
    r_memory[67] = 8'b1010_0101;	//
end

assign o_data = (i_ren&&i_cen)? r_memory[i_addr]:8'hzz;	

endmodule
