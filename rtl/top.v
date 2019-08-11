module top (
    input           clk_50m,
    input           sys_rst,

    output          cmos_scl,         //cmos i2c clock
    inout           cmos_sda,         //cmos i2c data
    input           cmos_vsync,       //cmos vsync
    input           cmos_href,        //cmos hsync refrence
    input           cmos_pclk,        //cmos pxiel clock

     input   [7:0]  cmos_d,           //cmos data
     output         cmos_reset       //cmos reset

);

wire    initial_en;                       //OV5640 register configure enable
wire    cmos_rstn;
wire    cmos2_reset;
wire    cmos_cfg_done;
wire    cmos_scl;
wire    cmos_sda;

power_on_delay	power_on_delay_inst(
	.clk_25m                 (clk_25m),
	.reset_n                 (sys_rst),	
	.camera1_rstn            (cmos_rstn),
	.camera2_rstn            (cmos2_reset),	
	.camera_pwnd             (),
	.initial_en              (initial_en)		
);

wire    locked;
wire    clk_25m;

sys_clk sys_clk_i (
    .clk_in(clk_50m),
    .rst(sys_rst),
    .locked(locked),
    .clk_25m(clk_25m)
);


reg_config	reg_config_i(
	.clk_25m                 (clk_25m),
	.camera_rstn             (cmos_rstn),
	.initial_en              (initial_en),		
	.i2c_sclk                (cmos_scl),
	.i2c_sdat                (cmos_sda),
	.reg_conf_done           (cmos_cfg_done),
	.reg_index               (),
	.clock_20k               ()
);

wire        sys_we;
wire [63:0] sys_data_in;
wire	    init_calib_complete;			   //ddr init done

camera_capture	camera_capture_inst(
	.rst_n                   (sys_rst),	       //external reset  
	.init_done               (cmos_cfg_done),	   // init done
	.camera_pclk             (cmos_pclk),	   //cmos pxiel clock
	.camera_href             (cmos_href),	   //cmos hsync refrence
	.camera_vsync            (cmos_vsync),    //cmos vsync
	.camera_data             (cmos_d),        //cmos data
	.ddr_wren                (sys_we),         //ddr write enable
	.ddr_data_camera         (sys_data_in)    //ddr write data

);



endmodule
