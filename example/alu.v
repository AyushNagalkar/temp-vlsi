module alu_top (
    input  [31:0] A,
    input  [31:0] B,
    input  [3:0]  opcode,
    input         clk,
    input         rst,
    output [31:0] Y
);

wire [31:0] add_out;
wire [31:0] sub_out;
wire [31:0] and_out;
wire [31:0] or_out;
wire [31:0] xor_out;
wire [31:0] mul_out;
wire [31:0] div_out;

wire carry_chain [32:0];

assign carry_chain[0] = 1'b0;

//////////////////////////////////////////////////////
// ADDER MACRO INSTANCES
//////////////////////////////////////////////////////

genvar i;
generate
for(i=0;i<32;i=i+1) begin : ADDER_CHAIN

    FA_X1 U_FA (
        .A(A[i]),
        .B(B[i]),
        .CI(carry_chain[i]),
        .S(add_out[i]),
        .CO(carry_chain[i+1])
    );

end
endgenerate

//////////////////////////////////////////////////////
// SUBTRACTOR
//////////////////////////////////////////////////////

wire [31:0] B_INV;

generate
for(i=0;i<32;i=i+1) begin : SUB_INV

    INV_X1 U_INV (
        .A(B[i]),
        .Y(B_INV[i])
    );

end
endgenerate

wire sub_carry [32:0];
assign sub_carry[0] = 1'b1;

generate
for(i=0;i<32;i=i+1) begin : SUB_CHAIN

    FA_X1 U_SUB_FA (
        .A(A[i]),
        .B(B_INV[i]),
        .CI(sub_carry[i]),
        .S(sub_out[i]),
        .CO(sub_carry[i+1])
    );

end
endgenerate

//////////////////////////////////////////////////////
// LOGIC OPERATIONS
//////////////////////////////////////////////////////

generate
for(i=0;i<32;i=i+1) begin : LOGIC_BLOCK

    AND2_X1 U_AND (
        .A(A[i]),
        .B(B[i]),
        .Y(and_out[i])
    );

    OR2_X1 U_OR (
        .A(A[i]),
        .B(B[i]),
        .Y(or_out[i])
    );

    XOR2_X1 U_XOR (
        .A(A[i]),
        .B(B[i]),
        .Y(xor_out[i])
    );

end
endgenerate

//////////////////////////////////////////////////////
// MULTIPLIER MACRO
//////////////////////////////////////////////////////

MULT_MACRO U_MULT (
    .A(A),
    .B(B),
    .P(mul_out)
);

//////////////////////////////////////////////////////
// DIVIDER MACRO
//////////////////////////////////////////////////////

DIV_MACRO U_DIV (
    .A(A),
    .B(B),
    .Q(div_out)
);

//////////////////////////////////////////////////////
// RESULT MUX
//////////////////////////////////////////////////////

generate
for(i=0;i<32;i=i+1) begin : RESULT_MUX

    MUX4_X1 U_MUX (
        .A(add_out[i]),
        .B(sub_out[i]),
        .C(and_out[i]),
        .D(or_out[i]),
        .S(opcode[1:0]),
        .Y(Y[i])
    );

end
endgenerate

endmodule