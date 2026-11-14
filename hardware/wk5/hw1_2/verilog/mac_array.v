// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_array (clk, reset, out_s, in_w, in_n, inst_w, valid);

  parameter bw = 4;
  parameter psum_bw = 16;
  parameter col = 8;
  parameter row = 8;

  input  clk, reset;
  output [psum_bw*col-1:0] out_s;
  input  [row*bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading
  input  [1:0] inst_w;
  input  [psum_bw*col-1:0] in_n;
  output [col-1:0] valid;


  //temp vars
  wire [row*col-1:0] temp_valid;
  reg [2*row-1:0] inst_w_temp; //our instr shift reg

  wire [psum_bw*(row+1)*col-1:0] temp;
  assign temp[psum_bw*col-1:0] = in_n;

  

  genvar i;
  for (i=1; i < row+1 ; i=i+1) begin : row_num
      mac_row #(.bw(bw), .psum_bw(psum_bw)) mac_row_instance (
        .clk(clk),
        .reset(reset),
        .in_w(in_w[i*bw-1:(i-1)*bw]),
        .inst_w(inst_w_temp[2*i-1:2*(i-1)]),
        .in_n(temp[psum_bw*col*i-1:psum_bw*col*(i-1)]),
        .out_s(temp[psum_bw*col*(i+1)-1:psum_bw*col*i]),
        .valid(temp_valid[i*col-1:(i-1)*col])
      );
  end

  //now we can assign out_s
  assign out_s = temp[psum_bw*(row+1)*col-1: psum_bw*row*col];

  /*
  input  clk, reset;
  output [psum_bw*col-1:0] out_s;
  output [col-1:0] valid;
  input  [bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading
  input  [1:0] inst_w;
  input  [psum_bw*col-1:0] in_n;
  */
  integer j;
  always @ (posedge clk) begin
    if (reset) begin
      inst_w_temp[2*row-1:0] <= 0;
    end else begin
      //instruction SR handling
      inst_w_temp[1:0] <= inst_w;
      for (j=1; j < row; j +=1) begin // inst_w flows to row0 to row7
        inst_w_temp[2*i+1:2*i] <= inst_w_temp[2*(i-1)+1:2*(i-1)];
      end
    end
   
 
  end



endmodule
