`timescale 1ns / 1ps
module SnakeBody #(parameter WIDTH = 10,SNAKE_MAX_SIZE = 64) (
    input switchClock,isCollision,video_on,VGAClock,
    input [1:0]direction,
    input [9:0]X,Y,SnakeHeadX,SnakeHeadY,
    input [6:0]SnakeSize,
    input RESET,
    input isDead,
    output reg snakeBody,
    output reg [9:0]SnakeOUTX,SnakeOUTY
);
    parameter D_LEFT                = 2'b00;
    parameter D_RIGHT               = 2'b01;
    parameter D_UP                  = 2'b10;
    parameter D_DOWN                = 2'b11;
    reg [9:0]SnakeX[0:63],SnakeY[0:63];
    integer SnakeBodyIndex;
    integer SnakeBodyIndex2;

    initial begin
        snakeBody = 0;
        SnakeX[0] = 0;
        SnakeY[0] = 0;
        for(SnakeBodyIndex = 0 ; SnakeBodyIndex < SNAKE_MAX_SIZE; SnakeBodyIndex = SnakeBodyIndex + 1) begin
            SnakeX[SnakeBodyIndex] = 0; 
            SnakeY[SnakeBodyIndex] = 0; 
        end
    end    
    
    
    always @ (posedge switchClock) begin
         if(RESET || isDead) begin
            for(SnakeBodyIndex = 0 ; SnakeBodyIndex < SNAKE_MAX_SIZE; SnakeBodyIndex = SnakeBodyIndex + 1) begin
                SnakeX[SnakeBodyIndex] <= 0; 
                SnakeY[SnakeBodyIndex] <= 0; 
            end 
        end
        else if(SnakeSize - 1 > 0) begin
            for(SnakeBodyIndex = SNAKE_MAX_SIZE - 1 ; SnakeBodyIndex > 0; SnakeBodyIndex = SnakeBodyIndex - 1) begin
                if(SnakeBodyIndex <= SnakeSize) begin
                    SnakeX[SnakeBodyIndex] <= SnakeX[SnakeBodyIndex - 1]; 
                    SnakeY[SnakeBodyIndex] <= SnakeY[SnakeBodyIndex - 1]; 
                end
            end 
            case (direction)
                D_LEFT  : SnakeX[0] <= (SnakeX[0] - (WIDTH * 2));
                D_RIGHT : SnakeX[0] <= (SnakeX[0] + (WIDTH * 2));
                D_UP    : SnakeY[0] <= (SnakeY[0] - (WIDTH * 2));
                D_DOWN  : SnakeY[0] <= (SnakeY[0] + (WIDTH * 2));
                default : begin
                    SnakeX[0] = SnakeHeadX;
                    SnakeY[0] = SnakeHeadY;
                end
            endcase
        end
        else begin
            SnakeX[0] = SnakeHeadX;
            SnakeY[0] = SnakeHeadY;
        end
    end
    
    always @ (*) begin
//        for(SnakeBodyIndex2 = 0; SnakeBodyIndex2 < SnakeSize ; SnakeBodyIndex2 = SnakeBodyIndex2 + 1) begin
//        snakeBody <= (X >= SnakeX[0] && X <= SnakeX[0] - 1 + (WIDTH * 2)  && Y >= SnakeY[0] &&  Y <= SnakeY[0] - 1 + (WIDTH * 2));
        SnakeOUTX <= SnakeX[0];
        SnakeOUTY <= SnakeY[0];
//        end
    end
    
endmodule
