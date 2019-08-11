
module sys_clk (
    input       clk_in,
    input       rst,

    output      locked,
    output      clk_25m
);

  clk_wiz_0 clk_wiz_inst(
  
    .clk_in1(clk_in),
    .reset(rst), 
    .locked(locked),
    .clk_25m(clk_25m), 
  
  );



endmodule