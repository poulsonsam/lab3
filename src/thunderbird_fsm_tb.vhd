--+----------------------------------------------------------------------------
--| 
--| COPYRIGHT 2017 United States Air Force Academy All rights reserved.
--| 
--| United States Air Force Academy     __  _______ ___    _________ 
--| Dept of Electrical &               / / / / ___//   |  / ____/   |
--| Computer Engineering              / / / /\__ \/ /| | / /_  / /| |
--| 2354 Fairchild Drive Ste 2F6     / /_/ /___/ / ___ |/ __/ / ___ |
--| USAF Academy, CO 80840           \____//____/_/  |_/_/   /_/  |_|
--| 
--| ---------------------------------------------------------------------------
--|
--| FILENAME      : thunderbird_fsm_tb.vhd (TEST BENCH)
--| AUTHOR(S)     : Capt Phillip Warner
--| CREATED       : 03/2017
--| DESCRIPTION   : This file tests the thunderbird_fsm modules.
--|
--|
--+----------------------------------------------------------------------------
--|
--| REQUIRED FILES :
--|
--|    Libraries : ieee
--|    Packages  : std_logic_1164, numeric_std
--|    Files     : thunderbird_fsm_enumerated.vhd, thunderbird_fsm_binary.vhd, 
--|				   or thunderbird_fsm_onehot.vhd
--|
--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity thunderbird_fsm_tb is
end thunderbird_fsm_tb;
architecture test_bench of thunderbird_fsm_tb is 
	component thunderbird_fsm is 
	   port(
	       i_clk, i_reset : in std_logic;
	       i_left, i_right: in std_logic;
	       o_lights_L     : out std_logic_vector(2 downto 0);
	       o_lights_R     : out std_logic_vector(2 downto 0)
	   );
	end component;
	-- Signals
	signal w_R : std_logic := '0';
	signal w_RL : std_logic_vector(1 downto 0) := "00";
	signal w_clk : std_logic := '0';
	signal w_lights : std_logic_vector(5 downto 0) := "000000";
	constant clk_period : time := 10 ns;
begin
	-- Instantiate Unit Under Test (UUT)
	uut: thunderbird_fsm port map (
	   i_clk => w_clk,
	   i_reset => w_R,
	   i_left => w_RL(1),
	   i_right => w_RL(0),
	   o_lights_L(0) => w_lights(0),
	   o_lights_L(1) => w_lights(1),
	   o_lights_L(2) => w_lights(2),
	   o_lights_R(0) => w_lights(3),
	   o_lights_R(1) => w_lights(4),
	   o_lights_R(2) => w_lights(5)
	);
	-- Clock generation
	clk_proc : process
	begin
		w_clk <= '0';
        wait for clk_period/2;
		w_clk <= '1';
		wait for clk_period/2;
	end process;
	-- Simulation process
	sim_process: process
	begin
	    w_RL <= "00";
		wait for clk_period;
		  assert w_lights = "000000" report "stop fails" severity failure;		
		w_RL <= "10";
		wait for clk_period;
		  assert w_lights = "000111" report "left 3 fails" severity failure;
		  
		  
        w_RL <= "01";
		wait for clk_period;
		  assert w_lights = "111000" report "right 3 fails" severity failure;
		wait for clk_period;
		  assert w_lights = "000000" report "all right fails" severity failure;
		w_RL <= "11";
		wait for clk_period;
		  assert w_lights = "111111" report "hazards fail" severity failure;
		wait;
	end process;
end test_bench;