module fsm_moore (
    input wire [1:0] mnm_in,
    input wire clk, rst, ula_ack, wr_ack, pc_ack, ri_ack,
    output reg ena_pc, ena_ri, ena_wr, sel_r0_rd, sel_addr_data, sel_ldr_ula, ena_ula,
    output reg [2:0] state_out
);

    reg [2:0] state;
    localparam pc     = 3'd0,
               fetch  = 3'd1,
               ldr    = 3'd2,
               arit   = 3'd3,
               wb_rd  = 3'd4,
               Logic  = 3'd5,
               wb_r0  = 3'd6;

    always @(*) begin
        ena_pc = 1'b0; ena_ri = 1'b0; ena_wr = 1'b0;
        sel_r0_rd = 1'b0; sel_addr_data = 1'b0;
        sel_ldr_ula = 1'b0; ena_ula = 1'b0;

        case (state)
            pc:      ena_pc = 1'b1;
            fetch:   ena_ri = 1'b1;
            ldr:     begin ena_wr = 1'b1; sel_r0_rd = 1'b1; sel_ldr_ula = 1'b1; end
            arit:    begin sel_addr_data = 1'b1; ena_ula = 1'b1; end
            wb_rd:   begin ena_wr = 1'b1; sel_r0_rd = 1'b1; end
            Logic:   begin sel_addr_data = 1'b1; ena_ula = 1'b1; end
            wb_r0:   ena_wr = 1'b1;
        endcase
    end

    always @(posedge clk, negedge rst) begin
        if (~rst)
            state <= fetch;
        else begin
            case (state)
                pc:     if (pc_ack) state <= fetch; else state <= pc;
                fetch:  if (mnm_in == 2'b00 && ri_ack) state <= ldr;
                        else if ((mnm_in == 2'b10 || mnm_in == 2'b11) && ri_ack) state <= arit;
                        else if (mnm_in == 2'b01 && ri_ack) state <= Logic;
                        else state <= fetch;
                ldr:    if (wr_ack) state <= pc; else state <= ldr;
                arit:   if (ula_ack) state <= wb_rd; else state <= arit;
                wb_rd:  if (wr_ack) state <= pc; else state <= wb_rd;
                Logic:  if (ula_ack) state <= wb_r0; else state <= Logic;
                wb_r0:  if (wr_ack) state <= pc; else state <= wb_r0;
            endcase
        end
        state_out <= state;
    end

endmodule
