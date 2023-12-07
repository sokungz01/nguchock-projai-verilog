`timescale 1ns / 1ps
module PixelGeneration(
    input VGAClock,
    input isDead,
    input isStart,
    input video_on,
    input [5:0]obj,
    output reg [11:0]RGB_COLORS,
//    output [19:0]Data,
//    output rawApple,dataBit,
    output reg [5:0] Index
    );
    parameter TEXT                  = 12'hFFF;
    parameter DEAD_BACKGROUND       = 12'hF66;
    parameter START_GAME_BACKGROUND = 12'h8DE;
    parameter SNAKE_BODY_COLOR      = 12'h8A8;
    parameter SNAKE_HEAD_COLOR      = 12'h454;
    parameter APPLE_COLOR           = 12'hF00;
    parameter BACKGROUND_COLOR      = 12'h8DE; 
    
    reg [11:0]objColor[4:0];
    reg appleBit;
    
    initial begin
        RGB_COLORS  = 12'h000;
        appleBit    = 0;
        Index       = 19;
        objColor[0] = BACKGROUND_COLOR;
        objColor[1] = TEXT;
        objColor[2] = SNAKE_HEAD_COLOR;
        objColor[3] = SNAKE_BODY_COLOR;
        objColor[4] = APPLE_COLOR;
//        appleData = 20'b00011110011001111100;
    end
    
//    Texture AppleTexture(
//        .inputObj(obj[3]),
//        .Items(4'b0001),
//        .data(appleData)
//    );
    
//    assign Data = appleData;
//    assign rawApple = obj[3];
//    assign mappingApple = obj[3] | appleBit;a
//    assign dataBit = appleBit;
    
//    always @ (posedge VGAClock) begin
//        if(rawApple && video_on) begin
//            if(Index == 0) begin
//                Index  <= 19;
//            end else begin
//                appleBit <= appleData[Index];
//                Index   <= Index-1;
//            end
//        end else begin
//            appleBit <= 0;
//            Index <= 19;
//        end
//    end
    
    always @ * begin
        if(~video_on) begin
            RGB_COLORS <= 12'h000;
        end
        else if (isStart) begin
            if(obj[2]) begin
                RGB_COLORS <= objColor[1];
            end
            else begin
                RGB_COLORS <= objColor[0];
            end
        end 
        else if (isDead) begin
            if(obj[1]) begin
                RGB_COLORS <= objColor[1];
            end
            else begin
                RGB_COLORS <= objColor[0];
            end
        end 
        else begin
            if(obj[4]) begin
                RGB_COLORS <= objColor[4];
            end
            else if(obj[3]) begin
                RGB_COLORS <= objColor[3];
            end
            else if(obj[0]) begin
                RGB_COLORS <= objColor[0];
            end
            else begin
                RGB_COLORS <= 12'hfff;
            end
        end

    end
endmodule
