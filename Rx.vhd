library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity Rx is
  port (
    clk        : in std_logic;
    clk_12     : in std_logic;
    rst        : in std_logic;
    data       : in std_logic;
    byte_sel   : in std_logic_vector(2 downto 0);
    selector_3 : out std_logic_vector(2 downto 0);
    x_move     : out std_logic_vector(8 downto 0);
    y_move     : out std_logic_vector(8 downto 0);
    Rx_valid   : out std_logic
  );
end entity Rx;

architecture arc_Rx of Rx is

  signal byte1_sig     : std_logic_vector(9 downto 0);
  signal x_sig         : std_logic_vector(9 downto 0);
  signal y_sig         : std_logic_vector(9 downto 0);
  signal pairity       : std_logic_vector(2 downto 0);
  signal counter       : integer;
  signal ack           : std_logic;
  signal reset_trigger : std_logic := '0';
  signal reset         : std_logic := '0';
  signal rst_flag      : std_logic;
  signal byte1_finish  : std_logic := '0';
  signal byteX_finish  : std_logic := '0';
  signal byteY_finish  : std_logic := '0';

  -- Watchdog timer parameters
  constant WATCHDOG_TIMEOUT : time := 50 ms; -- Modify timeout value as needed
  constant CLK_12_PERIOD   : time := 83.33 us;

begin

  process (clk_12, rst) is
    variable watchdog_timer : time := 0 ns;
  begin

    if rst = '0' or reset = '1' then
      selector_3 <= (others => '0');
      x_sig <= (others => '0');
      y_sig <= (others => '0');
      byte1_sig <= (others => '0');
      pairity <= (others => '0');
      counter <= 0;
      ack <= '0';
      reset_trigger <= '0';
    elsif rising_edge(clk_12) then
      selector_3 <= (others => '0');

      case byte_sel is

        -- Byte 1 data
        when "001" =>
          if data = '0' and ack = '0' then
            ack <= '1';
            pairity <= (others => '0');
			byte1_finish <= '0';
			byteX_finish <= '0';
			byteY_finish <= '0';
          end if;

          if ack = '1' then
            if data = '1' then
              pairity(0) <= not pairity(0);
            end if;
            
            byte1_sig <= data & byte1_sig(9 downto 1); -- Shift register
            counter <= counter + 1;
			if counter = 9 then 
			byte1_finish <= '1' ;
			end if;
          end if;

        -- X move 
        when "010" =>
          if data = '0' and ack = '0' then
            ack <= '1';
          end if;

          if ack = '1' then
            if data = '1' then
              pairity(1) <= not pairity(1);
            end if;
            
            x_sig <= data & x_sig(9 downto 1); -- Shift register
            counter <= counter + 1;
			if counter = 9 then 
			byteX_finish <= '1' ;
			end if;
          end if;

        -- Y move 
        when "100" =>
          if data = '0' and ack = '0' then
            ack <= '1';
          end if;

          if ack = '1' then
            if data = '1' then
              pairity(2) <= not pairity(2);
            end if;
            
            y_sig <= data & y_sig(9 downto 1); -- Shift register
            counter <= counter + 1;
			if counter = 9 then 
			byteY_finish <= '1' ;
			end if;
          end if;

        when others => null;

      end case;

      if counter = 9 then
        counter <= 0;
        ack <= '0';
        selector_3 <= byte_sel and "111";
      end if;

      -- Watchdog timer reset
      if ((watchdog_timer < WATCHDOG_TIMEOUT) or (rst_flag = '0' ))then
        watchdog_timer := watchdog_timer + CLK_12_PERIOD;
        reset_trigger <= '0'; -- Reset trigger reset
      else
        reset_trigger <= '1'; -- Trigger reset
      end if;

    end if;

  end process;

  x_move <= byte1_sig(4) & x_sig(7 downto 0);
  y_move <= byte1_sig(5) & y_sig(7 downto 0);
  Rx_valid <= pairity(0) and pairity(1) and pairity(2) and (not byte1_sig(7)) and (not byte1_sig(6)) and byte1_finish and byteX_finish and byteY_finish;
  rst_flag <= (byte1_sig(7) or byte1_sig(6)) and byte1_finish ;
  
  -- Reset trigger assertion process
  reset_trigger_assertion: process(clk)
  begin
    if falling_edge(clk) then
      if reset_trigger = '1' then
         reset <= '1';
      else
         reset <= '0';
      end if;
    end if;
  end process;

end architecture arc_Rx;
