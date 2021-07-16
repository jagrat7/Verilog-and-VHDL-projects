`timescale 1ns/1ns




module i2cmaster(sda,scl,rst,slaveadd,wr,data,start,stop,clk,readdata);
    
    parameter intadd=8'b10011101;
    
    parameter idle =1;
	parameter addressst = 2;				
    parameter ackst =3;
    parameter writest =4;
    parameter readst =5;
    
    
    
    
    
    parameter n=8;
    
   
    input rst,clk,start,stop;
    reg ack;
    input wr;//write is active low
    input [7:0]slaveadd;
    
    inout  sda;
    output reg scl;
    output reg [7:0] readdata;
    
    
    reg sdain;
    reg [5:0]count;
    reg [5:0]countr;
    reg [2:0] crstate,cstr;
    input [7:0] data;
	assign sda = wr ? 8'bz:sdain ;
	
 

    always @ ( clk )			   
    begin
         scl<=clk;

        
    end
    
    always @ (posedge scl or posedge rst )			   
    begin
       
        if(rst)
        begin
            sdain<=0;
            readdata<=0;
            count<=0;
            //crstate<=idle;       
        end
    
        case(crstate) 
           idle:
           begin
            sdain<=0;
            count<=0;
            if(start==1) 
            begin
                sdain<=1;
                crstate<=addressst;
            end
            else if(stop==1)
            begin
             sdain<=1;
             crstate<=idle;
            end
            
            else crstate<=idle;   
           end
  
           addressst:
           begin
                   sdain<=0; 
                   if (count>7)
                   begin
                       count<=0;
                       ack<=1;
                       sdain<=1;
                       if(slaveadd==intadd)
                       begin
                       crstate<=ackst;  
                       end
                       else 
                       begin
                       sdain<=0;
                       crstate<=idle;
                       end
                   end
                   else
                   begin  
                        crstate<=addressst;
                        if(count<(n))
                        begin
                          sdain<=slaveadd[7-count];
                          count<= count + 1; 
                        end
                    end
            
           end
           
           writest:
           begin            
                   if (count>7)
                   begin
                       count<=0;
                       ack<=0;
                       sdain<=1; 
                       crstate<=ackst;
                   end
                   else
                   begin  
                        
                      crstate<=writest;
                      
                      if(count<(n))
                      begin
                      sdain<=data[7-count];
                      count<= count + 1;
                    end
                        
                    end
           end
                
           ackst:
           begin  
               if(ack==1 && wr==0)
               begin
                   ack=0;
                   sdain<=0;
                   crstate<=writest;
               end
               else if(ack==1&& wr==1)
               begin
                   ack=0;
                   sdain<=1;
                   if (readdata>1)
                   begin
                   sdain<=1;
                   crstate<=idle;
                   end
                   else crstate<=readst;
               end
               else
               begin
                sdain<=1;
                crstate<=idle;
               end
           end
           
           readst:
           begin 
                if (count<8) 
                begin
                   crstate<=readst; 
                   readdata[7-count] <= sda; 
                   count<=count+1;
               end
               else
               begin
                    ack<=1;
                    sdain<=1;
                    count<=0;
                    crstate<=ackst;     
              end
           end

           default:
           begin
            crstate<=idle;
           end
        endcase
    end
    

    
   

endmodule