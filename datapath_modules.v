module pc_reg(input clk,reset,input [31:0] next_pc,output reg [31:0] pc);
 always @(posedge clk or posedge reset) if(reset) pc<=0; else pc<=next_pc;
endmodule
module mux2_32(input [31:0] a,b,input sel,output [31:0] y);
 assign y=sel?b:a;
endmodule
module register_file32(input clk,reset,we,input [4:0] ra1,ra2,wa,
 input [31:0] wd,output [31:0] rd1,rd2);
 reg [31:0] r[0:31]; integer i;
 always @(posedge clk or posedge reset) begin
  if(reset) for(i=0;i<32;i=i+1) r[i]<=0;
  else if(we && wa!=0) r[wa]<=wd;
 end
 assign rd1=(ra1==0)?0:r[ra1]; assign rd2=(ra2==0)?0:r[ra2];
endmodule
module imm_gen(input [31:0] inst,input [1:0] imm_sel,output reg [31:0] imm);
 always @* begin
  case(imm_sel)
   2'b00: imm={{20{inst[31]}},inst[31:20]}; // I
   2'b01: imm={{20{inst[31]}},inst[31:25],inst[11:7]}; // S
   2'b10: imm={{19{inst[31]}},inst[31],inst[7],inst[30:25],inst[11:8],1'b0}; // B
   2'b11: imm={{11{inst[31]}},inst[31],inst[19:12],inst[20],inst[30:21],1'b0}; // J
  endcase
 end
endmodule
module alu32_dp(input [31:0] a,b,input [2:0] sel,output reg [31:0] y);
 always @* case(sel)
  3'b000:y=a+b;
  3'b001:y=a-b;
  3'b010:y=a&b;
  3'b011:y=a|b;
  3'b100:y=a^b;
  3'b101:y=($signed(a)<$signed(b))?1:0;
  default:y=0;
 endcase
endmodule
module branch_compare(input [31:0] a,b,output eq,lt);
 assign eq=(a==b); assign lt=($signed(a)<$signed(b));
endmodule
module instruction_memory(input [31:0] pc,output reg [31:0] inst);
 reg [31:0] rom[0:15]; integer i;
 initial begin
  for(i=0;i<16;i=i+1) rom[i]=32'h00000013;
  rom[0]=32'h00500093; // addi x1,x0,5
  rom[1]=32'h00300113; // addi x2,x0,3
  rom[2]=32'h002081B3; // add x3,x1,x2
  rom[3]=32'h40208233; // sub x4,x1,x2
 end
 always @* if(pc[5:2]<16) inst=rom[pc[5:2]]; else inst=32'h00000013;
endmodule
module datapath_top(
 input clk,reset,input PCSel,RegWEn,ASel,BSel,
 input [2:0] ALUSel,input [1:0] ImmSel,input [1:0] WBSel,
 output [31:0] pc,inst,alu_result,wb,output BrEq,BrLT,
 output [31:0] DataA,DataB,Imm,pc4,next_pc,alu_a,alu_b
);
 wire [31:0] target;
 assign pc4=pc+32'd4;
 instruction_memory im(pc,inst);
 pc_reg p(clk,reset,next_pc,pc);
 assign next_pc=PCSel?alu_result:pc4;
 register_file32 rf(clk,reset,RegWEn,inst[19:15],inst[24:20],inst[11:7],wb,DataA,DataB);
 imm_gen ig(inst,ImmSel,Imm);
 mux2_32 ma(DataA,pc,ASel,alu_a);
 mux2_32 mb(DataB,Imm,BSel,alu_b);
 alu32_dp alu(alu_a,alu_b,ALUSel,alu_result);
 branch_compare bc(DataA,DataB,BrEq,BrLT);
 assign wb=(WBSel==2'b01)?pc4:alu_result; // WBSel 00=ALU, 01=PC+4
endmodule
