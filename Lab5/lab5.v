`timescale 1ns / 1ps
/////////////////////////////////////////////////////////
module lab5(
  input clk,
  input reset_n,
  input [3:0] usr_btn,
  output [3:0] usr_led,
  output LCD_RS,
  output LCD_RW,
  output LCD_E,
  output [3:0] LCD_D
);

// turn off all the LEDs
assign usr_led = 4'b0000;

wire btn_level, btn_pressed;
reg prev_btn_level;
//reg [127:0] row_A = "Press BTN3 to   "; // Initialize the text of the first row. 
reg [127:0] row_A = "                ";
reg [127:0] row_B = "                "; // Initialize the text of the second row.
LCD_module lcd0(
  .clk(clk),
  .reset(~reset_n),
  .row_A(row_A),
  .row_B(row_B),
  .LCD_E(LCD_E),
  .LCD_RS(LCD_RS),
  .LCD_RW(LCD_RW),
  .LCD_D(LCD_D)
);
    
debounce btn_db0(
  .clk(clk),
  .btn_input(usr_btn[3]),
  .btn_output(btn_level)
);
    
always @(posedge clk) begin
  if (~reset_n)
    prev_btn_level <= 1;
  else
    prev_btn_level <= btn_level;
end
assign btn_pressed = (btn_level == 1 && prev_btn_level == 0);

reg [16*25-1:0] storage=0;

reg [15:0] adder;
reg [5:0] state=0;
reg [3:0] num1=1;
reg [3:0] num2=0;
reg [3:0] num3=2;
reg [3:0] num4=0;
reg enable=0;
reg[32:0] timer=0;
reg state1=0;
always@(posedge clk) begin
    if(~reset_n) begin
        num1 <= 1;
        num2 <= 0;
        num3 <= 2;
        num4 <= 0;
        state1 <= 0;
    end
    else begin
        case(state1)
        0: begin
            if(btn_pressed) begin
                state1 <= state1 + 1;
            end
            else state1 <= state1;
            if(timer==70000000) begin
                if(num1==9 && num2==1) begin
                    num1 <= 1;
                    num2 <= 0;
                end
                else if(num1==15) begin
                    num1 <= 0;
                    num2 <= num2 + 1;
                end
                else num1 <= num1 + 1;
                
                if(num3==9 && num4==1) begin
                    num3 <= 1;
                    num4 <= 0;
                end
                else if(num3==15) begin
                    num3 <= 0;
                    num4 <= num4 + 1;
                end
                else num3 <= num3 + 1;
            end
            else begin
                num1 <= num1;
                num2 <= num2;
                num3 <= num3;
                num4 <= num4;
            end
        end
        1: begin
            if(btn_pressed) begin
                state1 <= state1 - 1;
            end
            else state1 <= state1;
            if(timer==70000000) begin
                if(num1==1 && num2==0) begin
                    num1 <= 9;
                    num2 <= 1;
                end
                else if(num1==0) begin
                    num1 <= 15;
                    num2 <= num2 - 1;
                end
                else num1 <= num1 - 1;
                
                if(num3==1 && num4==0) begin
                    num3 <= 9;
                    num4 <= 1;
                end
                else if(num3==0) begin
                    num3 <= 15;
                    num4 <= num4 - 1;
                end
                else num3 <= num3 - 1;
            end
            else begin
                num1 <= num1;
                num2 <= num2;
                num3 <= num3;
                num4 <= num4;
            end
        end
        endcase
    end
end

always@(posedge clk) begin
    if(~reset_n) begin
        state <= 0;
    end
    else begin
         case(state) 
            0: begin
                storage[383:368] <= 0;
                storage[399:384] <= 1;
                enable <= 0;
                state <= state + 1;
            end
            1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39,41,43,45: begin
                adder <= storage[383:368] + storage[399:384];
                storage <= storage >> 16;
                state <= state + 1;
                enable <= 0;
            end 
            2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44,46: begin
                storage[399:384] <= adder;
                state <= state + 1;
                enable <= 0;
            end 
            47: begin
                if(timer==70000000) begin
                    storage <= {storage[15:0],storage[399:16]};
                end
                else storage <= storage;
                if(btn_pressed) begin
                    state <= state +1;
                end
                else state <= state;
            end
            48: begin
                if(timer==70000000) begin
                    storage <= {storage[383:0],storage[399:384]};
                end
                else storage <= storage;
                if(btn_pressed) begin
                    state <= state - 1;
                end
                else state <= state;
            end
            default: begin
                state <= 0;
            end
        endcase
    end
end




wire [31:0] upnum;
wire [31:0] downnum;
wire [15:0] number;
wire [15:0] number1;
translator n0(clk,num1,number[7:0]);
translator n1(clk,num2,number[15:8]);
translator n3(clk,num3,number1[7:0]);
translator n4(clk,num4,number1[15:8]);
translator t0(clk,storage[3:0],upnum[7:0]);
translator t1(clk,storage[7:4],upnum[15:8]);
translator t2(clk,storage[11:8],upnum[23:16]);
translator t3(clk,storage[15:12],upnum[31:24]);

translator t4(clk,storage[19:16],downnum[7:0]);
translator t5(clk,storage[23:20],downnum[15:8]);
translator t6(clk,storage[27:24],downnum[23:16]);
translator t7(clk,storage[31:28],downnum[31:24]);


always@(posedge clk) begin
    if(btn_pressed) timer <= 0;
    else timer <= (timer==70000000) ? 0 : timer + 1;
end

always@(upnum,downnum) begin
    row_A <= (timer==70000000)? {"Fibo #",number," is ",upnum} : row_A;
    row_B <= (timer==70000000)? {"Fibo #",number1," is ",downnum} : row_B;
end







endmodule
module translator(
    input clk,
    input  [3:0] twobits,
    output reg [7:0] ascii16
    );
always@(posedge clk) begin
    case(twobits)
        0: ascii16 <= 8'b00110000;
        1: ascii16 <= 8'b00110001;
        2: ascii16 <= 8'b00110010; 
        3: ascii16 <= 8'b00110011;
        4: ascii16 <= 8'b00110100;
        5: ascii16 <= 8'b00110101;
        6: ascii16 <= 8'b00110110;
        7: ascii16 <= 8'b00110111;
        8: ascii16 <= 8'b00111000;
        9: ascii16 <= 8'b00111001;
        10: ascii16 <= 8'b01000001;
        11: ascii16 <= 8'b01000010;
        12: ascii16 <= 8'b01000011;
        13: ascii16 <= 8'b01000100;
        14: ascii16 <= 8'b01000101;
        15: ascii16 <= 8'b01000110;
        default: ascii16 <= 8'b00110000;
    endcase
end
endmodule

module debounce(
    input clk,
    input btn_input,
    output btn_output
    );
    assign btn_output = btn_input;
endmodule