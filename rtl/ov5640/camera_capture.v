`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name:    camera_capture 
//////////////////////////////////////////////////////////////////////////////////
module camera_capture(
	input rst_n,	
	input init_done,
	input camera_pclk,
    input camera_href,
	input camera_vsync,
	input [7:0] camera_data,	
	output reg ddr_wren,                             //ddr camera write
	output reg [63:0] ddr_data_camera               //ddr camera write data

	
);

reg [10:0] camera_h_count;            
reg [9:0] camera_v_count;       

reg [63:0] camera_data_reg;
reg [9:0] counter;

reg camera_vsync_buf1;
reg camera_vsync_buf2;

reg cmos_wren;



//camera lines
always @(posedge camera_pclk)
begin
	 if (~rst_n) 
       camera_h_count<=1;
	 else if((camera_href==1'b1) & (camera_vsync==1'b0))  
       camera_h_count<=camera_h_count+1'b1;	  
	 else 
	 	 camera_h_count<=1;
 
end

//camera column counter
always @(posedge camera_pclk)
begin
	 if (~rst_n | camera_vsync) 
       camera_v_count<=0;
	 else if(camera_h_count==1280)   
       camera_v_count<=camera_v_count+1'b1;	  
	 else 
	 	 camera_v_count<=camera_v_count;
end
	

// request for storing data to DDR and transformed to 256 bit
always @(posedge camera_pclk)
begin
	 if (~rst_n) begin 
			camera_data_reg<=0;
			cmos_wren<=1'b0;
			counter<=0;
	 end	
	 else if((camera_href==1'b1) & (camera_vsync==1'b0)) begin   //cmos valid
		   if(counter<7) begin                              //read the first 31 data 	  
				 camera_data_reg<={camera_data_reg[55:0],camera_data};
				 counter<=counter+1'b1;
				 ddr_data_camera<=ddr_data_camera;	
				 cmos_wren<=1'b0;
			end
			else begin                                       //read 32nd camera		  
			    ddr_data_camera<={camera_data_reg[55:0],camera_data};
				 camera_data_reg<=0;		
				 counter<=0; 
			    cmos_wren<=1'b1;                              //when receive 32 bytes, generate ddr write				 
			end
	  end
	  else begin
				camera_data_reg<=0;
				ddr_data_camera<=0;
				cmos_wren<=1'b0;
				counter<=0;
	  end
end

always @(negedge camera_pclk)
begin
  ddr_wren<=cmos_wren;
end  
		
endmodule

