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
    parameter SNAKE_MAX_SIZE        = 256;
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
    reg [9:0]SnakeX[255:0];
    reg [9:0]SnakeY[255:0];

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
                            (X >= SnakeX[255]  && X <= SnakeX[255] - 1 + (WIDTH * 2)) && (Y >= SnakeY[255] && Y <= SnakeY[255] - 1 + (WIDTH *2))
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
