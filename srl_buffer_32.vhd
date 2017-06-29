----------------------------------------------------------------------------
----                                                                    ----
----                                                                    ----
---- This file is copied and modofied from the srl_fifo project         ----
---- http://www.opencores.org/cores/srl_fifo                            ----
----                                                                    ----
---- Description                                                        ----
---- Implementation of srl_buffer IP core according to                  ----
---- srl_buffer IP core specification document.                         ----
----                                                                    ----
---- To Do:                                                             ----
----	NA                                                              ----
----                                                                    ----
---- Author(s):                                                         ----
----   Andrew Mulcock, amulcock@opencores.org        
---- Modified to buffer instead of FIFO by:
----    Rehab Massoud, hatoon@opencores.org                             ----
---- The modified buffer is a one time write/one time read buffer       ----
----     In the modified design 2 different pointers used for r/w.      ----
---- Reads and Writes are independant, so user should take care of      ----
---- possibele racing or overwrites. 
----   All below comments are from the original FIFO project            ----
----------------------------------------------------------------------------
----                                                                    ----
---- Copyright (C) 2008 Authors and OPENCORES.ORG                       ----
----                                                                    ----
---- This source file may be used and distributed without               ----
---- restriction provided that this copyright statement is not          ----
---- removed from the file and that any derivative work contains        ----
---- the original copyright notice and the associated disclaimer.       ----
----                                                                    ----
---- This source file is free software; you can redistribute it         ----
---- and/or modify it under the terms of the GNU Lesser General         ----
---- Public License as published by the Free Software Foundation;       ----
---- either version 2.1 of the License, or (at your option) any         ----
---- later version.                                                     ----
----                                                                    ----
---- This source is distributed in the hope that it will be             ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied         ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR            ----
---- PURPOSE. See the GNU Lesser General Public License for more        ----
---- details.                                                           ----
----                                                                    ----
---- You should have received a copy of the GNU Lesser General          ----
---- Public License along with this source; if not, download it         ----
---- from http://www.opencores.org/lgpl.shtml                           ----
----                                                                    ----
----------------------------------------------------------------------------
----                                                                    ----
-- CVS Revision History                                                 ----
----                                                                    ----
-- $Log: not supported by cvs2svn $                                     ----
----                                                                    ----
----                                                                    ----
-- quick description
--
--  Based upon the using a shift register as a buffer which has been 
--   around for years ( decades ), but really came of use to VHDL 
--   when the Xilinx FPGA's started having SRL's. 
--
--  In my view, the definitive article on shift register logic buffer's 
--   comes from Mr Chapman at Xilinx, in the form of his BBFIFO
--    tecXeclusive article, which as at early 2008, Xilinx have
--     removed.
--
--
-- using Xilinx ISE 10.1 and later, the tools are getting real clever.
--   In previous version of ISE, SRL inferance was not this clever.
--     now if one infers a 32 bit srl in a device that has inherantly 16 
--      bit srls, then an srl and a series of registers was created.
--   In 10,1 and later, if you infer a 32 bit srl for a device with
--    16 bit srls in, then you end up with the cascaded srls as expected.
--
--    Well done Xilinx..
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.NUMERIC_STD.all;

entity srl_buffer_32 is
    generic ( width : integer := 32 ); -- set to how wide buffer is to be
    port( 
-----------------------------------------------------------------------------------
----------------add editing--------------------------------------------------------
        data_in      : in     std_logic_vector (width -1 downto 0);

-----------------end editing-------------------------------------------------------
-----------------------------------------------------------------------------------
        data_out     : out    std_logic_vector (width -1 downto 0);
        reset        : in     std_logic; -- reset is done when reset = 1
        writes       : in     std_logic;
        reads        : in     std_logic;
        full         : out    std_logic;
        data_present : out    std_logic;
        clk          : in     std_logic
    );

-- Declarations

end srl_buffer_32 ;
--
------------------------------------------------------------------------------------
--
architecture rtl of srl_buffer_32 is
--
------------------------------------------------------------------------------------
--

constant srl_length  : integer := 320;    -- set to srl 'type' 16 or 32 bit length

type	srl_array	is array ( srl_length - 1  downto 0 ) of STD_LOGIC_VECTOR ( WIDTH - 1 downto 0 );
--------------------------------------------------------------------------------------
----add editing-----------------------------------------------------------------------
signal	buffer_store		: srl_array;
--signal buffer_store :srl-array:= (others => "00000000000000000000000000000000");
----------end editing-----------------------------------------------------------------
--------------------------------------------------------------------------------------

signal  pointer            : integer range 0 to srl_length - 1;
signal  pointer_out        : integer range 0 to srl_length - 1;

signal pointer_zero        : std_logic := '1';
signal pointer_full        : std_logic := '0';
signal valid_write         : std_logic;
signal valid_read          : std_logic;

signal empty               : std_logic := '1';
signal valid_count         : std_logic ;

------------------------------------------------------------------------------------
--
------------------------------------------------------------------------------------
--	
begin

--	W	R	Action
--	0	0	pointer <= pointer
--	0	1	pointer <= pointer - 1	Read, but no write, so less data in counter
--	1	0	pointer <= pointer + 1	Write, but no read, so more data in buffer
--	1	1	pointer <= pointer      Read and write, so same number of words in buffer
--

valid_count <= '1' when (
                             (writes = '1' and reads = '0' and pointer_full = '0' and empty = '0' )
                        or
                             (writes = '0' and reads = '1' and pointer_zero = '0' )
                         ) else '0';

-- Valid write, high when valid to write data to the store.
valid_write <= '1' when ( writes = '1' and pointer_full = '0')  
                     else '0';
-- Valid read, high when valid to read data from the store.
valid_read  <= '1' when ( reads  = '1' and empty = '0')  
                     else '0';

-- data store SRL's
data_srl_w :process( clk )
begin
    if rising_edge( clk ) then
        if reset = '1' then
            pointer <= 0;
        elsif valid_write = '1' then
            buffer_store (pointer) <= data_in;
            if valid_count = '1' then
                pointer <= pointer + 1;
                if pointer = (srl_length-1) then 
                    pointer <= 0 ; --cyclic write
                end if;
            end if; -- valid_count
        end if;--end of if valid_write = '1' 
    end if;
end process;
    
-- data read SRL's
data_srl_r :process( clk )
begin
    if rising_edge( clk ) then
        if reset = '1' then
            pointer_out <= 0;
        elsif valid_read = '1' then
            data_out <= buffer_store( pointer_out );
            if valid_count = '1' then
                pointer_out <= pointer_out + 1;
                if pointer_out = (srl_length-1) then 
                    pointer_out <= 0 ; --cyclic read
                end if;
            end if; -- valid_count
        end if;--end of if valid_read = '1'
    end if;
end process;

reset_read_write_pointers_and_epmty: process( clk)
begin
    if rising_edge( clk ) then
        if reset = '1' then
            empty <= '1';           
        elsif empty = '1' and writes = '1' then
            empty <= '0';
        elsif pointer_zero = '1' and writes = '0' then
            empty <= '1';
        end if;
    end if;
end process;


  -- Detect when pointer is zero and maximum
pointer_zero <= '1' when (pointer = 0 and writes = '0') else '0'; -- = 1 when true, i.e. pointer_zero is 1 when the pointer is in any other position than 0
pointer_full <= '1' when (pointer = srl_length - 1) else '0';




  -- assign internal signals to outputs
  full <= pointer_full;  
  data_present <= not( empty );

end rtl;

------------------------------------------------------------------------------------
--
------------------------------------------------------------------------------------


