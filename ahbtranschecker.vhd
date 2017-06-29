------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003, Gaisler Research
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
library std;
use std.textio.all;
use ieee.std_logic_textio.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library techmap;
use techmap.gencomp.all;
library gaisler;
-------------------------------------------------
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
-----------------------------------------------

use gaisler.uart.all;


entity ahbtranschecker is
  generic (
    hindex  : integer := 0;
    ioaddr  : integer := 16#000#;
    iomask  : integer := 16#E00#;
    tech    : integer := DEFMEMTECH; 
    irq     : integer := 0; 
    kbytes  : integer := 1); 
  port (
    rst    : in  std_ulogic;
    clk    : in  std_ulogic;
    ahbmi  : in  ahb_mst_in_type;
    ahbsi  : in  ahb_slv_in_type;
    
------------------------------------------------
   -- outccf : out std_logic;
   ---outccf : out std_logic_vector(31 downto 0); --original
   outccf : inout std_logic_vector(31 downto 0);
-------------------------------------------------
----------start editing------------------------



    u_tx   : out std_logic;
   -- u_rx   : in  std_logic;
    --u_tx   : out std_logic_vector;
    --u_rx   : in  std_logic_vector;
---------end editing----------------------------
--------adding extra port ccf cal start------------
    ccf_calc_start_port : in std_logic; ----adding this port to make a swicth input
--------------------------------------------------
    sw_func_or_timed : in std_logic
  );
end; 


architecture rtl of ahbtranschecker is

constant TBUFABITS    : integer := log2(kbytes) + 6;
constant TIMEBITS     : integer := 32;

--These constants for the CCF calcs
constant INIT_CSA_0   : std_logic_vector:= X"0F551C5466A295CA83B00A5B94752A1F9534F4E68B33CD3DA80B5805F2D7C3C26C519FAFA37AF1385CBDF2CABBBA347C2772791FCB53F232C0AD0CA93BD59158";
constant INIT_VALUE   : std_logic_vector:= X"00000000";
constant SYNC_RESET   : integer := 1;--(range 0 to 1);  -- use sync./async reset
constant N_CCF        : integer := 100;
constant CCF_DISTANCE : integer := 1024;
constant msb          : integer := INIT_VALUE'length - 1;

 --signal NC_counter    : integer := 0;
signal NC_counter    : integer := 0;
-- Signals

 signal   ccf_calc_stop            : std_logic:='0';
 signal   ccf_calc_start           : std_logic:='0';
 signal   ccf_calc_en              : std_logic:='0';
 signal   ccf_timed_calc_en        : std_logic:='0';
 signal   ccf_func_calc_en         : std_logic:='0';
 signal   ccf_store_in_buffer      : std_logic_vector(msb downto 0):= X"00000000";
 signal   ccf_to_uart              : std_logic_vector(msb downto 0):= X"00000000";
 signal   ccf_to_uart_prev         : std_logic_vector(msb downto 0):= X"00000000"; 
 signal   ccf_store_in_buffer_write: std_logic:='0';
 signal   ccf_store_in_buffer_read : std_logic:= '0';
 signal   ccf_func_not_timed       : std_logic:= '0';
 signal   start_wait_for_startaddr : std_logic:='0';
 signal   stored_ccf_count         : integer:= 0 ;
 signal   srl_buffer_full          : std_logic:= '0';
 signal   srl_buffer_data_present  : std_logic:= '0';
 
 -- signal   ccf_compare_to_ref       : std_logic:='0'; -- not used now commented below ----- #FUTUREWORK1
 
 signal   match_o: std_logic;             -- CCF match flag
 signal   ccf , ccfa, csa32, ccf_prev: std_logic_vector(msb downto 0):= X"00000000"; -- CCF output & intermediate values
 signal   tcf_prev, tcf, fc, fc_prev : std_logic_vector(msb downto 0):= X"00000000";
------------------------------------------------------------------------------------------------------------------------------- 
--signal   N_counted                  : std_logic_vector(9 downto 0):= "0000000000";
 signal N_counted     : integer range 0 to 1024:= 0;
 signal N_counted_vec: std_logic_vector(15 downto 0):= "0000000000000000";
--signal N_counted_vec: std_logic_vector(10 downto 0):= "00000000";

--N_counted_vec <= std_logic_vector(to_unsigned(N_counted,16));
signal max_sent_char     : integer range 0 to 101:= 0;

