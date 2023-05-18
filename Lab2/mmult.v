`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/29 16:34:18
// Design Name: 
// Module Name: mmult
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mmult(
    input clk,
    input reset_n,
    input enable,
    input [0:9*8-1] A_mat,
    input [0:9*8-1] B_mat,
    output valid,
    output reg [0:9*17-1] C_mat
    );

reg [0:3*17-1] prodmatr;
reg [0:9*8-1] secondmatr;
wire [0:7] row1element;
wire [0:7] row2element;
wire [0:7] row3element;
assign row1element = secondmatr[0:7];
assign row2element = secondmatr[24:31];
assign row3element = secondmatr[48:55];
reg [2:0] counter;
wire shift; 
assign shift = |(counter^4);
assign valid = ~shift;
always @(negedge reset_n) begin
    secondmatr <= B_mat;
    prodmatr <= 0;
    counter <= 0;
    C_mat <= 0;
end
always @(posedge clk) begin
    if(enable) begin
        prodmatr[0:16] <= A_mat[0:7] * row1element + A_mat[8:15] * row2element + A_mat[16:23] * row3element ;
        prodmatr[17:33] <= A_mat[24:31] * row1element + A_mat[32:39] * row2element + A_mat[40:47] * row3element ;
        prodmatr[34:50] <= A_mat[48:55] * row1element + A_mat[56:63] * row2element + A_mat[64:71] * row3element ;
        counter <= counter + shift;
        secondmatr <= secondmatr << 8;
        if(counter==1)
            begin
                C_mat[0:16] <= prodmatr[0:16];
                C_mat[51:67] <= prodmatr[17:33];
                C_mat[102:118] <= prodmatr[34:50];
            end
        else if(counter==2)
            begin
                C_mat[17:33] <= prodmatr[0:16];
                C_mat[68:84] <= prodmatr[17:33];
                C_mat[119:135] <= prodmatr[34:50];
            end
        else if(counter==3)
            begin
                C_mat[34:50] <= prodmatr[0:16];
                C_mat[85:101] <= prodmatr[17:33];
                C_mat[136:152] <= prodmatr[34:50];
            end
        else begin end
    end
end

endmodule
