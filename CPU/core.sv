module core    (input logic         clk, reset,             //тактирующий сигнал, сигнал сброса
    output logic [31:0] PC,                     //адрес следующей команды
    input logic [31:0]  Instr,                  //текущая инструкция на выполнение
    output logic        MemWrite,               //сигнал разрешения записи в память
    output logic [31:0] ALUResult, WriteData,   //результат АЛУ (адрес для памяти данных), данные для записи
    input logic [31:0]  ReadData);              //считанные из памяти данные

logic       ALUSrc, RegWrite, Jump, Zero;
logic [1:0] ResultSrc, ImmSrc;
logic [2:0] ALUControl;

controller  c(Instr[6:0], Instr[14:12], Instr[30], 
      Zero, ResultSrc, MemWrite, PCSrc, 
      ALUSrc, RegWrite, Jump, ImmSrc, ALUControl);

datapath    dp(clk, reset, ResultSrc, PCSrc, ALUSrc, RegWrite, 
       ImmSrc, ALUControl, Zero, PC, Instr, ALUResult, 
       WriteData, ReadData);

endmodule