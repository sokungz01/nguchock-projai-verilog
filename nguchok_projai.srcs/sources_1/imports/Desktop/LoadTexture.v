`timescale 1ns / 1ps
module LoadTexture(
    input [9:0]X,
    input inputObj,
    input [19:0]data,
    output outObj
    );
    reg [5:0]Index;
    reg dataBit;
    initial begin
        dataBit = 0;
        Index = 19;
    end
    
    always @ (X) begin
        if(flag) begin
            
        end
    end
    
    assign outObj = dataBit & inputObj;
endmodule
