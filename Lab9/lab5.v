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
reg [127:0] row_A = "Press BTN3 to   "; // Initialize the text of the first row. 
reg [127:0] row_B = "show a message.."; // Initialize the text of the second row.

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
reg st= 1'b0;
reg [63:0] num = "33333333";
reg [63:0] innum = "00000000";
reg [63:0] innum2 = "33333333";
reg [63:0] innum3 = "66666666";
wire [127:0] hash; 
wire [127:0] hash2;
wire [127:0] hash3;
wire [63:0] password;
wire [63:0] password2;
wire [63:0] password3;
//reg [127:0] passwd_hash = 128'h7a1f54db682b4dd097e73bd7ac9b25ca;
reg [127:0] passwd_hash = 128'hE8CD0953ABDFDE433DFEC7FAA70DF7F6;


reg [127:0] t_hash;
reg [127:0] t_hash2;
reg [127:0] t_hash3;
reg [63:0] t_password;
reg [63:0] t_password2;
reg [63:0] t_password3;
reg [63:0] t_innum;
reg [63:0] t_innum2;
reg [63:0] t_innum3;
always@(posedge clk) begin
    t_innum <= innum;
    t_innum2 <= innum2;
    t_innum3 <= innum3;
    t_hash <= hash;
    t_hash2 <= hash2;
    t_hash3 <= hash3;
    t_password <= password;
    t_password2 <= password2;
    t_password3 <= password3;
end 


pipeline_md5 t0(clk,t_innum,hash,password);
pipeline_md5 t1(clk,t_innum2,hash2,password2);
pipeline_md5 t2(clk,t_innum3,hash3,password3);
reg [63:0] f_password;
reg done;
reg [4:0] counter = 0;
always@(posedge clk) begin
    if(st == 1) begin
//        if(counter == 1) begin
//            counter <= 0;
//        end
//        else begin
//            counter <= counter + 1;
//        end
        counter <= 1;
    end
    else counter <= 0;
end
always@(posedge clk) begin
    if(~reset_n) begin
        f_password <= "00000000";
        done <= 0;
    end
    else if(st == 1 && done != 1) begin
        if(t_hash == passwd_hash) begin
            f_password <= t_password;
            done <= 1;
        end 
        else if(t_hash2 == passwd_hash) begin
            f_password <= t_password2;
            done <= 1;
        end
        else if(t_hash3 == passwd_hash) begin
            f_password <= t_password3;
            done <= 1;
        end
    end
    else done <= done;
end
reg [71:0] timer;
always@(posedge clk) begin
    if(~reset_n) begin
        timer <= "000000000";
    end
    else if(done == 1)begin
        timer <= timer;
    end
    else if(st == 1) begin
        if(timer[7:0] == "9") begin
            timer[7:0] <= "0";
            if(timer[15:8] == "9") begin
                timer[15:8] <= "0";
                if(timer[23:16] == "9") begin
                    timer[23:16] <= "0";
                    if(timer[31:24] == "9") begin
                        timer[31:24] <= "0";
                        if(timer[39:32] == "9") begin
                            timer[39:32] <= "0";
                            if(timer[47:40] == "9") begin
                                timer[47:40] <= "0";
                                if(timer[55:48] == "9") begin
                                    timer[55:48] <= "0";
                                    if(timer[63:56] == "9") begin
                                        timer[63:56] <= "0";
                                        if(timer[71:64] == "9") begin
                                            timer[71:64] <= "0";
                                        end else timer[71:64] <= timer[71:64] + 1;
                                    end else timer[63:56] <= timer[63:56] + 1;
                                end else timer[55:48] <= timer[55:48] + 1;
                            end else timer[47:40] <= timer[47:40] + 1; 
                        end else timer[39:32] <= timer[39:32] + 1; 
                    end else timer[31:24] <= timer[31:24] + 1;
                end else timer[23:16] <= timer[23:16] + 1;
            end else timer[15:8] <= timer[15:8] + 1;
        end else timer[7:0] <= timer[7:0] + 1;
    end
end




