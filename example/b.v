// =======================================================
// MINI COMPUTE SOC - SKY130 HD
// Tech: Sky130A
// Library: sky130_fd_sc_hd
// =======================================================

module mini_soc (
    input clk,
    input rst,
    input [15:0] A,
    input [15:0] B,
    output [15:0] Y
);

// =======================================================
// INTERNAL BUSES
// =======================================================

wire [15:0] alu_out;
wire [15:0] pipe1, pipe2, pipe3, pipe4;
wire [15:0] mem0_out, mem1_out;
wire [15:0] dma_data;
wire enable_global;
wire [7:0] dma_counter;

// =======================================================
// 16-BIT ALU (Adder + Logic Mix)
// =======================================================

genvar i;

generate
for (i=0; i<16; i=i+1) begin : ALU

    wire x1, a1, o1;

    sky130_fd_sc_hd__xor2_1 U1 (.A(A[i]), .B(B[i]), .X(x1));
    sky130_fd_sc_hd__and2_1 U2 (.A(A[i]), .B(B[i]), .X(a1));
    sky130_fd_sc_hd__or2_1  U3 (.A(x1), .B(a1), .X(o1));
    sky130_fd_sc_hd__buf_1  U4 (.A(o1), .X(alu_out[i]));

end
endgenerate

// =======================================================
// 4-STAGE PIPELINE REGISTERS (Deep Sequential Region)
// =======================================================

generate
for (i=0; i<16; i=i+1) begin : PIPE

    sky130_fd_sc_hd__dfrtp_1 P1 (.CLK(clk), .D(alu_out[i]), .RESET_B(~rst), .Q(pipe1[i]));
    sky130_fd_sc_hd__dfrtp_1 P2 (.CLK(clk), .D(pipe1[i]),  .RESET_B(~rst), .Q(pipe2[i]));
    sky130_fd_sc_hd__dfrtp_1 P3 (.CLK(clk), .D(pipe2[i]),  .RESET_B(~rst), .Q(pipe3[i]));
    sky130_fd_sc_hd__dfrtp_1 P4 (.CLK(clk), .D(pipe3[i]),  .RESET_B(~rst), .Q(pipe4[i]));

end
endgenerate

// =======================================================
// GLOBAL ENABLE LOGIC (High Fanout Net)
// =======================================================

sky130_fd_sc_hd__and2_1 G1 (.A(pipe4[0]), .B(pipe4[1]), .X(enable_global));
sky130_fd_sc_hd__buf_4  GBUF (.A(enable_global), .X(enable_global));

// =======================================================
// DMA ENGINE (Counter + Control)
// =======================================================

generate
for (i=0; i<8; i=i+1) begin : DMA_CNT

    sky130_fd_sc_hd__dfrtp_1 CNT (
        .CLK(clk),
        .D(dma_counter[i] ^ enable_global),
        .RESET_B(~rst),
        .Q(dma_counter[i])
    );

end
endgenerate

// =======================================================
// SRAM MACROS (Hard Macros)
// =======================================================

sky130_sram_32kbyte_1rw1r_1024x256_8 SRAM0 (
    .clk0(clk),
    .csb0(1'b0),
    .web0(1'b1),
    .addr0(dma_counter),
    .din0(pipe4),
    .dout0(mem0_out)
);

sky130_sram_32kbyte_1rw1r_1024x256_8 SRAM1 (
    .clk0(clk),
    .csb0(1'b0),
    .web0(1'b1),
    .addr0(dma_counter),
    .din0(mem0_out),
    .dout0(mem1_out)
);

// =======================================================
// ROM MACRO
// =======================================================

sky130_rom_16kbyte_512x256_8 ROM0 (
    .clk(clk),
    .addr(dma_counter),
    .data(dma_data)
);

// =======================================================
// OUTPUT MUX NETWORK
// =======================================================

generate
for (i=0; i<16; i=i+1) begin : OUTMUX

    sky130_fd_sc_hd__mux2_1 OM1 (
        .A0(mem1_out[i]),
        .A1(dma_data[i]),
        .S(enable_global),
        .X(Y[i])
    );

end
endgenerate

endmodule