-------------------------
signal   P : std_logic_vector(47 downto 0):= "000000000000000000000000000000000000000000000000";
signal   PS : std_logic_vector(47 downto 0):= "000000000000000000000000000000000000000000000000";
signal tx_counter : integer := 0;
signal fp_tx_done  : std_logic:='1';
signal transmit_footprint : std_logic := '0';
signal stop_tx : std_logic := '0';
signal transmit_footprint_next_clk : std_logic:= '0';
------------------------------------------------------------------------------------------------------------------------------- 
 signal   uart_data_in   : std_logic_vector(7 downto 0):= "00000000";
 --signal   uart_data_out  : std_logic_vector(7 downto 0);

---------------------------------------------------------------
----------------start editing---------------------------------
------------------------------------------
 signal buffer_out: std_logic_vector(msb downto 0):= X"00000000";
 --signal buffer_out: std_logic_vector(31 downto 0);--original
------------------------------------------
 signal uart_enable: std_logic;
----------------end editing------------------------------------
-----------------------------------------------------------------
 signal   IntTx_O_signal     : std_logic;--dummy signal
 signal   Intrx_O_signal       : std_logic;---dummysignal
------------------------------------------------------------ 
 signal uart_wait_for_byte_to_tx : std_logic:='0';
 signal uart_byte_received       : std_logic;
 signal uart_tx : std_logic;
 signal uart_rx : std_logic;
 
 signal zero: std_logic_vector(msb downto 0);
 signal arst, srst: std_logic;
 signal curr_addr : std_logic_vector(31 downto 0):= X"00000000";
 signal prev_addr : std_logic_vector(31 downto 0):= X"00000000";
 signal csa : std_logic_vector(INIT_CSA_0'length -1 downto 0):=INIT_CSA_0;

-- Footprints Generation Signals
  ---signal current_pc   : std_logic_vector(31 downto 0) :=X"00000000";;
  --signal previous_pc  : std_logic_vector(31 downto 0) :=X"00000000";
  --signal N_pc         : integer range (512 downto 0);
  --signal FC_pc        : std_logic_vector(31 downto 0);
  signal ts_signal    : std_logic_vector(31 downto 0);
  --signal TCF_pc       : std_logic_vector(31 downto 0);
  --signal M_count      : integer range 0 to 512 := 0;
 -- signal fp           : std_logic_vector(73 downto 0);
  --signal bit_out      : std_logic := '0';
-- End of Footprints Generation Signals




constant hconfig : ahb_config_type := (
  0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_AHBTRACE, 0, 0, irq),
  4 => ahb_iobar (ioaddr, iomask),
  others => zero32);

--------------------------------------------------------
----------------editing start package-------------------
--package mini_uart is

--type mini_uart_out_type is record
  --u_tx   	: std_ulogic;
  --ctsn   	: std_ulogic;
  --extclk	: std_ulogic;
--end record;

--type mini_uart_out_vector_type is array (natural range <>) of mini_uart_out_type;

-----------------end editing---------------------------
------------------------------------------------------

type tracebuf_in_type is record 
  addr             : std_logic_vector(11 downto 0);
  data             : std_logic_vector(127 downto 0);--data_i in the CRC code
  enable           : std_logic;
  write            : std_logic_vector(3 downto 0);
end record;

type tracebuf_out_type is record 
  data             : std_logic_vector(127 downto 0);
end record;

type trace_break_reg is record
  addr          : std_logic_vector(31 downto 2);
  mask          : std_logic_vector(31 downto 2);
  read          : std_logic;
  write         : std_logic;
end record;

type regtype is record
  haddr         : std_logic_vector(31 downto 0);
  hwrite        : std_logic;
  htrans	: std_logic_vector(1 downto 0);
  hsize         : std_logic_vector(2 downto 0);
  hburst        : std_logic_vector(2 downto 0);
  hwdata        : std_logic_vector(31 downto 0);
  hmaster       : std_logic_vector(3 downto 0);
  hmastlock     : std_logic;
  hsel          : std_logic;
  hready        : std_logic;
  hready2       : std_logic;
  hready3       : std_logic;
  ahbactive     : std_logic;
  timer         : std_logic_vector(TIMEBITS-1 downto 0);
  aindex  	: std_logic_vector(TBUFABITS - 1 downto 0); -- buffer index
  enable        : std_logic;	-- trace enable
  bahb          : std_logic;	-- break on AHB watchpoint hit
  bhit          : std_logic;	-- breakpoint hit
  dcnten        : std_logic;	-- delay counter enable
  delaycnt      : std_logic_vector(TBUFABITS - 1 downto 0); -- delay counter

  tbreg1	: trace_break_reg;
  tbreg2	: trace_break_reg;
