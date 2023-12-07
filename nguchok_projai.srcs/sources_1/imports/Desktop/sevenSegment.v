`timescale 1ns / 1ps
module sevenSegment(
    input Clock,
    input [9:0]Count,
    input Reset,
    output [6:0]sevenSegment,
    output reg [3:0]Anode_Activate
    );
    reg [6:0]seg;
    reg [19:0]Counter;
    reg [3:0]Number;
    wire [1:0]LED_activating_counter;
    initial Counter = 0;
    always @(posedge Clock or posedge Reset)
    begin 
        if(Reset==1)
            Counter <= 0;
        else
            Counter <= Counter + 1;
    end 
    assign LED_activating_counter = Counter[19:18];
    always @ * begin
        case(LED_activating_counter)
        2'b00: begin
            Anode_Activate = 4'b0111; 
            Number = 0;
              end
        2'b01: begin
            Anode_Activate = 4'b1011; 
            Number = 0;
              end
        2'b10: begin
            Anode_Activate = 4'b1101; 
            Number = ((Count % 1000)%100)/10;
            end
       2'b11: begin
            Anode_Activate = 4'b1110; 
            Number = ((Count % 1000)%100)%10;
           end
        endcase
        case (Number)
            0 : seg <= 7'b1000000;
            1 : seg <= 7'b1111001;
            2 : seg <= 7'b0100100;
            3 : seg <= 7'b0110000;
            4 : seg <= 7'b0011001;
            5 : seg <= 7'b0010010;
            6 : seg <= 7'b0000010;
            7 : seg <= 7'b1111000;
            8 : seg <= 7'b0000000;
            9 : seg <= 7'b0010000;
            default : seg <= 7'b100000; 
        endcase
    end
    assign sevenSegment = seg;
endmodule
