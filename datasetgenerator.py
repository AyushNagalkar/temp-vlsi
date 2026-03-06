import random

NUM_STD_CELLS = 50000
NUM_MACROS = 120
ALU_WIDTH = 256

UTILIZATION = 0.72

STD_CELL_AREA = 4
MACRO_AREA = 2500

total_area = NUM_STD_CELLS * STD_CELL_AREA + NUM_MACROS * MACRO_AREA
core_area = total_area / UTILIZATION

core_side = int(core_area ** 0.5)

die_margin = 200
die_side = core_side + die_margin

print("Core size:", core_side)
print("Die size:", die_side)

###################################################
# Generate Verilog Netlist
###################################################

with open("large_alu_netlist.v","w") as f:

    f.write("module large_alu(\n")
    f.write("input clk,\n")
    f.write("input rst,\n")
    f.write("input [{}:0] A,\n".format(ALU_WIDTH-1))
    f.write("input [{}:0] B,\n".format(ALU_WIDTH-1))
    f.write("output [{}:0] Y\n".format(ALU_WIDTH-1))
    f.write(");\n\n")

    f.write("wire [{}:0] carry;\n".format(ALU_WIDTH))

    for i in range(ALU_WIDTH):
        f.write("FA_X1 fa{} (.A(A[{}]), .B(B[{}]), .CI(carry[{}]), .S(Y[{}]), .CO(carry[{}]));\n".format(
            i,i,i,i,i,i+1
        ))

    for i in range(NUM_STD_CELLS):

        cell = random.choice(["AND2_X1","OR2_X1","XOR2_X1","INV_X1"])

        if cell == "INV_X1":

            f.write("{} U{} (.A(A[{}]), .Y(Y[{}]));\n".format(
                cell,i,random.randint(0,ALU_WIDTH-1),random.randint(0,ALU_WIDTH-1)
            ))

        else:

            f.write("{} U{} (.A(A[{}]), .B(B[{}]), .Y(Y[{}]));\n".format(
                cell,i,
                random.randint(0,ALU_WIDTH-1),
                random.randint(0,ALU_WIDTH-1),
                random.randint(0,ALU_WIDTH-1)
            ))

    for i in range(NUM_MACROS):

        f.write("MACRO_BLOCK M{} (.A(A), .B(B), .Y(Y));\n".format(i))

    f.write("endmodule\n")

###################################################
# Generate LEF
###################################################

with open("cells.lef","w") as f:

    f.write("VERSION 5.8 ;\n")
    f.write("UNITS DATABASE MICRONS 1000 ;\n")

    cells = ["AND2_X1","OR2_X1","XOR2_X1","INV_X1","FA_X1"]

    for cell in cells:

        f.write("MACRO {} \n".format(cell))
        f.write("CLASS CORE ;\n")
        f.write("SIZE 2 BY 2 ;\n")
        f.write("PIN A DIRECTION INPUT ; END A\n")
        f.write("PIN B DIRECTION INPUT ; END B\n")
        f.write("PIN Y DIRECTION OUTPUT ; END Y\n")
        f.write("END {}\n".format(cell))

    f.write("MACRO MACRO_BLOCK\n")
    f.write("CLASS BLOCK ;\n")
    f.write("SIZE 50 BY 50 ;\n")
    f.write("PIN A DIRECTION INPUT ; END A\n")
    f.write("PIN B DIRECTION INPUT ; END B\n")
    f.write("PIN Y DIRECTION OUTPUT ; END Y\n")
    f.write("END MACRO_BLOCK\n")

###################################################
# Generate DEF
###################################################

with open("layout.def","w") as f:

    f.write("VERSION 5.8 ;\n")
    f.write("DESIGN large_alu ;\n")
    f.write("UNITS DISTANCE MICRONS 1000 ;\n")

    f.write("DIEAREA ( 0 0 ) ( {} {} ) ;\n".format(die_side,die_side))

    f.write("COMPONENTS {} ;\n".format(NUM_STD_CELLS+NUM_MACROS))

    x = 0
    y = 0

    step = 10

    for i in range(NUM_STD_CELLS):

        f.write("- U{} AND2_X1 + PLACED ( {} {} ) N ;\n".format(i,x,y))

        x += step
        if x > core_side:
            x = 0
            y += step

    for i in range(NUM_MACROS):

        x = random.randint(0,core_side-100)
        y = random.randint(0,core_side-100)

        f.write("- M{} MACRO_BLOCK + PLACED ( {} {} ) N ;\n".format(i,x,y))

    f.write("END COMPONENTS\n")
    f.write("END DESIGN\n")