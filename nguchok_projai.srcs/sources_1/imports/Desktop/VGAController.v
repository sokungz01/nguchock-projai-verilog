module VGAController

	(
		input  wire clock, reset,
		output wire Hsync, Vsync, activeVDO,
		output wire [9:0] X, Y
	);
	
	// constant declarations for VGA sync parameters
	parameter H_DISPLAY       = 640; 
	parameter H_BACK          =  48; 
	parameter H_FRONT         =  16;
	parameter H_PULSE         =  96;
	parameter H_MAX           = H_DISPLAY + H_BACK + H_FRONT + H_PULSE - 1;
	parameter START_H_PULSE   = H_DISPLAY + H_FRONT;
	parameter END_H_PULSE     = H_DISPLAY + H_FRONT + H_PULSE - 1;
	
	parameter V_DISPLAY       = 480;
	parameter V_FRONT         =  10; 
	parameter V_BACK          =  33; 
	parameter V_PULSE         =   2;
	parameter V_MAX           = V_DISPLAY + V_FRONT + V_BACK + V_PULSE - 1;
    parameter START_V_PULSE   = V_DISPLAY + V_BACK;
	parameter END_V_PULSE     = V_DISPLAY + V_BACK + V_PULSE - 1;
	
	// registers to keep track of current pixel location
	reg [9:0] h_count_reg,h_count_next,v_count_reg ,v_count_next;
    reg vsync_reg, hsync_reg;
    wire vsync_next, hsync_next;
    
	initial begin
        v_count_reg <= 0;
        h_count_reg <= 0;
        vsync_reg   <= 0;
        hsync_reg   <= 0;
	end
 
	always @(posedge clock, posedge reset)
		if(reset)
		    begin
                    v_count_reg <= 0;
                    h_count_reg <= 0;
                    vsync_reg   <= 0;
                    hsync_reg   <= 0;
		    end
		else
		    begin
                    v_count_reg <= v_count_next;
                    h_count_reg <= h_count_next;
                    vsync_reg   <= vsync_next;
                    hsync_reg   <= hsync_next;
		    end
			
	always @ * begin
		h_count_next = (clock == 0) ? 
		               h_count_reg == H_MAX ? 0 : h_count_reg + 1
			         : h_count_reg;
		
		v_count_next = (clock == 0) && h_count_reg == H_MAX ? 
		               (v_count_reg == V_MAX ? 0 : v_count_reg + 1) 
			       : v_count_reg;
    end
		
    assign hsync_next = h_count_reg >= START_H_PULSE  && h_count_reg <= END_H_PULSE;
    assign vsync_next = v_count_reg >= START_V_PULSE  && v_count_reg <= END_V_PULSE;
    assign activeVDO  = (h_count_reg < H_DISPLAY) && (v_count_reg < V_DISPLAY);
    assign Hsync      = hsync_reg;
    assign Vsync      = vsync_reg;
    assign X          = h_count_reg;
    assign Y          = v_count_reg;
 
 
endmodule
 