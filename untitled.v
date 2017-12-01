module data_to_flit(input_data, destination, virtual_channel, generated_flit);
  input [63:0] input_data;
  input [3:0] destination;
  input virtual_channel;
  output [70:0] generated_flit; //1+1+4+1+64, 70 bit of data

  generated_flit = {1'b1, 1'b1, destination, virtual_channel, input_data};

endmodule

module flit_to_data(input_flit, decryped_data);
  input [70:0] input_flit;
  output [63:0] decryped_data;

  decryped_data = input_flit[63:0];

endmodule

module add1(input_flit1, input_flit2, output_flit1/*, output_flit2, output_flit3*/);
  input [70:0] input_flit1;
  input [70:0] input_flit2;
  output [70:0] output_flit1;
  // output [70:0] output_flit2;
  // output [70:0] output_flit3;

  reg data1, data2, result;

  data1 = input_flit1[63:0];
  data2 = input_flit2[63:0];
  result = data1 + data2;
  output_flit1 = {1'b1, 1'b1, destination, 1'b1, result};

endmodule

module and(input_flit1, input_flit2, output_flit1);
  input [70:0] input_flit1;
  input [70:0] input_flit2;
  output [70:0] output_flit1;

  reg data1, data2, result;

  data1 = input_flit1[63:0];
  data2 = input_flit2[63:0];
  result = data1 & data2;
  output_flit1 = {1'b1, 1'b1, destination, 1'b1, result};

endmodule


