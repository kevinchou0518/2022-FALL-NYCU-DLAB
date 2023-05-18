`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/15 15:35:52
// Design Name: 
// Module Name: alu
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


module alu(
    output reg [7:0] alu_out,
    output zero,
    input [2:0] opcode,
    input [7:0] data,
    input [7:0] accum,
    input clk,
    input reset
    );
    assign zero = (accum == 0) ? 1:0;
    always@(posedge clk) begin
        if(reset == 1)  alu_out <= 0;
        else begin
           case(opcode)
           3'b000: alu_out <= accum;
           3'b001: alu_out <= accum + data;
           3'b010: alu_out <= accum - data;
           3'b011: alu_out <= accum & data;
           3'b100: alu_out <= accum ^ data;
           3'b101: begin 
                    if(accum[7] == 1) alu_out <= ~(accum - 1) ;
                    else alu_out <= accum;
                   end
           3'b110: begin
                    if(accum[3]==1 && data[3]==1) begin
                        alu_out <= ((~(accum-1))&(8'b00001111)) * (~(data-1))&(8'b00001111);
                    end 
                    else if(accum[3]==1 && data[3]==0) begin
                        alu_out <= ~(((~(accum-1))&(8'b00001111)) * data) + 1;
                    end
                    else if(accum[3]==0 && data[3]==1) begin 
                        alu_out <= ~(accum *((~(data-1))&(8'b00001111))) +1;
                    end
                    else begin 
                        alu_out <= accum * data;
                    end
                    //alu_out <= accum * data;
           end
           3'b111: alu_out <= data;
           endcase
        end
    end
    
    
    
endmodule