end record;

signal tbi   : tracebuf_in_type;
signal tbo   : tracebuf_out_type;
-----------------------------------------------------
-------start editing signal------------------------
--signal uart_tx : mini_uart_out_type;
--------end editing signal-------------------------
------------------------------------------------

signal enable : std_logic_vector(1 downto 0);
signal r, rin : regtype;

--signal i : integer;

begin
    
    r.enable <= '1';
    ccf_func_not_timed <= sw_func_or_timed;

----------------------------------------------
-----add editing------------------------------
    u_tx <= uart_tx;
-----end editing----------------------------
--------------------------------------------
    

ctrl : process(rst, ahbmi, ahbsi, r, tbo)
  variable v : regtype;
  variable vabufi : tracebuf_in_type;
  variable regsd : std_logic_vector(31 downto 0);   -- data from registers
  variable aindex : std_logic_vector(TBUFABITS - 1 downto 0); -- buffer index
  variable bphit : std_logic;
  variable bufdata : std_logic_vector(127 downto 0);
  variable hirq : std_logic_vector(NAHBIRQ-1 downto 0); 

  begin

    v := r; regsd := (others => '0'); vabufi.enable := '0'; 
    vabufi.data := (others => '0'); vabufi.addr := (others => '0'); 
    vabufi.write := (others => '0'); bphit := '0'; 
    v.hready := r.hready2; v.hready2 := r.hready3; v.hready3 := '0'; 
    bufdata := tbo.data;
    hirq := (others => '0'); hirq(irq) := r.bhit;

-- trace buffer index and delay counters
    --if r.enable = '1' 
    --then 
    v.timer := r.timer + 1; 
    --end if;
    aindex := r.aindex + 1;

-- check for AHB watchpoints
--deleted part    

-- generate buffer inputs
      vabufi.write := "0000";
      --if r.enable = '1' then
        vabufi.addr(TBUFABITS-1 downto 0) := r.aindex;
        vabufi.data(127 downto 96) := r.timer; 
        vabufi.data(95) := bphit;
  	vabufi.data(94 downto 80) := ahbmi.hirq(15 downto 1);
 	vabufi.data(79) := r.hwrite;
  	vabufi.data(78 downto 77) := r.htrans;
  	vabufi.data(76 downto 74) := r.hsize;
  	vabufi.data(73 downto 71) := r.hburst;
  	vabufi.data(70 downto 67) := r.hmaster;
  	vabufi.data(66) := r.hmastlock;
  	vabufi.data(65 downto 64) := ahbmi.hresp;
        if r.hwrite = '1' then
          vabufi.data(63 downto 32) := ahbsi.hwdata;
        else
          vabufi.data(63 downto 32) := ahbmi.hrdata;
        end if; 
        vabufi.data(31 downto 0) := r.haddr;
      --else
        --vabufi.addr(TBUFABITS-1 downto 0) := r.haddr(TBUFABITS+3 downto 4);
        --vabufi.data := ahbsi.hwdata & ahbsi.hwdata & 
		       --ahbsi.hwdata & ahbsi.hwdata;
      --end if;

-- write trace buffer

      --if r.enable = '1' then 
        if (r.ahbactive and ahbsi.hready) = '1' then
          v.aindex := aindex;
          vabufi.enable := '1'; vabufi.write := "1111";
        end if;
      --end if;

-- trace buffer delay counter handling
--deleted part

-- save AHB transfer parameters

    if (ahbsi.hready = '1' ) then
      v.haddr := ahbsi.haddr; v.hwrite := ahbsi.hwrite; v.htrans := ahbsi.htrans;
      v.hsize := ahbsi.hsize; v.hburst := ahbsi.hburst;
      v.hmaster := ahbsi.hmaster; v.hmastlock := ahbsi.hmastlock;
    end if;
    if r.hsel = '1' then v.hwdata := ahbsi.hwdata; end if;
    if ahbsi.hready = '1' then
      v.hsel := ahbsi.hsel(hindex);
      v.ahbactive := ahbsi.htrans(1);
    end if;

