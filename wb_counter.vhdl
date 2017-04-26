------------------------------------------------------------------------------
----                                                                      ----
----  Wishbone Counter                                                    ----
----                                                                      ----
----  This file is part FPGA Libre project http://fpgalibre.sf.net/       ----
----                                                                      ----
----  Description:                                                        ----
----  Programable 8 to 16 bits counter with wishbone interface            ----
----                                                                      ----
----  Registers:                                                          ----
----  0 Divisor Low, R/W only                                             ----
----  1 Divisor High, R/W only                                            ----
----                                                                      ----
----  Important: the new count is effective after writing the low part.   ----
----  It means you must write the high part first.                        ----
----  Important: after loading the low register one extra clock pulse is  ----
----  needed before starting the count.                                   ----
----                                                                      ----
----  To Do:                                                              ----
----   -                                                                  ----
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
---- Design unit:      SCounter(Count)  (Entity and architecture)         ----
---- File name:        wb_counter.vhdl                                    ----
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
----                                                                      ----
---- Wishbone Datasheet                                                   ----
----                                                                      ----
----  1 Revision level                      B.3                           ----
----  2 Type of interface                   SLAVE                         ----
----  3 Defined signal names                RST_I => wb_rst_i             ----
----                                        CLK_I => wb_clk_i             ----
----                                        ADR_I => wb_adr_i             ----
----                                        DAT_I => wb_dat_i             ----
----                                        DAT_O => wb_dat_o             ----
----                                        WE_I  => wb_we_i              ----
----                                        ACK_O => wb_ack_o             ----
----                                        STB_I => wb_stb_i             ----
----  4 ERR_I                               Unsupported                   ----
----  5 RTY_I                               Unsupported                   ----
----  6 TAGs                                None                          ----
----  7 Port size                           8-bit                         ----
----  8 Port granularity                    8-bit                         ----
----  9 Maximum operand size                8-bit                         ----
---- 10 Data transfer ordering              N/A                           ----
---- 11 Data transfer sequencing            Undefined                     ----
---- 12 Constraints on the CLK_I signal     None                          ----
----                                                                      ----
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity SCounter is
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
end entity SCounter;

architecture Count of SCounter is
   signal modul_r   : unsigned(MOD_WIDTH-1 downto 0):=to_unsigned(MOD_START,MOD_WIDTH);
   signal rst_cnt_r : std_logic:='0';
begin
   cuenta:
   process (wb_clk_i)
      variable cnt : unsigned(MOD_WIDTH-1 downto 0);
   begin
      if rising_edge(wb_clk_i) then
         o_o <= '0';
         if wb_rst_i='1' or rst_cnt_r='1' then
            cnt:=modul_r;
         else -- wb_rst_i='0'
            if ce_i='1' then
               if cnt=0 then
                  o_o <= '1';
                  cnt:=modul_r;
               else
                  cnt:=cnt-1;
               end if; -- cnt/=0
            end if; -- ce_i='1'
         end if; -- wb_rst_i='0'
      end if; -- rising_edge(wb_clk_i)
   end process cuenta;

   WBctrl:
   process (wb_clk_i)
   begin
      if rising_edge(wb_clk_i) then
         rst_cnt_r <= '0';
         if wb_rst_i='1' then
            modul_r <= to_unsigned(MOD_START,MOD_WIDTH);
         elsif wb_stb_i='1' and wb_we_i='1' then
            if wb_adr_i="1" then
               -- Write Byte to modul_hi
               modul_r(MOD_WIDTH-1 downto 8) <= unsigned(wb_dat_i(MOD_WIDTH-9 downto 0));
            else -- Write Byte to modul_lo
               modul_r(7 downto 0) <= unsigned(wb_dat_i);
               -- After loading the low portion we force a counter reset
               rst_cnt_r <= '1';
            end if;
         end if;
      end if;
   end process WBctrl;

  wb_ack_o <= wb_stb_i;
  wb_dat_o <= std_logic_vector(modul_r(7 downto 0)) when wb_adr_i="0" else
              std_logic_vector(resize(modul_r(MOD_WIDTH-1 downto 8),8));
end architecture Count; -- Entity: SCounter

