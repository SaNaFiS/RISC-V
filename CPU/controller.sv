//основной дешифратор
module maindec (input logic [6:0]   op,             //код операции (из архитектуры) 
                output logic [1:0]  ResultSrc,      //сигнал выбора результата (АЛУ, данные из памяти, PC (для команды jal))
                output logic        MemWrite,       //сигнал разрешения записи в память
                output logic        Branch, ALUSrc, //сигнал команды условного перехода, сигнал выбора входного сигнала на АЛУ (Imm или регистр)
                output logic        RegWrite, Jump, //сигнал разрешения записи в регстровый файл, сигнал команды безусловного перехода
                output logic [1:0]  ImmSrc,         //сигнал выбора битов для Imm (для расширения знака)
                output logic [1:0]  ALUOp);         //2-битовый сигнал операции на АЛУ (пойдет в дешифратор АЛУ)

    logic [10:0] controls;

    assign {RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, Branch, ALUOp, Jump} = controls;

    always_comb
        case(op)
            7'b0000011: controls = 11'b1_00_1_0_01_0_00_0; // lw
            7'b0100011: controls = 11'b0_01_1_1_00_0_00_0; // sw
            7'b0110011: controls = 11'b1_xx_0_0_00_0_10_0; // тип R
            7'b1100011: controls = 11'b0_10_0_0_00_1_01_0; // beq
            7'b0010011: controls = 11'b1_00_1_0_00_0_10_0; // тип I
            7'b1101111: controls = 11'b1_11_0_0_10_0_00_1; // jal
            default: controls = 11'bx_xx_x_x_xx_x_xx_x;    // ???
        endcase

endmodule

module aludec  (input logic         opb5,           //5й бит кода операции
                input logic [2:0]   funct3,         //3-битовая функция
                input logic         funct7b5,       //5й бит 7-ми битовой функции
                input logic [1:0]   ALUOp,          //2-битовый сигнал операции на АЛУ
                output logic [2:0]  ALUControl);    //3-битовый сигнал операции на АЛУ (пойдет непосредственно в АЛУ)

    logic RtypeSub;

    assign RtypeSub = funct7b5 & opb5;
    
    always_comb
        case(ALUOp)
            2'b00:  ALUControl = 3'b000;
            2'b01:  ALUControl = 3'b001;
            default: case(funct3)
                        3'b000: if (RtypeSub)
                                    ALUControl = 3'b001; // sub
                                else
                                    ALUControl = 3'b000; // add, addi
                        3'b010: ALUControl = 3'b101;     // slt, slti
                        3'b110: ALUControl = 3'b011;     // or, ori
                        3'b111: ALUControl = 3'b010;     // and, andi
                        default: ALUControl = 3'bxxx;    // ???

                     endcase
        endcase

endmodule


module controller  (input logic [6:0]   op,
                    input logic [2:0]   funct3,
                    input logic         funct7b5,
                    input logic         Zero,
                    output logic [1:0]  ResultSrc,
                    output logic        MemWrite,
                    output logic        PCSrc, ALUSrc,
                    output logic        RegWrite, Jump,
                    output logic [1:0]  ImmSrc,
                    output logic [2:0]  ALUControl);

    logic [1:0] ALUOp;
    logic       Branch;

    maindec     md(op, ResultSrc, MemWrite, Branch, ALUSrc, RegWrite, Jump, ImmSrc, ALUOp);

    aludec      ad(op[5], funct3, funct7b5, ALUOp, ALUControl);

    assign PCSrc = Branch & Zero | Jump;

endmodule