-- AHB slave access to DSU registers and trace buffers
--deleted part

--the next part should be inspected whether to be left or not
    if ((ahbsi.hsel(hindex) and ahbsi.hready) = '1') and 
          ((ahbsi.htrans = HTRANS_BUSY) or (ahbsi.htrans = HTRANS_IDLE))
    then v.hready := '1'; end if;

    if rst = '0' then
      v.ahbactive := '0'; v.enable := '0'; v.timer := (others => '0');
      v.hsel := '0'; v.dcnten := '0'; v.bhit := '0';
      v.tbreg1.read := '0'; v.tbreg1.write := '0';
      v.tbreg2.read := '0'; v.tbreg2.write := '0';
    end if;

    tbi <= vabufi;
    
    rin <= v;

--    ahbso.hconfig <= hconfig;
--    ahbso.hirq    <= hirq;
--    ahbso.hsplit  <= (others => '0');
--    ahbso.hcache  <= '0';
--    ahbso.hrdata <= r.hwdata;
--    ahbso.hready <= r.hready;
--    ahbso.hindex <= hindex;

  end process; -- ctrl : process(rst, ahbmi, ahbsi, r, tbo)
  

-- srl_buffer_32 connections
buffer32: entity work.srl_buffer_32
  generic map (32)
  port map(
  	data_in => ccf_store_in_buffer,
  	data_out=> buffer_out,
  	reset => rst,
  	writes => ccf_store_in_buffer_write,
  	reads  => ccf_store_in_buffer_read,
  	full  => srl_buffer_full,
  	data_present => srl_buffer_data_present,
  	clk => clk
        );
-- including the timestamps component

  timestamps_comp : entity work.timestamps
    generic map ( m => 1024)
    port map (start => ccf_calc_start,
    clk => clk,
    ts => ts_signal
             );
    

  	  


-- miniuart connections
----------------------------------------------------------------------
miniuart : entity work.UART_TX
  generic map(
    g_CLKS_PER_BIT => 5208---2604---19200br----5208 ---50mhz with 9600br (5208)  -- Needs to be set correctly
    )
  port map(
    i_Clk =>clk,
    i_TX_DV=> transmit_footprint,
    --i_TX_Byte =>"01011001",-- DataIn Bus
    i_TX_Byte => uart_data_in,-- DataIn Bus
    o_TX_Active =>IntTx_O_signal ,---dummy signal
    o_TX_Serial=>uart_tx,-- Tx RS232 Line
    o_TX_Done=>uart_wait_for_byte_to_tx --dummysignal to done bit
    );
----------------------------------------------------------------------------
------------miniuart old----------------------------------------------------
--muart: entity work.miniuart
  -- generic map (130)
   --port map (
-- Wishbone signals
     --WB_CLK_I => clk,  -- clock
     --WB_RST_I => rst,  -- Reset input
     --WB_ADR_I => "00", -- Adress bus          
     --WB_DAT_I => uart_data_in,  -- DataIn Bus
     --WB_DAT_O => uart_data_out, -- DataOut Bus
--------------------------------------------------------
-----------start editing-------------------------------
     --WB_WE_I  => '1',  -- Write Enable
     --WB_WE_I  => uart_enable,  -- Write Enable
----------endediting------------------------------------
----------------------------------------------------------
    -- WB_STB_I => uart_strobe,  -- Strobe
     --WB_ACK_O => uart_ack,    -- Acknowledge
-- process signals     
    -- IntTx_O  => uart_wait_for_byte_to_tx,  -- Transmit interrupt: indicate waiting for Byte
    -- IntRx_O  => uart_byte_received,        -- Receive interrupt: indicate Byte received
     --BR_Clk_I => clk,  -- Clock used for Transmit/Receive
     --TxD_PAD_O=> uart_tx,  -- Tx RS232 Line
     --RxD_PAD_I=> uart_rx   -- Rx RS232 Line
     --);     


-- end of components added for CCF storing and transmission: srl_buffer_32 and miniuart


--  ahbso.hresp <= HRESP_OKAY;

  regs : process(clk)
     begin if rising_edge(clk) then r <= rin; end if; 
  end process;--regs : process(clk)

--  mem0 : tbufmem cut part

-- end of part from AHBTRACE

