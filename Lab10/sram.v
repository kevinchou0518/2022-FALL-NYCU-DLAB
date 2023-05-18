//
// This module show you how to infer an initialized SRAM block
// in your circuit using the standard Verilog code.  The initial
// values of the SRAM cells is defined in the text file "image.dat"
// Each line defines a cell value. The number of data in image.dat
// must match the size of the sram block exactly.

module sram
#(parameter DATA_WIDTH = 8, ADDR_WIDTH = 16, RAM_SIZE = 65536, FILE = "images.mem")
 (input clk, input we,input we2, input en,
  input  [ADDR_WIDTH-1 : 0] addr,
  input  [DATA_WIDTH-1 : 0] data_i,
  output reg [DATA_WIDTH-1 : 0] data_o,
  input  [ADDR_WIDTH-1 : 0] addr2,
  input  [DATA_WIDTH-1 : 0] data_i2,
  output reg [DATA_WIDTH-1 : 0] data_o2);

// Declareation of the memory cells
(* ram_style = "block" *) reg [DATA_WIDTH-1 : 0] RAM [RAM_SIZE - 1:0];

integer idx;

// ------------------------------------
// SRAM cell initialization
// ------------------------------------
// Initialize the sram cells with the values defined in "image.dat."
initial begin
    $readmemh(FILE, RAM);
end

// ------------------------------------
// SRAM read operation
// ------------------------------------
always@(posedge clk)
begin
  if (en & we) begin
    RAM[addr] <= data_i;
    data_o <= data_i;
  end
  else begin
    data_o <= RAM[addr];
  end
end

always@(posedge clk)
begin
  if (en & we2) begin
    RAM[addr2] <= data_i2;
    data_o2 <= data_i2;
  end
  else begin
    data_o2 <= RAM[addr2];
  end
end
//// ------------------------------------
//// SRAM write operation
//// ------------------------------------
//always@(posedge clk)
//begin
//  if (en & we)
//    RAM[addr] <= data_i;
//end

endmodule
