------------------------------------------------------------------------------
----                                                                      ----
----  Wishbone Counter Testbench                                          ----
----                                                                      ----
----  This file is part FPGA Libre project http://fpgalibre.sf.net/       ----
----                                                                      ----
----  Description:                                                        ----
----  Test the funcionality of the counter.                               ----
----                                                                      ----
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
---- Design unit:      TestBench(Bench) (Entity and architecture)         ----
---- File name:        wb_counter_tb.vhdl                                 ----
---- Note:             None                                               ----
---- Limitations:      None known                                         ----
---- Errors:           None known                                         ----
---- Library:          None                                               ----
---- Dependencies:     IEEE.std_logic_1164                                ----
----                   IEEE.numeric_std                                   ----
----                   wb_handler.WishboneTB                              ----
----                   wb_counter.Counters                                ----
----                   utils.stdio                                        ----
---- Target FPGA:      None                                               ----
---- Language:         VHDL                                               ----
---- Wishbone:         None                                               ----
---- Synthesis tools:  None                                               ----
---- Simulation tools: GHDL [Sokcho edition] (0.1x)                       ----
---- Text editor:      SETEdit 0.5.x                                      ----
----                                                                      ----
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library wb_handler;
use wb_handler.WishboneTB.all;
library wb_counter;
use wb_counter.Counters.all;
library utils;
use utils.stdio.all;

entity TestBench is
end entity TestBench;

architecture Bench of TestBench is
   constant CLKPERIOD    : time:=40 ns;
   constant PULSESPERIOD : time:=1 us;
   
   signal wb_rst   : std_logic:='1';
   signal wb_clk   : std_logic;
   signal wb_adr   : std_logic_vector(7 downto 0);
   signal adr      : std_logic_vector(0 downto 0);
   signal wb_dati  : std_logic_vector(7 downto 0):=(others => 'Z');
   signal wb_dato  : std_logic_vector(7 downto 0);
   signal wb_we    : std_logic;
   signal wb_stb   : std_logic;
   signal wb_ack   : std_logic;
   
   signal wbi      : wb_bus_i_type;
   signal wbo      : wb_bus_o_type;
   
   -- SimpleCounter
   signal finish   : std_logic;
   signal enable   : std_logic:='0';

   signal stop_clk : std_logic:='0';
begin
   adr <= wb_adr(0 downto 0);

   -- Clock
   p_clks:
   process
   begin
      wb_clk <= '0';
      wait for CLKPERIOD/2;
      wb_clk <= '1';
      wait for CLKPERIOD/2;
      if stop_clk='1' then
         wait;
      end if;
   end process p_clks;

   -- Reset pulse
   p_reset:
   process
   begin
      wb_rst <= '1';
      wait until rising_edge(wb_clk);
      wb_rst <= '0' after 150 ns;
      wait;
   end process p_reset;

   -- Connect the records to the individual signals
   wbi.clk  <= wb_clk;
   wbi.rst  <= wb_rst;
   wbi.dato <= wb_dato;
   wbi.ack  <= wb_ack;

   wb_stb   <= wbo.stb;
   wb_we    <= wbo.we;
   wb_adr   <= wbo.adr;
   wb_dati  <= wbo.dati;

   count1: SCounter
      generic map(MOD_WIDTH => 10)
      port map(
          --Wishbone signals
          wb_clk_i => wb_clk, wb_rst_i => wb_rst, wb_adr_i => adr,
          wb_dat_i => wb_dati, wb_dat_o => wb_dato, wb_we_i => wb_we,
          wb_stb_i => wb_stb, wb_ack_o => wb_ack,
          --Counter signals
          ce_i => enable, o_o => finish);

   do_testbench:
   process
      variable start  : time;
      variable pulses : integer;
   begin
      outwrite("* Simple Counter testbench");
      --initial reset
      wait until wb_rst='0';
      outwrite(" - Reseted");

      --Check the state of finish
      assert finish='0' report "finish sholud be '0' for initial count" severity failure;

      outwrite(" - Want to count to 5");
      --want to count to 5 -- send a 4
      WBWrite(SCOUNTER_HI,"00000000",wbi,wbo);
      outwrite(" - Writing high byte");
      WBWrite(SCOUNTER_LO,"00000100",wbi,wbo);
      outwrite(" - Writing low byte");
      -- Wait until the new count is loaded
      wait until rising_edge(wb_clk);

      enable <= '1';
      start:=now;
      
      wait until finish='1';
      pulses:=(now-start)/CLKPERIOD;
      outwrite(" - Finished counting: "&integer'image(pulses));
      assert pulses=5 report "Wrong timing" severity failure;
      start:=now;
      wait until finish='0';

      wait until finish='1';
      pulses:=(now-start)/CLKPERIOD;
      outwrite(" - Finished counting: "&integer'image(pulses));
      assert pulses=5 report "Wrong timing" severity failure;
      start:=now;
      wait until finish='0';
      
      wait until finish='1';
      pulses:=(now-start)/CLKPERIOD;
      outwrite(" - Finished counting: "&integer'image(pulses));
      assert pulses=5 report "Wrong timing" severity failure;
      
      enable <= '0';
      
      outwrite(" - Want to count to 1000");
      --now, want to count to 1000 -- send a 999=0b11 1110 0111
      WBWrite(SCOUNTER_HI,"00000011",wbi,wbo);
      outwrite(" - Writing high byte");
      WBWrite(SCOUNTER_LO,"11100111",wbi,wbo);
      outwrite(" - Writing low byte");
      -- Wait until the new count is loaded
      wait until rising_edge(wb_clk);
      
      enable <= '1';
      start:=now;
      
      wait until finish='1';
      pulses:=(now-start)/CLKPERIOD;
      outwrite(" - Finished counting: "&integer'image(pulses));
      assert pulses=1000 report "Wrong timing" severity failure;
      start:=now;
      wait until finish='0';
      
      wait until finish='1';
      pulses:=(now-start)/CLKPERIOD;
      outwrite(" - Finished counting: "&integer'image(pulses));
      assert pulses=1000 report "Wrong timing" severity failure;

      outwrite("* End of test");
      stop_clk <= '1';
      wait;
   end process do_testbench;
end architecture Bench; -- Entity: TestBench

