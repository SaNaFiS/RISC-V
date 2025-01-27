module regfile (input logic         clk,        // тактовый сигнал
    input logic         we,         // сигнал разрешения записи
    input logic [4:0]   A1, A2, A3, // шины адресов (1,2 - на чтение; 3 - на запись)
    input logic [31:0]  WriteData,  // шина ввода
    output logic [31:0] RD1, RD2);  // шины вывода
logic [31:0] rf[31:0];

always (@posedge clk)                       // запись по переднему фронту
if (we) rf[A3] <= WriteData;

assign RD1 = (A1 != 0) ? rf[A1] : 0;
assign RD2 = (A2 != 0) ? rf[A2] : 0;
endmodule;


//АЛУ для выполнения and, or, add, sub, slt(без переполнения)
module alu (input logic [31:0]  A, B,
input logic [2:0]   ALUControl,
output logic [31:0] ALUResult,
output logic        Zero);

logic [31:0] invB;
logic [31:0] srcB;
logic [31:0] addResult;
logic [31:0] zeroExt;
logic [31:0] andAB;
logic [31:0] orAB;

assign invB = !B;

mux2 #(32) bmux(B, invB, ALUControl[0], srcB);

adder      aluadd(A, srcB, addResult);

assign zeroExt = {31'b0, addResult[31]};

assign andAB = A & B;

assign orAB = A | B;

mux5 #(32) resultmux(addResult, addResult, andAB, orAB, zeroExt, ALUControl, ALUResult);


assign Zero = !(&ALUResult);

endmodule;


module datapath(input logic         clk, reset,     // тактовый сигнал, сигнал сброса
    input logic[1:0]    ResultSrc,      // сигнал выбора результата 
    input logic         PCSrc, ALUSrc,  // сигналы управления мультиплексорами (источник счетчика команд, источник АЛУ)
    input logic         RegWrite,       // сигнал записи в регистровый файл
    input logic[1:0]    ImmSrc,         // сигнал управления расширителем знака
    input logic[2:0]    ALUControl,     // сигнал выбора операции на АЛУ
    output logic        Zero,           // флаг нулевого результата
    output logic[31:0]  PC,             // адрес следующей инструкции
    input logic[31:0]   Instr,          // текущая инструкция
    output logic[31:0]  ALUResult,      // результат АЛУ
                        WriteData,      // данные для записи
    input logic[31:0]   ReadData );     // считанные данные из памяти

logic [31:0] PCNext, PCPlus4, PCTarget;
logic [31:0] ImmExt;
logic [31:0] SrcA, SrcB;
logic [31:0] Result;

//PC
flopr #(32) pcreg(clk, reset, PCNext, PC);          //регистр команд (счетчик команд)
adder       pcadd4(PC, 32'd4, PCPlus4);             //прибавление к адресу 4 байта
adder       pcaddbranch(PC, ImmExt, PCTarget);      //прибавление к адресу смещения (команда beq/j)
mux2  #(32) pcmux(PCPlus4, PCTarget, PCSrc, PCNext);//мультиплексор выбора следующей команды

//regfile
regfile     rf(clk, RegWrite, Instr[19:15], Instr[24:20], Instr[11:7], Result, SrcA, WriteData);

extend      ext(Instr[31:7], ImmSrc, ImmExt); //расширитель знака

//АЛУ
mux2  #(32) srcbmux(WriteData, ImmExt, ALUSrc, SrcB); //мультиплексор для выбора входного значения АЛУ

alu         alu(SrcA, SrcB, ALUControl, ALUResult, Zero); //АЛУ

mux3  #(32) resultmux(ALUResult, ReadData, PCPlus4, ResultSrc, Result); //мультиплексор для выбора результата выполнения инструкции

endmodule;