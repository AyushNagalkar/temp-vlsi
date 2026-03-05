// 4-bit Ripple Carry Adder
// Technology: Sky130A
// Library: sky130_fd_sc_hd (High Density)

module adder4_sky130 (
    input  [3:0] A,
    input  [3:0] B,
    input        Cin,
    output [3:0] Sum,
    output       Cout
);

wire c1, c2, c3;
wire s1_0, s1_1, s1_2, s1_3;
wire a1_0, a1_1, a1_2, a1_3;
wire a2_0, a2_1, a2_2, a2_3;

// ----------------------
// Bit 0
// ----------------------
sky130_fd_sc_hd__xor2_1 U1  (.A(A[0]), .B(B[0]), .X(s1_0));
sky130_fd_sc_hd__xor2_1 U2  (.A(s1_0), .B(Cin), .X(Sum[0]));
sky130_fd_sc_hd__and2_1 U3  (.A(A[0]), .B(B[0]), .X(a1_0));
sky130_fd_sc_hd__and2_1 U4  (.A(s1_0), .B(Cin), .X(a2_0));
sky130_fd_sc_hd__or2_1  U5  (.A(a1_0), .B(a2_0), .X(c1));

// ----------------------
// Bit 1
// ----------------------
sky130_fd_sc_hd__xor2_1 U6  (.A(A[1]), .B(B[1]), .X(s1_1));
sky130_fd_sc_hd__xor2_1 U7  (.A(s1_1), .B(c1),   .X(Sum[1]));
sky130_fd_sc_hd__and2_1 U8  (.A(A[1]), .B(B[1]), .X(a1_1));
sky130_fd_sc_hd__and2_1 U9  (.A(s1_1), .B(c1),   .X(a2_1));
sky130_fd_sc_hd__or2_1  U10 (.A(a1_1), .B(a2_1), .X(c2));

// ----------------------
// Bit 2
// ----------------------
sky130_fd_sc_hd__xor2_1 U11 (.A(A[2]), .B(B[2]), .X(s1_2));
sky130_fd_sc_hd__xor2_1 U12 (.A(s1_2), .B(c2),   .X(Sum[2]));
sky130_fd_sc_hd__and2_1 U13 (.A(A[2]), .B(B[2]), .X(a1_2));
sky130_fd_sc_hd__and2_1 U14 (.A(s1_2), .B(c2),   .X(a2_2));
sky130_fd_sc_hd__or2_1  U15 (.A(a1_2), .B(a2_2), .X(c3));

// ----------------------
// Bit 3
// ----------------------
sky130_fd_sc_hd__xor2_1 U16 (.A(A[3]), .B(B[3]), .X(s1_3));
sky130_fd_sc_hd__xor2_1 U17 (.A(s1_3), .B(c3),   .X(Sum[3]));
sky130_fd_sc_hd__and2_1 U18 (.A(A[3]), .B(B[3]), .X(a1_3));
sky130_fd_sc_hd__and2_1 U19 (.A(s1_3), .B(c3),   .X(a2_3));
sky130_fd_sc_hd__or2_1  U20 (.A(a1_3), .B(a2_3), .X(Cout));

endmodule