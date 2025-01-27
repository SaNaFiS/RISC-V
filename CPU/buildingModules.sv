//32-битный сумматор (без Carry)
module adder       (input [31:0] a, b, 
                    output [31:0] c);
    assign c = a + b;
endmodule;


//расширение знака (в зависимости от команды)
module extend      (input logic [31:7]  instr,
                    input logic [1:0]   immsrc,
                    output logic [31:0] immext);

    always_comb
        case(immsrc)
            2'b00: immext = {{20{instr[31]}},instr[31:20]}; //I тип

            2'b01: immext = {{20{instr[31]}},instr[31:25],instr[11:7]}; //тип S (запись в память)

            2'b10: immext = {{20{instr[31]}},instr[7],instr[30:25],instr[11:8],1'b0}; //тип B (условный переход)

            2'b11: immext = {{20{instr[31]}},instr[19:12],instr[20],instr[30:21],1'b0}; //тип J (jal)

            default: immext = 32'bx;
        endcase
endmodule;


//тригер с сигналом сброса
module flopr      #(parameter WIDTH = 8)
                   (input logic clk, reset,
                    input logic [WIDTH-1:0] d,
                    output logic [WIDTH-1:0] q);

    always_ff @(posedge clk, posedge reset)
        if (reset) q <= 0;
        else q <= d;

endmodule;


//триггер с сигналом сброса и входом выбора
module flopenr    #(parameter WIDTH = 8)
                   (input logic clk, reset, en,
                    input logic [WIDTH-1:0] d,
                    output logic [WIDTH-1:0] q);

    always_ff @(posedge clk, posedge reset)
        if (reset) q <= 0;
        else if (en) q <= d;
        
endmodule;


//двухвходовый мультиплексор
module mux2       #(parameter WIDTH = 8)
                   (input logic [WIDTH-1:0]     d0,d1,
                    input logic                 s,
                    output logic [WIDTH-1:0]    y);  

    assign y = s ? d1 : d0;

endmodule;

//трехвходвый мультиплексор
module mux3       #(parameter WIDTH = 8)
                   (input logic [WIDTH-1:0]     d0,d1,d2,
                    input logic [1:0]           s,
                    output logic [WIDTH-1:0]    y);  

    assign y = s[1] ? d2 : (s[0] ? d1 : d0);

endmodule;

//пятивходовый мультиплексор
module mux5       #(parameter WIDTH = 8)
                   (input logic [WIDTH-1:0] do,d1,d2,d3,d4,
                    input logic [1:0]       s,
                    output logic [WIDTH-1:0] y);

    assign y = s[2] ? d4 : (s[1] ? (s[0] ? d3 : d2) : (s[0] ? d1 : d0));

endmodule;