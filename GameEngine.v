`timescale 1ns / 1ps
module GameEngine(
       input switchClock,
       input UP,DOWN,LEFT,RIGHT,RESET,ENTER,GAMEMODE,DIFFICULTY,
       input [9:0]X,Y,
       output reg isDead,isStart,
       output reg [9:0]SnakeCount,
       output wire field,snakeBody,apple,DeadText,StartText
    );
    
    parameter D_LEFT                = 3'b000;
    parameter D_RIGHT               = 3'b001;
    parameter D_UP                  = 3'b010;
    parameter D_DOWN                = 3'b011;
    parameter D_NULL                = 3'b111;
    
    parameter WIDTH                 = 10;
    parameter MIN_WIDTH             = 20;
    parameter MIN_HEIGHT            = 20;
    parameter MAX_WIDTH             = 620;
    parameter MAX_HEIGHT            = 460;
    parameter INIT_SNAKE            = 640;
    parameter SNAKE_INIT_SIZE       = 1;
    parameter SNAKE_MAX_SIZE        = 1024;
    parameter SNAKE_START_POINT_X   = 320;
    parameter SNAKE_START_POINT_Y   = 240;    
    parameter APPLE_START_POINT_X   = 400;
    parameter APPLE_START_POINT_Y   = 200;
    parameter EASY                  = 4;
    parameter HARD                  = 2;
    
    
    reg [3:0]moveDivide;
    reg snakeBodyReg;
    reg isMove;
    reg [3:0]MOD;
//    reg isDead;
    reg isCollision;
    reg found;
    reg [2:0]direction;
    reg [6:0]SnakeSize = SNAKE_INIT_SIZE;
    reg [9:0]AppleX,AppleY;
    reg [9:0]OldAppleX,OldAppleY;
    reg [9:0]SnakeX[1023:0];
    reg [9:0]SnakeY[1023:0];

    integer SnakeBodyIndex;
    integer i;

    initial begin
        isStart     = 1;
        isDead      = 0;
        isMove      = 0;
        found       = 0;  
        isCollision = 0;
        SnakeCount  = 0;
        moveDivide  = 0;
        MOD         = 0;
        SnakeSize   = SNAKE_INIT_SIZE;
        snakeBodyReg = 0;
        direction   = D_NULL;
        for(SnakeBodyIndex = 1 ; SnakeBodyIndex < SNAKE_MAX_SIZE; SnakeBodyIndex = SnakeBodyIndex + 1) begin
              SnakeX[SnakeBodyIndex] <= INIT_SNAKE; 
         end 
        SnakeX[0]   = SNAKE_START_POINT_X; 
        SnakeY[0]   = SNAKE_START_POINT_Y; 
        AppleX      = APPLE_START_POINT_X;
        AppleY      = APPLE_START_POINT_Y;

    end

    always @ (posedge switchClock) begin 
        if(isStart) begin
            if(ENTER) begin
                isStart <= 0 ;
            end
            MOD <= DIFFICULTY ? EASY : HARD;
        end
        else begin
            moveDivide <= moveDivide + 1;
            if(moveDivide == 4'b1111)
            begin 
                moveDivide <= 0;
            end
            if(RESET) begin
                isMove      <= 0;
                isDead      <= 0;
                SnakeCount  <= 0;
                moveDivide  <= 0;
                isStart     <= 1;
                direction   <= D_NULL;
                SnakeSize   <= SNAKE_INIT_SIZE;
                AppleX      <= APPLE_START_POINT_X;
                AppleY      <= APPLE_START_POINT_Y;
               for(SnakeBodyIndex = 1 ; SnakeBodyIndex < SNAKE_MAX_SIZE; SnakeBodyIndex = SnakeBodyIndex + 1) begin
                     SnakeX[SnakeBodyIndex] <= INIT_SNAKE; 
                     SnakeY[SnakeBodyIndex] <= INIT_SNAKE; 
                end 
                SnakeX[0]   <= SNAKE_START_POINT_X;
                SnakeY[0]   <= SNAKE_START_POINT_Y;
            end 
            else if (isDead) begin
                if(ENTER) begin
                    isDead      <= 0;
                end
               direction   <= D_NULL;
                isMove      <= 0;
                moveDivide  <= 0;
                SnakeSize   <= SNAKE_INIT_SIZE;
                AppleX      <= APPLE_START_POINT_X;
                AppleY      <= APPLE_START_POINT_Y;
                for(SnakeBodyIndex = 1 ; SnakeBodyIndex < SNAKE_MAX_SIZE; SnakeBodyIndex = SnakeBodyIndex + 1) begin
                     SnakeX[SnakeBodyIndex] <= INIT_SNAKE; 
                     SnakeY[SnakeBodyIndex] <= INIT_SNAKE; 
                end 
                SnakeX[0]   <= SNAKE_START_POINT_X;
                SnakeY[0]   <= SNAKE_START_POINT_Y;
               
            end
            else if(isCollision) begin
                isCollision <= 0;
                SnakeCount  <= SnakeCount  + 1;
                SnakeSize   <= SnakeSize   + 1;
                AppleX      <= MIN_WIDTH  + (SnakeX[0] * OldAppleY + 20) % MAX_WIDTH     - (WIDTH * 2);
                AppleY      <= MIN_HEIGHT + (SnakeY[0] * OldAppleX - 20) % MAX_HEIGHT    - (WIDTH * 2);
            end
            else if(isMove == 0 && (RIGHT || LEFT || UP || DOWN)) begin
                SnakeCount  <= 0;
                isMove <= 1;
            end
            else if(RIGHT && direction != D_LEFT)   direction <= D_RIGHT;
            else if(LEFT  && direction != D_RIGHT)  direction <= D_LEFT;
            else if(UP    && direction != D_DOWN)   direction <= D_UP;
            else if(DOWN  && direction != D_UP)     direction <= D_DOWN;
            if(moveDivide%MOD == 0 ) begin // mod mak snake slow, mod noi snake fast
                if(isMove && direction == D_LEFT)         SnakeX[0] <= SnakeX[0] - (WIDTH * 2);
                else if(isMove && direction == D_RIGHT)   SnakeX[0] <= SnakeX[0] + (WIDTH * 2);
                else if(isMove && direction == D_UP)      SnakeY[0] <= SnakeY[0] - (WIDTH * 2);
                else if(isMove && direction == D_DOWN)    SnakeY[0] <= SnakeY[0] + (WIDTH * 2);
                if(SnakeSize > 1) begin
                    for(SnakeBodyIndex = SNAKE_MAX_SIZE - 1 ; SnakeBodyIndex > 0 ; SnakeBodyIndex = SnakeBodyIndex - 1 )begin
                        if(SnakeBodyIndex < SnakeSize) begin
                            SnakeX[SnakeBodyIndex] <= SnakeX[SnakeBodyIndex-1];
                            SnakeY[SnakeBodyIndex] <= SnakeY[SnakeBodyIndex-1];
                        end
                    end
                end
            end
           
            if(
                ( (SnakeX[0] - AppleX < (WIDTH * 2)  && (SnakeY[0] - AppleY < (WIDTH * 2)) )  ||
                ( (AppleX - SnakeX[0] < (WIDTH*2))   && (SnakeY[0] - AppleY < (WIDTH * 2)) )
            ))
            begin 
                isCollision     <= 1;
                OldAppleX       <= AppleX;
                OldAppleY       <= AppleY;
                AppleX          <= INIT_SNAKE;
                AppleY          <= 0;
            end
            
            if(
                (
                (SnakeX[0] == 0)  ||
                (MAX_WIDTH - SnakeX[0] < (WIDTH * 2))  ||
                (SnakeY[0] == 0)  ||
                (MAX_HEIGHT - SnakeY[0] < (WIDTH * 2))
                )
                && ~GAMEMODE
            )
            begin
                    isDead <= 1;
            end
            if(GAMEMODE) begin
                
                if(SnakeX[0] == 0) begin
                    SnakeX[0] <= 600;
                end 
                else if(SnakeX[0] >= 620  ) begin
                    SnakeX[0] <= 20;
                end 
                else if( SnakeY[0] == 0 ) begin
                        SnakeY[0] <= 440;              
                end 
                else if(SnakeY[0] == 460 ) begin
                        SnakeY[0] <= 20;                 
                end
                
                
            end 
            for(i=4; i<SNAKE_MAX_SIZE; i = i+1)begin
                if(SnakeX[0] - SnakeX[i] < (WIDTH * 2) && SnakeY[0] - SnakeY[i] < (WIDTH * 2)) begin
                    isDead <= 1;
                end
            end
        
        end
    end
    

    
//    assign snakeHead =  (~isDead && ~isStart) ? (  (X >= SnakeX[0]  && X <= SnakeX[0] - 1 + (WIDTH * 2)) && (Y >= SnakeY[0] && Y <= SnakeY[0] - 1 + (WIDTH *2))  ) : 0;
    assign snakeBody =  (~isDead && ~isStart) ? (    
                            (X >= SnakeX[0]  && X <= SnakeX[0] - 1 + (WIDTH * 2)) && (Y >= SnakeY[0] && Y <= SnakeY[0] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[1]  && X <= SnakeX[1] - 1 + (WIDTH * 2)) && (Y >= SnakeY[1] && Y <= SnakeY[1] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[2]  && X <= SnakeX[2] - 1 + (WIDTH * 2)) && (Y >= SnakeY[2] && Y <= SnakeY[2] - 1 + (WIDTH *2)) ||  
                            (X >= SnakeX[3]  && X <= SnakeX[3] - 1 + (WIDTH * 2)) && (Y >= SnakeY[3] && Y <= SnakeY[3] - 1 + (WIDTH *2)) ||  
                            (X >= SnakeX[4]  && X <= SnakeX[4] - 1 + (WIDTH * 2)) && (Y >= SnakeY[4] && Y <= SnakeY[4] - 1 + (WIDTH *2)) ||  
                            (X >= SnakeX[5]  && X <= SnakeX[5] - 1 + (WIDTH * 2)) && (Y >= SnakeY[5] && Y <= SnakeY[5] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[6]  && X <= SnakeX[6] - 1 + (WIDTH * 2)) && (Y >= SnakeY[6] && Y <= SnakeY[6] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[7]  && X <= SnakeX[7] - 1 + (WIDTH * 2)) && (Y >= SnakeY[7] && Y <= SnakeY[7] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[8]  && X <= SnakeX[8] - 1 + (WIDTH * 2)) && (Y >= SnakeY[8] && Y <= SnakeY[8] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[9]  && X <= SnakeX[9] - 1 + (WIDTH * 2)) && (Y >= SnakeY[9] && Y <= SnakeY[9] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[10]  && X <= SnakeX[10] - 1 + (WIDTH * 2)) && (Y >= SnakeY[10] && Y <= SnakeY[10] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[11]  && X <= SnakeX[11] - 1 + (WIDTH * 2)) && (Y >= SnakeY[11] && Y <= SnakeY[11] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[12]  && X <= SnakeX[12] - 1 + (WIDTH * 2)) && (Y >= SnakeY[12] && Y <= SnakeY[12] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[13]  && X <= SnakeX[13] - 1 + (WIDTH * 2)) && (Y >= SnakeY[13] && Y <= SnakeY[13] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[14]  && X <= SnakeX[14] - 1 + (WIDTH * 2)) && (Y >= SnakeY[14] && Y <= SnakeY[14] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[15]  && X <= SnakeX[15] - 1 + (WIDTH * 2)) && (Y >= SnakeY[15] && Y <= SnakeY[15] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[16]  && X <= SnakeX[16] - 1 + (WIDTH * 2)) && (Y >= SnakeY[16] && Y <= SnakeY[16] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[17]  && X <= SnakeX[17] - 1 + (WIDTH * 2)) && (Y >= SnakeY[17] && Y <= SnakeY[17] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[18]  && X <= SnakeX[18] - 1 + (WIDTH * 2)) && (Y >= SnakeY[18] && Y <= SnakeY[18] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[19]  && X <= SnakeX[19] - 1 + (WIDTH * 2)) && (Y >= SnakeY[19] && Y <= SnakeY[19] - 1 + (WIDTH *2)) || 
                            (X >= SnakeX[20]  && X <= SnakeX[20] - 1 + (WIDTH * 2)) && (Y >= SnakeY[20] && Y <= SnakeY[20] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[21]  && X <= SnakeX[21] - 1 + (WIDTH * 2)) && (Y >= SnakeY[21] && Y <= SnakeY[21] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[22]  && X <= SnakeX[22] - 1 + (WIDTH * 2)) && (Y >= SnakeY[22] && Y <= SnakeY[22] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[23]  && X <= SnakeX[23] - 1 + (WIDTH * 2)) && (Y >= SnakeY[23] && Y <= SnakeY[23] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[24]  && X <= SnakeX[24] - 1 + (WIDTH * 2)) && (Y >= SnakeY[24] && Y <= SnakeY[24] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[25]  && X <= SnakeX[25] - 1 + (WIDTH * 2)) && (Y >= SnakeY[25] && Y <= SnakeY[25] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[26]  && X <= SnakeX[26] - 1 + (WIDTH * 2)) && (Y >= SnakeY[26] && Y <= SnakeY[26] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[27]  && X <= SnakeX[27] - 1 + (WIDTH * 2)) && (Y >= SnakeY[27] && Y <= SnakeY[27] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[28]  && X <= SnakeX[28] - 1 + (WIDTH * 2)) && (Y >= SnakeY[28] && Y <= SnakeY[28] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[29]  && X <= SnakeX[29] - 1 + (WIDTH * 2)) && (Y >= SnakeY[29] && Y <= SnakeY[29] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[30]  && X <= SnakeX[30] - 1 + (WIDTH * 2)) && (Y >= SnakeY[30] && Y <= SnakeY[30] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[31]  && X <= SnakeX[31] - 1 + (WIDTH * 2)) && (Y >= SnakeY[31] && Y <= SnakeY[31] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[32]  && X <= SnakeX[32] - 1 + (WIDTH * 2)) && (Y >= SnakeY[32] && Y <= SnakeY[32] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[33]  && X <= SnakeX[33] - 1 + (WIDTH * 2)) && (Y >= SnakeY[33] && Y <= SnakeY[33] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[34]  && X <= SnakeX[34] - 1 + (WIDTH * 2)) && (Y >= SnakeY[34] && Y <= SnakeY[34] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[35]  && X <= SnakeX[35] - 1 + (WIDTH * 2)) && (Y >= SnakeY[35] && Y <= SnakeY[35] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[36]  && X <= SnakeX[36] - 1 + (WIDTH * 2)) && (Y >= SnakeY[36] && Y <= SnakeY[36] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[37]  && X <= SnakeX[37] - 1 + (WIDTH * 2)) && (Y >= SnakeY[37] && Y <= SnakeY[37] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[38]  && X <= SnakeX[38] - 1 + (WIDTH * 2)) && (Y >= SnakeY[38] && Y <= SnakeY[38] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[39]  && X <= SnakeX[39] - 1 + (WIDTH * 2)) && (Y >= SnakeY[39] && Y <= SnakeY[39] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[40]  && X <= SnakeX[40] - 1 + (WIDTH * 2)) && (Y >= SnakeY[40] && Y <= SnakeY[40] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[41]  && X <= SnakeX[41] - 1 + (WIDTH * 2)) && (Y >= SnakeY[41] && Y <= SnakeY[41] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[42]  && X <= SnakeX[42] - 1 + (WIDTH * 2)) && (Y >= SnakeY[42] && Y <= SnakeY[42] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[43]  && X <= SnakeX[43] - 1 + (WIDTH * 2)) && (Y >= SnakeY[43] && Y <= SnakeY[43] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[44]  && X <= SnakeX[44] - 1 + (WIDTH * 2)) && (Y >= SnakeY[44] && Y <= SnakeY[44] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[45]  && X <= SnakeX[45] - 1 + (WIDTH * 2)) && (Y >= SnakeY[45] && Y <= SnakeY[45] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[46]  && X <= SnakeX[46] - 1 + (WIDTH * 2)) && (Y >= SnakeY[46] && Y <= SnakeY[46] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[47]  && X <= SnakeX[47] - 1 + (WIDTH * 2)) && (Y >= SnakeY[47] && Y <= SnakeY[47] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[48]  && X <= SnakeX[48] - 1 + (WIDTH * 2)) && (Y >= SnakeY[48] && Y <= SnakeY[48] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[49]  && X <= SnakeX[49] - 1 + (WIDTH * 2)) && (Y >= SnakeY[49] && Y <= SnakeY[49] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[50]  && X <= SnakeX[50] - 1 + (WIDTH * 2)) && (Y >= SnakeY[50] && Y <= SnakeY[50] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[51]  && X <= SnakeX[51] - 1 + (WIDTH * 2)) && (Y >= SnakeY[51] && Y <= SnakeY[51] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[52]  && X <= SnakeX[52] - 1 + (WIDTH * 2)) && (Y >= SnakeY[52] && Y <= SnakeY[52] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[53]  && X <= SnakeX[53] - 1 + (WIDTH * 2)) && (Y >= SnakeY[53] && Y <= SnakeY[53] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[54]  && X <= SnakeX[54] - 1 + (WIDTH * 2)) && (Y >= SnakeY[54] && Y <= SnakeY[54] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[55]  && X <= SnakeX[55] - 1 + (WIDTH * 2)) && (Y >= SnakeY[55] && Y <= SnakeY[55] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[56]  && X <= SnakeX[56] - 1 + (WIDTH * 2)) && (Y >= SnakeY[56] && Y <= SnakeY[56] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[57]  && X <= SnakeX[57] - 1 + (WIDTH * 2)) && (Y >= SnakeY[57] && Y <= SnakeY[57] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[58]  && X <= SnakeX[58] - 1 + (WIDTH * 2)) && (Y >= SnakeY[58] && Y <= SnakeY[58] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[59]  && X <= SnakeX[59] - 1 + (WIDTH * 2)) && (Y >= SnakeY[59] && Y <= SnakeY[59] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[60]  && X <= SnakeX[60] - 1 + (WIDTH * 2)) && (Y >= SnakeY[60] && Y <= SnakeY[60] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[61]  && X <= SnakeX[61] - 1 + (WIDTH * 2)) && (Y >= SnakeY[61] && Y <= SnakeY[61] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[62]  && X <= SnakeX[62] - 1 + (WIDTH * 2)) && (Y >= SnakeY[62] && Y <= SnakeY[62] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[63]  && X <= SnakeX[63] - 1 + (WIDTH * 2)) && (Y >= SnakeY[63] && Y <= SnakeY[63] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[64]  && X <= SnakeX[64] - 1 + (WIDTH * 2)) && (Y >= SnakeY[64] && Y <= SnakeY[64] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[65]  && X <= SnakeX[65] - 1 + (WIDTH * 2)) && (Y >= SnakeY[65] && Y <= SnakeY[65] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[66]  && X <= SnakeX[66] - 1 + (WIDTH * 2)) && (Y >= SnakeY[66] && Y <= SnakeY[66] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[67]  && X <= SnakeX[67] - 1 + (WIDTH * 2)) && (Y >= SnakeY[67] && Y <= SnakeY[67] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[68]  && X <= SnakeX[68] - 1 + (WIDTH * 2)) && (Y >= SnakeY[68] && Y <= SnakeY[68] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[69]  && X <= SnakeX[69] - 1 + (WIDTH * 2)) && (Y >= SnakeY[69] && Y <= SnakeY[69] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[70]  && X <= SnakeX[70] - 1 + (WIDTH * 2)) && (Y >= SnakeY[70] && Y <= SnakeY[70] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[71]  && X <= SnakeX[71] - 1 + (WIDTH * 2)) && (Y >= SnakeY[71] && Y <= SnakeY[71] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[72]  && X <= SnakeX[72] - 1 + (WIDTH * 2)) && (Y >= SnakeY[72] && Y <= SnakeY[72] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[73]  && X <= SnakeX[73] - 1 + (WIDTH * 2)) && (Y >= SnakeY[73] && Y <= SnakeY[73] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[74]  && X <= SnakeX[74] - 1 + (WIDTH * 2)) && (Y >= SnakeY[74] && Y <= SnakeY[74] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[75]  && X <= SnakeX[75] - 1 + (WIDTH * 2)) && (Y >= SnakeY[75] && Y <= SnakeY[75] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[76]  && X <= SnakeX[76] - 1 + (WIDTH * 2)) && (Y >= SnakeY[76] && Y <= SnakeY[76] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[77]  && X <= SnakeX[77] - 1 + (WIDTH * 2)) && (Y >= SnakeY[77] && Y <= SnakeY[77] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[78]  && X <= SnakeX[78] - 1 + (WIDTH * 2)) && (Y >= SnakeY[78] && Y <= SnakeY[78] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[79]  && X <= SnakeX[79] - 1 + (WIDTH * 2)) && (Y >= SnakeY[79] && Y <= SnakeY[79] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[80]  && X <= SnakeX[80] - 1 + (WIDTH * 2)) && (Y >= SnakeY[80] && Y <= SnakeY[80] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[81]  && X <= SnakeX[81] - 1 + (WIDTH * 2)) && (Y >= SnakeY[81] && Y <= SnakeY[81] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[82]  && X <= SnakeX[82] - 1 + (WIDTH * 2)) && (Y >= SnakeY[82] && Y <= SnakeY[82] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[83]  && X <= SnakeX[83] - 1 + (WIDTH * 2)) && (Y >= SnakeY[83] && Y <= SnakeY[83] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[84]  && X <= SnakeX[84] - 1 + (WIDTH * 2)) && (Y >= SnakeY[84] && Y <= SnakeY[84] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[85]  && X <= SnakeX[85] - 1 + (WIDTH * 2)) && (Y >= SnakeY[85] && Y <= SnakeY[85] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[86]  && X <= SnakeX[86] - 1 + (WIDTH * 2)) && (Y >= SnakeY[86] && Y <= SnakeY[86] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[87]  && X <= SnakeX[87] - 1 + (WIDTH * 2)) && (Y >= SnakeY[87] && Y <= SnakeY[87] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[88]  && X <= SnakeX[88] - 1 + (WIDTH * 2)) && (Y >= SnakeY[88] && Y <= SnakeY[88] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[89]  && X <= SnakeX[89] - 1 + (WIDTH * 2)) && (Y >= SnakeY[89] && Y <= SnakeY[89] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[90]  && X <= SnakeX[90] - 1 + (WIDTH * 2)) && (Y >= SnakeY[90] && Y <= SnakeY[90] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[91]  && X <= SnakeX[91] - 1 + (WIDTH * 2)) && (Y >= SnakeY[91] && Y <= SnakeY[91] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[92]  && X <= SnakeX[92] - 1 + (WIDTH * 2)) && (Y >= SnakeY[92] && Y <= SnakeY[92] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[93]  && X <= SnakeX[93] - 1 + (WIDTH * 2)) && (Y >= SnakeY[93] && Y <= SnakeY[93] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[94]  && X <= SnakeX[94] - 1 + (WIDTH * 2)) && (Y >= SnakeY[94] && Y <= SnakeY[94] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[95]  && X <= SnakeX[95] - 1 + (WIDTH * 2)) && (Y >= SnakeY[95] && Y <= SnakeY[95] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[96]  && X <= SnakeX[96] - 1 + (WIDTH * 2)) && (Y >= SnakeY[96] && Y <= SnakeY[96] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[97]  && X <= SnakeX[97] - 1 + (WIDTH * 2)) && (Y >= SnakeY[97] && Y <= SnakeY[97] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[98]  && X <= SnakeX[98] - 1 + (WIDTH * 2)) && (Y >= SnakeY[98] && Y <= SnakeY[98] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[99]  && X <= SnakeX[99] - 1 + (WIDTH * 2)) && (Y >= SnakeY[99] && Y <= SnakeY[99] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[100]  && X <= SnakeX[100] - 1 + (WIDTH * 2)) && (Y >= SnakeY[100] && Y <= SnakeY[100] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[101]  && X <= SnakeX[101] - 1 + (WIDTH * 2)) && (Y >= SnakeY[101] && Y <= SnakeY[101] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[102]  && X <= SnakeX[102] - 1 + (WIDTH * 2)) && (Y >= SnakeY[102] && Y <= SnakeY[102] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[103]  && X <= SnakeX[103] - 1 + (WIDTH * 2)) && (Y >= SnakeY[103] && Y <= SnakeY[103] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[104]  && X <= SnakeX[104] - 1 + (WIDTH * 2)) && (Y >= SnakeY[104] && Y <= SnakeY[104] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[105]  && X <= SnakeX[105] - 1 + (WIDTH * 2)) && (Y >= SnakeY[105] && Y <= SnakeY[105] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[106]  && X <= SnakeX[106] - 1 + (WIDTH * 2)) && (Y >= SnakeY[106] && Y <= SnakeY[106] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[107]  && X <= SnakeX[107] - 1 + (WIDTH * 2)) && (Y >= SnakeY[107] && Y <= SnakeY[107] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[108]  && X <= SnakeX[108] - 1 + (WIDTH * 2)) && (Y >= SnakeY[108] && Y <= SnakeY[108] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[109]  && X <= SnakeX[109] - 1 + (WIDTH * 2)) && (Y >= SnakeY[109] && Y <= SnakeY[109] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[110]  && X <= SnakeX[110] - 1 + (WIDTH * 2)) && (Y >= SnakeY[110] && Y <= SnakeY[110] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[111]  && X <= SnakeX[111] - 1 + (WIDTH * 2)) && (Y >= SnakeY[111] && Y <= SnakeY[111] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[112]  && X <= SnakeX[112] - 1 + (WIDTH * 2)) && (Y >= SnakeY[112] && Y <= SnakeY[112] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[113]  && X <= SnakeX[113] - 1 + (WIDTH * 2)) && (Y >= SnakeY[113] && Y <= SnakeY[113] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[114]  && X <= SnakeX[114] - 1 + (WIDTH * 2)) && (Y >= SnakeY[114] && Y <= SnakeY[114] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[115]  && X <= SnakeX[115] - 1 + (WIDTH * 2)) && (Y >= SnakeY[115] && Y <= SnakeY[115] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[116]  && X <= SnakeX[116] - 1 + (WIDTH * 2)) && (Y >= SnakeY[116] && Y <= SnakeY[116] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[117]  && X <= SnakeX[117] - 1 + (WIDTH * 2)) && (Y >= SnakeY[117] && Y <= SnakeY[117] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[118]  && X <= SnakeX[118] - 1 + (WIDTH * 2)) && (Y >= SnakeY[118] && Y <= SnakeY[118] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[119]  && X <= SnakeX[119] - 1 + (WIDTH * 2)) && (Y >= SnakeY[119] && Y <= SnakeY[119] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[120]  && X <= SnakeX[120] - 1 + (WIDTH * 2)) && (Y >= SnakeY[120] && Y <= SnakeY[120] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[121]  && X <= SnakeX[121] - 1 + (WIDTH * 2)) && (Y >= SnakeY[121] && Y <= SnakeY[121] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[122]  && X <= SnakeX[122] - 1 + (WIDTH * 2)) && (Y >= SnakeY[122] && Y <= SnakeY[122] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[123]  && X <= SnakeX[123] - 1 + (WIDTH * 2)) && (Y >= SnakeY[123] && Y <= SnakeY[123] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[124]  && X <= SnakeX[124] - 1 + (WIDTH * 2)) && (Y >= SnakeY[124] && Y <= SnakeY[124] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[125]  && X <= SnakeX[125] - 1 + (WIDTH * 2)) && (Y >= SnakeY[125] && Y <= SnakeY[125] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[126]  && X <= SnakeX[126] - 1 + (WIDTH * 2)) && (Y >= SnakeY[126] && Y <= SnakeY[126] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[127]  && X <= SnakeX[127] - 1 + (WIDTH * 2)) && (Y >= SnakeY[127] && Y <= SnakeY[127] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[128]  && X <= SnakeX[128] - 1 + (WIDTH * 2)) && (Y >= SnakeY[128] && Y <= SnakeY[128] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[129]  && X <= SnakeX[129] - 1 + (WIDTH * 2)) && (Y >= SnakeY[129] && Y <= SnakeY[129] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[130]  && X <= SnakeX[130] - 1 + (WIDTH * 2)) && (Y >= SnakeY[130] && Y <= SnakeY[130] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[131]  && X <= SnakeX[131] - 1 + (WIDTH * 2)) && (Y >= SnakeY[131] && Y <= SnakeY[131] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[132]  && X <= SnakeX[132] - 1 + (WIDTH * 2)) && (Y >= SnakeY[132] && Y <= SnakeY[132] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[133]  && X <= SnakeX[133] - 1 + (WIDTH * 2)) && (Y >= SnakeY[133] && Y <= SnakeY[133] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[134]  && X <= SnakeX[134] - 1 + (WIDTH * 2)) && (Y >= SnakeY[134] && Y <= SnakeY[134] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[135]  && X <= SnakeX[135] - 1 + (WIDTH * 2)) && (Y >= SnakeY[135] && Y <= SnakeY[135] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[136]  && X <= SnakeX[136] - 1 + (WIDTH * 2)) && (Y >= SnakeY[136] && Y <= SnakeY[136] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[137]  && X <= SnakeX[137] - 1 + (WIDTH * 2)) && (Y >= SnakeY[137] && Y <= SnakeY[137] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[138]  && X <= SnakeX[138] - 1 + (WIDTH * 2)) && (Y >= SnakeY[138] && Y <= SnakeY[138] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[139]  && X <= SnakeX[139] - 1 + (WIDTH * 2)) && (Y >= SnakeY[139] && Y <= SnakeY[139] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[140]  && X <= SnakeX[140] - 1 + (WIDTH * 2)) && (Y >= SnakeY[140] && Y <= SnakeY[140] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[141]  && X <= SnakeX[141] - 1 + (WIDTH * 2)) && (Y >= SnakeY[141] && Y <= SnakeY[141] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[142]  && X <= SnakeX[142] - 1 + (WIDTH * 2)) && (Y >= SnakeY[142] && Y <= SnakeY[142] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[143]  && X <= SnakeX[143] - 1 + (WIDTH * 2)) && (Y >= SnakeY[143] && Y <= SnakeY[143] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[144]  && X <= SnakeX[144] - 1 + (WIDTH * 2)) && (Y >= SnakeY[144] && Y <= SnakeY[144] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[145]  && X <= SnakeX[145] - 1 + (WIDTH * 2)) && (Y >= SnakeY[145] && Y <= SnakeY[145] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[146]  && X <= SnakeX[146] - 1 + (WIDTH * 2)) && (Y >= SnakeY[146] && Y <= SnakeY[146] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[147]  && X <= SnakeX[147] - 1 + (WIDTH * 2)) && (Y >= SnakeY[147] && Y <= SnakeY[147] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[148]  && X <= SnakeX[148] - 1 + (WIDTH * 2)) && (Y >= SnakeY[148] && Y <= SnakeY[148] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[149]  && X <= SnakeX[149] - 1 + (WIDTH * 2)) && (Y >= SnakeY[149] && Y <= SnakeY[149] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[150]  && X <= SnakeX[150] - 1 + (WIDTH * 2)) && (Y >= SnakeY[150] && Y <= SnakeY[150] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[151]  && X <= SnakeX[151] - 1 + (WIDTH * 2)) && (Y >= SnakeY[151] && Y <= SnakeY[151] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[152]  && X <= SnakeX[152] - 1 + (WIDTH * 2)) && (Y >= SnakeY[152] && Y <= SnakeY[152] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[153]  && X <= SnakeX[153] - 1 + (WIDTH * 2)) && (Y >= SnakeY[153] && Y <= SnakeY[153] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[154]  && X <= SnakeX[154] - 1 + (WIDTH * 2)) && (Y >= SnakeY[154] && Y <= SnakeY[154] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[155]  && X <= SnakeX[155] - 1 + (WIDTH * 2)) && (Y >= SnakeY[155] && Y <= SnakeY[155] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[156]  && X <= SnakeX[156] - 1 + (WIDTH * 2)) && (Y >= SnakeY[156] && Y <= SnakeY[156] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[157]  && X <= SnakeX[157] - 1 + (WIDTH * 2)) && (Y >= SnakeY[157] && Y <= SnakeY[157] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[158]  && X <= SnakeX[158] - 1 + (WIDTH * 2)) && (Y >= SnakeY[158] && Y <= SnakeY[158] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[159]  && X <= SnakeX[159] - 1 + (WIDTH * 2)) && (Y >= SnakeY[159] && Y <= SnakeY[159] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[160]  && X <= SnakeX[160] - 1 + (WIDTH * 2)) && (Y >= SnakeY[160] && Y <= SnakeY[160] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[161]  && X <= SnakeX[161] - 1 + (WIDTH * 2)) && (Y >= SnakeY[161] && Y <= SnakeY[161] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[162]  && X <= SnakeX[162] - 1 + (WIDTH * 2)) && (Y >= SnakeY[162] && Y <= SnakeY[162] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[163]  && X <= SnakeX[163] - 1 + (WIDTH * 2)) && (Y >= SnakeY[163] && Y <= SnakeY[163] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[164]  && X <= SnakeX[164] - 1 + (WIDTH * 2)) && (Y >= SnakeY[164] && Y <= SnakeY[164] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[165]  && X <= SnakeX[165] - 1 + (WIDTH * 2)) && (Y >= SnakeY[165] && Y <= SnakeY[165] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[166]  && X <= SnakeX[166] - 1 + (WIDTH * 2)) && (Y >= SnakeY[166] && Y <= SnakeY[166] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[167]  && X <= SnakeX[167] - 1 + (WIDTH * 2)) && (Y >= SnakeY[167] && Y <= SnakeY[167] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[168]  && X <= SnakeX[168] - 1 + (WIDTH * 2)) && (Y >= SnakeY[168] && Y <= SnakeY[168] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[169]  && X <= SnakeX[169] - 1 + (WIDTH * 2)) && (Y >= SnakeY[169] && Y <= SnakeY[169] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[170]  && X <= SnakeX[170] - 1 + (WIDTH * 2)) && (Y >= SnakeY[170] && Y <= SnakeY[170] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[171]  && X <= SnakeX[171] - 1 + (WIDTH * 2)) && (Y >= SnakeY[171] && Y <= SnakeY[171] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[172]  && X <= SnakeX[172] - 1 + (WIDTH * 2)) && (Y >= SnakeY[172] && Y <= SnakeY[172] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[173]  && X <= SnakeX[173] - 1 + (WIDTH * 2)) && (Y >= SnakeY[173] && Y <= SnakeY[173] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[174]  && X <= SnakeX[174] - 1 + (WIDTH * 2)) && (Y >= SnakeY[174] && Y <= SnakeY[174] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[175]  && X <= SnakeX[175] - 1 + (WIDTH * 2)) && (Y >= SnakeY[175] && Y <= SnakeY[175] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[176]  && X <= SnakeX[176] - 1 + (WIDTH * 2)) && (Y >= SnakeY[176] && Y <= SnakeY[176] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[177]  && X <= SnakeX[177] - 1 + (WIDTH * 2)) && (Y >= SnakeY[177] && Y <= SnakeY[177] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[178]  && X <= SnakeX[178] - 1 + (WIDTH * 2)) && (Y >= SnakeY[178] && Y <= SnakeY[178] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[179]  && X <= SnakeX[179] - 1 + (WIDTH * 2)) && (Y >= SnakeY[179] && Y <= SnakeY[179] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[180]  && X <= SnakeX[180] - 1 + (WIDTH * 2)) && (Y >= SnakeY[180] && Y <= SnakeY[180] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[181]  && X <= SnakeX[181] - 1 + (WIDTH * 2)) && (Y >= SnakeY[181] && Y <= SnakeY[181] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[182]  && X <= SnakeX[182] - 1 + (WIDTH * 2)) && (Y >= SnakeY[182] && Y <= SnakeY[182] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[183]  && X <= SnakeX[183] - 1 + (WIDTH * 2)) && (Y >= SnakeY[183] && Y <= SnakeY[183] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[184]  && X <= SnakeX[184] - 1 + (WIDTH * 2)) && (Y >= SnakeY[184] && Y <= SnakeY[184] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[185]  && X <= SnakeX[185] - 1 + (WIDTH * 2)) && (Y >= SnakeY[185] && Y <= SnakeY[185] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[186]  && X <= SnakeX[186] - 1 + (WIDTH * 2)) && (Y >= SnakeY[186] && Y <= SnakeY[186] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[187]  && X <= SnakeX[187] - 1 + (WIDTH * 2)) && (Y >= SnakeY[187] && Y <= SnakeY[187] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[188]  && X <= SnakeX[188] - 1 + (WIDTH * 2)) && (Y >= SnakeY[188] && Y <= SnakeY[188] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[189]  && X <= SnakeX[189] - 1 + (WIDTH * 2)) && (Y >= SnakeY[189] && Y <= SnakeY[189] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[190]  && X <= SnakeX[190] - 1 + (WIDTH * 2)) && (Y >= SnakeY[190] && Y <= SnakeY[190] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[191]  && X <= SnakeX[191] - 1 + (WIDTH * 2)) && (Y >= SnakeY[191] && Y <= SnakeY[191] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[192]  && X <= SnakeX[192] - 1 + (WIDTH * 2)) && (Y >= SnakeY[192] && Y <= SnakeY[192] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[193]  && X <= SnakeX[193] - 1 + (WIDTH * 2)) && (Y >= SnakeY[193] && Y <= SnakeY[193] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[194]  && X <= SnakeX[194] - 1 + (WIDTH * 2)) && (Y >= SnakeY[194] && Y <= SnakeY[194] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[195]  && X <= SnakeX[195] - 1 + (WIDTH * 2)) && (Y >= SnakeY[195] && Y <= SnakeY[195] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[196]  && X <= SnakeX[196] - 1 + (WIDTH * 2)) && (Y >= SnakeY[196] && Y <= SnakeY[196] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[197]  && X <= SnakeX[197] - 1 + (WIDTH * 2)) && (Y >= SnakeY[197] && Y <= SnakeY[197] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[198]  && X <= SnakeX[198] - 1 + (WIDTH * 2)) && (Y >= SnakeY[198] && Y <= SnakeY[198] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[199]  && X <= SnakeX[199] - 1 + (WIDTH * 2)) && (Y >= SnakeY[199] && Y <= SnakeY[199] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[200]  && X <= SnakeX[200] - 1 + (WIDTH * 2)) && (Y >= SnakeY[200] && Y <= SnakeY[200] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[201]  && X <= SnakeX[201] - 1 + (WIDTH * 2)) && (Y >= SnakeY[201] && Y <= SnakeY[201] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[202]  && X <= SnakeX[202] - 1 + (WIDTH * 2)) && (Y >= SnakeY[202] && Y <= SnakeY[202] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[203]  && X <= SnakeX[203] - 1 + (WIDTH * 2)) && (Y >= SnakeY[203] && Y <= SnakeY[203] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[204]  && X <= SnakeX[204] - 1 + (WIDTH * 2)) && (Y >= SnakeY[204] && Y <= SnakeY[204] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[205]  && X <= SnakeX[205] - 1 + (WIDTH * 2)) && (Y >= SnakeY[205] && Y <= SnakeY[205] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[206]  && X <= SnakeX[206] - 1 + (WIDTH * 2)) && (Y >= SnakeY[206] && Y <= SnakeY[206] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[207]  && X <= SnakeX[207] - 1 + (WIDTH * 2)) && (Y >= SnakeY[207] && Y <= SnakeY[207] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[208]  && X <= SnakeX[208] - 1 + (WIDTH * 2)) && (Y >= SnakeY[208] && Y <= SnakeY[208] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[209]  && X <= SnakeX[209] - 1 + (WIDTH * 2)) && (Y >= SnakeY[209] && Y <= SnakeY[209] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[210]  && X <= SnakeX[210] - 1 + (WIDTH * 2)) && (Y >= SnakeY[210] && Y <= SnakeY[210] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[211]  && X <= SnakeX[211] - 1 + (WIDTH * 2)) && (Y >= SnakeY[211] && Y <= SnakeY[211] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[212]  && X <= SnakeX[212] - 1 + (WIDTH * 2)) && (Y >= SnakeY[212] && Y <= SnakeY[212] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[213]  && X <= SnakeX[213] - 1 + (WIDTH * 2)) && (Y >= SnakeY[213] && Y <= SnakeY[213] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[214]  && X <= SnakeX[214] - 1 + (WIDTH * 2)) && (Y >= SnakeY[214] && Y <= SnakeY[214] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[215]  && X <= SnakeX[215] - 1 + (WIDTH * 2)) && (Y >= SnakeY[215] && Y <= SnakeY[215] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[216]  && X <= SnakeX[216] - 1 + (WIDTH * 2)) && (Y >= SnakeY[216] && Y <= SnakeY[216] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[217]  && X <= SnakeX[217] - 1 + (WIDTH * 2)) && (Y >= SnakeY[217] && Y <= SnakeY[217] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[218]  && X <= SnakeX[218] - 1 + (WIDTH * 2)) && (Y >= SnakeY[218] && Y <= SnakeY[218] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[219]  && X <= SnakeX[219] - 1 + (WIDTH * 2)) && (Y >= SnakeY[219] && Y <= SnakeY[219] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[220]  && X <= SnakeX[220] - 1 + (WIDTH * 2)) && (Y >= SnakeY[220] && Y <= SnakeY[220] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[221]  && X <= SnakeX[221] - 1 + (WIDTH * 2)) && (Y >= SnakeY[221] && Y <= SnakeY[221] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[222]  && X <= SnakeX[222] - 1 + (WIDTH * 2)) && (Y >= SnakeY[222] && Y <= SnakeY[222] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[223]  && X <= SnakeX[223] - 1 + (WIDTH * 2)) && (Y >= SnakeY[223] && Y <= SnakeY[223] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[224]  && X <= SnakeX[224] - 1 + (WIDTH * 2)) && (Y >= SnakeY[224] && Y <= SnakeY[224] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[225]  && X <= SnakeX[225] - 1 + (WIDTH * 2)) && (Y >= SnakeY[225] && Y <= SnakeY[225] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[226]  && X <= SnakeX[226] - 1 + (WIDTH * 2)) && (Y >= SnakeY[226] && Y <= SnakeY[226] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[227]  && X <= SnakeX[227] - 1 + (WIDTH * 2)) && (Y >= SnakeY[227] && Y <= SnakeY[227] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[228]  && X <= SnakeX[228] - 1 + (WIDTH * 2)) && (Y >= SnakeY[228] && Y <= SnakeY[228] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[229]  && X <= SnakeX[229] - 1 + (WIDTH * 2)) && (Y >= SnakeY[229] && Y <= SnakeY[229] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[230]  && X <= SnakeX[230] - 1 + (WIDTH * 2)) && (Y >= SnakeY[230] && Y <= SnakeY[230] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[231]  && X <= SnakeX[231] - 1 + (WIDTH * 2)) && (Y >= SnakeY[231] && Y <= SnakeY[231] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[232]  && X <= SnakeX[232] - 1 + (WIDTH * 2)) && (Y >= SnakeY[232] && Y <= SnakeY[232] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[233]  && X <= SnakeX[233] - 1 + (WIDTH * 2)) && (Y >= SnakeY[233] && Y <= SnakeY[233] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[234]  && X <= SnakeX[234] - 1 + (WIDTH * 2)) && (Y >= SnakeY[234] && Y <= SnakeY[234] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[235]  && X <= SnakeX[235] - 1 + (WIDTH * 2)) && (Y >= SnakeY[235] && Y <= SnakeY[235] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[236]  && X <= SnakeX[236] - 1 + (WIDTH * 2)) && (Y >= SnakeY[236] && Y <= SnakeY[236] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[237]  && X <= SnakeX[237] - 1 + (WIDTH * 2)) && (Y >= SnakeY[237] && Y <= SnakeY[237] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[238]  && X <= SnakeX[238] - 1 + (WIDTH * 2)) && (Y >= SnakeY[238] && Y <= SnakeY[238] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[239]  && X <= SnakeX[239] - 1 + (WIDTH * 2)) && (Y >= SnakeY[239] && Y <= SnakeY[239] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[240]  && X <= SnakeX[240] - 1 + (WIDTH * 2)) && (Y >= SnakeY[240] && Y <= SnakeY[240] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[241]  && X <= SnakeX[241] - 1 + (WIDTH * 2)) && (Y >= SnakeY[241] && Y <= SnakeY[241] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[242]  && X <= SnakeX[242] - 1 + (WIDTH * 2)) && (Y >= SnakeY[242] && Y <= SnakeY[242] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[243]  && X <= SnakeX[243] - 1 + (WIDTH * 2)) && (Y >= SnakeY[243] && Y <= SnakeY[243] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[244]  && X <= SnakeX[244] - 1 + (WIDTH * 2)) && (Y >= SnakeY[244] && Y <= SnakeY[244] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[245]  && X <= SnakeX[245] - 1 + (WIDTH * 2)) && (Y >= SnakeY[245] && Y <= SnakeY[245] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[246]  && X <= SnakeX[246] - 1 + (WIDTH * 2)) && (Y >= SnakeY[246] && Y <= SnakeY[246] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[247]  && X <= SnakeX[247] - 1 + (WIDTH * 2)) && (Y >= SnakeY[247] && Y <= SnakeY[247] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[248]  && X <= SnakeX[248] - 1 + (WIDTH * 2)) && (Y >= SnakeY[248] && Y <= SnakeY[248] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[249]  && X <= SnakeX[249] - 1 + (WIDTH * 2)) && (Y >= SnakeY[249] && Y <= SnakeY[249] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[250]  && X <= SnakeX[250] - 1 + (WIDTH * 2)) && (Y >= SnakeY[250] && Y <= SnakeY[250] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[251]  && X <= SnakeX[251] - 1 + (WIDTH * 2)) && (Y >= SnakeY[251] && Y <= SnakeY[251] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[252]  && X <= SnakeX[252] - 1 + (WIDTH * 2)) && (Y >= SnakeY[252] && Y <= SnakeY[252] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[253]  && X <= SnakeX[253] - 1 + (WIDTH * 2)) && (Y >= SnakeY[253] && Y <= SnakeY[253] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[254]  && X <= SnakeX[254] - 1 + (WIDTH * 2)) && (Y >= SnakeY[254] && Y <= SnakeY[254] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[255]  && X <= SnakeX[255] - 1 + (WIDTH * 2)) && (Y >= SnakeY[255] && Y <= SnakeY[255] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[256]  && X <= SnakeX[256] - 1 + (WIDTH * 2)) && (Y >= SnakeY[256] && Y <= SnakeY[256] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[257]  && X <= SnakeX[257] - 1 + (WIDTH * 2)) && (Y >= SnakeY[257] && Y <= SnakeY[257] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[258]  && X <= SnakeX[258] - 1 + (WIDTH * 2)) && (Y >= SnakeY[258] && Y <= SnakeY[258] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[259]  && X <= SnakeX[259] - 1 + (WIDTH * 2)) && (Y >= SnakeY[259] && Y <= SnakeY[259] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[260]  && X <= SnakeX[260] - 1 + (WIDTH * 2)) && (Y >= SnakeY[260] && Y <= SnakeY[260] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[261]  && X <= SnakeX[261] - 1 + (WIDTH * 2)) && (Y >= SnakeY[261] && Y <= SnakeY[261] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[262]  && X <= SnakeX[262] - 1 + (WIDTH * 2)) && (Y >= SnakeY[262] && Y <= SnakeY[262] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[263]  && X <= SnakeX[263] - 1 + (WIDTH * 2)) && (Y >= SnakeY[263] && Y <= SnakeY[263] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[264]  && X <= SnakeX[264] - 1 + (WIDTH * 2)) && (Y >= SnakeY[264] && Y <= SnakeY[264] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[265]  && X <= SnakeX[265] - 1 + (WIDTH * 2)) && (Y >= SnakeY[265] && Y <= SnakeY[265] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[266]  && X <= SnakeX[266] - 1 + (WIDTH * 2)) && (Y >= SnakeY[266] && Y <= SnakeY[266] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[267]  && X <= SnakeX[267] - 1 + (WIDTH * 2)) && (Y >= SnakeY[267] && Y <= SnakeY[267] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[268]  && X <= SnakeX[268] - 1 + (WIDTH * 2)) && (Y >= SnakeY[268] && Y <= SnakeY[268] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[269]  && X <= SnakeX[269] - 1 + (WIDTH * 2)) && (Y >= SnakeY[269] && Y <= SnakeY[269] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[270]  && X <= SnakeX[270] - 1 + (WIDTH * 2)) && (Y >= SnakeY[270] && Y <= SnakeY[270] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[271]  && X <= SnakeX[271] - 1 + (WIDTH * 2)) && (Y >= SnakeY[271] && Y <= SnakeY[271] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[272]  && X <= SnakeX[272] - 1 + (WIDTH * 2)) && (Y >= SnakeY[272] && Y <= SnakeY[272] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[273]  && X <= SnakeX[273] - 1 + (WIDTH * 2)) && (Y >= SnakeY[273] && Y <= SnakeY[273] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[274]  && X <= SnakeX[274] - 1 + (WIDTH * 2)) && (Y >= SnakeY[274] && Y <= SnakeY[274] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[275]  && X <= SnakeX[275] - 1 + (WIDTH * 2)) && (Y >= SnakeY[275] && Y <= SnakeY[275] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[276]  && X <= SnakeX[276] - 1 + (WIDTH * 2)) && (Y >= SnakeY[276] && Y <= SnakeY[276] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[277]  && X <= SnakeX[277] - 1 + (WIDTH * 2)) && (Y >= SnakeY[277] && Y <= SnakeY[277] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[278]  && X <= SnakeX[278] - 1 + (WIDTH * 2)) && (Y >= SnakeY[278] && Y <= SnakeY[278] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[279]  && X <= SnakeX[279] - 1 + (WIDTH * 2)) && (Y >= SnakeY[279] && Y <= SnakeY[279] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[280]  && X <= SnakeX[280] - 1 + (WIDTH * 2)) && (Y >= SnakeY[280] && Y <= SnakeY[280] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[281]  && X <= SnakeX[281] - 1 + (WIDTH * 2)) && (Y >= SnakeY[281] && Y <= SnakeY[281] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[282]  && X <= SnakeX[282] - 1 + (WIDTH * 2)) && (Y >= SnakeY[282] && Y <= SnakeY[282] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[283]  && X <= SnakeX[283] - 1 + (WIDTH * 2)) && (Y >= SnakeY[283] && Y <= SnakeY[283] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[284]  && X <= SnakeX[284] - 1 + (WIDTH * 2)) && (Y >= SnakeY[284] && Y <= SnakeY[284] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[285]  && X <= SnakeX[285] - 1 + (WIDTH * 2)) && (Y >= SnakeY[285] && Y <= SnakeY[285] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[286]  && X <= SnakeX[286] - 1 + (WIDTH * 2)) && (Y >= SnakeY[286] && Y <= SnakeY[286] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[287]  && X <= SnakeX[287] - 1 + (WIDTH * 2)) && (Y >= SnakeY[287] && Y <= SnakeY[287] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[288]  && X <= SnakeX[288] - 1 + (WIDTH * 2)) && (Y >= SnakeY[288] && Y <= SnakeY[288] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[289]  && X <= SnakeX[289] - 1 + (WIDTH * 2)) && (Y >= SnakeY[289] && Y <= SnakeY[289] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[290]  && X <= SnakeX[290] - 1 + (WIDTH * 2)) && (Y >= SnakeY[290] && Y <= SnakeY[290] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[291]  && X <= SnakeX[291] - 1 + (WIDTH * 2)) && (Y >= SnakeY[291] && Y <= SnakeY[291] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[292]  && X <= SnakeX[292] - 1 + (WIDTH * 2)) && (Y >= SnakeY[292] && Y <= SnakeY[292] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[293]  && X <= SnakeX[293] - 1 + (WIDTH * 2)) && (Y >= SnakeY[293] && Y <= SnakeY[293] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[294]  && X <= SnakeX[294] - 1 + (WIDTH * 2)) && (Y >= SnakeY[294] && Y <= SnakeY[294] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[295]  && X <= SnakeX[295] - 1 + (WIDTH * 2)) && (Y >= SnakeY[295] && Y <= SnakeY[295] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[296]  && X <= SnakeX[296] - 1 + (WIDTH * 2)) && (Y >= SnakeY[296] && Y <= SnakeY[296] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[297]  && X <= SnakeX[297] - 1 + (WIDTH * 2)) && (Y >= SnakeY[297] && Y <= SnakeY[297] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[298]  && X <= SnakeX[298] - 1 + (WIDTH * 2)) && (Y >= SnakeY[298] && Y <= SnakeY[298] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[299]  && X <= SnakeX[299] - 1 + (WIDTH * 2)) && (Y >= SnakeY[299] && Y <= SnakeY[299] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[300]  && X <= SnakeX[300] - 1 + (WIDTH * 2)) && (Y >= SnakeY[300] && Y <= SnakeY[300] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[301]  && X <= SnakeX[301] - 1 + (WIDTH * 2)) && (Y >= SnakeY[301] && Y <= SnakeY[301] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[302]  && X <= SnakeX[302] - 1 + (WIDTH * 2)) && (Y >= SnakeY[302] && Y <= SnakeY[302] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[303]  && X <= SnakeX[303] - 1 + (WIDTH * 2)) && (Y >= SnakeY[303] && Y <= SnakeY[303] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[304]  && X <= SnakeX[304] - 1 + (WIDTH * 2)) && (Y >= SnakeY[304] && Y <= SnakeY[304] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[305]  && X <= SnakeX[305] - 1 + (WIDTH * 2)) && (Y >= SnakeY[305] && Y <= SnakeY[305] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[306]  && X <= SnakeX[306] - 1 + (WIDTH * 2)) && (Y >= SnakeY[306] && Y <= SnakeY[306] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[307]  && X <= SnakeX[307] - 1 + (WIDTH * 2)) && (Y >= SnakeY[307] && Y <= SnakeY[307] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[308]  && X <= SnakeX[308] - 1 + (WIDTH * 2)) && (Y >= SnakeY[308] && Y <= SnakeY[308] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[309]  && X <= SnakeX[309] - 1 + (WIDTH * 2)) && (Y >= SnakeY[309] && Y <= SnakeY[309] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[310]  && X <= SnakeX[310] - 1 + (WIDTH * 2)) && (Y >= SnakeY[310] && Y <= SnakeY[310] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[311]  && X <= SnakeX[311] - 1 + (WIDTH * 2)) && (Y >= SnakeY[311] && Y <= SnakeY[311] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[312]  && X <= SnakeX[312] - 1 + (WIDTH * 2)) && (Y >= SnakeY[312] && Y <= SnakeY[312] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[313]  && X <= SnakeX[313] - 1 + (WIDTH * 2)) && (Y >= SnakeY[313] && Y <= SnakeY[313] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[314]  && X <= SnakeX[314] - 1 + (WIDTH * 2)) && (Y >= SnakeY[314] && Y <= SnakeY[314] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[315]  && X <= SnakeX[315] - 1 + (WIDTH * 2)) && (Y >= SnakeY[315] && Y <= SnakeY[315] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[316]  && X <= SnakeX[316] - 1 + (WIDTH * 2)) && (Y >= SnakeY[316] && Y <= SnakeY[316] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[317]  && X <= SnakeX[317] - 1 + (WIDTH * 2)) && (Y >= SnakeY[317] && Y <= SnakeY[317] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[318]  && X <= SnakeX[318] - 1 + (WIDTH * 2)) && (Y >= SnakeY[318] && Y <= SnakeY[318] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[319]  && X <= SnakeX[319] - 1 + (WIDTH * 2)) && (Y >= SnakeY[319] && Y <= SnakeY[319] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[320]  && X <= SnakeX[320] - 1 + (WIDTH * 2)) && (Y >= SnakeY[320] && Y <= SnakeY[320] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[321]  && X <= SnakeX[321] - 1 + (WIDTH * 2)) && (Y >= SnakeY[321] && Y <= SnakeY[321] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[322]  && X <= SnakeX[322] - 1 + (WIDTH * 2)) && (Y >= SnakeY[322] && Y <= SnakeY[322] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[323]  && X <= SnakeX[323] - 1 + (WIDTH * 2)) && (Y >= SnakeY[323] && Y <= SnakeY[323] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[324]  && X <= SnakeX[324] - 1 + (WIDTH * 2)) && (Y >= SnakeY[324] && Y <= SnakeY[324] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[325]  && X <= SnakeX[325] - 1 + (WIDTH * 2)) && (Y >= SnakeY[325] && Y <= SnakeY[325] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[326]  && X <= SnakeX[326] - 1 + (WIDTH * 2)) && (Y >= SnakeY[326] && Y <= SnakeY[326] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[327]  && X <= SnakeX[327] - 1 + (WIDTH * 2)) && (Y >= SnakeY[327] && Y <= SnakeY[327] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[328]  && X <= SnakeX[328] - 1 + (WIDTH * 2)) && (Y >= SnakeY[328] && Y <= SnakeY[328] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[329]  && X <= SnakeX[329] - 1 + (WIDTH * 2)) && (Y >= SnakeY[329] && Y <= SnakeY[329] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[330]  && X <= SnakeX[330] - 1 + (WIDTH * 2)) && (Y >= SnakeY[330] && Y <= SnakeY[330] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[331]  && X <= SnakeX[331] - 1 + (WIDTH * 2)) && (Y >= SnakeY[331] && Y <= SnakeY[331] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[332]  && X <= SnakeX[332] - 1 + (WIDTH * 2)) && (Y >= SnakeY[332] && Y <= SnakeY[332] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[333]  && X <= SnakeX[333] - 1 + (WIDTH * 2)) && (Y >= SnakeY[333] && Y <= SnakeY[333] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[334]  && X <= SnakeX[334] - 1 + (WIDTH * 2)) && (Y >= SnakeY[334] && Y <= SnakeY[334] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[335]  && X <= SnakeX[335] - 1 + (WIDTH * 2)) && (Y >= SnakeY[335] && Y <= SnakeY[335] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[336]  && X <= SnakeX[336] - 1 + (WIDTH * 2)) && (Y >= SnakeY[336] && Y <= SnakeY[336] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[337]  && X <= SnakeX[337] - 1 + (WIDTH * 2)) && (Y >= SnakeY[337] && Y <= SnakeY[337] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[338]  && X <= SnakeX[338] - 1 + (WIDTH * 2)) && (Y >= SnakeY[338] && Y <= SnakeY[338] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[339]  && X <= SnakeX[339] - 1 + (WIDTH * 2)) && (Y >= SnakeY[339] && Y <= SnakeY[339] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[340]  && X <= SnakeX[340] - 1 + (WIDTH * 2)) && (Y >= SnakeY[340] && Y <= SnakeY[340] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[341]  && X <= SnakeX[341] - 1 + (WIDTH * 2)) && (Y >= SnakeY[341] && Y <= SnakeY[341] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[342]  && X <= SnakeX[342] - 1 + (WIDTH * 2)) && (Y >= SnakeY[342] && Y <= SnakeY[342] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[343]  && X <= SnakeX[343] - 1 + (WIDTH * 2)) && (Y >= SnakeY[343] && Y <= SnakeY[343] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[344]  && X <= SnakeX[344] - 1 + (WIDTH * 2)) && (Y >= SnakeY[344] && Y <= SnakeY[344] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[345]  && X <= SnakeX[345] - 1 + (WIDTH * 2)) && (Y >= SnakeY[345] && Y <= SnakeY[345] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[346]  && X <= SnakeX[346] - 1 + (WIDTH * 2)) && (Y >= SnakeY[346] && Y <= SnakeY[346] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[347]  && X <= SnakeX[347] - 1 + (WIDTH * 2)) && (Y >= SnakeY[347] && Y <= SnakeY[347] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[348]  && X <= SnakeX[348] - 1 + (WIDTH * 2)) && (Y >= SnakeY[348] && Y <= SnakeY[348] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[349]  && X <= SnakeX[349] - 1 + (WIDTH * 2)) && (Y >= SnakeY[349] && Y <= SnakeY[349] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[350]  && X <= SnakeX[350] - 1 + (WIDTH * 2)) && (Y >= SnakeY[350] && Y <= SnakeY[350] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[351]  && X <= SnakeX[351] - 1 + (WIDTH * 2)) && (Y >= SnakeY[351] && Y <= SnakeY[351] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[352]  && X <= SnakeX[352] - 1 + (WIDTH * 2)) && (Y >= SnakeY[352] && Y <= SnakeY[352] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[353]  && X <= SnakeX[353] - 1 + (WIDTH * 2)) && (Y >= SnakeY[353] && Y <= SnakeY[353] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[354]  && X <= SnakeX[354] - 1 + (WIDTH * 2)) && (Y >= SnakeY[354] && Y <= SnakeY[354] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[355]  && X <= SnakeX[355] - 1 + (WIDTH * 2)) && (Y >= SnakeY[355] && Y <= SnakeY[355] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[356]  && X <= SnakeX[356] - 1 + (WIDTH * 2)) && (Y >= SnakeY[356] && Y <= SnakeY[356] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[357]  && X <= SnakeX[357] - 1 + (WIDTH * 2)) && (Y >= SnakeY[357] && Y <= SnakeY[357] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[358]  && X <= SnakeX[358] - 1 + (WIDTH * 2)) && (Y >= SnakeY[358] && Y <= SnakeY[358] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[359]  && X <= SnakeX[359] - 1 + (WIDTH * 2)) && (Y >= SnakeY[359] && Y <= SnakeY[359] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[360]  && X <= SnakeX[360] - 1 + (WIDTH * 2)) && (Y >= SnakeY[360] && Y <= SnakeY[360] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[361]  && X <= SnakeX[361] - 1 + (WIDTH * 2)) && (Y >= SnakeY[361] && Y <= SnakeY[361] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[362]  && X <= SnakeX[362] - 1 + (WIDTH * 2)) && (Y >= SnakeY[362] && Y <= SnakeY[362] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[363]  && X <= SnakeX[363] - 1 + (WIDTH * 2)) && (Y >= SnakeY[363] && Y <= SnakeY[363] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[364]  && X <= SnakeX[364] - 1 + (WIDTH * 2)) && (Y >= SnakeY[364] && Y <= SnakeY[364] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[365]  && X <= SnakeX[365] - 1 + (WIDTH * 2)) && (Y >= SnakeY[365] && Y <= SnakeY[365] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[366]  && X <= SnakeX[366] - 1 + (WIDTH * 2)) && (Y >= SnakeY[366] && Y <= SnakeY[366] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[367]  && X <= SnakeX[367] - 1 + (WIDTH * 2)) && (Y >= SnakeY[367] && Y <= SnakeY[367] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[368]  && X <= SnakeX[368] - 1 + (WIDTH * 2)) && (Y >= SnakeY[368] && Y <= SnakeY[368] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[369]  && X <= SnakeX[369] - 1 + (WIDTH * 2)) && (Y >= SnakeY[369] && Y <= SnakeY[369] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[370]  && X <= SnakeX[370] - 1 + (WIDTH * 2)) && (Y >= SnakeY[370] && Y <= SnakeY[370] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[371]  && X <= SnakeX[371] - 1 + (WIDTH * 2)) && (Y >= SnakeY[371] && Y <= SnakeY[371] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[372]  && X <= SnakeX[372] - 1 + (WIDTH * 2)) && (Y >= SnakeY[372] && Y <= SnakeY[372] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[373]  && X <= SnakeX[373] - 1 + (WIDTH * 2)) && (Y >= SnakeY[373] && Y <= SnakeY[373] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[374]  && X <= SnakeX[374] - 1 + (WIDTH * 2)) && (Y >= SnakeY[374] && Y <= SnakeY[374] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[375]  && X <= SnakeX[375] - 1 + (WIDTH * 2)) && (Y >= SnakeY[375] && Y <= SnakeY[375] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[376]  && X <= SnakeX[376] - 1 + (WIDTH * 2)) && (Y >= SnakeY[376] && Y <= SnakeY[376] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[377]  && X <= SnakeX[377] - 1 + (WIDTH * 2)) && (Y >= SnakeY[377] && Y <= SnakeY[377] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[378]  && X <= SnakeX[378] - 1 + (WIDTH * 2)) && (Y >= SnakeY[378] && Y <= SnakeY[378] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[379]  && X <= SnakeX[379] - 1 + (WIDTH * 2)) && (Y >= SnakeY[379] && Y <= SnakeY[379] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[380]  && X <= SnakeX[380] - 1 + (WIDTH * 2)) && (Y >= SnakeY[380] && Y <= SnakeY[380] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[381]  && X <= SnakeX[381] - 1 + (WIDTH * 2)) && (Y >= SnakeY[381] && Y <= SnakeY[381] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[382]  && X <= SnakeX[382] - 1 + (WIDTH * 2)) && (Y >= SnakeY[382] && Y <= SnakeY[382] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[383]  && X <= SnakeX[383] - 1 + (WIDTH * 2)) && (Y >= SnakeY[383] && Y <= SnakeY[383] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[384]  && X <= SnakeX[384] - 1 + (WIDTH * 2)) && (Y >= SnakeY[384] && Y <= SnakeY[384] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[385]  && X <= SnakeX[385] - 1 + (WIDTH * 2)) && (Y >= SnakeY[385] && Y <= SnakeY[385] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[386]  && X <= SnakeX[386] - 1 + (WIDTH * 2)) && (Y >= SnakeY[386] && Y <= SnakeY[386] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[387]  && X <= SnakeX[387] - 1 + (WIDTH * 2)) && (Y >= SnakeY[387] && Y <= SnakeY[387] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[388]  && X <= SnakeX[388] - 1 + (WIDTH * 2)) && (Y >= SnakeY[388] && Y <= SnakeY[388] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[389]  && X <= SnakeX[389] - 1 + (WIDTH * 2)) && (Y >= SnakeY[389] && Y <= SnakeY[389] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[390]  && X <= SnakeX[390] - 1 + (WIDTH * 2)) && (Y >= SnakeY[390] && Y <= SnakeY[390] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[391]  && X <= SnakeX[391] - 1 + (WIDTH * 2)) && (Y >= SnakeY[391] && Y <= SnakeY[391] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[392]  && X <= SnakeX[392] - 1 + (WIDTH * 2)) && (Y >= SnakeY[392] && Y <= SnakeY[392] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[393]  && X <= SnakeX[393] - 1 + (WIDTH * 2)) && (Y >= SnakeY[393] && Y <= SnakeY[393] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[394]  && X <= SnakeX[394] - 1 + (WIDTH * 2)) && (Y >= SnakeY[394] && Y <= SnakeY[394] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[395]  && X <= SnakeX[395] - 1 + (WIDTH * 2)) && (Y >= SnakeY[395] && Y <= SnakeY[395] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[396]  && X <= SnakeX[396] - 1 + (WIDTH * 2)) && (Y >= SnakeY[396] && Y <= SnakeY[396] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[397]  && X <= SnakeX[397] - 1 + (WIDTH * 2)) && (Y >= SnakeY[397] && Y <= SnakeY[397] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[398]  && X <= SnakeX[398] - 1 + (WIDTH * 2)) && (Y >= SnakeY[398] && Y <= SnakeY[398] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[399]  && X <= SnakeX[399] - 1 + (WIDTH * 2)) && (Y >= SnakeY[399] && Y <= SnakeY[399] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[400]  && X <= SnakeX[400] - 1 + (WIDTH * 2)) && (Y >= SnakeY[400] && Y <= SnakeY[400] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[401]  && X <= SnakeX[401] - 1 + (WIDTH * 2)) && (Y >= SnakeY[401] && Y <= SnakeY[401] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[402]  && X <= SnakeX[402] - 1 + (WIDTH * 2)) && (Y >= SnakeY[402] && Y <= SnakeY[402] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[403]  && X <= SnakeX[403] - 1 + (WIDTH * 2)) && (Y >= SnakeY[403] && Y <= SnakeY[403] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[404]  && X <= SnakeX[404] - 1 + (WIDTH * 2)) && (Y >= SnakeY[404] && Y <= SnakeY[404] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[405]  && X <= SnakeX[405] - 1 + (WIDTH * 2)) && (Y >= SnakeY[405] && Y <= SnakeY[405] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[406]  && X <= SnakeX[406] - 1 + (WIDTH * 2)) && (Y >= SnakeY[406] && Y <= SnakeY[406] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[407]  && X <= SnakeX[407] - 1 + (WIDTH * 2)) && (Y >= SnakeY[407] && Y <= SnakeY[407] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[408]  && X <= SnakeX[408] - 1 + (WIDTH * 2)) && (Y >= SnakeY[408] && Y <= SnakeY[408] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[409]  && X <= SnakeX[409] - 1 + (WIDTH * 2)) && (Y >= SnakeY[409] && Y <= SnakeY[409] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[410]  && X <= SnakeX[410] - 1 + (WIDTH * 2)) && (Y >= SnakeY[410] && Y <= SnakeY[410] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[411]  && X <= SnakeX[411] - 1 + (WIDTH * 2)) && (Y >= SnakeY[411] && Y <= SnakeY[411] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[412]  && X <= SnakeX[412] - 1 + (WIDTH * 2)) && (Y >= SnakeY[412] && Y <= SnakeY[412] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[413]  && X <= SnakeX[413] - 1 + (WIDTH * 2)) && (Y >= SnakeY[413] && Y <= SnakeY[413] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[414]  && X <= SnakeX[414] - 1 + (WIDTH * 2)) && (Y >= SnakeY[414] && Y <= SnakeY[414] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[415]  && X <= SnakeX[415] - 1 + (WIDTH * 2)) && (Y >= SnakeY[415] && Y <= SnakeY[415] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[416]  && X <= SnakeX[416] - 1 + (WIDTH * 2)) && (Y >= SnakeY[416] && Y <= SnakeY[416] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[417]  && X <= SnakeX[417] - 1 + (WIDTH * 2)) && (Y >= SnakeY[417] && Y <= SnakeY[417] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[418]  && X <= SnakeX[418] - 1 + (WIDTH * 2)) && (Y >= SnakeY[418] && Y <= SnakeY[418] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[419]  && X <= SnakeX[419] - 1 + (WIDTH * 2)) && (Y >= SnakeY[419] && Y <= SnakeY[419] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[420]  && X <= SnakeX[420] - 1 + (WIDTH * 2)) && (Y >= SnakeY[420] && Y <= SnakeY[420] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[421]  && X <= SnakeX[421] - 1 + (WIDTH * 2)) && (Y >= SnakeY[421] && Y <= SnakeY[421] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[422]  && X <= SnakeX[422] - 1 + (WIDTH * 2)) && (Y >= SnakeY[422] && Y <= SnakeY[422] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[423]  && X <= SnakeX[423] - 1 + (WIDTH * 2)) && (Y >= SnakeY[423] && Y <= SnakeY[423] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[424]  && X <= SnakeX[424] - 1 + (WIDTH * 2)) && (Y >= SnakeY[424] && Y <= SnakeY[424] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[425]  && X <= SnakeX[425] - 1 + (WIDTH * 2)) && (Y >= SnakeY[425] && Y <= SnakeY[425] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[426]  && X <= SnakeX[426] - 1 + (WIDTH * 2)) && (Y >= SnakeY[426] && Y <= SnakeY[426] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[427]  && X <= SnakeX[427] - 1 + (WIDTH * 2)) && (Y >= SnakeY[427] && Y <= SnakeY[427] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[428]  && X <= SnakeX[428] - 1 + (WIDTH * 2)) && (Y >= SnakeY[428] && Y <= SnakeY[428] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[429]  && X <= SnakeX[429] - 1 + (WIDTH * 2)) && (Y >= SnakeY[429] && Y <= SnakeY[429] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[430]  && X <= SnakeX[430] - 1 + (WIDTH * 2)) && (Y >= SnakeY[430] && Y <= SnakeY[430] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[431]  && X <= SnakeX[431] - 1 + (WIDTH * 2)) && (Y >= SnakeY[431] && Y <= SnakeY[431] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[432]  && X <= SnakeX[432] - 1 + (WIDTH * 2)) && (Y >= SnakeY[432] && Y <= SnakeY[432] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[433]  && X <= SnakeX[433] - 1 + (WIDTH * 2)) && (Y >= SnakeY[433] && Y <= SnakeY[433] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[434]  && X <= SnakeX[434] - 1 + (WIDTH * 2)) && (Y >= SnakeY[434] && Y <= SnakeY[434] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[435]  && X <= SnakeX[435] - 1 + (WIDTH * 2)) && (Y >= SnakeY[435] && Y <= SnakeY[435] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[436]  && X <= SnakeX[436] - 1 + (WIDTH * 2)) && (Y >= SnakeY[436] && Y <= SnakeY[436] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[437]  && X <= SnakeX[437] - 1 + (WIDTH * 2)) && (Y >= SnakeY[437] && Y <= SnakeY[437] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[438]  && X <= SnakeX[438] - 1 + (WIDTH * 2)) && (Y >= SnakeY[438] && Y <= SnakeY[438] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[439]  && X <= SnakeX[439] - 1 + (WIDTH * 2)) && (Y >= SnakeY[439] && Y <= SnakeY[439] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[440]  && X <= SnakeX[440] - 1 + (WIDTH * 2)) && (Y >= SnakeY[440] && Y <= SnakeY[440] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[441]  && X <= SnakeX[441] - 1 + (WIDTH * 2)) && (Y >= SnakeY[441] && Y <= SnakeY[441] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[442]  && X <= SnakeX[442] - 1 + (WIDTH * 2)) && (Y >= SnakeY[442] && Y <= SnakeY[442] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[443]  && X <= SnakeX[443] - 1 + (WIDTH * 2)) && (Y >= SnakeY[443] && Y <= SnakeY[443] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[444]  && X <= SnakeX[444] - 1 + (WIDTH * 2)) && (Y >= SnakeY[444] && Y <= SnakeY[444] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[445]  && X <= SnakeX[445] - 1 + (WIDTH * 2)) && (Y >= SnakeY[445] && Y <= SnakeY[445] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[446]  && X <= SnakeX[446] - 1 + (WIDTH * 2)) && (Y >= SnakeY[446] && Y <= SnakeY[446] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[447]  && X <= SnakeX[447] - 1 + (WIDTH * 2)) && (Y >= SnakeY[447] && Y <= SnakeY[447] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[448]  && X <= SnakeX[448] - 1 + (WIDTH * 2)) && (Y >= SnakeY[448] && Y <= SnakeY[448] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[449]  && X <= SnakeX[449] - 1 + (WIDTH * 2)) && (Y >= SnakeY[449] && Y <= SnakeY[449] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[450]  && X <= SnakeX[450] - 1 + (WIDTH * 2)) && (Y >= SnakeY[450] && Y <= SnakeY[450] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[451]  && X <= SnakeX[451] - 1 + (WIDTH * 2)) && (Y >= SnakeY[451] && Y <= SnakeY[451] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[452]  && X <= SnakeX[452] - 1 + (WIDTH * 2)) && (Y >= SnakeY[452] && Y <= SnakeY[452] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[453]  && X <= SnakeX[453] - 1 + (WIDTH * 2)) && (Y >= SnakeY[453] && Y <= SnakeY[453] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[454]  && X <= SnakeX[454] - 1 + (WIDTH * 2)) && (Y >= SnakeY[454] && Y <= SnakeY[454] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[455]  && X <= SnakeX[455] - 1 + (WIDTH * 2)) && (Y >= SnakeY[455] && Y <= SnakeY[455] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[456]  && X <= SnakeX[456] - 1 + (WIDTH * 2)) && (Y >= SnakeY[456] && Y <= SnakeY[456] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[457]  && X <= SnakeX[457] - 1 + (WIDTH * 2)) && (Y >= SnakeY[457] && Y <= SnakeY[457] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[458]  && X <= SnakeX[458] - 1 + (WIDTH * 2)) && (Y >= SnakeY[458] && Y <= SnakeY[458] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[459]  && X <= SnakeX[459] - 1 + (WIDTH * 2)) && (Y >= SnakeY[459] && Y <= SnakeY[459] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[460]  && X <= SnakeX[460] - 1 + (WIDTH * 2)) && (Y >= SnakeY[460] && Y <= SnakeY[460] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[461]  && X <= SnakeX[461] - 1 + (WIDTH * 2)) && (Y >= SnakeY[461] && Y <= SnakeY[461] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[462]  && X <= SnakeX[462] - 1 + (WIDTH * 2)) && (Y >= SnakeY[462] && Y <= SnakeY[462] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[463]  && X <= SnakeX[463] - 1 + (WIDTH * 2)) && (Y >= SnakeY[463] && Y <= SnakeY[463] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[464]  && X <= SnakeX[464] - 1 + (WIDTH * 2)) && (Y >= SnakeY[464] && Y <= SnakeY[464] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[465]  && X <= SnakeX[465] - 1 + (WIDTH * 2)) && (Y >= SnakeY[465] && Y <= SnakeY[465] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[466]  && X <= SnakeX[466] - 1 + (WIDTH * 2)) && (Y >= SnakeY[466] && Y <= SnakeY[466] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[467]  && X <= SnakeX[467] - 1 + (WIDTH * 2)) && (Y >= SnakeY[467] && Y <= SnakeY[467] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[468]  && X <= SnakeX[468] - 1 + (WIDTH * 2)) && (Y >= SnakeY[468] && Y <= SnakeY[468] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[469]  && X <= SnakeX[469] - 1 + (WIDTH * 2)) && (Y >= SnakeY[469] && Y <= SnakeY[469] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[470]  && X <= SnakeX[470] - 1 + (WIDTH * 2)) && (Y >= SnakeY[470] && Y <= SnakeY[470] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[471]  && X <= SnakeX[471] - 1 + (WIDTH * 2)) && (Y >= SnakeY[471] && Y <= SnakeY[471] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[472]  && X <= SnakeX[472] - 1 + (WIDTH * 2)) && (Y >= SnakeY[472] && Y <= SnakeY[472] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[473]  && X <= SnakeX[473] - 1 + (WIDTH * 2)) && (Y >= SnakeY[473] && Y <= SnakeY[473] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[474]  && X <= SnakeX[474] - 1 + (WIDTH * 2)) && (Y >= SnakeY[474] && Y <= SnakeY[474] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[475]  && X <= SnakeX[475] - 1 + (WIDTH * 2)) && (Y >= SnakeY[475] && Y <= SnakeY[475] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[476]  && X <= SnakeX[476] - 1 + (WIDTH * 2)) && (Y >= SnakeY[476] && Y <= SnakeY[476] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[477]  && X <= SnakeX[477] - 1 + (WIDTH * 2)) && (Y >= SnakeY[477] && Y <= SnakeY[477] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[478]  && X <= SnakeX[478] - 1 + (WIDTH * 2)) && (Y >= SnakeY[478] && Y <= SnakeY[478] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[479]  && X <= SnakeX[479] - 1 + (WIDTH * 2)) && (Y >= SnakeY[479] && Y <= SnakeY[479] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[480]  && X <= SnakeX[480] - 1 + (WIDTH * 2)) && (Y >= SnakeY[480] && Y <= SnakeY[480] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[481]  && X <= SnakeX[481] - 1 + (WIDTH * 2)) && (Y >= SnakeY[481] && Y <= SnakeY[481] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[482]  && X <= SnakeX[482] - 1 + (WIDTH * 2)) && (Y >= SnakeY[482] && Y <= SnakeY[482] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[483]  && X <= SnakeX[483] - 1 + (WIDTH * 2)) && (Y >= SnakeY[483] && Y <= SnakeY[483] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[484]  && X <= SnakeX[484] - 1 + (WIDTH * 2)) && (Y >= SnakeY[484] && Y <= SnakeY[484] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[485]  && X <= SnakeX[485] - 1 + (WIDTH * 2)) && (Y >= SnakeY[485] && Y <= SnakeY[485] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[486]  && X <= SnakeX[486] - 1 + (WIDTH * 2)) && (Y >= SnakeY[486] && Y <= SnakeY[486] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[487]  && X <= SnakeX[487] - 1 + (WIDTH * 2)) && (Y >= SnakeY[487] && Y <= SnakeY[487] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[488]  && X <= SnakeX[488] - 1 + (WIDTH * 2)) && (Y >= SnakeY[488] && Y <= SnakeY[488] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[489]  && X <= SnakeX[489] - 1 + (WIDTH * 2)) && (Y >= SnakeY[489] && Y <= SnakeY[489] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[490]  && X <= SnakeX[490] - 1 + (WIDTH * 2)) && (Y >= SnakeY[490] && Y <= SnakeY[490] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[491]  && X <= SnakeX[491] - 1 + (WIDTH * 2)) && (Y >= SnakeY[491] && Y <= SnakeY[491] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[492]  && X <= SnakeX[492] - 1 + (WIDTH * 2)) && (Y >= SnakeY[492] && Y <= SnakeY[492] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[493]  && X <= SnakeX[493] - 1 + (WIDTH * 2)) && (Y >= SnakeY[493] && Y <= SnakeY[493] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[494]  && X <= SnakeX[494] - 1 + (WIDTH * 2)) && (Y >= SnakeY[494] && Y <= SnakeY[494] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[495]  && X <= SnakeX[495] - 1 + (WIDTH * 2)) && (Y >= SnakeY[495] && Y <= SnakeY[495] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[496]  && X <= SnakeX[496] - 1 + (WIDTH * 2)) && (Y >= SnakeY[496] && Y <= SnakeY[496] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[497]  && X <= SnakeX[497] - 1 + (WIDTH * 2)) && (Y >= SnakeY[497] && Y <= SnakeY[497] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[498]  && X <= SnakeX[498] - 1 + (WIDTH * 2)) && (Y >= SnakeY[498] && Y <= SnakeY[498] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[499]  && X <= SnakeX[499] - 1 + (WIDTH * 2)) && (Y >= SnakeY[499] && Y <= SnakeY[499] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[500]  && X <= SnakeX[500] - 1 + (WIDTH * 2)) && (Y >= SnakeY[500] && Y <= SnakeY[500] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[501]  && X <= SnakeX[501] - 1 + (WIDTH * 2)) && (Y >= SnakeY[501] && Y <= SnakeY[501] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[502]  && X <= SnakeX[502] - 1 + (WIDTH * 2)) && (Y >= SnakeY[502] && Y <= SnakeY[502] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[503]  && X <= SnakeX[503] - 1 + (WIDTH * 2)) && (Y >= SnakeY[503] && Y <= SnakeY[503] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[504]  && X <= SnakeX[504] - 1 + (WIDTH * 2)) && (Y >= SnakeY[504] && Y <= SnakeY[504] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[505]  && X <= SnakeX[505] - 1 + (WIDTH * 2)) && (Y >= SnakeY[505] && Y <= SnakeY[505] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[506]  && X <= SnakeX[506] - 1 + (WIDTH * 2)) && (Y >= SnakeY[506] && Y <= SnakeY[506] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[507]  && X <= SnakeX[507] - 1 + (WIDTH * 2)) && (Y >= SnakeY[507] && Y <= SnakeY[507] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[508]  && X <= SnakeX[508] - 1 + (WIDTH * 2)) && (Y >= SnakeY[508] && Y <= SnakeY[508] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[509]  && X <= SnakeX[509] - 1 + (WIDTH * 2)) && (Y >= SnakeY[509] && Y <= SnakeY[509] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[510]  && X <= SnakeX[510] - 1 + (WIDTH * 2)) && (Y >= SnakeY[510] && Y <= SnakeY[510] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[511]  && X <= SnakeX[511] - 1 + (WIDTH * 2)) && (Y >= SnakeY[511] && Y <= SnakeY[511] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[512]  && X <= SnakeX[512] - 1 + (WIDTH * 2)) && (Y >= SnakeY[512] && Y <= SnakeY[512] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[513]  && X <= SnakeX[513] - 1 + (WIDTH * 2)) && (Y >= SnakeY[513] && Y <= SnakeY[513] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[514]  && X <= SnakeX[514] - 1 + (WIDTH * 2)) && (Y >= SnakeY[514] && Y <= SnakeY[514] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[515]  && X <= SnakeX[515] - 1 + (WIDTH * 2)) && (Y >= SnakeY[515] && Y <= SnakeY[515] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[516]  && X <= SnakeX[516] - 1 + (WIDTH * 2)) && (Y >= SnakeY[516] && Y <= SnakeY[516] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[517]  && X <= SnakeX[517] - 1 + (WIDTH * 2)) && (Y >= SnakeY[517] && Y <= SnakeY[517] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[518]  && X <= SnakeX[518] - 1 + (WIDTH * 2)) && (Y >= SnakeY[518] && Y <= SnakeY[518] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[519]  && X <= SnakeX[519] - 1 + (WIDTH * 2)) && (Y >= SnakeY[519] && Y <= SnakeY[519] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[520]  && X <= SnakeX[520] - 1 + (WIDTH * 2)) && (Y >= SnakeY[520] && Y <= SnakeY[520] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[521]  && X <= SnakeX[521] - 1 + (WIDTH * 2)) && (Y >= SnakeY[521] && Y <= SnakeY[521] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[522]  && X <= SnakeX[522] - 1 + (WIDTH * 2)) && (Y >= SnakeY[522] && Y <= SnakeY[522] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[523]  && X <= SnakeX[523] - 1 + (WIDTH * 2)) && (Y >= SnakeY[523] && Y <= SnakeY[523] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[524]  && X <= SnakeX[524] - 1 + (WIDTH * 2)) && (Y >= SnakeY[524] && Y <= SnakeY[524] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[525]  && X <= SnakeX[525] - 1 + (WIDTH * 2)) && (Y >= SnakeY[525] && Y <= SnakeY[525] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[526]  && X <= SnakeX[526] - 1 + (WIDTH * 2)) && (Y >= SnakeY[526] && Y <= SnakeY[526] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[527]  && X <= SnakeX[527] - 1 + (WIDTH * 2)) && (Y >= SnakeY[527] && Y <= SnakeY[527] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[528]  && X <= SnakeX[528] - 1 + (WIDTH * 2)) && (Y >= SnakeY[528] && Y <= SnakeY[528] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[529]  && X <= SnakeX[529] - 1 + (WIDTH * 2)) && (Y >= SnakeY[529] && Y <= SnakeY[529] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[530]  && X <= SnakeX[530] - 1 + (WIDTH * 2)) && (Y >= SnakeY[530] && Y <= SnakeY[530] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[531]  && X <= SnakeX[531] - 1 + (WIDTH * 2)) && (Y >= SnakeY[531] && Y <= SnakeY[531] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[532]  && X <= SnakeX[532] - 1 + (WIDTH * 2)) && (Y >= SnakeY[532] && Y <= SnakeY[532] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[533]  && X <= SnakeX[533] - 1 + (WIDTH * 2)) && (Y >= SnakeY[533] && Y <= SnakeY[533] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[534]  && X <= SnakeX[534] - 1 + (WIDTH * 2)) && (Y >= SnakeY[534] && Y <= SnakeY[534] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[535]  && X <= SnakeX[535] - 1 + (WIDTH * 2)) && (Y >= SnakeY[535] && Y <= SnakeY[535] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[536]  && X <= SnakeX[536] - 1 + (WIDTH * 2)) && (Y >= SnakeY[536] && Y <= SnakeY[536] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[537]  && X <= SnakeX[537] - 1 + (WIDTH * 2)) && (Y >= SnakeY[537] && Y <= SnakeY[537] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[538]  && X <= SnakeX[538] - 1 + (WIDTH * 2)) && (Y >= SnakeY[538] && Y <= SnakeY[538] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[539]  && X <= SnakeX[539] - 1 + (WIDTH * 2)) && (Y >= SnakeY[539] && Y <= SnakeY[539] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[540]  && X <= SnakeX[540] - 1 + (WIDTH * 2)) && (Y >= SnakeY[540] && Y <= SnakeY[540] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[541]  && X <= SnakeX[541] - 1 + (WIDTH * 2)) && (Y >= SnakeY[541] && Y <= SnakeY[541] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[542]  && X <= SnakeX[542] - 1 + (WIDTH * 2)) && (Y >= SnakeY[542] && Y <= SnakeY[542] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[543]  && X <= SnakeX[543] - 1 + (WIDTH * 2)) && (Y >= SnakeY[543] && Y <= SnakeY[543] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[544]  && X <= SnakeX[544] - 1 + (WIDTH * 2)) && (Y >= SnakeY[544] && Y <= SnakeY[544] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[545]  && X <= SnakeX[545] - 1 + (WIDTH * 2)) && (Y >= SnakeY[545] && Y <= SnakeY[545] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[546]  && X <= SnakeX[546] - 1 + (WIDTH * 2)) && (Y >= SnakeY[546] && Y <= SnakeY[546] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[547]  && X <= SnakeX[547] - 1 + (WIDTH * 2)) && (Y >= SnakeY[547] && Y <= SnakeY[547] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[548]  && X <= SnakeX[548] - 1 + (WIDTH * 2)) && (Y >= SnakeY[548] && Y <= SnakeY[548] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[549]  && X <= SnakeX[549] - 1 + (WIDTH * 2)) && (Y >= SnakeY[549] && Y <= SnakeY[549] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[550]  && X <= SnakeX[550] - 1 + (WIDTH * 2)) && (Y >= SnakeY[550] && Y <= SnakeY[550] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[551]  && X <= SnakeX[551] - 1 + (WIDTH * 2)) && (Y >= SnakeY[551] && Y <= SnakeY[551] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[552]  && X <= SnakeX[552] - 1 + (WIDTH * 2)) && (Y >= SnakeY[552] && Y <= SnakeY[552] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[553]  && X <= SnakeX[553] - 1 + (WIDTH * 2)) && (Y >= SnakeY[553] && Y <= SnakeY[553] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[554]  && X <= SnakeX[554] - 1 + (WIDTH * 2)) && (Y >= SnakeY[554] && Y <= SnakeY[554] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[555]  && X <= SnakeX[555] - 1 + (WIDTH * 2)) && (Y >= SnakeY[555] && Y <= SnakeY[555] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[556]  && X <= SnakeX[556] - 1 + (WIDTH * 2)) && (Y >= SnakeY[556] && Y <= SnakeY[556] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[557]  && X <= SnakeX[557] - 1 + (WIDTH * 2)) && (Y >= SnakeY[557] && Y <= SnakeY[557] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[558]  && X <= SnakeX[558] - 1 + (WIDTH * 2)) && (Y >= SnakeY[558] && Y <= SnakeY[558] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[559]  && X <= SnakeX[559] - 1 + (WIDTH * 2)) && (Y >= SnakeY[559] && Y <= SnakeY[559] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[560]  && X <= SnakeX[560] - 1 + (WIDTH * 2)) && (Y >= SnakeY[560] && Y <= SnakeY[560] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[561]  && X <= SnakeX[561] - 1 + (WIDTH * 2)) && (Y >= SnakeY[561] && Y <= SnakeY[561] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[562]  && X <= SnakeX[562] - 1 + (WIDTH * 2)) && (Y >= SnakeY[562] && Y <= SnakeY[562] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[563]  && X <= SnakeX[563] - 1 + (WIDTH * 2)) && (Y >= SnakeY[563] && Y <= SnakeY[563] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[564]  && X <= SnakeX[564] - 1 + (WIDTH * 2)) && (Y >= SnakeY[564] && Y <= SnakeY[564] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[565]  && X <= SnakeX[565] - 1 + (WIDTH * 2)) && (Y >= SnakeY[565] && Y <= SnakeY[565] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[566]  && X <= SnakeX[566] - 1 + (WIDTH * 2)) && (Y >= SnakeY[566] && Y <= SnakeY[566] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[567]  && X <= SnakeX[567] - 1 + (WIDTH * 2)) && (Y >= SnakeY[567] && Y <= SnakeY[567] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[568]  && X <= SnakeX[568] - 1 + (WIDTH * 2)) && (Y >= SnakeY[568] && Y <= SnakeY[568] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[569]  && X <= SnakeX[569] - 1 + (WIDTH * 2)) && (Y >= SnakeY[569] && Y <= SnakeY[569] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[570]  && X <= SnakeX[570] - 1 + (WIDTH * 2)) && (Y >= SnakeY[570] && Y <= SnakeY[570] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[571]  && X <= SnakeX[571] - 1 + (WIDTH * 2)) && (Y >= SnakeY[571] && Y <= SnakeY[571] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[572]  && X <= SnakeX[572] - 1 + (WIDTH * 2)) && (Y >= SnakeY[572] && Y <= SnakeY[572] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[573]  && X <= SnakeX[573] - 1 + (WIDTH * 2)) && (Y >= SnakeY[573] && Y <= SnakeY[573] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[574]  && X <= SnakeX[574] - 1 + (WIDTH * 2)) && (Y >= SnakeY[574] && Y <= SnakeY[574] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[575]  && X <= SnakeX[575] - 1 + (WIDTH * 2)) && (Y >= SnakeY[575] && Y <= SnakeY[575] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[576]  && X <= SnakeX[576] - 1 + (WIDTH * 2)) && (Y >= SnakeY[576] && Y <= SnakeY[576] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[577]  && X <= SnakeX[577] - 1 + (WIDTH * 2)) && (Y >= SnakeY[577] && Y <= SnakeY[577] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[578]  && X <= SnakeX[578] - 1 + (WIDTH * 2)) && (Y >= SnakeY[578] && Y <= SnakeY[578] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[579]  && X <= SnakeX[579] - 1 + (WIDTH * 2)) && (Y >= SnakeY[579] && Y <= SnakeY[579] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[580]  && X <= SnakeX[580] - 1 + (WIDTH * 2)) && (Y >= SnakeY[580] && Y <= SnakeY[580] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[581]  && X <= SnakeX[581] - 1 + (WIDTH * 2)) && (Y >= SnakeY[581] && Y <= SnakeY[581] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[582]  && X <= SnakeX[582] - 1 + (WIDTH * 2)) && (Y >= SnakeY[582] && Y <= SnakeY[582] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[583]  && X <= SnakeX[583] - 1 + (WIDTH * 2)) && (Y >= SnakeY[583] && Y <= SnakeY[583] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[584]  && X <= SnakeX[584] - 1 + (WIDTH * 2)) && (Y >= SnakeY[584] && Y <= SnakeY[584] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[585]  && X <= SnakeX[585] - 1 + (WIDTH * 2)) && (Y >= SnakeY[585] && Y <= SnakeY[585] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[586]  && X <= SnakeX[586] - 1 + (WIDTH * 2)) && (Y >= SnakeY[586] && Y <= SnakeY[586] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[587]  && X <= SnakeX[587] - 1 + (WIDTH * 2)) && (Y >= SnakeY[587] && Y <= SnakeY[587] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[588]  && X <= SnakeX[588] - 1 + (WIDTH * 2)) && (Y >= SnakeY[588] && Y <= SnakeY[588] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[589]  && X <= SnakeX[589] - 1 + (WIDTH * 2)) && (Y >= SnakeY[589] && Y <= SnakeY[589] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[590]  && X <= SnakeX[590] - 1 + (WIDTH * 2)) && (Y >= SnakeY[590] && Y <= SnakeY[590] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[591]  && X <= SnakeX[591] - 1 + (WIDTH * 2)) && (Y >= SnakeY[591] && Y <= SnakeY[591] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[592]  && X <= SnakeX[592] - 1 + (WIDTH * 2)) && (Y >= SnakeY[592] && Y <= SnakeY[592] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[593]  && X <= SnakeX[593] - 1 + (WIDTH * 2)) && (Y >= SnakeY[593] && Y <= SnakeY[593] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[594]  && X <= SnakeX[594] - 1 + (WIDTH * 2)) && (Y >= SnakeY[594] && Y <= SnakeY[594] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[595]  && X <= SnakeX[595] - 1 + (WIDTH * 2)) && (Y >= SnakeY[595] && Y <= SnakeY[595] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[596]  && X <= SnakeX[596] - 1 + (WIDTH * 2)) && (Y >= SnakeY[596] && Y <= SnakeY[596] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[597]  && X <= SnakeX[597] - 1 + (WIDTH * 2)) && (Y >= SnakeY[597] && Y <= SnakeY[597] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[598]  && X <= SnakeX[598] - 1 + (WIDTH * 2)) && (Y >= SnakeY[598] && Y <= SnakeY[598] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[599]  && X <= SnakeX[599] - 1 + (WIDTH * 2)) && (Y >= SnakeY[599] && Y <= SnakeY[599] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[600]  && X <= SnakeX[600] - 1 + (WIDTH * 2)) && (Y >= SnakeY[600] && Y <= SnakeY[600] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[601]  && X <= SnakeX[601] - 1 + (WIDTH * 2)) && (Y >= SnakeY[601] && Y <= SnakeY[601] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[602]  && X <= SnakeX[602] - 1 + (WIDTH * 2)) && (Y >= SnakeY[602] && Y <= SnakeY[602] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[603]  && X <= SnakeX[603] - 1 + (WIDTH * 2)) && (Y >= SnakeY[603] && Y <= SnakeY[603] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[604]  && X <= SnakeX[604] - 1 + (WIDTH * 2)) && (Y >= SnakeY[604] && Y <= SnakeY[604] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[605]  && X <= SnakeX[605] - 1 + (WIDTH * 2)) && (Y >= SnakeY[605] && Y <= SnakeY[605] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[606]  && X <= SnakeX[606] - 1 + (WIDTH * 2)) && (Y >= SnakeY[606] && Y <= SnakeY[606] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[607]  && X <= SnakeX[607] - 1 + (WIDTH * 2)) && (Y >= SnakeY[607] && Y <= SnakeY[607] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[608]  && X <= SnakeX[608] - 1 + (WIDTH * 2)) && (Y >= SnakeY[608] && Y <= SnakeY[608] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[609]  && X <= SnakeX[609] - 1 + (WIDTH * 2)) && (Y >= SnakeY[609] && Y <= SnakeY[609] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[610]  && X <= SnakeX[610] - 1 + (WIDTH * 2)) && (Y >= SnakeY[610] && Y <= SnakeY[610] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[611]  && X <= SnakeX[611] - 1 + (WIDTH * 2)) && (Y >= SnakeY[611] && Y <= SnakeY[611] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[612]  && X <= SnakeX[612] - 1 + (WIDTH * 2)) && (Y >= SnakeY[612] && Y <= SnakeY[612] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[613]  && X <= SnakeX[613] - 1 + (WIDTH * 2)) && (Y >= SnakeY[613] && Y <= SnakeY[613] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[614]  && X <= SnakeX[614] - 1 + (WIDTH * 2)) && (Y >= SnakeY[614] && Y <= SnakeY[614] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[615]  && X <= SnakeX[615] - 1 + (WIDTH * 2)) && (Y >= SnakeY[615] && Y <= SnakeY[615] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[616]  && X <= SnakeX[616] - 1 + (WIDTH * 2)) && (Y >= SnakeY[616] && Y <= SnakeY[616] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[617]  && X <= SnakeX[617] - 1 + (WIDTH * 2)) && (Y >= SnakeY[617] && Y <= SnakeY[617] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[618]  && X <= SnakeX[618] - 1 + (WIDTH * 2)) && (Y >= SnakeY[618] && Y <= SnakeY[618] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[619]  && X <= SnakeX[619] - 1 + (WIDTH * 2)) && (Y >= SnakeY[619] && Y <= SnakeY[619] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[620]  && X <= SnakeX[620] - 1 + (WIDTH * 2)) && (Y >= SnakeY[620] && Y <= SnakeY[620] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[621]  && X <= SnakeX[621] - 1 + (WIDTH * 2)) && (Y >= SnakeY[621] && Y <= SnakeY[621] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[622]  && X <= SnakeX[622] - 1 + (WIDTH * 2)) && (Y >= SnakeY[622] && Y <= SnakeY[622] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[623]  && X <= SnakeX[623] - 1 + (WIDTH * 2)) && (Y >= SnakeY[623] && Y <= SnakeY[623] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[624]  && X <= SnakeX[624] - 1 + (WIDTH * 2)) && (Y >= SnakeY[624] && Y <= SnakeY[624] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[625]  && X <= SnakeX[625] - 1 + (WIDTH * 2)) && (Y >= SnakeY[625] && Y <= SnakeY[625] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[626]  && X <= SnakeX[626] - 1 + (WIDTH * 2)) && (Y >= SnakeY[626] && Y <= SnakeY[626] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[627]  && X <= SnakeX[627] - 1 + (WIDTH * 2)) && (Y >= SnakeY[627] && Y <= SnakeY[627] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[628]  && X <= SnakeX[628] - 1 + (WIDTH * 2)) && (Y >= SnakeY[628] && Y <= SnakeY[628] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[629]  && X <= SnakeX[629] - 1 + (WIDTH * 2)) && (Y >= SnakeY[629] && Y <= SnakeY[629] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[630]  && X <= SnakeX[630] - 1 + (WIDTH * 2)) && (Y >= SnakeY[630] && Y <= SnakeY[630] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[631]  && X <= SnakeX[631] - 1 + (WIDTH * 2)) && (Y >= SnakeY[631] && Y <= SnakeY[631] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[632]  && X <= SnakeX[632] - 1 + (WIDTH * 2)) && (Y >= SnakeY[632] && Y <= SnakeY[632] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[633]  && X <= SnakeX[633] - 1 + (WIDTH * 2)) && (Y >= SnakeY[633] && Y <= SnakeY[633] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[634]  && X <= SnakeX[634] - 1 + (WIDTH * 2)) && (Y >= SnakeY[634] && Y <= SnakeY[634] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[635]  && X <= SnakeX[635] - 1 + (WIDTH * 2)) && (Y >= SnakeY[635] && Y <= SnakeY[635] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[636]  && X <= SnakeX[636] - 1 + (WIDTH * 2)) && (Y >= SnakeY[636] && Y <= SnakeY[636] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[637]  && X <= SnakeX[637] - 1 + (WIDTH * 2)) && (Y >= SnakeY[637] && Y <= SnakeY[637] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[638]  && X <= SnakeX[638] - 1 + (WIDTH * 2)) && (Y >= SnakeY[638] && Y <= SnakeY[638] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[639]  && X <= SnakeX[639] - 1 + (WIDTH * 2)) && (Y >= SnakeY[639] && Y <= SnakeY[639] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[640]  && X <= SnakeX[640] - 1 + (WIDTH * 2)) && (Y >= SnakeY[640] && Y <= SnakeY[640] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[641]  && X <= SnakeX[641] - 1 + (WIDTH * 2)) && (Y >= SnakeY[641] && Y <= SnakeY[641] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[642]  && X <= SnakeX[642] - 1 + (WIDTH * 2)) && (Y >= SnakeY[642] && Y <= SnakeY[642] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[643]  && X <= SnakeX[643] - 1 + (WIDTH * 2)) && (Y >= SnakeY[643] && Y <= SnakeY[643] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[644]  && X <= SnakeX[644] - 1 + (WIDTH * 2)) && (Y >= SnakeY[644] && Y <= SnakeY[644] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[645]  && X <= SnakeX[645] - 1 + (WIDTH * 2)) && (Y >= SnakeY[645] && Y <= SnakeY[645] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[646]  && X <= SnakeX[646] - 1 + (WIDTH * 2)) && (Y >= SnakeY[646] && Y <= SnakeY[646] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[647]  && X <= SnakeX[647] - 1 + (WIDTH * 2)) && (Y >= SnakeY[647] && Y <= SnakeY[647] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[648]  && X <= SnakeX[648] - 1 + (WIDTH * 2)) && (Y >= SnakeY[648] && Y <= SnakeY[648] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[649]  && X <= SnakeX[649] - 1 + (WIDTH * 2)) && (Y >= SnakeY[649] && Y <= SnakeY[649] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[650]  && X <= SnakeX[650] - 1 + (WIDTH * 2)) && (Y >= SnakeY[650] && Y <= SnakeY[650] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[651]  && X <= SnakeX[651] - 1 + (WIDTH * 2)) && (Y >= SnakeY[651] && Y <= SnakeY[651] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[652]  && X <= SnakeX[652] - 1 + (WIDTH * 2)) && (Y >= SnakeY[652] && Y <= SnakeY[652] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[653]  && X <= SnakeX[653] - 1 + (WIDTH * 2)) && (Y >= SnakeY[653] && Y <= SnakeY[653] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[654]  && X <= SnakeX[654] - 1 + (WIDTH * 2)) && (Y >= SnakeY[654] && Y <= SnakeY[654] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[655]  && X <= SnakeX[655] - 1 + (WIDTH * 2)) && (Y >= SnakeY[655] && Y <= SnakeY[655] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[656]  && X <= SnakeX[656] - 1 + (WIDTH * 2)) && (Y >= SnakeY[656] && Y <= SnakeY[656] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[657]  && X <= SnakeX[657] - 1 + (WIDTH * 2)) && (Y >= SnakeY[657] && Y <= SnakeY[657] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[658]  && X <= SnakeX[658] - 1 + (WIDTH * 2)) && (Y >= SnakeY[658] && Y <= SnakeY[658] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[659]  && X <= SnakeX[659] - 1 + (WIDTH * 2)) && (Y >= SnakeY[659] && Y <= SnakeY[659] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[660]  && X <= SnakeX[660] - 1 + (WIDTH * 2)) && (Y >= SnakeY[660] && Y <= SnakeY[660] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[661]  && X <= SnakeX[661] - 1 + (WIDTH * 2)) && (Y >= SnakeY[661] && Y <= SnakeY[661] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[662]  && X <= SnakeX[662] - 1 + (WIDTH * 2)) && (Y >= SnakeY[662] && Y <= SnakeY[662] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[663]  && X <= SnakeX[663] - 1 + (WIDTH * 2)) && (Y >= SnakeY[663] && Y <= SnakeY[663] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[664]  && X <= SnakeX[664] - 1 + (WIDTH * 2)) && (Y >= SnakeY[664] && Y <= SnakeY[664] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[665]  && X <= SnakeX[665] - 1 + (WIDTH * 2)) && (Y >= SnakeY[665] && Y <= SnakeY[665] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[666]  && X <= SnakeX[666] - 1 + (WIDTH * 2)) && (Y >= SnakeY[666] && Y <= SnakeY[666] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[667]  && X <= SnakeX[667] - 1 + (WIDTH * 2)) && (Y >= SnakeY[667] && Y <= SnakeY[667] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[668]  && X <= SnakeX[668] - 1 + (WIDTH * 2)) && (Y >= SnakeY[668] && Y <= SnakeY[668] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[669]  && X <= SnakeX[669] - 1 + (WIDTH * 2)) && (Y >= SnakeY[669] && Y <= SnakeY[669] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[670]  && X <= SnakeX[670] - 1 + (WIDTH * 2)) && (Y >= SnakeY[670] && Y <= SnakeY[670] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[671]  && X <= SnakeX[671] - 1 + (WIDTH * 2)) && (Y >= SnakeY[671] && Y <= SnakeY[671] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[672]  && X <= SnakeX[672] - 1 + (WIDTH * 2)) && (Y >= SnakeY[672] && Y <= SnakeY[672] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[673]  && X <= SnakeX[673] - 1 + (WIDTH * 2)) && (Y >= SnakeY[673] && Y <= SnakeY[673] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[674]  && X <= SnakeX[674] - 1 + (WIDTH * 2)) && (Y >= SnakeY[674] && Y <= SnakeY[674] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[675]  && X <= SnakeX[675] - 1 + (WIDTH * 2)) && (Y >= SnakeY[675] && Y <= SnakeY[675] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[676]  && X <= SnakeX[676] - 1 + (WIDTH * 2)) && (Y >= SnakeY[676] && Y <= SnakeY[676] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[677]  && X <= SnakeX[677] - 1 + (WIDTH * 2)) && (Y >= SnakeY[677] && Y <= SnakeY[677] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[678]  && X <= SnakeX[678] - 1 + (WIDTH * 2)) && (Y >= SnakeY[678] && Y <= SnakeY[678] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[679]  && X <= SnakeX[679] - 1 + (WIDTH * 2)) && (Y >= SnakeY[679] && Y <= SnakeY[679] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[680]  && X <= SnakeX[680] - 1 + (WIDTH * 2)) && (Y >= SnakeY[680] && Y <= SnakeY[680] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[681]  && X <= SnakeX[681] - 1 + (WIDTH * 2)) && (Y >= SnakeY[681] && Y <= SnakeY[681] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[682]  && X <= SnakeX[682] - 1 + (WIDTH * 2)) && (Y >= SnakeY[682] && Y <= SnakeY[682] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[683]  && X <= SnakeX[683] - 1 + (WIDTH * 2)) && (Y >= SnakeY[683] && Y <= SnakeY[683] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[684]  && X <= SnakeX[684] - 1 + (WIDTH * 2)) && (Y >= SnakeY[684] && Y <= SnakeY[684] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[685]  && X <= SnakeX[685] - 1 + (WIDTH * 2)) && (Y >= SnakeY[685] && Y <= SnakeY[685] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[686]  && X <= SnakeX[686] - 1 + (WIDTH * 2)) && (Y >= SnakeY[686] && Y <= SnakeY[686] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[687]  && X <= SnakeX[687] - 1 + (WIDTH * 2)) && (Y >= SnakeY[687] && Y <= SnakeY[687] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[688]  && X <= SnakeX[688] - 1 + (WIDTH * 2)) && (Y >= SnakeY[688] && Y <= SnakeY[688] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[689]  && X <= SnakeX[689] - 1 + (WIDTH * 2)) && (Y >= SnakeY[689] && Y <= SnakeY[689] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[690]  && X <= SnakeX[690] - 1 + (WIDTH * 2)) && (Y >= SnakeY[690] && Y <= SnakeY[690] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[691]  && X <= SnakeX[691] - 1 + (WIDTH * 2)) && (Y >= SnakeY[691] && Y <= SnakeY[691] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[692]  && X <= SnakeX[692] - 1 + (WIDTH * 2)) && (Y >= SnakeY[692] && Y <= SnakeY[692] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[693]  && X <= SnakeX[693] - 1 + (WIDTH * 2)) && (Y >= SnakeY[693] && Y <= SnakeY[693] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[694]  && X <= SnakeX[694] - 1 + (WIDTH * 2)) && (Y >= SnakeY[694] && Y <= SnakeY[694] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[695]  && X <= SnakeX[695] - 1 + (WIDTH * 2)) && (Y >= SnakeY[695] && Y <= SnakeY[695] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[696]  && X <= SnakeX[696] - 1 + (WIDTH * 2)) && (Y >= SnakeY[696] && Y <= SnakeY[696] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[697]  && X <= SnakeX[697] - 1 + (WIDTH * 2)) && (Y >= SnakeY[697] && Y <= SnakeY[697] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[698]  && X <= SnakeX[698] - 1 + (WIDTH * 2)) && (Y >= SnakeY[698] && Y <= SnakeY[698] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[699]  && X <= SnakeX[699] - 1 + (WIDTH * 2)) && (Y >= SnakeY[699] && Y <= SnakeY[699] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[700]  && X <= SnakeX[700] - 1 + (WIDTH * 2)) && (Y >= SnakeY[700] && Y <= SnakeY[700] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[701]  && X <= SnakeX[701] - 1 + (WIDTH * 2)) && (Y >= SnakeY[701] && Y <= SnakeY[701] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[702]  && X <= SnakeX[702] - 1 + (WIDTH * 2)) && (Y >= SnakeY[702] && Y <= SnakeY[702] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[703]  && X <= SnakeX[703] - 1 + (WIDTH * 2)) && (Y >= SnakeY[703] && Y <= SnakeY[703] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[704]  && X <= SnakeX[704] - 1 + (WIDTH * 2)) && (Y >= SnakeY[704] && Y <= SnakeY[704] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[705]  && X <= SnakeX[705] - 1 + (WIDTH * 2)) && (Y >= SnakeY[705] && Y <= SnakeY[705] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[706]  && X <= SnakeX[706] - 1 + (WIDTH * 2)) && (Y >= SnakeY[706] && Y <= SnakeY[706] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[707]  && X <= SnakeX[707] - 1 + (WIDTH * 2)) && (Y >= SnakeY[707] && Y <= SnakeY[707] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[708]  && X <= SnakeX[708] - 1 + (WIDTH * 2)) && (Y >= SnakeY[708] && Y <= SnakeY[708] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[709]  && X <= SnakeX[709] - 1 + (WIDTH * 2)) && (Y >= SnakeY[709] && Y <= SnakeY[709] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[710]  && X <= SnakeX[710] - 1 + (WIDTH * 2)) && (Y >= SnakeY[710] && Y <= SnakeY[710] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[711]  && X <= SnakeX[711] - 1 + (WIDTH * 2)) && (Y >= SnakeY[711] && Y <= SnakeY[711] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[712]  && X <= SnakeX[712] - 1 + (WIDTH * 2)) && (Y >= SnakeY[712] && Y <= SnakeY[712] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[713]  && X <= SnakeX[713] - 1 + (WIDTH * 2)) && (Y >= SnakeY[713] && Y <= SnakeY[713] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[714]  && X <= SnakeX[714] - 1 + (WIDTH * 2)) && (Y >= SnakeY[714] && Y <= SnakeY[714] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[715]  && X <= SnakeX[715] - 1 + (WIDTH * 2)) && (Y >= SnakeY[715] && Y <= SnakeY[715] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[716]  && X <= SnakeX[716] - 1 + (WIDTH * 2)) && (Y >= SnakeY[716] && Y <= SnakeY[716] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[717]  && X <= SnakeX[717] - 1 + (WIDTH * 2)) && (Y >= SnakeY[717] && Y <= SnakeY[717] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[718]  && X <= SnakeX[718] - 1 + (WIDTH * 2)) && (Y >= SnakeY[718] && Y <= SnakeY[718] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[719]  && X <= SnakeX[719] - 1 + (WIDTH * 2)) && (Y >= SnakeY[719] && Y <= SnakeY[719] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[720]  && X <= SnakeX[720] - 1 + (WIDTH * 2)) && (Y >= SnakeY[720] && Y <= SnakeY[720] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[721]  && X <= SnakeX[721] - 1 + (WIDTH * 2)) && (Y >= SnakeY[721] && Y <= SnakeY[721] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[722]  && X <= SnakeX[722] - 1 + (WIDTH * 2)) && (Y >= SnakeY[722] && Y <= SnakeY[722] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[723]  && X <= SnakeX[723] - 1 + (WIDTH * 2)) && (Y >= SnakeY[723] && Y <= SnakeY[723] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[724]  && X <= SnakeX[724] - 1 + (WIDTH * 2)) && (Y >= SnakeY[724] && Y <= SnakeY[724] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[725]  && X <= SnakeX[725] - 1 + (WIDTH * 2)) && (Y >= SnakeY[725] && Y <= SnakeY[725] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[726]  && X <= SnakeX[726] - 1 + (WIDTH * 2)) && (Y >= SnakeY[726] && Y <= SnakeY[726] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[727]  && X <= SnakeX[727] - 1 + (WIDTH * 2)) && (Y >= SnakeY[727] && Y <= SnakeY[727] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[728]  && X <= SnakeX[728] - 1 + (WIDTH * 2)) && (Y >= SnakeY[728] && Y <= SnakeY[728] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[729]  && X <= SnakeX[729] - 1 + (WIDTH * 2)) && (Y >= SnakeY[729] && Y <= SnakeY[729] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[730]  && X <= SnakeX[730] - 1 + (WIDTH * 2)) && (Y >= SnakeY[730] && Y <= SnakeY[730] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[731]  && X <= SnakeX[731] - 1 + (WIDTH * 2)) && (Y >= SnakeY[731] && Y <= SnakeY[731] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[732]  && X <= SnakeX[732] - 1 + (WIDTH * 2)) && (Y >= SnakeY[732] && Y <= SnakeY[732] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[733]  && X <= SnakeX[733] - 1 + (WIDTH * 2)) && (Y >= SnakeY[733] && Y <= SnakeY[733] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[734]  && X <= SnakeX[734] - 1 + (WIDTH * 2)) && (Y >= SnakeY[734] && Y <= SnakeY[734] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[735]  && X <= SnakeX[735] - 1 + (WIDTH * 2)) && (Y >= SnakeY[735] && Y <= SnakeY[735] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[736]  && X <= SnakeX[736] - 1 + (WIDTH * 2)) && (Y >= SnakeY[736] && Y <= SnakeY[736] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[737]  && X <= SnakeX[737] - 1 + (WIDTH * 2)) && (Y >= SnakeY[737] && Y <= SnakeY[737] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[738]  && X <= SnakeX[738] - 1 + (WIDTH * 2)) && (Y >= SnakeY[738] && Y <= SnakeY[738] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[739]  && X <= SnakeX[739] - 1 + (WIDTH * 2)) && (Y >= SnakeY[739] && Y <= SnakeY[739] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[740]  && X <= SnakeX[740] - 1 + (WIDTH * 2)) && (Y >= SnakeY[740] && Y <= SnakeY[740] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[741]  && X <= SnakeX[741] - 1 + (WIDTH * 2)) && (Y >= SnakeY[741] && Y <= SnakeY[741] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[742]  && X <= SnakeX[742] - 1 + (WIDTH * 2)) && (Y >= SnakeY[742] && Y <= SnakeY[742] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[743]  && X <= SnakeX[743] - 1 + (WIDTH * 2)) && (Y >= SnakeY[743] && Y <= SnakeY[743] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[744]  && X <= SnakeX[744] - 1 + (WIDTH * 2)) && (Y >= SnakeY[744] && Y <= SnakeY[744] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[745]  && X <= SnakeX[745] - 1 + (WIDTH * 2)) && (Y >= SnakeY[745] && Y <= SnakeY[745] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[746]  && X <= SnakeX[746] - 1 + (WIDTH * 2)) && (Y >= SnakeY[746] && Y <= SnakeY[746] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[747]  && X <= SnakeX[747] - 1 + (WIDTH * 2)) && (Y >= SnakeY[747] && Y <= SnakeY[747] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[748]  && X <= SnakeX[748] - 1 + (WIDTH * 2)) && (Y >= SnakeY[748] && Y <= SnakeY[748] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[749]  && X <= SnakeX[749] - 1 + (WIDTH * 2)) && (Y >= SnakeY[749] && Y <= SnakeY[749] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[750]  && X <= SnakeX[750] - 1 + (WIDTH * 2)) && (Y >= SnakeY[750] && Y <= SnakeY[750] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[751]  && X <= SnakeX[751] - 1 + (WIDTH * 2)) && (Y >= SnakeY[751] && Y <= SnakeY[751] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[752]  && X <= SnakeX[752] - 1 + (WIDTH * 2)) && (Y >= SnakeY[752] && Y <= SnakeY[752] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[753]  && X <= SnakeX[753] - 1 + (WIDTH * 2)) && (Y >= SnakeY[753] && Y <= SnakeY[753] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[754]  && X <= SnakeX[754] - 1 + (WIDTH * 2)) && (Y >= SnakeY[754] && Y <= SnakeY[754] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[755]  && X <= SnakeX[755] - 1 + (WIDTH * 2)) && (Y >= SnakeY[755] && Y <= SnakeY[755] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[756]  && X <= SnakeX[756] - 1 + (WIDTH * 2)) && (Y >= SnakeY[756] && Y <= SnakeY[756] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[757]  && X <= SnakeX[757] - 1 + (WIDTH * 2)) && (Y >= SnakeY[757] && Y <= SnakeY[757] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[758]  && X <= SnakeX[758] - 1 + (WIDTH * 2)) && (Y >= SnakeY[758] && Y <= SnakeY[758] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[759]  && X <= SnakeX[759] - 1 + (WIDTH * 2)) && (Y >= SnakeY[759] && Y <= SnakeY[759] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[760]  && X <= SnakeX[760] - 1 + (WIDTH * 2)) && (Y >= SnakeY[760] && Y <= SnakeY[760] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[761]  && X <= SnakeX[761] - 1 + (WIDTH * 2)) && (Y >= SnakeY[761] && Y <= SnakeY[761] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[762]  && X <= SnakeX[762] - 1 + (WIDTH * 2)) && (Y >= SnakeY[762] && Y <= SnakeY[762] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[763]  && X <= SnakeX[763] - 1 + (WIDTH * 2)) && (Y >= SnakeY[763] && Y <= SnakeY[763] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[764]  && X <= SnakeX[764] - 1 + (WIDTH * 2)) && (Y >= SnakeY[764] && Y <= SnakeY[764] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[765]  && X <= SnakeX[765] - 1 + (WIDTH * 2)) && (Y >= SnakeY[765] && Y <= SnakeY[765] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[766]  && X <= SnakeX[766] - 1 + (WIDTH * 2)) && (Y >= SnakeY[766] && Y <= SnakeY[766] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[767]  && X <= SnakeX[767] - 1 + (WIDTH * 2)) && (Y >= SnakeY[767] && Y <= SnakeY[767] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[768]  && X <= SnakeX[768] - 1 + (WIDTH * 2)) && (Y >= SnakeY[768] && Y <= SnakeY[768] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[769]  && X <= SnakeX[769] - 1 + (WIDTH * 2)) && (Y >= SnakeY[769] && Y <= SnakeY[769] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[770]  && X <= SnakeX[770] - 1 + (WIDTH * 2)) && (Y >= SnakeY[770] && Y <= SnakeY[770] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[771]  && X <= SnakeX[771] - 1 + (WIDTH * 2)) && (Y >= SnakeY[771] && Y <= SnakeY[771] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[772]  && X <= SnakeX[772] - 1 + (WIDTH * 2)) && (Y >= SnakeY[772] && Y <= SnakeY[772] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[773]  && X <= SnakeX[773] - 1 + (WIDTH * 2)) && (Y >= SnakeY[773] && Y <= SnakeY[773] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[774]  && X <= SnakeX[774] - 1 + (WIDTH * 2)) && (Y >= SnakeY[774] && Y <= SnakeY[774] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[775]  && X <= SnakeX[775] - 1 + (WIDTH * 2)) && (Y >= SnakeY[775] && Y <= SnakeY[775] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[776]  && X <= SnakeX[776] - 1 + (WIDTH * 2)) && (Y >= SnakeY[776] && Y <= SnakeY[776] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[777]  && X <= SnakeX[777] - 1 + (WIDTH * 2)) && (Y >= SnakeY[777] && Y <= SnakeY[777] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[778]  && X <= SnakeX[778] - 1 + (WIDTH * 2)) && (Y >= SnakeY[778] && Y <= SnakeY[778] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[779]  && X <= SnakeX[779] - 1 + (WIDTH * 2)) && (Y >= SnakeY[779] && Y <= SnakeY[779] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[780]  && X <= SnakeX[780] - 1 + (WIDTH * 2)) && (Y >= SnakeY[780] && Y <= SnakeY[780] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[781]  && X <= SnakeX[781] - 1 + (WIDTH * 2)) && (Y >= SnakeY[781] && Y <= SnakeY[781] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[782]  && X <= SnakeX[782] - 1 + (WIDTH * 2)) && (Y >= SnakeY[782] && Y <= SnakeY[782] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[783]  && X <= SnakeX[783] - 1 + (WIDTH * 2)) && (Y >= SnakeY[783] && Y <= SnakeY[783] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[784]  && X <= SnakeX[784] - 1 + (WIDTH * 2)) && (Y >= SnakeY[784] && Y <= SnakeY[784] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[785]  && X <= SnakeX[785] - 1 + (WIDTH * 2)) && (Y >= SnakeY[785] && Y <= SnakeY[785] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[786]  && X <= SnakeX[786] - 1 + (WIDTH * 2)) && (Y >= SnakeY[786] && Y <= SnakeY[786] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[787]  && X <= SnakeX[787] - 1 + (WIDTH * 2)) && (Y >= SnakeY[787] && Y <= SnakeY[787] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[788]  && X <= SnakeX[788] - 1 + (WIDTH * 2)) && (Y >= SnakeY[788] && Y <= SnakeY[788] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[789]  && X <= SnakeX[789] - 1 + (WIDTH * 2)) && (Y >= SnakeY[789] && Y <= SnakeY[789] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[790]  && X <= SnakeX[790] - 1 + (WIDTH * 2)) && (Y >= SnakeY[790] && Y <= SnakeY[790] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[791]  && X <= SnakeX[791] - 1 + (WIDTH * 2)) && (Y >= SnakeY[791] && Y <= SnakeY[791] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[792]  && X <= SnakeX[792] - 1 + (WIDTH * 2)) && (Y >= SnakeY[792] && Y <= SnakeY[792] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[793]  && X <= SnakeX[793] - 1 + (WIDTH * 2)) && (Y >= SnakeY[793] && Y <= SnakeY[793] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[794]  && X <= SnakeX[794] - 1 + (WIDTH * 2)) && (Y >= SnakeY[794] && Y <= SnakeY[794] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[795]  && X <= SnakeX[795] - 1 + (WIDTH * 2)) && (Y >= SnakeY[795] && Y <= SnakeY[795] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[796]  && X <= SnakeX[796] - 1 + (WIDTH * 2)) && (Y >= SnakeY[796] && Y <= SnakeY[796] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[797]  && X <= SnakeX[797] - 1 + (WIDTH * 2)) && (Y >= SnakeY[797] && Y <= SnakeY[797] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[798]  && X <= SnakeX[798] - 1 + (WIDTH * 2)) && (Y >= SnakeY[798] && Y <= SnakeY[798] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[799]  && X <= SnakeX[799] - 1 + (WIDTH * 2)) && (Y >= SnakeY[799] && Y <= SnakeY[799] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[800]  && X <= SnakeX[800] - 1 + (WIDTH * 2)) && (Y >= SnakeY[800] && Y <= SnakeY[800] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[801]  && X <= SnakeX[801] - 1 + (WIDTH * 2)) && (Y >= SnakeY[801] && Y <= SnakeY[801] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[802]  && X <= SnakeX[802] - 1 + (WIDTH * 2)) && (Y >= SnakeY[802] && Y <= SnakeY[802] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[803]  && X <= SnakeX[803] - 1 + (WIDTH * 2)) && (Y >= SnakeY[803] && Y <= SnakeY[803] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[804]  && X <= SnakeX[804] - 1 + (WIDTH * 2)) && (Y >= SnakeY[804] && Y <= SnakeY[804] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[805]  && X <= SnakeX[805] - 1 + (WIDTH * 2)) && (Y >= SnakeY[805] && Y <= SnakeY[805] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[806]  && X <= SnakeX[806] - 1 + (WIDTH * 2)) && (Y >= SnakeY[806] && Y <= SnakeY[806] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[807]  && X <= SnakeX[807] - 1 + (WIDTH * 2)) && (Y >= SnakeY[807] && Y <= SnakeY[807] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[808]  && X <= SnakeX[808] - 1 + (WIDTH * 2)) && (Y >= SnakeY[808] && Y <= SnakeY[808] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[809]  && X <= SnakeX[809] - 1 + (WIDTH * 2)) && (Y >= SnakeY[809] && Y <= SnakeY[809] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[810]  && X <= SnakeX[810] - 1 + (WIDTH * 2)) && (Y >= SnakeY[810] && Y <= SnakeY[810] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[811]  && X <= SnakeX[811] - 1 + (WIDTH * 2)) && (Y >= SnakeY[811] && Y <= SnakeY[811] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[812]  && X <= SnakeX[812] - 1 + (WIDTH * 2)) && (Y >= SnakeY[812] && Y <= SnakeY[812] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[813]  && X <= SnakeX[813] - 1 + (WIDTH * 2)) && (Y >= SnakeY[813] && Y <= SnakeY[813] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[814]  && X <= SnakeX[814] - 1 + (WIDTH * 2)) && (Y >= SnakeY[814] && Y <= SnakeY[814] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[815]  && X <= SnakeX[815] - 1 + (WIDTH * 2)) && (Y >= SnakeY[815] && Y <= SnakeY[815] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[816]  && X <= SnakeX[816] - 1 + (WIDTH * 2)) && (Y >= SnakeY[816] && Y <= SnakeY[816] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[817]  && X <= SnakeX[817] - 1 + (WIDTH * 2)) && (Y >= SnakeY[817] && Y <= SnakeY[817] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[818]  && X <= SnakeX[818] - 1 + (WIDTH * 2)) && (Y >= SnakeY[818] && Y <= SnakeY[818] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[819]  && X <= SnakeX[819] - 1 + (WIDTH * 2)) && (Y >= SnakeY[819] && Y <= SnakeY[819] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[820]  && X <= SnakeX[820] - 1 + (WIDTH * 2)) && (Y >= SnakeY[820] && Y <= SnakeY[820] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[821]  && X <= SnakeX[821] - 1 + (WIDTH * 2)) && (Y >= SnakeY[821] && Y <= SnakeY[821] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[822]  && X <= SnakeX[822] - 1 + (WIDTH * 2)) && (Y >= SnakeY[822] && Y <= SnakeY[822] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[823]  && X <= SnakeX[823] - 1 + (WIDTH * 2)) && (Y >= SnakeY[823] && Y <= SnakeY[823] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[824]  && X <= SnakeX[824] - 1 + (WIDTH * 2)) && (Y >= SnakeY[824] && Y <= SnakeY[824] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[825]  && X <= SnakeX[825] - 1 + (WIDTH * 2)) && (Y >= SnakeY[825] && Y <= SnakeY[825] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[826]  && X <= SnakeX[826] - 1 + (WIDTH * 2)) && (Y >= SnakeY[826] && Y <= SnakeY[826] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[827]  && X <= SnakeX[827] - 1 + (WIDTH * 2)) && (Y >= SnakeY[827] && Y <= SnakeY[827] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[828]  && X <= SnakeX[828] - 1 + (WIDTH * 2)) && (Y >= SnakeY[828] && Y <= SnakeY[828] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[829]  && X <= SnakeX[829] - 1 + (WIDTH * 2)) && (Y >= SnakeY[829] && Y <= SnakeY[829] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[830]  && X <= SnakeX[830] - 1 + (WIDTH * 2)) && (Y >= SnakeY[830] && Y <= SnakeY[830] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[831]  && X <= SnakeX[831] - 1 + (WIDTH * 2)) && (Y >= SnakeY[831] && Y <= SnakeY[831] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[832]  && X <= SnakeX[832] - 1 + (WIDTH * 2)) && (Y >= SnakeY[832] && Y <= SnakeY[832] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[833]  && X <= SnakeX[833] - 1 + (WIDTH * 2)) && (Y >= SnakeY[833] && Y <= SnakeY[833] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[834]  && X <= SnakeX[834] - 1 + (WIDTH * 2)) && (Y >= SnakeY[834] && Y <= SnakeY[834] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[835]  && X <= SnakeX[835] - 1 + (WIDTH * 2)) && (Y >= SnakeY[835] && Y <= SnakeY[835] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[836]  && X <= SnakeX[836] - 1 + (WIDTH * 2)) && (Y >= SnakeY[836] && Y <= SnakeY[836] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[837]  && X <= SnakeX[837] - 1 + (WIDTH * 2)) && (Y >= SnakeY[837] && Y <= SnakeY[837] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[838]  && X <= SnakeX[838] - 1 + (WIDTH * 2)) && (Y >= SnakeY[838] && Y <= SnakeY[838] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[839]  && X <= SnakeX[839] - 1 + (WIDTH * 2)) && (Y >= SnakeY[839] && Y <= SnakeY[839] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[840]  && X <= SnakeX[840] - 1 + (WIDTH * 2)) && (Y >= SnakeY[840] && Y <= SnakeY[840] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[841]  && X <= SnakeX[841] - 1 + (WIDTH * 2)) && (Y >= SnakeY[841] && Y <= SnakeY[841] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[842]  && X <= SnakeX[842] - 1 + (WIDTH * 2)) && (Y >= SnakeY[842] && Y <= SnakeY[842] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[843]  && X <= SnakeX[843] - 1 + (WIDTH * 2)) && (Y >= SnakeY[843] && Y <= SnakeY[843] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[844]  && X <= SnakeX[844] - 1 + (WIDTH * 2)) && (Y >= SnakeY[844] && Y <= SnakeY[844] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[845]  && X <= SnakeX[845] - 1 + (WIDTH * 2)) && (Y >= SnakeY[845] && Y <= SnakeY[845] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[846]  && X <= SnakeX[846] - 1 + (WIDTH * 2)) && (Y >= SnakeY[846] && Y <= SnakeY[846] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[847]  && X <= SnakeX[847] - 1 + (WIDTH * 2)) && (Y >= SnakeY[847] && Y <= SnakeY[847] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[848]  && X <= SnakeX[848] - 1 + (WIDTH * 2)) && (Y >= SnakeY[848] && Y <= SnakeY[848] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[849]  && X <= SnakeX[849] - 1 + (WIDTH * 2)) && (Y >= SnakeY[849] && Y <= SnakeY[849] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[850]  && X <= SnakeX[850] - 1 + (WIDTH * 2)) && (Y >= SnakeY[850] && Y <= SnakeY[850] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[851]  && X <= SnakeX[851] - 1 + (WIDTH * 2)) && (Y >= SnakeY[851] && Y <= SnakeY[851] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[852]  && X <= SnakeX[852] - 1 + (WIDTH * 2)) && (Y >= SnakeY[852] && Y <= SnakeY[852] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[853]  && X <= SnakeX[853] - 1 + (WIDTH * 2)) && (Y >= SnakeY[853] && Y <= SnakeY[853] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[854]  && X <= SnakeX[854] - 1 + (WIDTH * 2)) && (Y >= SnakeY[854] && Y <= SnakeY[854] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[855]  && X <= SnakeX[855] - 1 + (WIDTH * 2)) && (Y >= SnakeY[855] && Y <= SnakeY[855] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[856]  && X <= SnakeX[856] - 1 + (WIDTH * 2)) && (Y >= SnakeY[856] && Y <= SnakeY[856] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[857]  && X <= SnakeX[857] - 1 + (WIDTH * 2)) && (Y >= SnakeY[857] && Y <= SnakeY[857] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[858]  && X <= SnakeX[858] - 1 + (WIDTH * 2)) && (Y >= SnakeY[858] && Y <= SnakeY[858] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[859]  && X <= SnakeX[859] - 1 + (WIDTH * 2)) && (Y >= SnakeY[859] && Y <= SnakeY[859] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[860]  && X <= SnakeX[860] - 1 + (WIDTH * 2)) && (Y >= SnakeY[860] && Y <= SnakeY[860] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[861]  && X <= SnakeX[861] - 1 + (WIDTH * 2)) && (Y >= SnakeY[861] && Y <= SnakeY[861] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[862]  && X <= SnakeX[862] - 1 + (WIDTH * 2)) && (Y >= SnakeY[862] && Y <= SnakeY[862] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[863]  && X <= SnakeX[863] - 1 + (WIDTH * 2)) && (Y >= SnakeY[863] && Y <= SnakeY[863] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[864]  && X <= SnakeX[864] - 1 + (WIDTH * 2)) && (Y >= SnakeY[864] && Y <= SnakeY[864] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[865]  && X <= SnakeX[865] - 1 + (WIDTH * 2)) && (Y >= SnakeY[865] && Y <= SnakeY[865] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[866]  && X <= SnakeX[866] - 1 + (WIDTH * 2)) && (Y >= SnakeY[866] && Y <= SnakeY[866] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[867]  && X <= SnakeX[867] - 1 + (WIDTH * 2)) && (Y >= SnakeY[867] && Y <= SnakeY[867] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[868]  && X <= SnakeX[868] - 1 + (WIDTH * 2)) && (Y >= SnakeY[868] && Y <= SnakeY[868] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[869]  && X <= SnakeX[869] - 1 + (WIDTH * 2)) && (Y >= SnakeY[869] && Y <= SnakeY[869] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[870]  && X <= SnakeX[870] - 1 + (WIDTH * 2)) && (Y >= SnakeY[870] && Y <= SnakeY[870] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[871]  && X <= SnakeX[871] - 1 + (WIDTH * 2)) && (Y >= SnakeY[871] && Y <= SnakeY[871] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[872]  && X <= SnakeX[872] - 1 + (WIDTH * 2)) && (Y >= SnakeY[872] && Y <= SnakeY[872] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[873]  && X <= SnakeX[873] - 1 + (WIDTH * 2)) && (Y >= SnakeY[873] && Y <= SnakeY[873] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[874]  && X <= SnakeX[874] - 1 + (WIDTH * 2)) && (Y >= SnakeY[874] && Y <= SnakeY[874] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[875]  && X <= SnakeX[875] - 1 + (WIDTH * 2)) && (Y >= SnakeY[875] && Y <= SnakeY[875] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[876]  && X <= SnakeX[876] - 1 + (WIDTH * 2)) && (Y >= SnakeY[876] && Y <= SnakeY[876] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[877]  && X <= SnakeX[877] - 1 + (WIDTH * 2)) && (Y >= SnakeY[877] && Y <= SnakeY[877] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[878]  && X <= SnakeX[878] - 1 + (WIDTH * 2)) && (Y >= SnakeY[878] && Y <= SnakeY[878] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[879]  && X <= SnakeX[879] - 1 + (WIDTH * 2)) && (Y >= SnakeY[879] && Y <= SnakeY[879] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[880]  && X <= SnakeX[880] - 1 + (WIDTH * 2)) && (Y >= SnakeY[880] && Y <= SnakeY[880] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[881]  && X <= SnakeX[881] - 1 + (WIDTH * 2)) && (Y >= SnakeY[881] && Y <= SnakeY[881] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[882]  && X <= SnakeX[882] - 1 + (WIDTH * 2)) && (Y >= SnakeY[882] && Y <= SnakeY[882] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[883]  && X <= SnakeX[883] - 1 + (WIDTH * 2)) && (Y >= SnakeY[883] && Y <= SnakeY[883] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[884]  && X <= SnakeX[884] - 1 + (WIDTH * 2)) && (Y >= SnakeY[884] && Y <= SnakeY[884] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[885]  && X <= SnakeX[885] - 1 + (WIDTH * 2)) && (Y >= SnakeY[885] && Y <= SnakeY[885] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[886]  && X <= SnakeX[886] - 1 + (WIDTH * 2)) && (Y >= SnakeY[886] && Y <= SnakeY[886] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[887]  && X <= SnakeX[887] - 1 + (WIDTH * 2)) && (Y >= SnakeY[887] && Y <= SnakeY[887] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[888]  && X <= SnakeX[888] - 1 + (WIDTH * 2)) && (Y >= SnakeY[888] && Y <= SnakeY[888] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[889]  && X <= SnakeX[889] - 1 + (WIDTH * 2)) && (Y >= SnakeY[889] && Y <= SnakeY[889] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[890]  && X <= SnakeX[890] - 1 + (WIDTH * 2)) && (Y >= SnakeY[890] && Y <= SnakeY[890] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[891]  && X <= SnakeX[891] - 1 + (WIDTH * 2)) && (Y >= SnakeY[891] && Y <= SnakeY[891] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[892]  && X <= SnakeX[892] - 1 + (WIDTH * 2)) && (Y >= SnakeY[892] && Y <= SnakeY[892] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[893]  && X <= SnakeX[893] - 1 + (WIDTH * 2)) && (Y >= SnakeY[893] && Y <= SnakeY[893] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[894]  && X <= SnakeX[894] - 1 + (WIDTH * 2)) && (Y >= SnakeY[894] && Y <= SnakeY[894] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[895]  && X <= SnakeX[895] - 1 + (WIDTH * 2)) && (Y >= SnakeY[895] && Y <= SnakeY[895] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[896]  && X <= SnakeX[896] - 1 + (WIDTH * 2)) && (Y >= SnakeY[896] && Y <= SnakeY[896] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[897]  && X <= SnakeX[897] - 1 + (WIDTH * 2)) && (Y >= SnakeY[897] && Y <= SnakeY[897] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[898]  && X <= SnakeX[898] - 1 + (WIDTH * 2)) && (Y >= SnakeY[898] && Y <= SnakeY[898] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[899]  && X <= SnakeX[899] - 1 + (WIDTH * 2)) && (Y >= SnakeY[899] && Y <= SnakeY[899] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[900]  && X <= SnakeX[900] - 1 + (WIDTH * 2)) && (Y >= SnakeY[900] && Y <= SnakeY[900] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[901]  && X <= SnakeX[901] - 1 + (WIDTH * 2)) && (Y >= SnakeY[901] && Y <= SnakeY[901] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[902]  && X <= SnakeX[902] - 1 + (WIDTH * 2)) && (Y >= SnakeY[902] && Y <= SnakeY[902] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[903]  && X <= SnakeX[903] - 1 + (WIDTH * 2)) && (Y >= SnakeY[903] && Y <= SnakeY[903] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[904]  && X <= SnakeX[904] - 1 + (WIDTH * 2)) && (Y >= SnakeY[904] && Y <= SnakeY[904] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[905]  && X <= SnakeX[905] - 1 + (WIDTH * 2)) && (Y >= SnakeY[905] && Y <= SnakeY[905] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[906]  && X <= SnakeX[906] - 1 + (WIDTH * 2)) && (Y >= SnakeY[906] && Y <= SnakeY[906] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[907]  && X <= SnakeX[907] - 1 + (WIDTH * 2)) && (Y >= SnakeY[907] && Y <= SnakeY[907] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[908]  && X <= SnakeX[908] - 1 + (WIDTH * 2)) && (Y >= SnakeY[908] && Y <= SnakeY[908] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[909]  && X <= SnakeX[909] - 1 + (WIDTH * 2)) && (Y >= SnakeY[909] && Y <= SnakeY[909] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[910]  && X <= SnakeX[910] - 1 + (WIDTH * 2)) && (Y >= SnakeY[910] && Y <= SnakeY[910] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[911]  && X <= SnakeX[911] - 1 + (WIDTH * 2)) && (Y >= SnakeY[911] && Y <= SnakeY[911] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[912]  && X <= SnakeX[912] - 1 + (WIDTH * 2)) && (Y >= SnakeY[912] && Y <= SnakeY[912] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[913]  && X <= SnakeX[913] - 1 + (WIDTH * 2)) && (Y >= SnakeY[913] && Y <= SnakeY[913] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[914]  && X <= SnakeX[914] - 1 + (WIDTH * 2)) && (Y >= SnakeY[914] && Y <= SnakeY[914] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[915]  && X <= SnakeX[915] - 1 + (WIDTH * 2)) && (Y >= SnakeY[915] && Y <= SnakeY[915] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[916]  && X <= SnakeX[916] - 1 + (WIDTH * 2)) && (Y >= SnakeY[916] && Y <= SnakeY[916] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[917]  && X <= SnakeX[917] - 1 + (WIDTH * 2)) && (Y >= SnakeY[917] && Y <= SnakeY[917] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[918]  && X <= SnakeX[918] - 1 + (WIDTH * 2)) && (Y >= SnakeY[918] && Y <= SnakeY[918] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[919]  && X <= SnakeX[919] - 1 + (WIDTH * 2)) && (Y >= SnakeY[919] && Y <= SnakeY[919] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[920]  && X <= SnakeX[920] - 1 + (WIDTH * 2)) && (Y >= SnakeY[920] && Y <= SnakeY[920] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[921]  && X <= SnakeX[921] - 1 + (WIDTH * 2)) && (Y >= SnakeY[921] && Y <= SnakeY[921] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[922]  && X <= SnakeX[922] - 1 + (WIDTH * 2)) && (Y >= SnakeY[922] && Y <= SnakeY[922] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[923]  && X <= SnakeX[923] - 1 + (WIDTH * 2)) && (Y >= SnakeY[923] && Y <= SnakeY[923] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[924]  && X <= SnakeX[924] - 1 + (WIDTH * 2)) && (Y >= SnakeY[924] && Y <= SnakeY[924] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[925]  && X <= SnakeX[925] - 1 + (WIDTH * 2)) && (Y >= SnakeY[925] && Y <= SnakeY[925] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[926]  && X <= SnakeX[926] - 1 + (WIDTH * 2)) && (Y >= SnakeY[926] && Y <= SnakeY[926] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[927]  && X <= SnakeX[927] - 1 + (WIDTH * 2)) && (Y >= SnakeY[927] && Y <= SnakeY[927] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[928]  && X <= SnakeX[928] - 1 + (WIDTH * 2)) && (Y >= SnakeY[928] && Y <= SnakeY[928] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[929]  && X <= SnakeX[929] - 1 + (WIDTH * 2)) && (Y >= SnakeY[929] && Y <= SnakeY[929] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[930]  && X <= SnakeX[930] - 1 + (WIDTH * 2)) && (Y >= SnakeY[930] && Y <= SnakeY[930] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[931]  && X <= SnakeX[931] - 1 + (WIDTH * 2)) && (Y >= SnakeY[931] && Y <= SnakeY[931] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[932]  && X <= SnakeX[932] - 1 + (WIDTH * 2)) && (Y >= SnakeY[932] && Y <= SnakeY[932] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[933]  && X <= SnakeX[933] - 1 + (WIDTH * 2)) && (Y >= SnakeY[933] && Y <= SnakeY[933] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[934]  && X <= SnakeX[934] - 1 + (WIDTH * 2)) && (Y >= SnakeY[934] && Y <= SnakeY[934] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[935]  && X <= SnakeX[935] - 1 + (WIDTH * 2)) && (Y >= SnakeY[935] && Y <= SnakeY[935] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[936]  && X <= SnakeX[936] - 1 + (WIDTH * 2)) && (Y >= SnakeY[936] && Y <= SnakeY[936] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[937]  && X <= SnakeX[937] - 1 + (WIDTH * 2)) && (Y >= SnakeY[937] && Y <= SnakeY[937] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[938]  && X <= SnakeX[938] - 1 + (WIDTH * 2)) && (Y >= SnakeY[938] && Y <= SnakeY[938] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[939]  && X <= SnakeX[939] - 1 + (WIDTH * 2)) && (Y >= SnakeY[939] && Y <= SnakeY[939] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[940]  && X <= SnakeX[940] - 1 + (WIDTH * 2)) && (Y >= SnakeY[940] && Y <= SnakeY[940] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[941]  && X <= SnakeX[941] - 1 + (WIDTH * 2)) && (Y >= SnakeY[941] && Y <= SnakeY[941] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[942]  && X <= SnakeX[942] - 1 + (WIDTH * 2)) && (Y >= SnakeY[942] && Y <= SnakeY[942] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[943]  && X <= SnakeX[943] - 1 + (WIDTH * 2)) && (Y >= SnakeY[943] && Y <= SnakeY[943] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[944]  && X <= SnakeX[944] - 1 + (WIDTH * 2)) && (Y >= SnakeY[944] && Y <= SnakeY[944] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[945]  && X <= SnakeX[945] - 1 + (WIDTH * 2)) && (Y >= SnakeY[945] && Y <= SnakeY[945] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[946]  && X <= SnakeX[946] - 1 + (WIDTH * 2)) && (Y >= SnakeY[946] && Y <= SnakeY[946] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[947]  && X <= SnakeX[947] - 1 + (WIDTH * 2)) && (Y >= SnakeY[947] && Y <= SnakeY[947] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[948]  && X <= SnakeX[948] - 1 + (WIDTH * 2)) && (Y >= SnakeY[948] && Y <= SnakeY[948] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[949]  && X <= SnakeX[949] - 1 + (WIDTH * 2)) && (Y >= SnakeY[949] && Y <= SnakeY[949] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[950]  && X <= SnakeX[950] - 1 + (WIDTH * 2)) && (Y >= SnakeY[950] && Y <= SnakeY[950] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[951]  && X <= SnakeX[951] - 1 + (WIDTH * 2)) && (Y >= SnakeY[951] && Y <= SnakeY[951] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[952]  && X <= SnakeX[952] - 1 + (WIDTH * 2)) && (Y >= SnakeY[952] && Y <= SnakeY[952] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[953]  && X <= SnakeX[953] - 1 + (WIDTH * 2)) && (Y >= SnakeY[953] && Y <= SnakeY[953] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[954]  && X <= SnakeX[954] - 1 + (WIDTH * 2)) && (Y >= SnakeY[954] && Y <= SnakeY[954] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[955]  && X <= SnakeX[955] - 1 + (WIDTH * 2)) && (Y >= SnakeY[955] && Y <= SnakeY[955] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[956]  && X <= SnakeX[956] - 1 + (WIDTH * 2)) && (Y >= SnakeY[956] && Y <= SnakeY[956] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[957]  && X <= SnakeX[957] - 1 + (WIDTH * 2)) && (Y >= SnakeY[957] && Y <= SnakeY[957] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[958]  && X <= SnakeX[958] - 1 + (WIDTH * 2)) && (Y >= SnakeY[958] && Y <= SnakeY[958] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[959]  && X <= SnakeX[959] - 1 + (WIDTH * 2)) && (Y >= SnakeY[959] && Y <= SnakeY[959] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[960]  && X <= SnakeX[960] - 1 + (WIDTH * 2)) && (Y >= SnakeY[960] && Y <= SnakeY[960] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[961]  && X <= SnakeX[961] - 1 + (WIDTH * 2)) && (Y >= SnakeY[961] && Y <= SnakeY[961] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[962]  && X <= SnakeX[962] - 1 + (WIDTH * 2)) && (Y >= SnakeY[962] && Y <= SnakeY[962] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[963]  && X <= SnakeX[963] - 1 + (WIDTH * 2)) && (Y >= SnakeY[963] && Y <= SnakeY[963] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[964]  && X <= SnakeX[964] - 1 + (WIDTH * 2)) && (Y >= SnakeY[964] && Y <= SnakeY[964] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[965]  && X <= SnakeX[965] - 1 + (WIDTH * 2)) && (Y >= SnakeY[965] && Y <= SnakeY[965] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[966]  && X <= SnakeX[966] - 1 + (WIDTH * 2)) && (Y >= SnakeY[966] && Y <= SnakeY[966] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[967]  && X <= SnakeX[967] - 1 + (WIDTH * 2)) && (Y >= SnakeY[967] && Y <= SnakeY[967] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[968]  && X <= SnakeX[968] - 1 + (WIDTH * 2)) && (Y >= SnakeY[968] && Y <= SnakeY[968] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[969]  && X <= SnakeX[969] - 1 + (WIDTH * 2)) && (Y >= SnakeY[969] && Y <= SnakeY[969] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[970]  && X <= SnakeX[970] - 1 + (WIDTH * 2)) && (Y >= SnakeY[970] && Y <= SnakeY[970] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[971]  && X <= SnakeX[971] - 1 + (WIDTH * 2)) && (Y >= SnakeY[971] && Y <= SnakeY[971] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[972]  && X <= SnakeX[972] - 1 + (WIDTH * 2)) && (Y >= SnakeY[972] && Y <= SnakeY[972] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[973]  && X <= SnakeX[973] - 1 + (WIDTH * 2)) && (Y >= SnakeY[973] && Y <= SnakeY[973] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[974]  && X <= SnakeX[974] - 1 + (WIDTH * 2)) && (Y >= SnakeY[974] && Y <= SnakeY[974] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[975]  && X <= SnakeX[975] - 1 + (WIDTH * 2)) && (Y >= SnakeY[975] && Y <= SnakeY[975] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[976]  && X <= SnakeX[976] - 1 + (WIDTH * 2)) && (Y >= SnakeY[976] && Y <= SnakeY[976] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[977]  && X <= SnakeX[977] - 1 + (WIDTH * 2)) && (Y >= SnakeY[977] && Y <= SnakeY[977] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[978]  && X <= SnakeX[978] - 1 + (WIDTH * 2)) && (Y >= SnakeY[978] && Y <= SnakeY[978] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[979]  && X <= SnakeX[979] - 1 + (WIDTH * 2)) && (Y >= SnakeY[979] && Y <= SnakeY[979] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[980]  && X <= SnakeX[980] - 1 + (WIDTH * 2)) && (Y >= SnakeY[980] && Y <= SnakeY[980] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[981]  && X <= SnakeX[981] - 1 + (WIDTH * 2)) && (Y >= SnakeY[981] && Y <= SnakeY[981] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[982]  && X <= SnakeX[982] - 1 + (WIDTH * 2)) && (Y >= SnakeY[982] && Y <= SnakeY[982] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[983]  && X <= SnakeX[983] - 1 + (WIDTH * 2)) && (Y >= SnakeY[983] && Y <= SnakeY[983] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[984]  && X <= SnakeX[984] - 1 + (WIDTH * 2)) && (Y >= SnakeY[984] && Y <= SnakeY[984] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[985]  && X <= SnakeX[985] - 1 + (WIDTH * 2)) && (Y >= SnakeY[985] && Y <= SnakeY[985] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[986]  && X <= SnakeX[986] - 1 + (WIDTH * 2)) && (Y >= SnakeY[986] && Y <= SnakeY[986] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[987]  && X <= SnakeX[987] - 1 + (WIDTH * 2)) && (Y >= SnakeY[987] && Y <= SnakeY[987] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[988]  && X <= SnakeX[988] - 1 + (WIDTH * 2)) && (Y >= SnakeY[988] && Y <= SnakeY[988] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[989]  && X <= SnakeX[989] - 1 + (WIDTH * 2)) && (Y >= SnakeY[989] && Y <= SnakeY[989] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[990]  && X <= SnakeX[990] - 1 + (WIDTH * 2)) && (Y >= SnakeY[990] && Y <= SnakeY[990] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[991]  && X <= SnakeX[991] - 1 + (WIDTH * 2)) && (Y >= SnakeY[991] && Y <= SnakeY[991] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[992]  && X <= SnakeX[992] - 1 + (WIDTH * 2)) && (Y >= SnakeY[992] && Y <= SnakeY[992] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[993]  && X <= SnakeX[993] - 1 + (WIDTH * 2)) && (Y >= SnakeY[993] && Y <= SnakeY[993] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[994]  && X <= SnakeX[994] - 1 + (WIDTH * 2)) && (Y >= SnakeY[994] && Y <= SnakeY[994] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[995]  && X <= SnakeX[995] - 1 + (WIDTH * 2)) && (Y >= SnakeY[995] && Y <= SnakeY[995] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[996]  && X <= SnakeX[996] - 1 + (WIDTH * 2)) && (Y >= SnakeY[996] && Y <= SnakeY[996] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[997]  && X <= SnakeX[997] - 1 + (WIDTH * 2)) && (Y >= SnakeY[997] && Y <= SnakeY[997] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[998]  && X <= SnakeX[998] - 1 + (WIDTH * 2)) && (Y >= SnakeY[998] && Y <= SnakeY[998] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[999]  && X <= SnakeX[999] - 1 + (WIDTH * 2)) && (Y >= SnakeY[999] && Y <= SnakeY[999] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[1000]  && X <= SnakeX[1000] - 1 + (WIDTH * 2)) && (Y >= SnakeY[1000] && Y <= SnakeY[1000] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[1001]  && X <= SnakeX[1001] - 1 + (WIDTH * 2)) && (Y >= SnakeY[1001] && Y <= SnakeY[1001] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[1002]  && X <= SnakeX[1002] - 1 + (WIDTH * 2)) && (Y >= SnakeY[1002] && Y <= SnakeY[1002] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[1003]  && X <= SnakeX[1003] - 1 + (WIDTH * 2)) && (Y >= SnakeY[1003] && Y <= SnakeY[1003] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[1004]  && X <= SnakeX[1004] - 1 + (WIDTH * 2)) && (Y >= SnakeY[1004] && Y <= SnakeY[1004] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[1005]  && X <= SnakeX[1005] - 1 + (WIDTH * 2)) && (Y >= SnakeY[1005] && Y <= SnakeY[1005] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[1006]  && X <= SnakeX[1006] - 1 + (WIDTH * 2)) && (Y >= SnakeY[1006] && Y <= SnakeY[1006] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[1007]  && X <= SnakeX[1007] - 1 + (WIDTH * 2)) && (Y >= SnakeY[1007] && Y <= SnakeY[1007] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[1008]  && X <= SnakeX[1008] - 1 + (WIDTH * 2)) && (Y >= SnakeY[1008] && Y <= SnakeY[1008] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[1009]  && X <= SnakeX[1009] - 1 + (WIDTH * 2)) && (Y >= SnakeY[1009] && Y <= SnakeY[1009] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[1010]  && X <= SnakeX[1010] - 1 + (WIDTH * 2)) && (Y >= SnakeY[1010] && Y <= SnakeY[1010] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[1011]  && X <= SnakeX[1011] - 1 + (WIDTH * 2)) && (Y >= SnakeY[1011] && Y <= SnakeY[1011] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[1012]  && X <= SnakeX[1012] - 1 + (WIDTH * 2)) && (Y >= SnakeY[1012] && Y <= SnakeY[1012] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[1013]  && X <= SnakeX[1013] - 1 + (WIDTH * 2)) && (Y >= SnakeY[1013] && Y <= SnakeY[1013] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[1014]  && X <= SnakeX[1014] - 1 + (WIDTH * 2)) && (Y >= SnakeY[1014] && Y <= SnakeY[1014] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[1015]  && X <= SnakeX[1015] - 1 + (WIDTH * 2)) && (Y >= SnakeY[1015] && Y <= SnakeY[1015] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[1016]  && X <= SnakeX[1016] - 1 + (WIDTH * 2)) && (Y >= SnakeY[1016] && Y <= SnakeY[1016] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[1017]  && X <= SnakeX[1017] - 1 + (WIDTH * 2)) && (Y >= SnakeY[1017] && Y <= SnakeY[1017] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[1018]  && X <= SnakeX[1018] - 1 + (WIDTH * 2)) && (Y >= SnakeY[1018] && Y <= SnakeY[1018] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[1019]  && X <= SnakeX[1019] - 1 + (WIDTH * 2)) && (Y >= SnakeY[1019] && Y <= SnakeY[1019] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[1020]  && X <= SnakeX[1020] - 1 + (WIDTH * 2)) && (Y >= SnakeY[1020] && Y <= SnakeY[1020] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[1021]  && X <= SnakeX[1021] - 1 + (WIDTH * 2)) && (Y >= SnakeY[1021] && Y <= SnakeY[1021] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[1022]  && X <= SnakeX[1022] - 1 + (WIDTH * 2)) && (Y >= SnakeY[1022] && Y <= SnakeY[1022] - 1 + (WIDTH *2)) ||
                            (X >= SnakeX[1023]  && X <= SnakeX[1023] - 1 + (WIDTH * 2)) && (Y >= SnakeY[1023] && Y <= SnakeY[1023] - 1 + (WIDTH *2))
                        ) : 0;

    assign field        = ((X >= MIN_WIDTH  && X < MAX_WIDTH)                    && (Y >= MIN_HEIGHT     && Y < MAX_HEIGHT));
    assign apple        = (
                ( (X >= AppleX+10 && X <= AppleX+11 ) && (Y >= AppleY  && Y <= AppleY + 3))
           ||   ( (X >= AppleX+2 && X <= AppleX + 17 ) && (Y >= AppleY+4  && Y <= AppleY + 18))
    
            );  
    assign StartText    = isStart ? (
                            //NGU
                               ( (Y >=  90 && Y < 190 ) && ( ( X >= 210 && X < 230 ) || (X >= 290 && X < 310) ) )
                            || ( (X >= 230 && X < 240 ) && ( ( Y >= 100 && Y < 120 ) ) )
                            || ( (X >= 240 && X < 250 ) && ( ( Y >= 110 && Y < 130 ) ) )
                            || ( (X >= 250 && X < 260 ) && ( ( Y >= 120 && Y < 140 ) ) )
                            || ( (X >= 260 && X < 270 ) && ( ( Y >= 130 && Y < 150 ) ) )
                            || ( (X >= 270 && X < 280 ) && ( ( Y >= 140 && Y < 160 ) ) )
                            || ( (X >= 280 && X < 290 ) && ( ( Y >= 150 && Y < 170 ) ) )
                            || ( (Y >= 100 && Y < 180 ) && ( ( X >= 340 && X < 360 ) ) )
                            || ( (Y >=  90 && Y < 180 ) && ( ( X >= 470 && X < 490 ) || (X >= 550 && X < 570) ) )
                            || ( ( (Y >=  90 && Y < 110 ) || (Y >=  170 && Y < 190 ) ) && (X >= 360 && X < 440 ) )
                            || ( (Y >=  140 && Y < 160) && (X >= 390 && X < 440 ) )
                            || ( (Y >=  160 && Y < 170) && (X >= 420 && X < 440 ) )
                            || ( (Y >=  170 && Y < 190) && (X >= 490 && X < 550 ) )
                            //CPE
//                            || 
                            || ( (Y >= 220 && Y < 230) && ( (X >= 350 && X < 370 )  || (X >= 380 && X < 400) || (X >= 420 && X < 450) || (X >= 460 && X < 490) || (X >= 500 && X < 530) ||  (X >= 540 && X < 570) ) ) 
                            || ( (Y >= 230 && Y < 240) && ( (X >= 340 && X < 350 )  || (X >= 380 && X < 390) || (X >= 400 && X < 410) || (X >= 420 && X < 430) || (X >= 480 && X < 490) ||  (X >= 520 && X < 530) ||  ( X >= 560 && X < 570) ) ) 
                            || ( (Y >= 240 && Y < 250) && ( (X >= 340 && X < 350 )  || (X >= 380 && X < 400) || (X >= 420 && X < 440) || (X >= 460 && X < 490) || (X >= 500 && X < 530) ||  (X >= 540 && X < 570) ) ) 
                            || ( (Y >= 250 && Y < 260) && ( (X >= 340 && X < 350 )  || (X >= 380 && X < 390) || (X >= 420 && X < 430) || (X >= 460 && X < 470) || (X >= 500 && X < 510) ||  (X >= 540 && X < 550) ) ) 
                            || ( (Y >= 260 && Y < 270) && ( (X >= 350 && X < 370 )  || (X >= 380 && X < 390) || (X >= 420 && X < 450) || (X >= 460 && X < 490) || (X >= 500 && X < 530) ||  (X >= 540 && X < 570) ) ) 
                            
                            //PRESS ENTER
                              ) : 0;
    assign DeadText     = isDead ? (
                        //GAME
                            ( (Y >= 120 && Y < 140) && ( (X >= 80 && X < 160)  || (X >= 220 && X < 280) || (X >= 340 && X < 360) || (X >= 420 && X < 440) || (X >= 480 && X < 580) ) )
                         || ( (Y >= 140 && Y < 160) && ( (X >= 60 && X < 80 )  || (X >= 200 && X < 220) || (X >= 280 && X < 300) || (X >= 340 && X < 380) || (X >= 400 && X < 440) ||  ( X >= 480 && X < 500) ) )
                         || ( (Y >= 160 && Y < 180) && ( (X >= 60 && X < 80 )  || (X >= 120 && X < 160) || (X >= 200 && X < 220) || (X >= 280 && X < 300) || (X >= 340 && X < 360) ||  ( X >= 380 && X < 400) ||  ( X >= 420 && X < 440) || ( X >= 480 && X < 560) ) ) 
                         || ( (Y >= 180 && Y < 200) && ( (X >= 60 && X < 80 )  || (X >= 140 && X < 160) || (X >= 200 && X < 300) || (X >= 340 && X < 360) || (X >= 420 && X < 440) ||  ( X >= 480 && X < 500) ) )
                         || ( (Y >= 200 && Y < 220) && ( (X >= 80 && X < 140 ) || (X >= 200 && X < 220) || (X >= 280 && X < 300) || (X >= 340 && X < 360) || (X >= 420 && X < 440) ||  ( X >= 480 && X < 580) ) )
                         //OVER
                         || ( (Y >= 260 && Y < 280) && ( (X >= 80 && X < 140 )  || (X >= 200 && X < 220) || (X >= 280 && X < 300) || (X >= 340 && X < 440) ||  ( X >= 480 && X < 560) ) )
                         || ( (Y >= 280 && Y < 300) && ( (X >= 60 && X < 80  )  || (X >= 140 && X < 160) || (X >= 200 && X < 220) || (X >= 280 && X < 300) || (X >= 340 && X < 360) ||  ( X >= 480 && X < 500) || ( X >= 560 && X < 580)   ) )
                         || ( (Y >= 300 && Y < 320) && ( (X >= 60 && X < 80  )  || (X >= 140 && X < 160) || (X >= 200 && X < 220) || (X >= 280 && X < 300) || (X >= 340 && X < 420) ||  ( X >= 480 && X < 560) ) )
                         || ( (Y >= 320 && Y < 340) && ( (X >= 60 && X < 80  )  || (X >= 140 && X < 160) || (X >= 220 && X < 240) || (X >= 260 && X < 280) || (X >= 340 && X < 360) ||  ( X >= 480 && X < 500) ||  ( X >= 540 && X < 560) ) )
                         || ( (Y >= 340 && Y < 360) && ( (X >= 80 && X < 140 )  || (X >= 240 && X < 260) || (X >= 340 && X < 440) || ( X >= 480 && X < 500) ||  ( X >= 560 && X < 580) ) )
                         ) : 0;
    
endmodule
