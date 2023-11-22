library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TB is
end;


architecture arc_TB of TB is

	component mouse_control
	port(
		clk		:in std_logic;
		rst     	:in std_logic;
		
		data_mouse	:inout std_logic;
		clk_mouse	:inout std_logic;
		
		valid	   	:out std_logic;
		x_move		:out std_logic_vector(8 downto 0);
		y_move		:out std_logic_vector(8 downto 0)
		);
	end component;

	
	constant clock_period: time := 20 ns;
	constant clock_period_12: time := 81.92 us;	-- T=50MHz/2^12=12.207kHz
	signal stop_the_clock_12: boolean:=true;
	signal sig_mouse_data	:std_logic:= '1';
	signal sig_clk_mouse	:std_logic:= '1';
	signal clk_12		   :std_logic:= '1';
	signal clk		   :std_logic:= '0';
	signal rst		   :std_logic:= '0';	
	signal valid		:std_logic:= '0';
	signal x_move		:std_logic_vector(8 downto 0):= "000000000";
	signal y_move		:std_logic_vector(8 downto 0):= "000000000";
	signal data_send	:std_logic_vector(10 downto 0):= "00000000000";
	signal data_send_s	:std_logic := '1';
	signal flag_sig	:boolean := false;


begin

	uut: mouse_control
	port map ( 
		clk        => clk,
		rst        => rst,
		data_mouse => data_send_s,
		clk_mouse  => sig_clk_mouse,
		valid      => valid,
		x_move     => x_move,
		y_move     => y_move
		);

		
rst <= '1' after 100 ns;


	-- 50MHz clock
	process
	begin
		wait for clock_period / 2;
		clk	<= (NOT clk);
	end process;
  
  
	-- 12.207kHz clock
	process
	begin
		wait for clock_period_12 / 2;
		if(stop_the_clock_12 = true) then
			clk_12	<= '1';
		else
			clk_12	<= (NOT clk_12);
		end if;
	end process;

-- receive F6 and conecting mouse to data
process
begin
	wait until falling_edge(clk);
	if (flag_sig = true) then
		sig_clk_mouse <= clk_12;
		data_send_s <= sig_mouse_data;
	else
		sig_clk_mouse <= 'Z';
		data_send_s <= 'Z';
	end if;
end process;

-- sending data, valid data, expact to work
process
begin
		wait for 1.5 ms;
		flag_sig <= true;
		

		stop_the_clock_12	<=	false;

		wait for clock_period_12*3;

		-- Byte 1
		data_send	<=	"00001110011";

		wait for clock_period_12;

		for i in 10 downto 0 loop
			sig_mouse_data	<=	data_send(i);
			wait until rising_edge(clk_12);
		end loop;

		-- X data
		data_send	<=	"01101101101";
		
		wait for 179.8 us;

		for i in 10 downto 0 loop
			sig_mouse_data	<=	data_send(i);
			wait until rising_edge(clk_12);
		end loop;

		-- Y data
		data_send	<=	"00010010001";
		
		wait for 179.8 us;

		for i in 10 downto 0 loop
			sig_mouse_data	<=	data_send(i);
			wait until rising_edge(clk_12);
		end loop;
		stop_the_clock_12 	<= true;
		wait for 1 ms;
		
		
		-- Test 2
		-- Data with overflow.
		--	Valid is expected to be '0'
		stop_the_clock_12	<= false;

		wait for clock_period_12*3;

		-- Byte 1
		data_send	<=	"00001001001";

		wait for clock_period_12;

		for i in 10 downto 0 loop
			sig_mouse_data	<=	data_send(i);
			wait until rising_edge(clk_12);
		end loop;

		-- X data
		data_send	<=	"01111100101";

		wait for 189.8 us;

		for i in 10 downto 0 loop
			sig_mouse_data	<=	data_send(i);
			wait until rising_edge(clk_12);
		end loop;

		-- Y data
		data_send	<=	"00111000011";
		
		wait for 189.8 us;

		for i in 10 downto 0 loop
			sig_mouse_data	<=	data_send(i);
			wait until rising_edge(clk_12);
		end loop;

		stop_the_clock_12 	<= true;
		
		wait for 189.8 us;
		-- Test 3
		-- watchdog
		--expected reset
		stop_the_clock_12	<= false;

		wait for clock_period_12*3;

		-- Byte 1
		data_send	<=	"00000000001";

		wait for clock_period_12;

		for i in 10 downto 0 loop
			sig_mouse_data	<=	data_send(i);
			wait until rising_edge(clk_12);
		end loop;

		-- X data
		data_send	<=	"01111111101";

		wait for 189.8 us;

		for i in 10 downto 0 loop
			sig_mouse_data	<=	data_send(i);
			wait until rising_edge(clk_12);
		end loop;

		-- Y data
		data_send	<=	"00111111111";
		
		wait for 189.8 us;

		for i in 10 downto 0 loop
			sig_mouse_data	<=	data_send(i);
			wait until rising_edge(clk_12);
		end loop;

		stop_the_clock_12 	<= true;
		


		wait;
	end process;
end architecture arc_TB;
		
		
	
		
