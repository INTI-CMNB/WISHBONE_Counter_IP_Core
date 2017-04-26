------------------------------------------------------------------------------
----                                                                      ----
----  Mini UART package file                                              ----
----                                                                      ----
----  This file is part FPGA Libre project http://fpgalibre.sf.net/       ----
----                                                                      ----
----  Description:                                                        ----
----  Package file to ease the use of the wb counter                      ----
----                                                                      ----
----  To Do:                                                              ----
----  -                                                                   ----
----                                                                      ----
----  Author:                                                             ----
----    - Juan Pablo D. Borgna, jpborgna en inti.gov.ar                   ----
----    - Salvador E. Tropea, salvador en inti gov ar                     ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Copyright (c) 2005 Juan Pablo D. Borgna <jpborgna en inti.gov.ar>    ----
---- Copyright (c) 2006-2008 Salvador E. Tropea <salvador en inti gov ar> ----
---- Copyright (c) 2005-2008 Instituto Nacional de Tecnología Industrial  ----
----                                                                      ----
---- Distributed under the GPL v2 or newer license                        ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Design unit:      Counters (Package)                                 ----
---- File name:        wb_counter_pkg.vhdl                                ----
---- Note:             None                                               ----
---- Limitations:      None known                                         ----
---- Errors:           None known                                         ----
---- Library:          None                                               ----
---- Dependencies:     IEEE.std_logic_1164                                ----
----                   IEEE.numeric_std                                   ----
---- Target FPGA:      Spartan II (XC2S100-5-PQ208)                       ----
---- Language:         VHDL                                               ----
---- Wishbone:         SLAVE (rev B.3)                                    ----
---- Synthesis tools:  Xilinx Release 6.2.03i - xst G.31a                 ----
---- Simulation tools: GHDL [Sokcho edition] (0.1x)                       ----
---- Text editor:      SETEdit 0.5.x                                      ----
----                                                                      ----
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package Counters is

   component SCounter is
      generic(
         MOD_START : integer:=0; -- Reset value
         MOD_WIDTH : integer range 9 to 16:=16); -- Divisor width
      port(
         --Wishbone signals
         wb_clk_i : in  std_logic;  -- Clock
         wb_rst_i : in  std_logic;  -- Reset input
         wb_adr_i : in  std_logic_vector(0 downto 0); -- Adress bus
         wb_dat_i : in  std_logic_vector(7 downto 0); -- DataIn Bus
         wb_dat_o : out std_logic_vector(7 downto 0); -- DataIn Bus
         wb_we_i  : in  std_logic;  -- Write Enable
         wb_stb_i : in  std_logic;  -- Strobe
         wb_ack_o : out std_logic;  -- Acknowledge
         --Counter signals
         ce_i     : in  std_logic;  -- Pulses to count
         o_o      : out std_logic); -- Output
   end component SCounter;
   
   -- EXPORT CONSTANTS
   constant SCOUNTER_HI    : std_logic_vector(7 downto 0):="00000001";
   constant SCOUNTER_LO    : std_logic_vector(7 downto 0):="00000000";
   -- END EXPORT CONSTANTS
end package Counters;


