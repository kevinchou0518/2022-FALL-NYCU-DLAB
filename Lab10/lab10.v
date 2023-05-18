`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Dept. of Computer Science, National Chiao Tung University
// Engineer: Chun-Jen Tsai 
// 
// Create Date: 2018/12/11 16:04:41
// Design Name: 
// Module Name: lab9
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: A circuit that show the animation of a fish swimming in a seabed
//              scene on a screen through the VGA interface of the Arty I/O card.
// 
// Dependencies: vga_sync, clk_divider, sram 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module lab10(
    input  clk,
    input  reset_n,
    input  [3:0] usr_btn,
    output [3:0] usr_led,
    
    // VGA specific I/O ports
    output VGA_HSYNC,
    output VGA_VSYNC,
    output [3:0] VGA_RED,
    output [3:0] VGA_GREEN,
    output [3:0] VGA_BLUE
    );
    
wire [3:0] btn_pressed;
debounce d0(clk,usr_btn[0],btn_pressed[0]);
debounce d1(clk,usr_btn[1],btn_pressed[1]);
debounce d2(clk,usr_btn[2],btn_pressed[2]);
debounce d3(clk,usr_btn[3],btn_pressed[3]);

// Declare system variables
reg  [31:0] fish_clock;
reg  [31:0] fish_clock2;
reg  [31:0] fish_clock3;
reg  [31:0] fish_clock4;
wire [9:0]  pos;
wire [9:0]  pos2;
wire [9:0]  pos3;
wire [9:0]  pos4;
wire        fish_region;
wire        fish_region2;
wire        fish_region3;
wire        fish_region4;

// declare SRAM control signals
wire [16:0] sram_addr;
wire [16:0] sram_addr2;
wire [16:0] sram_addr3;
wire [16:0] sram_addr4;
wire [11:0] data_in;
wire [11:0] data_in2;
wire [11:0] data_in3;
wire [11:0] data_in4;
wire [11:0] data_out;
wire [11:0] data_out2;
wire [11:0] data_out3;
wire [11:0] data_out4;
wire        sram_we, sram_we2, sram_we3, sram_we4, sram_en;

// General VGA control signals
wire vga_clk;         // 50MHz clock for VGA control
wire video_on;        // when video_on is 0, the VGA controller is sending
                      // synchronization signals to the display device.
  
wire pixel_tick;      // when pixel tick is 1, we must update the RGB value
                      // based for the new coordinate (pixel_x, pixel_y)
  
wire [9:0] pixel_x;   // x coordinate of the next pixel (between 0 ~ 639) 
wire [9:0] pixel_y;   // y coordinate of the next pixel (between 0 ~ 479)
  
reg  [11:0] rgb_reg;  // RGB value for the current pixel
reg  [11:0] rgb_next; // RGB value for the next pixel

  
// Application-specific VGA signals
reg  [17:0] pixel_addr;
reg  [17:0] pixel_addr2;
reg  [17:0] pixel_addr3;
reg  [17:0] pixel_addr4;
// Declare the video buffer size
localparam VBUF_W = 320; // video buffer width
localparam VBUF_H = 240; // video buffer height

// Set parameters for the fish images
localparam FISH_VPOS   = 64; // Vertical location of the fish in the sea image.
localparam FISH_VPOS2   = 150;
localparam FISH_VPOS3   = 10;
localparam FISH_VPOS4   = 64;
localparam FISH_W      = 64; // Width of the fish.
localparam FISH_H      = 32; // Height of the fish.
localparam FISH_W2      = 64; // Width of the fish.
localparam FISH_H2      = 32; // Height of the fish.
localparam FISH_W3      = 48; // Width of the fish.
localparam FISH_H3      = 33; // Height of the fish.
localparam FISH_W4      = 32; // Width of the fish.
localparam FISH_H4      = 36; // Height of the fish.
reg [17:0] fish_addr[0:2];   // Address array for up to 8 fish images.
reg [17:0] fish_addr2[0:2]; 
reg [17:0] fish_addr3[0:2];
reg [17:0] fish_addr4[0:2]; 

// Initializes the fish images starting addresses.
// Note: System Verilog has an easier way to initialize an array,
//       but we are using Verilog 2001 :(
initial begin
  fish_addr[0] = 18'd0;         /* Addr for fish image #1 */
  fish_addr[1] = FISH_W*FISH_H; /* Addr for fish image #2 */
  fish_addr[2] = FISH_W*FISH_H*2;
  fish_addr[3] = FISH_W*FISH_H*3;
  fish_addr[4] = FISH_W*FISH_H*4;
  fish_addr[5] = FISH_W*FISH_H*5;
  fish_addr[6] = FISH_W*FISH_H*6;
  fish_addr[7] = FISH_W*FISH_H*7;
end
initial begin
  fish_addr3[0] = FISH_W*FISH_H*8;         /* Addr for fish image #1 */
  fish_addr3[1] = FISH_W*FISH_H*8 + FISH_W3*FISH_H3;
  fish_addr3[2] = FISH_W*FISH_H*8 + FISH_W3*FISH_H3*2;
  fish_addr3[3] = FISH_W*FISH_H*8 + FISH_W3*FISH_H3*3;
  fish_addr3[4] = FISH_W*FISH_H*8 + FISH_W3*FISH_H3*4;
  fish_addr3[5] = FISH_W*FISH_H*8 + FISH_W3*FISH_H3*5;
  fish_addr3[6] = FISH_W*FISH_H*8 + FISH_W3*FISH_H3*6;
  fish_addr3[7] = FISH_W*FISH_H*8 + FISH_W3*FISH_H3*7;
end
initial begin
    fish_addr4[0] = VBUF_W*VBUF_H + 18'd0; 
    fish_addr4[1] = VBUF_W*VBUF_H + FISH_W4*FISH_H4;
    fish_addr4[2] = VBUF_W*VBUF_H + FISH_W4*FISH_H4*2;
    fish_addr4[3] = VBUF_W*VBUF_H + FISH_W4*FISH_H4*3;
    fish_addr4[4] = VBUF_W*VBUF_H + FISH_W4*FISH_H4*4;
    fish_addr4[5] = VBUF_W*VBUF_H + FISH_W4*FISH_H4*5;
    fish_addr4[6] = VBUF_W*VBUF_H + FISH_W4*FISH_H4*6;
    fish_addr4[7] = VBUF_W*VBUF_H + FISH_W4*FISH_H4*7;
end
// Instiantiate the VGA sync signal generator
vga_sync vs0(
  .clk(vga_clk), .reset(~reset_n), .oHS(VGA_HSYNC), .oVS(VGA_VSYNC),
  .visible(video_on), .p_tick(pixel_tick),
  .pixel_x(pixel_x), .pixel_y(pixel_y)
);

clk_divider#(2) clk_divider0(
  .clk(clk),
  .reset(~reset_n),
  .clk_out(vga_clk)
);

// ------------------------------------------------------------------------
// The following code describes an initialized SRAM memory block that
// stores a 320x240 12-bit seabed image, plus two 64x32 fish images.
sram #(.DATA_WIDTH(12), .ADDR_WIDTH(18), .RAM_SIZE(VBUF_W*VBUF_H+FISH_W4*FISH_H4*8), .FILE("images1.mem"))
  ram0 (.clk(clk), .we(sram_we), .we2(sram_we2), .en(sram_en),
          .addr(sram_addr), .data_i(data_in), .data_o(data_out),
          .addr2(sram_addr2), .data_i2(data_in2), .data_o2(data_out2));
sram #(.DATA_WIDTH(12), .ADDR_WIDTH(18), .RAM_SIZE(FISH_W*FISH_H*8 + FISH_W3*FISH_H3*5), .FILE("images2.mem"))
  ram1 (.clk(clk), .we(sram_we3), .we2(sram_we4), .en(sram_en),
          .addr(sram_addr3), .data_i(data_in3), .data_o(data_out3),
          .addr2(sram_addr4), .data_i2(data_in4), .data_o2(data_out4)); 
assign sram_we = (btn_pressed[3] == 1)? btn_pressed[2]: btn_pressed[3];; // In this demo, we do not write the SRAM. However, if
                             // you set 'sram_we' to 0, Vivado fails to synthesize
                             // ram0 as a BRAM -- this is a bug in Vivado.
assign sram_we2 = (btn_pressed[3] == 1)? btn_pressed[2]: btn_pressed[3];
assign sram_we3 = (btn_pressed[3] == 1)? btn_pressed[2]: btn_pressed[3];
assign sram_we4 = (btn_pressed[3] == 1)? btn_pressed[2]: btn_pressed[3];


assign sram_en = 1;          // Here, we always enable the SRAM block.
assign sram_addr = pixel_addr;
assign sram_addr2 = pixel_addr2;
assign sram_addr3 = pixel_addr3;
assign sram_addr4 = pixel_addr4;
assign data_in = 12'h000; // SRAM is read-only so we tie inputs to zeros.
// End of the SRAM memory block.
// ------------------------------------------------------------------------

// VGA color pixel generator
assign {VGA_RED, VGA_GREEN, VGA_BLUE} = rgb_reg;

// ------------------------------------------------------------------------
// An animation clock for the motion of the fish, upper bits of the
// fish clock is the x position of the fish on the VGA screen.
// Note that the fish will move one screen pixel every 2^20 clock cycles,
// or 10.49 msec
assign pos = fish_clock[31:20]; // the x position of the right edge of the fish image
                                // in the 640x480 VGA screen
assign pos2 = fish_clock2[31:20];
assign pos3 = fish_clock3[31:20];
assign pos4 = fish_clock4[31:20];
localparam [2:0] S_IDLE = 0, S_SPEED = 1, S_BG = 2;
reg [2:0] control,nextcontrol;

always@(*)begin
        case(control)
        S_IDLE: if(btn_pressed[3]) nextcontrol <= S_SPEED;
                else nextcontrol <= S_IDLE;
        S_SPEED: if(btn_pressed[3]) nextcontrol <= S_BG;
                else nextcontrol <= S_SPEED;
        S_BG: if(btn_pressed[3]) nextcontrol <= S_IDLE;
                else nextcontrol <= S_BG;
        default: nextcontrol <= S_IDLE;
        endcase
end
always@(posedge clk)begin
    if(~reset_n)begin
        control <= 0;
    end
    else begin
        control <= nextcontrol;
    end
end
reg [3:0] currentfish=0;
reg [5:0] f1speed = 1;
reg [5:0] f2speed = 1;
reg [5:0] f3speed = 1;
reg [5:0] f4speed = 1;
always@(posedge clk)begin
    if(control == S_SPEED) begin
        if(btn_pressed[2]) begin
            if(currentfish == 4) currentfish = 1;
            else currentfish = currentfish + 1;
        end
        else begin
            currentfish <= currentfish;
        end
    end
    else begin 
        currentfish = 0;
    end
end
always@(posedge clk)begin
    if(~reset_n) begin
        f1speed <= 1;
        f2speed <= 1;
        f3speed <= 1;
        f4speed <= 1;
        //f1speed <= 1;
    end
    else if(control == S_SPEED) begin
        if(currentfish == 1) begin
            if(btn_pressed[1]) begin
                f1speed <= (f1speed == 1)? 1:f1speed - 1;
            end
            else if(btn_pressed[0]) begin
                f1speed <= (f1speed == 5)? 5:f1speed + 1;
            end
            else begin
                f1speed <= f1speed;
            end
        end
        if(currentfish == 2) begin
            if(btn_pressed[1]) begin
                f2speed <= (f2speed == 1)? 1:f2speed - 1;
            end
            else if(btn_pressed[0]) begin
                f2speed <= (f2speed == 5)? 5:f2speed + 1;
            end
            else begin
                f2speed <= f2speed;
            end
        end
        if(currentfish == 3) begin
            if(btn_pressed[1]) begin
                f3speed <= (f3speed == 1)? 1:f3speed - 1;
            end
            else if(btn_pressed[0]) begin
                f3speed <= (f3speed == 5)? 5:f3speed + 1;
            end
            else begin
                f3speed <= f3speed;
            end
        end
        if(currentfish == 4) begin
            if(btn_pressed[1]) begin
                f4speed <= (f4speed == 1)? 1:f4speed - 1;
            end
            else if(btn_pressed[0]) begin
                f4speed <= (f4speed == 5)? 5:f4speed + 1;
            end
            else begin
                f4speed <= f4speed;
            end
        end
    end
end
reg [3:0] bgtype;
always@(posedge clk) begin
    if(~reset_n) begin
        bgtype <= 0;
    end
    else begin
        if(btn_pressed[2] && control == S_BG) begin
            if(bgtype == 4) begin
                bgtype <= 0;
            end
            else begin
                bgtype <= bgtype + 1;
            end
        end
        else begin
            bgtype <= bgtype;
        end
    end
end




always @(posedge clk) begin
  if (~reset_n || fish_clock[31:21] > VBUF_W + FISH_W)
    fish_clock <= 0;
  else
    fish_clock <= fish_clock + f1speed;
end
always @(posedge clk) begin
  if (~reset_n || fish_clock2[31:21] > VBUF_W + FISH_W)
    fish_clock2 <= 0;
  else
    fish_clock2 <= fish_clock2 + f2speed;
end
always @(posedge clk) begin
  if (~reset_n || fish_clock3[31:21] > VBUF_W + FISH_W)
    fish_clock3 <= 0;
  else
    fish_clock3 <= fish_clock3 + f3speed;
end
always @(posedge clk) begin
  if (~reset_n || fish_clock4[31:21] < 0) begin
    fish_clock4[31:21] <= VBUF_W - 200;
    fish_clock4[20:0] <= 0;
  end
  else
    fish_clock4 <= fish_clock4 - f4speed;
end
// End of the animation clock code.
// ------------------------------------------------------------------------

// ------------------------------------------------------------------------
// Video frame buffer address generation unit (AGU) with scaling control
// Note that the width x height of the fish image is 64x32, when scaled-up
// on the screen, it becomes 128x64. 'pos' specifies the right edge of the
// fish image.
wire [11:0] vposf3;
assign vposf3 = vfish_clock[31:21];
reg [31:0] vfish_clock;
reg state;
always@(posedge clk)begin
    if(state == 1)begin
        if(vfish_clock[31:21] < 10)begin
            state <= 0;
            vfish_clock = vfish_clock + 1;
        end
        else begin
            state <= 1;
            vfish_clock = vfish_clock - 1;
        end
    end
    else begin
        if(vfish_clock[31:21] > VBUF_H - FISH_H3)begin
            state <= 1;
            vfish_clock = vfish_clock - 1;
        end
        else begin
            state <= 0;
            vfish_clock = vfish_clock + 1;
        end
    end
end
assign fish_region =
           pixel_y >= (FISH_VPOS<<1) && pixel_y < (FISH_VPOS+FISH_H)<<1 &&
           (pixel_x + 127) >= pos && pixel_x < pos + 1;
assign fish_region2 =
           pixel_y >= (FISH_VPOS2<<1) && pixel_y < (FISH_VPOS2+FISH_H2)<<1 &&
           (pixel_x + 127) >= pos2 && pixel_x < pos2 + 1;
assign fish_region3 =
           pixel_y >= (vposf3<<1) && pixel_y < (vposf3+FISH_H3)<<1 &&
           (pixel_x + 95) >= pos3 && pixel_x < pos3 + 1;
//           pixel_y >= (FISH_VPOS3<<1) && pixel_y < (FISH_VPOS3+FISH_H3)<<1 &&
//           (pixel_x + 95) >= pos3 && pixel_x < pos3 + 1;
assign fish_region4 =
           pixel_y >= (FISH_VPOS4<<1) && pixel_y < (FISH_VPOS4+FISH_H4)<<1 &&
           (pixel_x + 63) >= pos4 && pixel_x < pos4 + 1;
always @ (posedge clk) begin
  if (~reset_n) begin
    pixel_addr <= 0;
    pixel_addr2 <= 0;
    pixel_addr3 <= 0;
    pixel_addr4 <= 0;
  end
//  else if (fish_region) begin
//    pixel_addr <= (pixel_y >> 1) * VBUF_W + (pixel_x >> 1);
//    pixel_addr2 <= fish_addr[fish_clock[25:23]] +
//                  ((pixel_y>>1)-FISH_VPOS)*FISH_W +
//                  ((pixel_x +(FISH_W*2-1)-pos)>>1);
//  end
  else begin
    // Scale up a 320x240 image for the 640x480 display.
    // (pixel_x, pixel_y) ranges from (0,0) to (639, 479)
    pixel_addr <= (pixel_y >> 1) * VBUF_W + (pixel_x >> 1);
    pixel_addr2 <= fish_addr4[fish_clock4[25:23]] +
                  ((pixel_y>>1)-FISH_VPOS4)*FISH_W4 +
                  ((pixel_x +(FISH_W4*2-1)-pos4)>>1);
    
    pixel_addr4 <= fish_addr3[fish_clock3[25:23]] +
                  ((pixel_y>>1)-vposf3)*FISH_W3 +
                  ((pixel_x +(FISH_W3*2-1)-pos3)>>1);
    if(fish_region) begin
        pixel_addr3 <= fish_addr[fish_clock[25:23]] +
                  ((pixel_y>>1)-FISH_VPOS)*FISH_W +
                  ((pixel_x +(FISH_W*2-1)-pos)>>1);
    end
    else begin
        pixel_addr3 <= fish_addr[fish_clock2[25:23]] +
                  ((pixel_y>>1)-FISH_VPOS2)*FISH_W2 +
                  ((pixel_x +(FISH_W2*2-1)-pos2)>>1);
    end
  end
end
// End of the AGU code.
// ------------------------------------------------------------------------

// ------------------------------------------------------------------------
// Send the video data in the sram to the VGA controller
always @(posedge clk) begin
  if (pixel_tick) rgb_reg <= rgb_next;
end

always @(*) begin
  if (~video_on)
    rgb_next = 12'h000; // Synchronization period, must set RGB values to zero.
  else if(fish_region && data_out3 != 12'h0f0) begin
    if(currentfish == 1)begin
        rgb_next = 12'hfff;
    end
    else rgb_next = data_out3; // RGB value at (pixel_x, pixel_y)
  end
  else if(fish_region2 && data_out3 != 12'h0f0 && data_out3 != 12'h000) begin
    //rgb_next = data_out3;
    if(currentfish == 2)begin
        rgb_next = 12'hfff;
    end
    else rgb_next = data_out3;
  end
  else if(fish_region3 && data_out4 != 12'h0f0 && data_out4 != 12'h000) begin
    //rgb_next = data_out4;
    if(currentfish == 3)begin
        rgb_next = 12'hfff;
    end
    else rgb_next = data_out4;
  end
  else if(fish_region4 && data_out2 != 12'h0f0) begin
    //rgb_next = data_out2;
    if(currentfish == 4)begin
        rgb_next = 12'hfff;
    end
    else rgb_next = data_out2;
  end
  else begin
//    if(data_out[11:8] < adj) rgb_next[11:8] == 4'h0;
//    else if(data_out
//    else 
//    if(data_out[7:4] < adj)
//    else 
    if(bgtype == 0) begin
        rgb_next = data_out;
    end
    else if(bgtype == 1) begin
        rgb_next[11:8] <= data_out[11:8];
        rgb_next[7:4] <= data_out[7:4];
        rgb_next[3:0] <= 0;
    end
    else if(bgtype == 2) begin
        rgb_next[11:8] <= 0;
        rgb_next[7:4] <= data_out[7:4];
        rgb_next[3:0] <= data_out[3:0];
    end
    else if(bgtype == 3) begin
        rgb_next[11:8] <= data_out[11:8];
        rgb_next[7:4] <= 0;
        rgb_next[3:0] <= data_out[3:0];
    end
    else if(bgtype == 4) begin
        rgb_next[11:8] <= 4'hf - data_out[11:8];
        rgb_next[7:4] <= 4'hf - data_out[7:4];
        rgb_next[3:0] <= 4'hf - data_out[3:0];
    end
    else rgb_next = data_out;
    //rgb_next = data_out;
  end
end
// End of the video data display code.
// ------------------------------------------------------------------------

endmodule
