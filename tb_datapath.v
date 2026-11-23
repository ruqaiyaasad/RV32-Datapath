module tb_datapath;
 reg clk=0,reset=0,PCSel=0,RegWEn=0,ASel=0,BSel=0;
 reg [2:0] ALUSel=0; reg [1:0] ImmSel=0,WBSel=0;
 wire [31:0] pc,inst,alu_result,wb,DataA,DataB,Imm,pc4,next_pc,alu_a,alu_b;
 wire BrEq,BrLT;
 datapath_top dut(clk,reset,PCSel,RegWEn,ASel,BSel,ALUSel,ImmSel,WBSel,
 pc,inst,alu_result,wb,BrEq,BrLT,DataA,DataB,Imm,pc4,next_pc,alu_a,alu_b);
 always #5 clk=~clk;
 initial begin
  reset=1;#12;reset=0;
  repeat(4) begin @(posedge clk);#1;$display("PC=%h INST=%h",pc,inst);end
  // Independent datapath path check: x0 + immediate 5
  ImmSel=0;BSel=1;ALUSel=0;ASel=0;#1;
  $display("DataA=%h Imm=%h ALUResult=%h",DataA,Imm,alu_result);
  $finish;
 end
endmodule
