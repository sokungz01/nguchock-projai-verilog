`timescale 1ns / 1ps
module Texture(
    input inputObj,
    input [3:0]Items,
    output reg [19:0]data
    );
    parameter WIDTH = 20;
    reg [6:0]Query;
    reg [5:0]Index;
    reg dataBit;
    
    initial begin
        dataBit = 0;
        Query   = 0;
        data    = 20'b00000000000000000000;
    end
    
    always @ (posedge inputObj) begin
        if(Query == Items * WIDTH - 1)begin
            Query = (Items - 1) * WIDTH;
            data <= 20'b00000000000000000000;
        end else begin
            case(Query) 
                10'd00: data <= 20'b00000000000000000000;
                10'd01: data <= 20'b00000000110110000000;
                10'd02: data <= 20'b00000000011100000000;
                10'd03: data <= 20'b00000000001000000000;
                10'd04: data <= 20'b00000000111110000000;
                10'd05: data <= 20'b00000011111111100000;
                10'd06: data <= 20'b00000111111111110000;
                10'd07: data <= 20'b00001111111111111000;
                10'd08: data <= 20'b00001110011001111000;
                10'd09: data <= 20'b00011110011001111100;
                10'd10: data <= 20'b00011110011001111100;
                10'd11: data <= 20'b00011111111111111100;
                10'd12: data <= 20'b00011111111111111100;
                10'd13: data <= 20'b00011111111111111100;
                10'd14: data <= 20'b00001111111111111000;
                10'd15: data <= 20'b00001111111111111000;
                10'd16: data <= 20'b00000111111111110000;
                10'd17: data <= 20'b00000011111111100000;
                10'd18: data <= 20'b00000000111110000000;
                10'd19: data <= 20'b00000000000000000000;
                default data <= 20'b00000000000000000000;
            endcase
            Query <= Query + 1;
        end
    end
endmodule
