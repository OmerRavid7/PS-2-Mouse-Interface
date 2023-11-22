library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity init is
port(
	clk				:in std_logic;
	rst			   :in std_logic;
	init_start		:in std_logic;
	
	set			:out std_logic;	
	clk_12		:out std_logic;
	data			:out std_logic
	);
end entity init;


architecture arc_init of init is

	-- siganls for init process
	signal f6 : std_logic_vector(10 downto 0);
	signal counter : integer;

	-- signals for clk 12K process
	signal count_clk :  std_logic_vector(11 downto 0);
	signal clk_12_s : std_logic;
		
begin

--clk process

clk_12_s <= count_clk(11);

-- process count for inner clk
process(rst, clk)
begin
	if (rst = '0') then
		count_clk <= (others=> '0');
		
	elsif falling_edge(clk) then
		count_clk <= count_clk + 1;
	end if;
end process;
	
--process clk12 for out clk
process(rst, clk) 
begin
	if(rst = '0') then
		clk_12 <= '1';
		
	elsif falling_edge(clk) then
		clk_12 <= 'Z';
			if(init_start = '1') then
				clk_12 <= count_clk(11);
			end if;
	end if;
end process;

--process init f6
process(rst, clk_12_s)
begin
	if(rst = '0') then
		f6 <= "00110111101";
		data <= '1';
		set <= '0';
		counter <= 0;
		
	elsif falling_edge(clk_12_s) then
		data <= '1'; 
		set <= '0';
			
		if (init_start = '1') then
			data <= f6(10);
			f6 <= f6(9 downto 0) & f6(10);
			counter <= counter + 1;
		end if;
		
		if(counter = 10) then
			set <= '1';
			counter <= 0;
		end if;
	end if;
end process;

end architecture arc_init;
	
	
	
	
	
	
	
	
	
