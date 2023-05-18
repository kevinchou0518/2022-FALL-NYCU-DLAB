`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Dept. of Computer Science, National Chiao Tung University
// Engineer: Chun-Jen Tsai
// 
// Create Date: 2018/11/01 11:16:50
// Design Name: 
// Module Name: lab6
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: This is a sample circuit to show you how to initialize an SRAM
//              with a pre-defined data file. Hit BTN0/BTN1 let you browse
//              through the data.
// 
// Dependencies: LCD_module, debounce
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module lab6(
  // General system I/O ports
  input  clk,
  input  reset_n,
  input  [3:0] usr_btn,
  output [3:0] usr_led,

  // 1602 LCD Module Interface
  input  uart_rx,
  output uart_tx
);
reg [19:0] result;
// declare system variables
wire [1:0]  btn_level, btn_pressed;
reg  [1:0]  prev_btn_level;

reg  [10:0] Amataddr =0;
reg  [10:0] Bmataddr =0;
reg  [7:0]  user_data;

// declare SRAM control signals
wire [10:0] sram_addr;
wire [10:0] sram_addr2;
wire [7:0]  data_in;
wire [7:0]  data_out;
wire [7:0]  data_out2;
wire        sram_we, sram_en;

localparam [2:0] S_MAIN_INIT = 0, S_MAIN_REPLY = 1, S_MAIN_WAIT = 2 ,S_MAIN_WAIT2 = 3, S_MAIN_CUL = 4;
                 
localparam [1:0] S_UART_IDLE = 0, S_UART_WAIT = 1,
                 S_UART_SEND = 2, S_UART_INCR = 3;
localparam [4:0] calinit = 0, calwait = 1, calwait2 = 2, calplus = 3, calcheck = 4, calprint1 = 5, calcheck2 = 6, calset2 = 7, 
                 calprint2 = 8, calset3 = 9, calprint3 = 10, calset4 = 11 , calprint4 = 12, caladdr = 13,calprint0 = 14, calset0 = 15;
reg [4:0] calstate,nextcalstate;
localparam REPLY_STR  = 0; // starting index of the hello message
localparam REPLY_LEN  = 40; // length of the hello message
localparam REPLY_STR1  = 40; // starting index of the hello message
localparam REPLY_LEN1  = 25; // length of the hello message
localparam MEM_SIZE   = REPLY_LEN + REPLY_LEN1;

// declare system variables
wire enter_pressed;
wire print_enable, print_done;
//reg [$clog2(MEM_SIZE):0] send_counter;
reg [$clog2(MEM_SIZE):0] send_counter2;
reg [2:0] P, P_next;
reg [1:0] Q, Q_next;
reg [7:0] data[0:MEM_SIZE-1];

reg  [0:REPLY_LEN*8-1]  msg1 = { "\015\012The matrix multiplication result is:\015\012"};
reg  [0:REPLY_LEN1*8-1]  msg2 = { "[", 8'h00," 11111",8'h00," ,",8'h00,"   ]\015\012[",8'h00," ]\015\012",8'h00 };

//reg  [19:0] num_reg;  // The key-in number register
//9 , 12 enter  19 end
// declare UART signals
wire transmit;
wire received;
wire [7:0] rx_byte;
reg  [7:0] rx_temp;  // if recevied is true, rx_temp latches rx_byte for ONLY ONE CLOCK CYCLE!
wire [7:0] tx_byte;
wire [7:0] echo_key; // keystrokes to be echoed to the terminal
wire is_num_key;
wire is_receiving;
wire is_transmitting;
wire recv_error;

reg cul_done = 0;

//reg state = 0;
/* The UART device takes a 100MHz clock to handle I/O at 9600 baudrate */
uart uart(
  .clk(clk),
  .rst(~reset_n),
  .rx(uart_rx),
  .tx(uart_tx),
  .transmit(transmit),
  .tx_byte(tx_byte),
  .received(received),
  .rx_byte(rx_byte),
  .is_receiving(is_receiving),
  .is_transmitting(is_transmitting),
  .recv_error(recv_error)
);
sram ram0(.clk(clk), .we(sram_we), .en(sram_en),
          .addr(sram_addr), .data_i(data_in), .data_o(data_out));
sram ram1(.clk(clk), .we(sram_we), .en(sram_en),
          .addr(sram_addr2), .data_i(data_in), .data_o(data_out2));
reg [19:0] answer;
integer idx;
always @(posedge clk) begin
  if (~reset_n) begin
    for (idx = 0; idx < REPLY_LEN; idx = idx + 1) data[idx] = msg1[idx*8 +: 8];
    for (idx = 0; idx < REPLY_LEN1; idx = idx + 1) data[idx+REPLY_LEN] = msg2[idx*8 +: 8];
  end
  else if (P == S_MAIN_CUL) begin
    data[REPLY_STR1+3] <= answer[19:16] + "0";
    data[REPLY_STR1+4] <= ((answer[15:12] > 9)? "7" : "0") + answer[15:12];
    data[REPLY_STR1+5] <= ((answer[11: 8] > 9)? "7" : "0") + answer[11: 8];
    data[REPLY_STR1+6] <= ((answer[ 7: 4] > 9)? "7" : "0") + answer[ 7: 4];
    data[REPLY_STR1+7] <= ((answer[ 3: 0] > 9)? "7" : "0") + answer[ 3: 0];
  end
end
always @(posedge clk) begin
    answer <= result;
end
assign usr_led = usr_btn;


always @(posedge clk) begin
  if (~reset_n) P <= S_MAIN_INIT;
  else P <= P_next;
end

always @(*) begin // FSM next-state logic
  case (P)
    S_MAIN_INIT: 
	   if (btn_pressed[1]) P_next = S_MAIN_WAIT;
		else P_next = S_MAIN_INIT;
    S_MAIN_WAIT: P_next = S_MAIN_WAIT2;
    S_MAIN_WAIT2: P_next = S_MAIN_CUL;
    S_MAIN_CUL:
        if (cul_done) P_next = S_MAIN_INIT;
        else P_next = S_MAIN_CUL;
    default: P_next = S_MAIN_INIT;
  endcase
end


assign print_enable =  (calstate != calprint1 && nextcalstate == calprint1) || (calstate != calprint2 && nextcalstate == calprint2)
                        || (calstate != calprint3 && nextcalstate == calprint3) || (calstate != calprint4 && nextcalstate == calprint4) || (calstate != calprint0 && nextcalstate == calprint0);
assign print_done = (tx_byte == 8'h0);

always @(posedge clk) begin
  if (~reset_n) Q <= S_UART_IDLE;
  else Q <= Q_next;
end

always @(*) begin // FSM next-state logic
  case (Q)
    S_UART_IDLE: // wait for the print_string flag
      if (print_enable) Q_next = S_UART_WAIT;
      else Q_next = S_UART_IDLE;
    S_UART_WAIT: // wait for the transmission of current data byte begins
      if (is_transmitting == 1) Q_next = S_UART_SEND;
      else Q_next = S_UART_WAIT;
    S_UART_SEND: // wait for the transmission of current data byte finishes
      if (is_transmitting == 0) Q_next = S_UART_INCR; // transmit next character
      else Q_next = S_UART_SEND;
    S_UART_INCR:
      if (tx_byte == 8'h0) Q_next = S_UART_IDLE; // string transmission ends
      else Q_next = S_UART_WAIT;
  endcase
end

reg [4:0] tempstate;
reg [2:0] mainstate;
always@(posedge clk) begin
    tempstate <= nextcalstate;
    mainstate <= P;
end

// FSM output logics: UART transmission control signals
assign transmit = (Q_next == S_UART_WAIT || print_enable);
//assign tx_byte  = (mainstate == S_MAIN_CUL) ? data[send_counter2] : data[send_counter];
assign tx_byte  = data[send_counter2] ;
//always@(posedge clk) begin
//    //transmit <= (Q_next == S_UART_WAIT || print_enable);
//    //tx_byte  <= (P == S_MAIN_CUL) ? data[send_counter2] : data[send_counter];
//end


//always @(posedge clk) begin
//  case (P_next)
//    S_MAIN_CUL: send_counter <= REPLY_STR1;
//    S_MAIN_INIT: send_counter <= REPLY_STR;
//    S_MAIN_WAIT: send_counter <= REPLY_STR1;
//    default: send_counter <= send_counter + (Q_next == S_UART_INCR);
//  endcase
//end

always @(posedge clk) begin
    case(tempstate) 
    calset0: send_counter2 <= REPLY_STR;
    calcheck: send_counter2 <= REPLY_STR1 + 2;
    calset2: send_counter2 <= REPLY_STR1 + 19;
    calset3: send_counter2 <= REPLY_STR1 + 13;
    calset4: send_counter2 <= REPLY_STR1 + 9;
    default:  send_counter2 <= send_counter2 + (Q_next == S_UART_INCR);
    endcase
end







//assign usr_led = 4'h00;

//LCD_module lcd0( 
//  .clk(clk),
//  .reset(~reset_n),
//  .row_A(row_A),
//  .row_B(row_B),
//  .LCD_E(LCD_E),
//  .LCD_RS(LCD_RS),
//  .LCD_RW(LCD_RW),
//  .LCD_D(LCD_D)
//);

debounce btn_db1(
  .clk(clk),
  .btn_input(usr_btn[1]),
  .btn_output(btn_level[1])
);

always @(posedge clk) begin
  if (~reset_n)
    prev_btn_level <= 2'b00;
  else
    prev_btn_level <= btn_level;
end

assign btn_pressed = (btn_level & ~prev_btn_level);




assign sram_we = usr_btn[3]; 
assign sram_en = (P_next != S_MAIN_INIT); 
assign sram_addr = Amataddr[10:0];
assign sram_addr2 = Bmataddr[10:0];

//assign sram_addr = 11'b0;
//assign sram_addr2 = 11'b0;
assign data_in = 8'b0; 


wire startcal;
assign startcal = (P != S_MAIN_CUL && P_next == S_MAIN_CUL);



reg [16:0] temp = 17'b0;
reg init,add,changeaddr,mul;
reg [16:0] t_data_out,t_data_out2;

always@(posedge clk) begin 
    if (~reset_n) begin
        t_data_out <= 17'b0;
    end
    else if (sram_en && !sram_we) begin
        t_data_out <= {9'b00,data_out};
    end
end

always@(posedge clk) begin 
    if (~reset_n) begin
        t_data_out2 <= 17'b0;
    end
    else if (sram_en && !sram_we) begin
        t_data_out2 <= {9'b00,data_out2};
    end
end


always @(posedge clk) begin 
    if( init == 1 ) begin
     Amataddr <= 0;
     Bmataddr <= 16;
     result <= 0;
    end
    else if( add == 1 ) begin
        //result <= result + temp;
        result <= result + t_data_out * t_data_out2;
        Amataddr <= Amataddr;
        Bmataddr <= Bmataddr;
    end
    else if(changeaddr == 1 ) begin
        if(Amataddr >= 12 && Bmataddr == 31) begin
            Amataddr <= Amataddr - 11;
            Bmataddr <= 16;
            result <= 0;
        end
        else if(Amataddr >= 12) begin
            Amataddr <= Amataddr - 12;
            Bmataddr <= Bmataddr + 1;
            result <= 0;
        end
        else begin
            Amataddr <= Amataddr + 4;
            Bmataddr <= Bmataddr + 1;
            result <= result;
        end
    end
    else begin
        Amataddr <= Amataddr;
        Bmataddr <= Bmataddr;
        result <= result;
    end
    calstate <= nextcalstate;
end

always @(*) begin
    init = 0;
    add = 0;
    changeaddr = 0;
    nextcalstate = 0;
    cul_done = 0;
    //mul = 0;
    case(calstate)
    calinit: begin
        if(startcal) nextcalstate = calset0;
        else begin
            init = 1;
            nextcalstate = calinit;
        end
    end
    calset0: begin
        nextcalstate = calprint0;
    end
    calprint0: begin
        if(print_done) nextcalstate = calwait;
        else nextcalstate = calprint0;
    end
    calwait: begin
        nextcalstate = calwait2;
    end
    calwait2: begin
        nextcalstate = calplus;
    end
    calplus: begin
        add = 1;
        nextcalstate = calcheck;
    end
    calcheck: begin
        if(Amataddr < 12) begin
            nextcalstate = caladdr;
        end
        else begin
            nextcalstate = calprint1;
        end
    end
    calprint1: begin
        if(print_done) begin
            nextcalstate = calcheck2;
        end
        else begin
            nextcalstate = calprint1;
        end
    end
    calcheck2: begin
        if(Amataddr == 15 && Bmataddr == 31) begin
            nextcalstate = calset2;
        end
        else if(Bmataddr == 31 ) begin
            nextcalstate = calset3;
        end
        else begin
            nextcalstate = calset4;
        end
    end
    calset2: begin
        nextcalstate = calprint2;
    end
    calprint2: begin
        if(print_done) begin
            cul_done = 1;
            nextcalstate = calinit;
        end
        else nextcalstate = calprint2;
    end
    calset3: begin
        nextcalstate = calprint3;
    end
    calprint3: begin
        if(print_done) begin
            nextcalstate = caladdr;
        end
        else nextcalstate = calprint3;
    end
    calset4: nextcalstate = calprint4;
    calprint4: begin
        if(print_done) begin
            nextcalstate = caladdr;
        end 
        else nextcalstate = calprint4;
    end
    caladdr: begin
        changeaddr = 1;
        nextcalstate = calwait;
    end
    default: begin
        nextcalstate = calinit;
    end 
    endcase
end

//always @(posedge clk) begin
//    temp <= t_data_out * t_data_out2;
//end




//reg [2:0] mulcounter;
//always@(posedge clk) begin
//    if(init == 1) begin
//        result <= 0;
//        answer <= 0;
//        Amataddr <= 0;
//        Bmataddr <= 0;
//    end
//    else if(add == 1) begin
//        result <= result + temp;
//        answer <= answer;
//        Amataddr <= Amataddr;
//        Bmataddr <= Bmataddr;
//    end
//    else if(changeaddr == 1) begin
//        if(Amataddr == 15 && Bmataddr == 31) begin
//            answer <= {answer[20*15-1:0],result};
//            result <= 0;
//            Amataddr <= Amataddr;
//            Bmataddr <= Bmataddr;
//        end
//        else if(Bmataddr == 31) begin
//            Bmataddr <= 16;
//            Amataddr <= Amataddr - 11;
//            answer <= {answer[20*15-1:0],result};
//            result <= 0;
//        end
//        else begin
//            if(Amataddr >= 12) begin
//                Bmataddr <= Bmataddr + 1;
//                Amataddr <= Amataddr - 12;
//                answer <= {answer[20*15-1:0],result};
//                result <= 0;
//            end
//            else begin
//                Bmataddr <= Bmataddr + 1;
//                Amataddr <= Amataddr + 4;
//                answer <= answer;
//                result <= result;
//            end
//        end
//    end
//    else begin
//        answer <= answer;
//        result <= result;
//        Amataddr <= Amataddr;
//        Bmataddr <= Bmataddr;
//    end
//    calstate <= nextcalstate;
//end

//always@(*) begin 
//    nextcalstate = 0;
//    add = 0;
//    init = 0;
//    changeaddr = 0;
//    cul_done = 0;
//    case(calstate)
//    calinit: begin
//        if(startcal) begin
//            init = 1;
//            nextcalstate = calplus;
//        end
//        else begin
//            init = 1;
//            nextcalstate = calinit;
//        end
//    end
//    calplus: begin
//        add = 1;
//        nextcalstate = caladdr;
//    end
//    caladdr: begin
//        changeaddr = 1;
//        nextcalstate = calcheck;
//    end 
//    calcheck: begin
//        if(Amataddr == 15 && Bmataddr == 31) begin
//            cul_done = 1;
//            nextcalstate = calinit;
//        end
//        else begin
//            cul_done = 0;
//            nextcalstate = calwait;
//        end
//    end
//    default: begin
//        nextcalstate = calinit;
//    end
//    endcase
//end


// FSM ouput logic: Fetch the data bus of sram[] for display



endmodule
