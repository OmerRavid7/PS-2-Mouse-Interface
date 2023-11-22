library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity sync is
port(
	clk		:in std_logic;
	rst		:in std_logic;
	d_in		:in std_logic;
	d_out		:out std_logic
	);
end entity sync;



--We use DFF to synchronize the signals to the clock of the system

architecture arc_sync of sync is
 
begin
process(clk, rst)
	begin
		if (rst = '0') then
			d_out <= '1';

		elsif rising_edge(clk) then
			d_out <= d_in;
		end if;

	end process;
 
end architecture arc_sync;