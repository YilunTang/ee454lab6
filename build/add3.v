`timescale 1ns / 1ps
module add3(clk, input_flit1, /*input_flit2,*/ output_flit1/*, output_flit2, output_flit3*/, ready_send);
  input clk;
  input [70:0] input_flit1;
  //input [70:0] input_flit2;
  output [70:0] output_flit1;
  // output [70:0] output_flit2;
  // output [70:0] output_flit3;
  output reg ready_send;

  reg [63:0]data1;
  reg [63:0] data2;
  reg [63:0]result;
  reg flag1 = 0;
  reg flag2 = 0;
  reg repeat_flag = 0;
  reg [70:0]temp;
  reg [70:0]output_flit1_reg;
  reg ready_send_reg = 0;
  
  parameter max_counter = 0;
  reg counter = 0;
  reg [3:0] dest[0:1];
  parameter [1:0] vc = '{1'b0, 1'b0};
  
  assign output_flit1 = output_flit1_reg;
  //assign ready_send = ready_send_reg;

  always @(posedge clk)
  begin
    dest[0] = 4'b0010;
    dest[1] = 4'b0010;
    if(ready_send_reg==1)
      begin
        ready_send_reg=0;
        ready_send = ready_send_reg;
      end
    if((input_flit1[70]==1&&input_flit1[69]==1))
      begin
      if(input_flit1[64] == 0)
        begin
          data1 = input_flit1[63:0];
          flag1 = 1;
        end
      if(input_flit1[64] == 1)
        begin
          data2 = input_flit1[63:0];
          flag2 = 1;
        end
      if(flag1==1&& flag2==1)
        begin
          $display("add3");
          result = data1 + data2;
          $display("%b", data1);
          $display("%b", data2);
          $display("%b", result);
          temp = {1'b1, 1'b1, dest[counter], vc[counter], result};
          output_flit1_reg = temp;
          ready_send_reg = 1;
          ready_send = ready_send_reg;
          flag1 = 0;
          flag2 = 0;
          repeat_flag = 1;
          $display("ADD3sending: %b", temp);
        end
      end
    else if(repeat_flag == 1)
      begin
      if(counter < max_counter) //if we need to output repeatedly
        begin
          counter = counter + 1;
          temp = {1'b1, 1'b1, dest[counter], vc[counter], result};
          output_flit1_reg = temp;
          ready_send_reg = 1;
          ready_send = ready_send_reg;
          $display("ADD3sending: %b", temp);
        end
      end
  end
  
endmodule