-- start of part for ccf calculations
-- Reset signal
 

  zero <= (others => '0');
  
  CCF_CALC_0 : process (clk)
  variable  counter          : integer:= 0 ;
  variable  tx_next_ccf      : std_logic:= '0';
  variable  new_address      : std_logic:= '0';
  begin
    if rising_edge(clk) then
--------------------------------------------
       ccf_to_uart <= outccf;          --assigning outccf to ccf_to_uart
-------------------------------------------
	    if start_wait_for_startaddr = '1' then --  now when start_wait_for_startaddr =1 , i.e. after reset
	          if curr_addr = X"40000000" or prev_addr = X"40000000" then
--------------------------------------------------------------------------------------------------------------
                     ccf_calc_start <= ccf_calc_start_port;
	            --ccf_calc_start <= '1';
-------------------------------------------------------------------------------------------------------------

	            --start_wait_for_startaddr <= '0';
	          end if;
                  prev_addr <= curr_addr; 
	          curr_addr <= tbi.data(31 downto 0); 
	        
	    end if; -- end of start_wait_for_startaddr
	    --
      if ccf_calc_start = '1' and ccf_calc_stop /= '1' then
         
        if ccf_func_not_timed = '0' then
           ccf_calc_en <= '1'; -- timed
        else -- ccf_func_not_timed = 1 
           if curr_addr /= prev_addr then 
               ccf_calc_en <= '1';
           else 
               ccf_calc_en <= '0';    
           end if;
        end if; -- end of if ccf_func_not_timed = '0'
        
        if stored_ccf_count < N_CCF then          
          counter := counter + 1;
          if counter = CCF_DISTANCE then -- writing CCF to memory
            ccf_store_in_buffer <= ccf;
            ccf_store_in_buffer_write <= '1';
            outccf <= ccf_store_in_buffer;
            counter := 0;
            stored_ccf_count <= stored_ccf_count + 1;
          elsif counter = 1 then 
            ccf_store_in_buffer_write <= '0';
          end if; -- end of if counter = CCF_DISTANCE 
        else --   stored_ccf_count > or =  N_CCF
         -- ccf_calc_stop <= '1';
          counter := 0;
          -- start the UART to transmit the buffer contents to host
        end if; -- end of if stored_ccf_count < N_CCF
      
      elsif ccf_calc_stop = '1' and uart_wait_for_byte_to_tx = '1' then
        --start output the CCFs sequentially from the FIFO through the miniUART
        if  (ccf_to_uart_prev xor ccf_to_uart) = X"00000000" then
           --transmit next CCF
           tx_next_ccf := '1';
           ccf_store_in_buffer_read <= '1';
        else 
           tx_next_ccf := '0';
           ccf_store_in_buffer_read <= '0';
        end if; 
        
        if tx_next_ccf = '1' then
           ccf_to_uart_prev <= ccf_to_uart;
        end if;
  --------------------------------------------------------------------------------      
        --uart_data_in <= ccf_to_uart(7 downto 0);
        --ccf_to_uart  <= ccf_to_uart(7 downto 0) & ccf_to_uart(msb downto 8); 
  ---------------------------------------------------------------------------------      
        
      end if; -- end of ccf_calc_start = '1' and ccf_calc_stop = '0'
    
    end if;
    -----
    ----- #FUTUREWORK1:START
    --if ccf_compare_to_ref = '1' then -- this is not yet implemented; intended for runtime CCF checks 
           --ccf_xor <= ccfa xor ccfref;
           --if ccf_xor = zero then
            --match_o <= '1';
          -- else
        --    match_o <= '0';
      --     end if; -- end of if ccf_xor = zero          
    --end if; -- end of ccf_compare_to_ref
    -----#FUTUREWORK1:END
    -----
  end process;
 
  --CCF_CALC : process (clk)
 -- begin
  --  if rising_edge(clk) then
    ---    if ccf_calc_en = '1' then 
       --    ccf_prev <= ccf;
       --    ccf <= tbi.data(31 downto 0) xor tbi.data(63 downto 32) xor csa32 xor ccf_prev ;           
     --   end if;
   -- end if;        
  --end process;

