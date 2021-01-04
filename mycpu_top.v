`timescale 1ns / 1ps
module mycpu_top(
    input  wire clk                    ,
    input  wire resetn                 ,
    input  wire int                    ,

    output wire         inst_sram_en           ,    //useless
    output wire [3:0]   inst_sram_wen          ,    //useless
    output wire [31:0]  inst_sram_addr         ,    //PCF
    output wire [31:0]  inst_sram_wdata        ,    //useless
    input  wire [31:0]  inst_sram_rdata        ,    //Inst

    output wire         data_sram_en           ,    //MemtoRegM | MemWriteM
    output wire [3:0]   data_sram_wen          ,    //Sel
    output wire [31:0]  data_sram_addr         ,    //ALUOutM
    output wire [31:0]  data_sram_wdata        ,    //WriteDataM
    input  wire [31:0]  data_sram_rdata        ,    //ReadDataM

    output wire [31:0]  debug_wb_pc            ,    //PCW
    output wire [3:0]   debug_wb_rf_wen        ,    //RegWriteW
    output wire [4:0]   debug_wb_rf_wnum       ,    //WriteRegW
    output wire [31:0]  debug_wb_rf_wdata           //ResultW
);


wire        RegWriteD;
wire [1:0]  DatatoRegD;
wire        MemWriteD;
wire [7:0]  ALUControlD;
wire        ALUSrcAD;
wire [1:0]  ALUSrcBD;
wire        RegDstD;
wire        JumpD;
wire        BranchD;


wire       JalD;
wire       JrD;
wire       BalD;

wire        HIWrite;
wire        LOWrite;
wire [1:0]  DatatoHID;
wire [1:0]  DatatoLOD;
wire        SignD;
wire        StartDivD;
wire        AnnulD;

wire        NoInst;
wire        Cp0Write, Cp0Read;

wire [5:0] Op;
wire [5:0] Funct;
wire [4:0] Rt, Rs;

wire [31:0] PCF, InstF;

wire        MemEn;
wire [3:0]  Sel;
wire [31:0] ALUOutM, WriteDataM, ReadDataM;

wire        RegWriteW;
wire [4:0]  WriteRegW;
wire [31:0] PCW, ResultW;

wire [39:0] ascii;
instdec id(InstF, ascii);

controller c(
    .Op(Op), 
    .Funct(Funct),
    .rt(Rt), .rs(Rs),
    .Jump(JumpD), 
    .RegWrite(RegWriteD), 
    .RegDst(RegDstD), 
    .ALUSrcA(ALUSrcAD), 
    .ALUSrcB(ALUSrcBD), 
    .Branch(BranchD), 
    .MemWrite(MemWriteD), 
    .DatatoReg(DatatoRegD), 
    .HIwrite(HIWrite), 
    .LOwrite(LOWrite),
    .DataToHI(DatatoHID), 
    .DataToLO(DatatoLOD), 
    .Sign(SignD), 
    .startDiv(StartDivD), 
    .annul(AnnulD),
    .ALUContr(ALUControlD),
    .jal(JalD), 
    .jr(JrD), 
    .bal(BalD)
    .Invalid(NoInst),
    .cp0Write(Cp0Write),
    .cp0Read(Cp0Read)
);

datapath dp(
    //--to sram--
    .clk(clk), .rst(resetn),
    .PCF(PCF), .InstF(InstF),
    
    .Op(Op), .Funct(Funct),
    .Rt(Rt), .Rs(Rs),
    .RegWriteD(RegWriteD),
    .DatatoRegD(DatatoRegD),
    .MemWriteD(MemWriteD),
    .ALUControlD(ALUControlD),
    .ALUSrcAD(ALUSrcAD),
    .ALUSrcBD(ALUSrcBD),
    .RegDstD(RegDstD),
    .JumpD(JumpD),
    .BranchD(BranchD),

    .JalD(JalD),
    .JrD(JrD),
    .BalD(BalD),

    .HIWriteD(HIWrite),
    .LOWriteD(LOWrite),
    .DatatoHID(DatatoHID),
    .DatatoLOD(DatatoLOD),
    .SignD(SignD),
    .StartDivD(StartDivD),
    .AnnulD(AnnulD),

    .Invalid(NoInst),
    .cp0Write(Cp0Write),
    .cp0Read(Cp0Read),
    //--to sram--
    .MemEn(MemEn),
    .Sel(Sel),
    .ALUOutM(ALUOutM),
    .WriteDataM(WriteDataM),
    .ReadDataM(ReadDataM),
    //--to sram--
    .PCW(PCW),
    .RegWriteW(RegWriteW),
    .WriteRegW(WriteRegW),
    .ResultW(ResultW)
);


assign inst_sram_en     = 1'b1;
assign inst_sram_wen    = 4'b0000;
assign inst_sram_addr   = PCF;
assign inst_sram_wdata  = 32'b0;
assign InstF            = inst_sram_rdata;

//inst_sram_rdata[31] ? {3'b0, inst_sram_rdata[28:0]} : inst_sram_rdata;
assign data_sram_en     = MemEn;
assign data_sram_wen    = Sel;
assign data_sram_addr   = ALUOutM[31] ? {3'b0, ALUOutM[28:0]} : ALUOutM;
//ALUOutM[31] ? {3'b0, ALUOutM[28:0]} : ALUOutM
assign data_sram_wdata  = WriteDataM;
assign ReadDataM        = data_sram_rdata;

assign debug_wb_pc             = PCW;
assign debug_wb_rf_wen         = {4{RegWriteW}};
assign debug_wb_rf_wnum        = WriteRegW;
assign debug_wb_rf_wdata       = ResultW;

endmodule