always@(posedge clk) begin
    if(~reset_n) begin
        innum <= "00000000";
    end
    else if(counter == 1) begin
        if(innum[7:0] == "9") begin
            innum[7:0] <= "0";
            if(innum[15:8] == "9") begin
                innum[15:8] <= "0";
                if(innum[23:16] == "9") begin
                    innum[23:16] <= "0";
                    if(innum[31:24] == "9") begin
                        innum[31:24] <= "0";
                        if(innum[39:32] == "9") begin
                            innum[39:32] <= "0";
                            if(innum[47:40] == "9") begin
                                innum[47:40] <= "0";
                                if(innum[55:48] == "9") begin
                                    innum[55:48] <= "0";
                                    if(innum[63:56] == "9") begin
                                        innum[63:56] <= "0";
                                    end else innum[63:56] <= innum[63:56] + 1;
                                end else innum[55:48] <= innum[55:48] + 1;
                            end else innum[47:40] <= innum[47:40] + 1; 
                        end else innum[39:32] <= innum[39:32] + 1; 
                    end else innum[31:24] <= innum[31:24] + 1;
                end else innum[23:16] <= innum[23:16] + 1;
            end else innum[15:8] <= innum[15:8] + 1;
        end else innum[7:0] <= innum[7:0] + 1;
    end
end

always@(posedge clk) begin
    if(~reset_n) begin
        innum3 <= "66666666";
    end
    else if(counter == 1) begin
        if(innum3[7:0] == "9") begin
            innum3[7:0] <= "0";
            if(innum3[15:8] == "9") begin
                innum3[15:8] <= "0";
                if(innum3[23:16] == "9") begin
                    innum3[23:16] <= "0";
                    if(innum3[31:24] == "9") begin
                        innum3[31:24] <= "0";
                        if(innum3[39:32] == "9") begin
                            innum3[39:32] <= "0";
                            if(innum3[47:40] == "9") begin
                                innum3[47:40] <= "0";
                                if(innum3[55:48] == "9") begin
                                    innum3[55:48] <= "0";
                                    if(innum3[63:56] == "9") begin
                                        innum3[63:56] <= "0";
                                    end else innum3[63:56] <= innum3[63:56] + 1;
                                end else innum3[55:48] <= innum3[55:48] + 1;
                            end else innum3[47:40] <= innum3[47:40] + 1; 
                        end else innum3[39:32] <= innum3[39:32] + 1; 
                    end else innum3[31:24] <= innum3[31:24] + 1;
                end else innum3[23:16] <= innum3[23:16] + 1;
            end else innum3[15:8] <= innum3[15:8] + 1;
        end else innum3[7:0] <= innum3[7:0] + 1;
    end
end

always@(posedge clk) begin
    if(~reset_n) begin
        innum2 <= "33333333";
    end
    else if(counter == 1) begin
        if(innum2[7:0] == "9") begin
            innum2[7:0] <= "0";
            if(innum2[15:8] == "9") begin
                innum2[15:8] <= "0";
                if(innum2[23:16] == "9") begin
                    innum2[23:16] <= "0";
                    if(innum2[31:24] == "9") begin
                        innum2[31:24] <= "0";
                        if(innum2[39:32] == "9") begin
                            innum2[39:32] <= "0";
                            if(innum2[47:40] == "9") begin
                                innum2[47:40] <= "0";
                                if(innum2[55:48] == "9") begin
                                    innum2[55:48] <= "0";
                                    if(innum2[63:56] == "9") begin
                                        innum2[63:56] <= "0";
                                    end else innum2[63:56] <= innum2[63:56] + 1;
                                end else innum2[55:48] <= innum2[55:48] + 1;
                            end else innum2[47:40] <= innum2[47:40] + 1; 
                        end else innum2[39:32] <= innum2[39:32] + 1; 
                    end else innum2[31:24] <= innum2[31:24] + 1;
                end else innum2[23:16] <= innum2[23:16] + 1;
            end else innum2[15:8] <= innum2[15:8] + 1;
        end else innum2[7:0] <= innum2[7:0] + 1;
    end
end