--Assigning the timestamps  
  --CSA32_CALC : process (clk)
  --begin
   -- if ccf_calc_start = '1' and ccf_calc_stop /= '1' then
    --  if rising_edge(clk) then
      --  csa <= csa(0) & csa(INIT_CSA_0'length-1 downto 1);
       -- csa32 <= csa(31 downto 0);
     -- end if;
    --end if;
  --end process;

--Calculating the the temporal cyclic footprints (from which temporal check can be reconstructed) 
  TCF_CALC : process (clk)
  begin
    if rising_edge(clk) then
        if ccf_calc_en = '1' then 
          --tcf_prev <= tcf;
          --tcf <= csa32 xor tcf_prev ;   
           tcf <= ts_signal;          
        end if;
    end if;        
  end process;


-------------------------------------
----------uart ack checking---------------
-- uart_ack : process (clk)
 -- variable max_sent_char := integer range 0 to 101:= 0;
 -- begin
   -- if rising_edge(clk) then
    -- NC_counter <=  NC_counter + 1;
   --   if (NC_counter < N_CCF) and (stop_tx /= '1') then
      
    --     if uart_wait_for_byte_to_tx = '1' then  
    --      transmit_footprint <= '1';
    --      uart_data_in <= "00001010";
    --     else
    --      transmit_footprint <= '1';
    --      uart_data_in <= "00001000";  
    --     end if;
  --   else 
  --    stop_tx <= '1';
  --    transmit_footprint <= '0';
  --   end if;
    --if NC_counter = 10000 then
      -- if ccf_calc_en = '1' then 
        --   if (ccf_calc_en = '1') then 
        --  N_counted <= N_counted + 1;
      --if uart_wait_for_byte_to_tx = '1' then  
    --if uart_wait_for_byte_to_tx = '1' and ccf_calc_en = '1' then              
         -- max_sent_char <= max_sent_char + 1;
        --  N_counted_vec <= std_logic_vector(to_unsigned(N_counted,8)); 
        --  uart_data_in <= "00001010";
       --else
         -- uart_data_in <= "00001000";  
       --end if;
    --NC_counter <= 0;
    --end if; 
 --  end if;        
--  end process;
----------end uart ack chexcking-------------
-------------------------------------------

  --- Calculating functional checks
 -- FC_CALC : process (clk)
 -- begin
    --if rising_edge(clk) then
     --  if ccf_calc_en = '1' then 
       --    fc_prev <= fc;
       --   fc <= tbi.data(63 downto 32) xor fc_prev ;           
--end if;
  --  end if;        
  --end process;

  --- Calculating N
  --N_CALC : process (clk)
  --begin
  --if rising_edge(clk) then 
  -- if (ccf_calc_en = '1') then 
  --    N_counted <= N_counted + 1;
  -- end if
     
  --end if;        
  --end process;
  
--------------------------------------------------------
Uart_Transfer: process (clk)
variable N_counted_var : integer range 0 to 1024:= 0; 
begin

 if rising_edge(clk) then
      
        if ccf_calc_start = '1' then 
          NC_counter <=  NC_counter + 1;  ---trace-cycle counter
         end if;    

         if (ccf_calc_en = '1') then 
           N_counted <= N_counted + 1;
         end if;
   
           if (NC_counter = 1023)then
           --put N_counted anf tcf in bytes to be txed

             if (ccf_calc_en = '1') then N_counted_var := N_counted +1; end if;
             N_counted_vec <= std_logic_vector(to_unsigned(N_counted_var,16));

               P(47 downto 40) <= N_counted_vec(15 downto 8);
               P(39 downto 32) <= N_counted_vec(7 downto 0);
               P(31 downto 24) <= tcf(31 downto 24);
               P(23 downto 16) <= tcf(23 downto 16);
               P(15 downto 8)  <= tcf(15 downto 8);
               P(7 downto 0)   <= tcf(7 downto 0);
          --
               PS(47 downto 0) <= P(47 downto 0);   
          --
               NC_counter <= 0;
               fp_tx_done <= '0';
               N_counted <= 0; 
               if (ccf_calc_en = '1') then 
                  N_counted <= 1; 
               end if;
               transmit_footprint_next_clk <= '1'; 
          --
               
            end if;

         if (transmit_footprint_next_clk = '1' ) then
              transmit_footprint <= '1'; 
              transmit_footprint_next_clk <= '0'; 
         end if;


   if (fp_tx_done = '0') then
 
    case tx_counter is
      when 0 =>
        transmit_footprint <= '1';
        uart_data_in <= PS(47 downto 40); --PS
       if (uart_wait_for_byte_to_tx = '1' ) then
        tx_counter <=1;
       else 
        tx_counter <= 0;
       end if;
      when 1 =>
        transmit_footprint <= '1';
        uart_data_in <= PS(39 downto 32);
       if (uart_wait_for_byte_to_tx = '1' )then
        tx_counter <= 2;
       else 
        tx_counter <= 1;
       end if;
      when 2 =>
        transmit_footprint <= '1';
        uart_data_in <= PS(31 downto 24);
       if (uart_wait_for_byte_to_tx = '1' ) then
        tx_counter <=3;
       else 
        tx_counter <=2;
       end if;
      when 3 =>
        transmit_footprint <= '1';
        uart_data_in <= PS(23 downto 16);
       if (uart_wait_for_byte_to_tx = '1' ) then
        tx_counter <=4;
       else
        tx_counter <=3;
       end if;
      when 4 =>
        transmit_footprint <= '1';
        uart_data_in <= PS(15 downto 8);
       if (uart_wait_for_byte_to_tx = '1' ) then
        tx_counter <=5;
       else
        tx_counter <=4;
       end if;
      when 5 =>
        transmit_footprint <= '1';
        uart_data_in <= PS(7 downto 0);
       if (uart_wait_for_byte_to_tx = '1' ) then
        tx_counter <= 6;
       else
        tx_counter <= 5;
       end if;
      when 6 =>
        tx_counter <= 0;
        fp_tx_done <= '1';
        transmit_footprint <= '0';
      when others =>
        tx_counter <= 0;
        transmit_footprint <= '0';
   end case;
   end if;
 end if;
end process;
--- -------------------------------------edited logic

-- including the logger component
--To Karthik: you don't need the bit logger (this was for the bit by bit transmission implementation), you might just group them into bytes to be sent directly with the URAT
  --logger : fp_bitlogger    
    --generic map(74)
    --port map (clk, fp, bit_out);
    
-- Footprints generation process
  --fp_gen : process(clk)
  --begin
   -- if rising_edge(clk) then
      -- Advancing the trace-cycle count
    --  M_count <= M_count +1;
      -- Handling instances of change
     -- if (r.e.ctrl.pc /= previous_pc) then
      --  TCF_pc <= TCF_pc xor ts_signal;
---	FC_pc  <= FC_pc xor r.e.ctrl.pc;
--	N_pc   <= N_pc + 1;
 --     end if;
      -- End of trace cycle tasks:
   --   if (M_count = 512)then
        -- Form and log footprint
    --    fp <= TCF_pc & FC_pc & N_pc ;
--	log_fp <= '1';
        -- reset N
  --      N_pc <= 0;
    --  else
      --  log_fp <= '0';  
      --end if;
      
      --previous_pc <= r.e.ctrl.pc;
    
    --end if;
  --end;
---------------------------------------------end edited logic











 
  --WRITE_CCFS_FROM_BUFF_TO_UART :process ()  
  
--CCF_INIT: process (clk)  
--  begin
--    if rising_edge(clk) then

--    end if; --- end of if rising_edge(clk)
--  end process;

PRESET: process (rst, clk)
  begin
   if rising_edge(clk) then
     if rst = '1' then                -- sync. reset
      --if rising_edge(clk) then
        --ccf <= INIT_VALUE;
        --ccf_prev <= INIT_VALUE;
        --ccf_calc_start <= '0';
        --csa <= INIT_CSA_0 ;
        start_wait_for_startaddr <= '1';
        --ccf_calc_stop <= '0';
        --match_o <= '0';
       --end if;
      end if; -- end of if rst = '1'
    end if;
  end process;

--------------------------------------------------------------------
---------------start editing srl buffer data out through uart-------------------
-- uart_out:process(clk)
-- begin
  -- if rising_edge(clk) then
  --   if uart_wait_for_byte_to_tx = '1' then     
    --    uart_data_in <=buffer_out(7 downto 0);
    --    buffer_out  <= buffer_out(7 downto 0) & buffer_out(msb downto 8);
   --  end if;
   --end if;
--end process;
      

---------------end editing-----------------------------------------
----------------------------------------------------------------------
  
-- Part to be revised
-- pragma translate_off
    bootmsg : report_version 
    generic map ("ahbtranschecker" & tost(hindex) &
    ": AHB Transactions CCF logger, " & tost(kbytes) & " kbytes");
-- pragma translate_on

end rtl;  

