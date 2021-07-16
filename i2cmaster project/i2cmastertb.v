`timescale 1ns / 1ns
//`define MONITOR_STR_1 "%d: din= %d, syclk = %d, send= %d, rst= %d, dout= %d, valid= %d, oclk=%d, odata= %d, ostrobe= %d"
//module toplvl(data,cin0,cin1,cin2,cin3,clk,out);
`define CLK_PERIOD 20

module i2cmastertb();
    
   
    reg rst,clk,start,stop;
    reg wr;//write is active low
    reg [7:0]slaveadd;
    reg [7:0]data;
    wire sda;
    reg sdadrive;
   // wire
    wire scl;
    wire [7:0] readdata;
    reg sdaintb;
    i2cmaster  UUT1(.sda(sda),.scl(scl),.rst(rst),.slaveadd(slaveadd),.wr(wr),.data(data),.start(start),.stop(stop),.clk(clk),.readdata(readdata));
    
	assign sda = (!wr) ? 8'bz:sdaintb;
    //sp  uut1 (.din(din),.syclk(syclk),.send(send),.iclk(oclktb),.idata(odatatb),.istrobe(ostrobetb),.rst(rst),.dout(dout),.valid(valid),.oclk(oclktb),.odata(odatatb),.ostrobe(ostrobetb));
   //module i2cmaster(sda,scl,rst,slaveadd,wr,data,start,stop,clk,ack);
   
   
   
initial begin
        clk = 0;
        forever begin
            #(`CLK_PERIOD/2) clk = ~clk;
        end
end
 


    initial 
    begin

       #0 rst=1;
       sdaintb=0;
        stop=0;
       start=0;
       #20 rst=0;
       #20
       wr=0;
       data=173;
       slaveadd=8'b10011101;
       stop=0;
       start=1;
       #20
       start=0;
      #370
       stop=1;
       #20 stop=1'b0;
       #160
       start=1'b1;
       #20
       start=1'b0;
       #180;
       wr=1;
       if(wr==1)sdaintb=1'b1;//it is done like this because the sda line has be in input mode to take the data therefore sdaintb is used here insead of UUT1.sdain
       
       
       //read data 1110_0110=E6
       #20
       sdaintb=1'b1;
       #20
       sdaintb=1'b1;
       #20
       sdaintb=1'b1;
       #20
       sdaintb=1'b0;
       #20
       sdaintb=1'b0;
       #20
       sdaintb=1'b1;
       #20
       sdaintb=1'b1;
       #20
       sdaintb=1'b0;
       
       
       
       #20
       if(UUT1.count>7) sdaintb=1'b1;
       #20
      stop=1;
      if(stop==1)sdaintb=1'b1;
       slaveadd=8'b10001101;
      #20
       stop=1'b0;
       wr=0;
      #20
      start=1'b1;
      #20
       start=1'b0; 
      
       
      
        
        
      #500   $finish;

    end


   

endmodule