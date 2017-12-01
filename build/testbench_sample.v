
`ifndef XST_SYNTH

`timescale 1ns / 1ps

`include "connect_parameters.v"


module CONNECT_testbench_sample();
  parameter HalfClkPeriod = 5;
  localparam ClkPeriod = 2*HalfClkPeriod;

  // non-VC routers still reeserve 1 dummy bit for VC.
  localparam vc_bits = (`NUM_VCS > 1) ? $clog2(`NUM_VCS) : 1;
  localparam dest_bits = $clog2(`NUM_USER_RECV_PORTS);
  localparam flit_port_width = 2 /*valid and tail bits*/+ `FLIT_DATA_WIDTH + dest_bits + vc_bits;
  localparam credit_port_width = 1 + vc_bits; // 1 valid bit
  localparam test_cycles = 40;

  reg Clk;
  reg Rst_n;

  // input regs
  reg send_flit [0:`NUM_USER_SEND_PORTS-1]; // enable sending flits
  reg [flit_port_width-1:0] flit_in [0:`NUM_USER_SEND_PORTS-1]; // send port inputs

  reg send_credit [0:`NUM_USER_RECV_PORTS-1]; // enable sending credits
  reg [credit_port_width-1:0] credit_in [0:`NUM_USER_RECV_PORTS-1]; //recv port credits

  // output wires
  wire [credit_port_width-1:0] credit_out [0:`NUM_USER_SEND_PORTS-1];
  wire [flit_port_width-1:0] flit_out [0:`NUM_USER_RECV_PORTS-1];

  reg [31:0] cycle;
  integer i;

  // packet fields
  reg is_valid;
  reg is_tail;
  reg [dest_bits-1:0] dest;
  reg [vc_bits-1:0]   vc;
  reg [`FLIT_DATA_WIDTH-1:0] data;
  
  //My code
  wire [flit_port_width-1:0] in_add1;
  //wire [flit_port_width-1:0] temp_out;
  wire send_add1;
  
  wire [flit_port_width-1:0] in_add2;
  wire send_add2;
  
  wire [flit_port_width-1:0] in_add3;
  wire send_add3;
  
  wire [flit_port_width-1:0] in_mul1;
  wire send_mul1;
  
  wire [flit_port_width-1:0] in_mul2;
  wire send_mul2;
  
  wire [flit_port_width-1:0] in_anD;
  wire send_anD;
  
  wire [flit_port_width-1:0] in_oR;
  wire send_oR;
  
  wire [flit_port_width-1:0] in_xoR;
  wire send_xoR;

  //assign temp_in = flit_in[2];
  //assign send_add1 = send_flit[2];

  // Generate Clock
  initial Clk = 0;
  always #(HalfClkPeriod) Clk = ~Clk;

  // Run simulation 
  initial begin 
    cycle = 0;
    for(i = 0; i < `NUM_USER_SEND_PORTS; i = i + 1) begin flit_in[i] = 0; send_flit[i] = 0; end
    for(i = 0; i < `NUM_USER_RECV_PORTS; i = i + 1) begin credit_in[i] = 0; send_credit[i] = 0; end
    
    $display("---- Performing Reset ----");
    Rst_n = 0; // perform reset (active low) 
    #(5*ClkPeriod+HalfClkPeriod); 
    Rst_n = 1; 
    #(HalfClkPeriod);

    // send a 2-flit packet from send port 0 to receive port 1
    //send_flit[0] = 1'b1;
    //dest = 2;
    //vc = 0;
    //data = 'ha;
    //flit_in[0] = {1'b1 /*valid*/, 1'b1 /*tail*/, dest, vc, data};
    //$display("@%3d: Injecting flit %b into send port %0d", cycle, flit_in[0], 0);

    //#(ClkPeriod);
    // send 2nd flit of packet
    //send_flit[0] = 1'b1;
    //vc = 1;
    //data = 'hb;
    //flit_in[0] = {1'b1 /*valid*/, 1'b1 /*tail*/, dest, vc, data};
    //$display("@%3d: Injecting flit %b into send port %0d", cycle, flit_in[0], 0);
    
    //#(ClkPeriod);
    // send 2nd flit of packet
    //send_flit[0] = 1'b1;
    //send_flit[2] = send_add1;
    //dest = 2;
    //data = 'hb;
    //flit_in[0] = {1'b1 /*valid*/, 1'b1 /*tail*/, dest, vc, data};
    //$display("@%3d: Injecting flit %b into send port %0d", cycle, flit_in[0], 0);
    
    #(ClkPeriod);
    // stop sending flits
    send_flit[0] = 1'b0;
    flit_in[0] = 'b0; // valid bit
  end


  // Monitor arriving flits
  always @ (posedge Clk) begin
    cycle <= cycle + 1;
    for(i = 0; i < `NUM_USER_RECV_PORTS; i = i + 1) begin
      if(flit_out[i][flit_port_width-1]) begin // valid flit
        $display("@%3d: Ejecting flit %b at receive port %0d", cycle, flit_out[i], i);
      end
    end

    // terminate simulation
    if (cycle > test_cycles) begin
      $finish();
    end
  end

  // Add your code to handle flow control here (sending receiving credits)

  // Instantiate  network
  mkNetwork dut
  (.CLK(Clk)
   ,.RST_N(Rst_n)

   ,.send_ports_0_putFlit_flit_in(in_mul1)
   ,.EN_send_ports_0_putFlit(send_mul1)

   ,.EN_send_ports_0_getCredits(1'b1) // drain credits
   ,.send_ports_0_getCredits(credit_out[0])

   ,.send_ports_1_putFlit_flit_in(in_oR)
   ,.EN_send_ports_1_putFlit(send_oR)

   ,.EN_send_ports_1_getCredits(1'b1) // drain credits
   ,.send_ports_1_getCredits(credit_out[1])

   // add rest of send ports here
   //
   ,.send_ports_2_putFlit_flit_in(flit_in[2])
   ,.EN_send_ports_2_putFlit(send_flit[2])

   ,.EN_send_ports_2_getCredits(1'b1) // drain credits
   ,.send_ports_2_getCredits(credit_out[2])
   
   ,.send_ports_3_putFlit_flit_in(in_anD)
   ,.EN_send_ports_3_putFlit(send_anD)

   ,.EN_send_ports_3_getCredits(1'b1) // drain credits
   ,.send_ports_3_getCredits(credit_out[3])
   
   ,.send_ports_4_putFlit_flit_in(in_add1)
   ,.EN_send_ports_4_putFlit(send_add1)

   ,.EN_send_ports_4_getCredits(1'b1) // drain credits
   ,.send_ports_4_getCredits(credit_out[4])
   
   ,.send_ports_5_putFlit_flit_in(in_mul2)
   ,.EN_send_ports_5_putFlit(send_mul2)

   ,.EN_send_ports_5_getCredits(1'b1) // drain credits
   ,.send_ports_5_getCredits(credit_out[5])
   
   ,.send_ports_6_putFlit_flit_in(in_add2)
   ,.EN_send_ports_6_putFlit(send_add2)

   ,.EN_send_ports_6_getCredits(1'b1) // drain credits
   ,.send_ports_6_getCredits(credit_out[6])
   
   ,.send_ports_7_putFlit_flit_in(in_add3)
   ,.EN_send_ports_7_putFlit(send_add3)

   ,.EN_send_ports_7_getCredits(1'b1) // drain credits
   ,.send_ports_7_getCredits(credit_out[7])
   
   ,.send_ports_8_putFlit_flit_in(in_xoR)
   ,.EN_send_ports_8_putFlit(send_xoR)

   ,.EN_send_ports_8_getCredits(1'b1) // drain credits
   ,.send_ports_8_getCredits(credit_out[8])
   
   //-----------------------------

   ,.EN_recv_ports_0_getFlit(1'b1) // drain flits
   ,.recv_ports_0_getFlit(flit_out[0])

   ,.recv_ports_0_putCredits_cr_in(credit_in[0])
   ,.EN_recv_ports_0_putCredits(send_credit[0])

   ,.EN_recv_ports_1_getFlit(1'b1) // drain flits
   ,.recv_ports_1_getFlit(flit_out[1])

   ,.recv_ports_1_putCredits_cr_in(credit_in[1])
   ,.EN_recv_ports_1_putCredits(send_credit[1])

   // add rest of receive ports here
   // 
   ,.EN_recv_ports_2_getFlit(1'b1) // drain flits
   ,.recv_ports_2_getFlit(flit_out[2])

   ,.recv_ports_2_putCredits_cr_in(credit_in[2])
   ,.EN_recv_ports_2_putCredits(send_credit[2])
   
   ,.EN_recv_ports_3_getFlit(1'b1) // drain flits
   ,.recv_ports_3_getFlit(flit_out[3])

   ,.recv_ports_3_putCredits_cr_in(credit_in[3])
   ,.EN_recv_ports_3_putCredits(send_credit[3])
   
   ,.EN_recv_ports_4_getFlit(1'b1) // drain flits
   ,.recv_ports_4_getFlit(flit_out[4])

   ,.recv_ports_4_putCredits_cr_in(credit_in[4])
   ,.EN_recv_ports_4_putCredits(send_credit[4])
   
   ,.EN_recv_ports_5_getFlit(1'b1) // drain flits
   ,.recv_ports_5_getFlit(flit_out[5])

   ,.recv_ports_5_putCredits_cr_in(credit_in[5])
   ,.EN_recv_ports_5_putCredits(send_credit[5])
   
   ,.EN_recv_ports_6_getFlit(1'b1) // drain flits
   ,.recv_ports_6_getFlit(flit_out[6])

   ,.recv_ports_6_putCredits_cr_in(credit_in[6])
   ,.EN_recv_ports_6_putCredits(send_credit[6])
   
   ,.EN_recv_ports_7_getFlit(1'b1) // drain flits
   ,.recv_ports_7_getFlit(flit_out[7])

   ,.recv_ports_7_putCredits_cr_in(credit_in[7])
   ,.EN_recv_ports_7_putCredits(send_credit[7])
   
   ,.EN_recv_ports_8_getFlit(1'b1) // drain flits
   ,.recv_ports_8_getFlit(flit_out[8])

   ,.recv_ports_8_putCredits_cr_in(credit_in[8])
   ,.EN_recv_ports_8_putCredits(send_credit[8])

   );
   
   add1 dut_add1(
   .clk(Clk)
   ,.input_flit1(flit_out[4])
   ,.output_flit1(in_add1)
   ,.ready_send(send_add1)
   );
   mul1 dut_mul1(
   .clk(Clk)
   ,.input_flit1(flit_out[0])
   ,.output_flit1(in_mul1)
   ,.ready_send(send_mul1)
   );
   anD dut_anD(
   .clk(Clk)
   ,.input_flit1(flit_out[3])
   ,.output_flit1(in_anD)
   ,.ready_send(send_anD)
   );
   oR dut_oR(
   .clk(Clk)
   ,.input_flit1(flit_out[1])
   ,.output_flit1(in_oR)
   ,.ready_send(send_oR)
   );
   mul2 dut_mul2(
   .clk(Clk)
   ,.input_flit1(flit_out[5])
   ,.output_flit1(in_mul2)
   ,.ready_send(send_mul2)
   );
   add2 dut_add2(
   .clk(Clk)
   ,.input_flit1(flit_out[6])
   ,.output_flit1(in_add2)
   ,.ready_send(send_add2)
   );
   xoR dut_xoR(
   .clk(Clk)
   ,.input_flit1(flit_out[8])
   ,.output_flit1(in_xoR)
   ,.ready_send(send_xoR)
   );
   add3 dut_add3(
   .clk(Clk)
   ,.input_flit1(flit_out[7])
   ,.output_flit1(in_add3)
   ,.ready_send(send_add3)
   );


endmodule

`endif
