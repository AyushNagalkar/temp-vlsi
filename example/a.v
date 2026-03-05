// =====================================================
// Complex Sky130 Chip with Macros
// Tech: Sky130A
// Library: sky130_fd_sc_hd
// =====================================================

module complex_chip (
    input clk,
    input rst,
    input [7:0] A,
    input [7:0] B,
    output [7:0] Y
);

// Internal wires
wire [7:0] alu_out;
wire [7:0] reg_out;
wire [3:0] state;
wire enable;
wire [7:0] mem_data;

// =====================================================
// 8-bit ALU (Adder + AND logic)
// =====================================================

genvar i;
generate
for (i=0; i<8; i=i+1) begin : ALU_BLOCK

    wire s1, s2;

    sky130_fd_sc_hd__xor2_1 U1 (.A(A[i]), .B(B[i]), .X(s1));
    sky130_fd_sc_hd__and2_1 U2 (.A(A[i]), .B(B[i]), .X(s2));
    sky130_fd_sc_hd__or2_1  U3 (.A(s1), .B(s2), .X(alu_out[i]));

end
endgenerate

// =====================================================
// Register File (8-bit)
// =====================================================

generate
for (i=0; i<8; i=i+1) begin : REG_BLOCK

    sky130_fd_sc_hd__dfrtp_1 REG (
        .CLK(clk),
        .D(alu_out[i]),
        .RESET_B(~rst),
        .Q(reg_out[i])
    );

end
endgenerate

// =====================================================
// 4-bit Control FSM
// =====================================================

generate
for (i=0; i<4; i=i+1) begin : FSM_BLOCK

    sky130_fd_sc_hd__dfrtp_1 STATE_REG (
        .CLK(clk),
        .D(state[i] ^ reg_out[i]),
        .RESET_B(~rst),
        .Q(state[i])
    );

end
endgenerate

sky130_fd_sc_hd__and2_1 CTRL_AND (
    .A(state[0]),
    .B(state[1]),
    .X(enable)
);

// =====================================================
// Counter Block
// =====================================================

wire [7:0] counter;

generate
for (i=0; i<8; i=i+1) begin : COUNTER_BLOCK

    sky130_fd_sc_hd__dfrtp_1 CNT (
        .CLK(clk),
        .D(counter[i] ^ enable),
        .RESET_B(~rst),
        .Q(counter[i])
    );

end
endgenerate

// =====================================================
// SRAM Macro (Hard Macro Block)
// =====================================================

sky130_sram_1kbyte_1rw1r_32x256_8 SRAM0 (
    .clk0(clk),
    .csb0(1'b0),
    .web0(1'b1),
    .addr0(counter[7:0]),
    .din0(reg_out),
    .dout0(mem_data)
);

// =====================================================
// Output Mux
// =====================================================

generate
for (i=0; i<8; i=i+1) begin : OUTPUT_BLOCK

    sky130_fd_sc_hd__mux2_1 OUTMUX (
        .A0(reg_out[i]),
        .A1(mem_data[i]),
        .S(enable),
        .X(Y[i])
    );

end
endgenerate

endmodule