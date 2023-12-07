`timescale 1ns / 1ps

module topModule(
    input clock,
    input UP,DOWN,LEFT,RIGHT,RESET,ENTER,
    input GAMEMODE,
    output [11:0]RGB,
    output Hsync,Vsync,
    output reg UP_LED,DOWN_LED,LEFT_LED,RIGHT_LED,RESET_LED,ENTER_LED,
    output [3:0]displaySegment,
    output [6:0]sevenSegment
    );
//    reg clock;
//    initial begin
//        clock = 0;
//        forever begin
//            #5 clock = ~clock;
//       end
//    end


    parameter HIGH = 1'b1;
    parameter LOW  = 1'b0;
    parameter MIN_WIDTH = 20;
    parameter MIN_HEIGHT = 20;
    parameter MAX_WIDTH = 610;
    parameter MAX_HEIGHT = 459;
    
    wire VGAClock,switchClock,activeVDO;
    wire [9:0]X,Y;
    wire [9:0]SnakeCount;
    wire [11:0]objColor;
    reg [11:0]RGB_REG;
    
    wire [4:0]obj;
    wire Testclock;
    wire isDead;
    
    
    ClockDivider VGADivider(
        .clock(clock),
        .dividerBy(2),
        .new_clock(VGAClock)
    );

    ClockDivider Test(
        .clock(clock),
        .dividerBy(2),
        .new_clock(Testclock)
    );    
    
    ClockDivider SwitchDivider(
        .clock(clock),
        .dividerBy(2000000),
        .new_clock(switchClock)
    );
    
    VGAController VGA(
        .clock(VGAClock),
        .reset(RESET),
        .activeVDO(activeVDO),
        .X(X),
        .Y(Y),
        .Hsync(Hsync),
        .Vsync(Vsync)
    ); 
    
    GameEngine SnakeGame(
        .switchClock(switchClock),
        .UP(UP),
        .DOWN(DOWN),
        .LEFT(LEFT),
        .RIGHT(RIGHT),
        .RESET(RESET),
        .ENTER(ENTER),
        .X(X),
        .Y(Y),
        .SnakeCount(SnakeCount),
        .isDead(isDead),
        .isStart(isStart),
        .GAMEMODE(GAMEMODE),
        .field(obj[0]),
        .DeadText(obj[1]),
        .StartText(obj[2]),
        .snakeBody(obj[3]),
        .apple(obj[4])
    );
    wire [5:0] Index;
    PixelGeneration DrawPixel(
        .VGAClock(Testclock),
        .video_on(activeVDO),
        .isDead(isDead),
        .isStart(isStart),
        .obj(obj),
//        .Data(appleData),
//        .rawApple(rawApple),
//        .dataBit(dataBit),
        .Index(Index),
        .RGB_COLORS(objColor)
    );
//    wire led;
    sevenSegment ScoreDisplay(
        .Clock(clock),
        .Count(SnakeCount),
        .Reset(RESET),
        .sevenSegment(sevenSegment),
//        .LED_activating_counter(led),
        .Anode_Activate(displaySegment)
    );

    
    always @ * begin
        UP_LED      <= UP    ? HIGH : LOW;
        DOWN_LED    <= DOWN  ? HIGH : LOW;
        LEFT_LED    <= LEFT  ? HIGH : LOW;
        RIGHT_LED   <= RIGHT ? HIGH : LOW;
        ENTER_LED   <= ENTER ? HIGH : LOW;
        RESET_LED   <= RESET ? HIGH : LOW;
    end
    
    always @ (posedge VGAClock)
        RGB_REG <= objColor;
    assign RGB = RGB_REG;
    
endmodule


