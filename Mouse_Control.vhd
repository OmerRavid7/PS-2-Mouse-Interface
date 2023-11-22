library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity Mouse_control is
port(
	clk			:in std_logic;
	rst   		:in std_logic;

	data_mouse	:inout std_logic;
	clk_mouse	:inout std_logic;
	
	valid	    	:out std_logic;
	x_move		:out std_logic_vector(8 downto 0);
	y_move		:out std_logic_vector(8 downto 0)
	);
end entity Mouse_control; 


architecture arc_Mouse_control of Mouse_control is

component init is
port(
	clk				 :in std_logic;
	rst			     :in std_logic;
	init_start		 :in std_logic;
	
	set    	    	:out std_logic;	
	clk_12		   :out std_logic;
	data		   :out std_logic
	);
end component;

component valid_check is
port(
	clk		   :in std_logic;
	rst		   :in std_logic;
	SM_valid	   :in std_logic;
	Rx_valid	   :in std_logic;
	
	valid	   	:out std_logic
	);
end component;

component sync is
port(
	clk		:in std_logic;
	rst		:in std_logic;
	d_in		:in std_logic;
	d_out		:out std_logic
	);
end component;

component Rx is
port(
	clk				:in std_logic;
	clk_12			:in std_logic;
	rst			   :in std_logic;
	data       		:in std_logic;
	byte_sel			:in std_logic_vector(2 downto 0);	
	
	selector_3		:out std_logic_vector(2 downto 0);
	x_move		   :out std_logic_vector(8 downto 0);
	y_move		   :out std_logic_vector(8 downto 0);
	Rx_valid		   :out std_logic
	);
end component;



-- init signals
signal init_start : std_logic;
signal set 			: std_logic;
signal clk_init		: std_logic;
signal data_init  : std_logic;

-- sync signals
signal sync_clk :std_logic;
signal sync_data :std_logic;

-- Rx signals
signal Rx_valid      :std_logic;
signal selector_3		:std_logic_vector(2 downto 0);
signal byte_sel		:std_logic_vector(2 downto 0);

--SM signals
signal SM_valid      :std_logic;
type SM_control is (reset , initsm , byte_1 , byte_2 , byte_3 , validsm);
signal state : SM_control ; 
 
begin

init11 : init
port map(
	clk	=>	clk,
	rst	=>	rst,
	init_start	=>	init_start,

	set	=>	set,
	clk_12	=>	clk_init,
	data	=>	data_init	
);


Reciver : Rx
port map(
	clk => clk,
	rst => rst,
	selector_3 => selector_3,
	byte_sel => byte_sel,
	clk_12 => sync_clk,
	data => sync_data,
	x_move => x_move,
	y_move => y_move,
	Rx_valid => Rx_valid
);

clk_sync : sync
port map(
	clk => clk,
	rst => rst,
	d_in => clk_mouse,
	d_out => sync_clk
);

data_sync : sync
port map(
	clk => clk,
	rst => rst,
	d_in => data_mouse,
	d_out => sync_data
);

	-- Process to set 'Z' on INOUT ports when init is done
	start_process: process(clk, rst)
	begin
	
		if (rst = '0') then
			data_mouse	<=  	data_init;
			clk_mouse	<=		clk_init;
		
		elsif falling_edge(clk) then
			if (init_start = '0') then
				data_mouse	<=	'Z';
				clk_mouse	<=	'Z';
			else
				data_mouse	<=	data_init;
				clk_mouse	<= clk_init;
			end if;
		end if;
		
	end process;
 
 

	-- Process for SM control

process (clk , rst) is 
begin 

	if (rst = '0') then
		state <= reset;
		
	elsif Falling_edge(clk) then

	state<= state;	


		case state is
			
			when reset => 
				state <= initsm;
				
			
			when initsm =>
			if (set ='1') then
				state <= byte_1;
			end if;
				
			when byte_1 =>
			if (selector_3 ="001") then
				state <= byte_2;
			end if;
			
			when byte_2 =>
			if (selector_3 = "010") then
				state <= byte_3;
			end if;
			
			when byte_3 => 
			if (selector_3 = "100") then
				state <= validsm;
			end if;
			
			when validsm =>
				state <= byte_1;
				
			when others =>
				state <= reset;
				
		end case;
	end if;
end process;
		

	
process(clk, rst)
begin 
	if(rst = '0') then
	
		init_start <= '0';
		byte_sel <= (others=>'0');
		sm_valid <= '0';
		
	elsif falling_edge(clk) then
	
		init_start <= '0';
		byte_sel <= (others=>'0');

			case state is
				when initsm =>
					init_start <= '1';
					sm_valid <= '0';

					
				when byte_1 => 
					byte_sel(0) <= '1';
					sm_valid <= '0';

					
				when byte_2 =>
					byte_sel(1) <= '1';
					
				when byte_3 =>
					byte_sel(2) <= '1';
					sm_valid <= '1';
					
				when validsm =>
					sm_valid <= '1';
					
				when others =>
				
			end case;
	end if;
end process;
 
 
 valid_process: process(clk, rst)
begin
	if (rst = '0') then
		valid	<=	'0';
		
	elsif falling_edge(clk) then
		valid	<=	SM_valid AND Rx_valid;
	end if;

end process;
 
end architecture arc_Mouse_control;
	



