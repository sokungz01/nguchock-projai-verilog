`timescale 1ns / 1ps
module Counter(
    input Clock,
    input [6:0]maxSize,
    input Reset,
    output reg [6:0]Counter
    );
    
    initial Counter = 0;
    
    always @ (posedge Clock) begin
        Counter <= Counter + 1;
        if( Reset || Counter == maxSize) Counter <= 0;
    end
    
endmodule
