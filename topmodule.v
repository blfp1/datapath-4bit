module topmodule( 
    input wire clk, rst,
    output wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
);

    // Control signals
    wire enable_pc, ack_pc;
    wire enable_ir, ack_ir;
    wire select_r0_or_rd;
    wire enable_write, ack_write;
    wire enable_alu, ack_alu;
    wire select_address_data, select_ldr_or_alu;

    // Instruction decoding
    wire [1:0] opcode, write_addr_from_opcode, write_addr_final;
    wire [3:0] reg_info_combined, reg_rd_addr, write_data;
    wire [3:0] operand_a, operand_b, alu_result, ldr_data;

    // Address and data buses
    wire [7:0] address_bus, instruction_data;

    // FSM current state
    wire [2:0] fsm_state;

    // Program Counter
    program_counter pc (
        .clk(clk), 
        .rst(rst), 
        .en(enable_pc), 
        .pc_out(address_bus), 
        .ack(ack_pc)
    );

    // Instruction memory (ROM)
    rom_8x256 memory (
        .addr(address_bus), 
        .data(instruction_data)
    );

    // Instruction Register (IR)
    instruction_register ir (
        .data_in(instruction_data), 
        .clk(clk), 
        .ena(enable_ir), 
        .rst(rst), 
        .mnm(opcode), 
        .wr_addr_mnm(write_addr_from_opcode),
        .rd_addr_wr_data(reg_info_combined), 
        .ack(ack_ir)
    );

    // 2-to-1 multiplexer to select write address
    mux2x1_2bit mux_write_addr (
        .in0(2'b00), 
        .in1(write_addr_from_opcode), 
        .sel(select_r0_or_rd), 
        .out(write_addr_final)
    );

    // Register File (General-purpose registers)
    register_file rf (
        .clk(clk), 
        .wr_en(enable_write), 
        .wr_addr(write_addr_final), 
        .wr_data(write_data), 
        .rd_addr1(reg_rd_addr[3:2]),
        .rd_addr2(reg_rd_addr[1:0]), 
        .rd_data1(operand_a), 
        .rd_data2(operand_b), 
        .wr_ack(ack_write)
    );

    // 4-bit ALU
    ula_4bit_sync alu (
        .clk(clk), 
        .enable(enable_alu), 
        .a(operand_a), 
        .b(operand_b), 
        .sel({opcode, write_addr_from_opcode}), 
        .result(alu_result), 
        .ula_ack(ack_alu)
    );

    // Demux to separate data and register address
    demux1x2_4bit demux_reg (
        .in(reg_info_combined), 
        .sel(select_address_data), 
        .out0(ldr_data), 
        .out1(reg_rd_addr)
    );

    // 2-to-1 multiplexer to choose write-back data
    mux2x1_4bit mux_write_data (
        .in0(alu_result), 
        .in1(ldr_data), 
        .sel(select_ldr_or_alu), 
        .out(write_data)
    );

    // Moore FSM - Control Unit
    fsm_moore controller (
        .clk(clk), 
        .rst(rst), 
        .mnm_in(opcode), 
        .ula_ack(ack_alu), 
        .wr_ack(ack_write), 
        .pc_ack(ack_pc), 
        .ri_ack(ack_ir),
        .ena_pc(enable_pc), 
        .ena_ri(enable_ir), 
        .ena_wr(enable_write), 
        .sel_r0_rd(select_r0_or_rd), 
        .sel_addr_data(select_address_data), 
        .sel_ldr_ula(select_ldr_or_alu), 
        .ena_ula(enable_alu), 
        .state_out(fsm_state)
    );

    // 7-segment display outputs for debugging
    hex_7seg d0 (.hex(alu_result),         .seg(HEX0));             // ALU result
    hex_7seg d1 (.hex(operand_b),          .seg(HEX1));             // Operand B
    hex_7seg d2 (.hex(operand_a),          .seg(HEX2));             // Operand A
    hex_7seg d3 (.hex({1'b0, fsm_state}),  .seg(HEX3));             // FSM state
    hex_7seg d4 (.hex(instruction_data[3:0]), .seg(HEX4));          // Instruction (low nibble)
    hex_7seg d5 (.hex(instruction_data[7:4]), .seg(HEX5));          // Instruction (high nibble)

endmodule
