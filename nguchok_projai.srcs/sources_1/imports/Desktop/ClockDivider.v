`timescale 1ns / 1ps
module ClockDivider(
    input clock,
    input [31:0]dividerBy,
    output reg new_clock
);  
    reg [20:0]count;
    initial begin
        new_clock = 0;
        count = 1;
    end
    always @ (posedge clock) begin
        count <= count + 1; 
        if(count == dividerBy)
           begin
                new_clock <= ~new_clock;
                count <= 1;
           end
    end
endmodule
