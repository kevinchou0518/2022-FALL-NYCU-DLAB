`timescale 1ns / 1ps
module lab4(
  input  clk,            // System clock at 100 MHz
  input  reset_n,        // System reset signal, in negative logic
  input  [3:0] usr_btn,  // Four user pushbuttons
  output [3:0] usr_led   // Four yellow LEDs
);
reg signed [3:0] temp_led=4'b0000;
wire [3:0] static_btn;
reg [2:0] state=3'b000;
reg [20:0] pwm_on=500000;
reg [20:0] pwm_counter=0;
debounce d0(clk,reset_n,usr_btn[0],static_btn[0]);
debounce d1(clk,reset_n,usr_btn[1],static_btn[1]);
debounce d2(clk,reset_n,usr_btn[2],static_btn[2]);
debounce d3(clk,reset_n,usr_btn[3],static_btn[3]);

//binary counter with light output
always@(posedge clk) begin
    if(reset_n == 1'b0) begin
        temp_led <= 0;
    end
    else if(static_btn[0]) begin
        temp_led <= (temp_led== -8) ? temp_led : temp_led - 1;         
    end
    else if(static_btn[1]) begin
        temp_led <= (temp_led == 7) ? temp_led : temp_led + 1;
    end
    else begin
        temp_led <= temp_led;
    end
end

always@(posedge clk) begin
    if(!reset_n) begin
        state <= 2;
    end
    else if(static_btn[3]) begin
        state <= (state==4) ? state:state+1;
    end
    else if(static_btn[2]) begin
        state <= (state==0) ? state:state-1;
    end
    else begin
        state <= state;
    end
end

//pwm determine bright from state
always@(state) begin
    if(state == 0) begin
        pwm_on <= 50000;
    end
    if(state == 1) begin
        pwm_on <= 250000;
    end
    else if(state == 2) begin
        pwm_on <= 500000;
    end
    else if(state == 3) begin
        pwm_on <= 750000;
    end
    else if(state == 4) begin
        pwm_on <= 1000000;
    end
end

//generate pwm  signed after knowing which light
always@(posedge clk) begin
    if(pwm_counter == 999999) begin
        pwm_counter <= 0;
    end
    else begin
        pwm_counter <= pwm_counter + 1;
    end
end

assign usr_led = (pwm_counter < pwm_on) ? temp_led : 0;
//assign usr_led = temp_led & {pwm_out,pwm_out,pwm_out,pwm_out};

endmodule

module debounce(clk, reset_n, btn_in, btn_out);
    input clk, reset_n, btn_in;
    output btn_out;
    reg [20:0] timer = 0;

assign btn_out = (timer == 300000);

always @(posedge clk or negedge reset_n) begin
    if(!reset_n) begin
        timer <= 0;
    end
    else if(btn_in) begin
        if(timer > 300000) timer <= timer;
        else timer <= timer + 1;
    end
    else begin
        timer <= 0;
    end
end
endmodule