always@(posedge clk) begin 
    if(~reset_n) begin
        row_A <= "Press BTN3 to   ";
        row_B <= "show a message..";
    end
    else if(done == 1) begin
        row_A <= {"Passwd: ",f_password};
        row_B <= {"Time: 000",timer[71:40]," ms"};
    end
    else if(st == 1) begin
        row_A <= {"Passwd: ",f_password};
        row_B <= {    ((hash[127:124] > 9)? "7" : "0") + hash[127:124],
                      ((hash[123:120] > 9)? "7" : "0") + hash[123:120],
                      ((hash[119:116] > 9)? "7" : "0") + hash[119:116],
                      ((hash[115:112] > 9)? "7" : "0") + hash[115:112],
                      ((hash[111:108] > 9)? "7" : "0") + hash[111:108],
                      ((hash[107:104] > 9)? "7" : "0") + hash[107:104],
                      ((hash[103:100] > 9)? "7" : "0") + hash[103:100],
                      ((hash[99:96] > 9)? "7" : "0") + hash[99:96],
                      ((hash[95:92] > 9)? "7" : "0") + hash[95:92],
                      ((hash[91:88] > 9)? "7" : "0") + hash[91:88],
                      ((hash[87:84] > 9)? "7" : "0") + hash[87:84],
                      ((hash[83:80] > 9)? "7" : "0") + hash[83:80],
                      ((hash[79:76] > 9)? "7" : "0") + hash[79:76],
                      ((hash[75:72] > 9)? "7" : "0") + hash[75:72],
                      ((hash[71:68] > 9)? "7" : "0") + hash[71:68],
                      ((hash[67:64] > 9)? "7" : "0") + hash[67:64]};
    end
end


always @(posedge clk) begin
  if (~reset_n) begin
    // Initialize the text when the user hit the reset button
    st <= 0;
    
  end 
  else if (btn_pressed) begin
    st <= 1;
//    row_A <= {    ((hash[127:124] > 9)? "7" : "0") + hash[127:124],
//                  ((hash[123:120] > 9)? "7" : "0") + hash[123:120],
//                  ((hash[119:116] > 9)? "7" : "0") + hash[119:116],
//                  ((hash[115:112] > 9)? "7" : "0") + hash[115:112],
//                  ((hash[111:108] > 9)? "7" : "0") + hash[111:108],
//                  ((hash[107:104] > 9)? "7" : "0") + hash[107:104],
//                  ((hash[103:100] > 9)? "7" : "0") + hash[103:100],
//                  ((hash[99:96] > 9)? "7" : "0") + hash[99:96],
//                  ((hash[95:92] > 9)? "7" : "0") + hash[95:92],
//                  ((hash[91:88] > 9)? "7" : "0") + hash[91:88],
//                  ((hash[87:84] > 9)? "7" : "0") + hash[87:84],
//                  ((hash[83:80] > 9)? "7" : "0") + hash[83:80],
//                  ((hash[79:76] > 9)? "7" : "0") + hash[79:76],
//                  ((hash[75:72] > 9)? "7" : "0") + hash[75:72],
//                  ((hash[71:68] > 9)? "7" : "0") + hash[71:68],
//                  ((hash[67:64] > 9)? "7" : "0") + hash[67:64]};
                  
//    row_B <= {    ((hash[63:60] > 9)? "7" : "0") + hash[63:60],
//                  ((hash[59:56] > 9)? "7" : "0") + hash[59:56],
//                  ((hash[55:52] > 9)? "7" : "0") + hash[55:52],
//                  ((hash[51:48] > 9)? "7" : "0") + hash[51:48],
//                  ((hash[47:44] > 9)? "7" : "0") + hash[47:44],
//                  ((hash[43:40] > 9)? "7" : "0") + hash[43:40],
//                  ((hash[39:36] > 9)? "7" : "0") + hash[39:36],
//                  ((hash[35:32] > 9)? "7" : "0") + hash[35:32],
//                  ((hash[31:28] > 9)? "7" : "0") + hash[31:28],
//                  ((hash[27:24] > 9)? "7" : "0") + hash[27:24],
//                  ((hash[23:20] > 9)? "7" : "0") + hash[23:20],
//                  ((hash[19:16] > 9)? "7" : "0") + hash[19:16],
//                  ((hash[15:12] > 9)? "7" : "0") + hash[15:12],
//                  ((hash[11:8] > 9)? "7" : "0") + hash[11:8],
//                  ((hash[7:4] > 9)? "7" : "0") + hash[7:4],
//                  ((hash[3:0] > 9)? "7" : "0") + hash[3:0]};                      
  end
end

endmodule

module debounce(
    input clk,
    input btn_input,
    output btn_output
    );
    assign btn_output = btn_input;
endmodule