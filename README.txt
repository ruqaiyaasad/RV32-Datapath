LAB 10 - RV32 DATAPATH
This solution implements the Lab 10 module specification, not an instruction decoder.
Control signals (PCSel, RegWEn, ASel, BSel, ALUSel, ImmSel, WBSel) are external inputs.
Included blocks: PC register, PC+4, PC mux, small instruction ROM, 32x32 register file,
I/S/B/J immediate generator, signed branch comparator, operand muxes, ALU and writeback mux.
ALU encoding: 000 ADD, 001 SUB, 010 AND, 011 OR, 100 XOR, 101 signed SLT.
ImmSel: 00 I, 01 S, 10 B, 11 J.
ASel: 0 DataA, 1 PC. BSel: 0 DataB, 1 Imm. PCSel: 0 PC+4, 1 ALU target.
WBSel: 00 ALU result, 01 PC+4. Memory writeback is not implemented as the manual says
it is not required in the directed tests. IMEM contains a small sample program.
Compile:
vlib work
vlog datapath_modules.v tb_datapath.v
vsim work.tb_datapath
add wave *
run -all
IMPORTANT: This is a datapath-only implementation. It deliberately does not decode
instruction opcodes into controls, and it does not include data memory/control unit.
The top-level controls must be driven by the testbench or external control unit.
The testbench is a starter directed simulation, not full integration verification.
Task 2 also asks for a Logisim circuit and systematic module testing; create that circuit
separately in Logisim.
