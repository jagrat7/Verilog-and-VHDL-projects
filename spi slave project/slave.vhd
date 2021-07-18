library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity slave is
generic(
  n               : integer:=16; 
  n1 : integer :=16 );

  Port (
        CLK      : in  std_logic; -- system clock
        SCLK     : in  std_logic; -- SPI clock
        ssn     : in  std_logic; -- SPI chip select, active in low
        MOSI     : in  std_logic; -- SPI serial data from master to slave
        MISO     : out std_logic; -- SPI serial data from slave to master
        addr      : out  unsigned(6 downto 0);
        wdata      : out  unsigned(15 downto 0); -- input data for SPI master
        wstrobe   : out std_logic; 
        rdata     : in unsigned(15 downto 0) -- output data from SPI master
  
    );
end slave;

architecture Behavioral of slave is

   

    signal r_data            : unsigned(15 downto 0);
    signal rw                  : std_logic;
    signal rwreg                  : unsigned(7 downto 0);
    signal wstrobeint                : std_logic;
    signal start_SCLK        : std_logic;
    signal wdataint           : unsigned(23 downto 0);
    signal r_count     : integer range 0 to n;
    signal MISO_i: unsigned(15 downto 0);
    signal addrint      :   unsigned(6 downto 0);
begin


   
    SCLKBEGIN : process (CLK)
        begin
            if (falling_edge(CLK)) then
                if ( ssn = '0') then
                    start_SCLK<= '1';
                 else
                    start_SCLK<= '0';
                end if;
            end if;
     end process;

     loadmosibitaddr : process (SCLK)
        variable i : natural:=6;
        begin
            if (start_SCLK<= '1' and rising_edge(SCLK) ) then
                addrint <= (others => '0');
              if (i>=0) then
                   addrint(6 downto 0) <= addrint(5 downto 0)& MOSI; 
                   
                   i:=i-1;
               else
                    addrint <= addrint;
              end if;
              
            else
                    
                    if(start_SCLK<= '0') then
                        addrint <= (others => '0');
                    else
                        addrint <= addrint ; 
                    end if;
            end if;            
        end process;
        
     loadmosibitrw : process (SCLK)
     variable j : natural:=7;
        begin
      
            if (start_SCLK<= '1' and rising_edge(SCLK)  and wstrobeint<='0') then
                  rwreg <= (others => '0');
              if (j>=0) then
                   rwreg(6 downto 0) <= rwreg(5 downto 0)& MOSI; 
                   
                   j:=j-1;
               else
                    rwreg <= rwreg;
              end if;
              
            else
                    
                    if(start_SCLK<= '0') then
                        rwreg <= (others => '0');
                    else
                        rwreg <= rwreg ; 
                    end if;
            end if;            
                 
                       
        end process;
        
        rw<=rwreg(0);
        
     loadmosibitwdata : process (SCLK)
             variable k : natural:=23;
        begin
        
        
            if (start_SCLK<= '1' and rising_edge(SCLK) and rw<= '1' ) then

                wdataint <= (others => '0');
              if (k>=0) then
                   wdataint(23 downto 0) <= wdataint(22 downto 0)& MOSI; 
                   
                   k:=k-1;
               else
                    wdataint <= wdataint;
              end if;
              
            else
                    
                    if(start_SCLK<= '0') then
                        wdataint <= (others => '0');
                    else
                        wdataint <= wdataint ; 
                    end if;
            end if;            
                    
                if (k=-1)then
                    wstrobeint<='1';
                    k:=k-1;
                else
                    wstrobeint<='0';
                end if;
                
                       
        end process;
        
        
        
        
        
        loadmisoread : process (SCLK) 
        begin
            
            if (start_SCLK<= '1' and rising_edge(SCLK) ) then
                
               if (MISO_i(15)=rdata(15)) then
                MISO_i<= (others=>'0');
               end if;              
                      r_count  <= 0; 
                           
                    MISO_i<=rdata;
                  
                if(r_count<(n-1)) then
                  r_count        <= r_count + 1;
                 
                  MISO_i         <= MISO_i(n-2 downto 0)&'0';

                end if;
             else
                    
                    if(start_SCLK<= '0') then
                        MISO_i <= (others => '0');
                    else
                        MISO_i <= MISO_i ; 
                    end if;     
           end if;            
        end process;
        
        
        addr<= addrint; 
        wstrobe<=wstrobeint ;
        wdata<=wdataint(15 downto 0)  ;
        MISO<= MISO_i(15);
        
end Behavioral;

