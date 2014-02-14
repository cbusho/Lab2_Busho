----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:18:31 02/12/2014 
-- Design Name: 
-- Module Name:    pong_control - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pong_control is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  Switch : in STD_LOGIC;
           up : in  STD_LOGIC;
           down : in  STD_LOGIC;
           v_completed : in  STD_LOGIC;
           ball_x : out  unsigned (10 downto 0);
           ball_y : out  unsigned (10 downto 0);
           paddle_y : out  unsigned (10 downto 0));
end pong_control;

architecture Behavioral of pong_control is

type state_type is
					(idle, up_left, up_right, down_left, down_right);
	signal state_reg, state_next: state_type;
	signal ball_x_mov_reg, ball_x_mov_next,
			 ball_y_mov_reg, ball_y_mov_next: std_logic;
	signal count_reg, count_next, paddle_next, paddle_reg,
			 ball_x_reg, ball_x_next, ball_y_reg, ball_y_next: unsigned(10 downto 0);	

begin

-- state register
	process(clk, reset)
	begin
		if (reset = '1') then
			state_reg <= idle;
		elsif (clk'event and clk = '1') then
			state_reg <= state_next;
		end if;
	end process;
	
--look ahead output buffer	
	process(clk)
	begin
		if reset = '1' then
			ball_x_reg <= to_unsigned(200,11);
			ball_y_reg <= to_unsigned(200,11);
			ball_x_mov_reg <= '1';
			ball_y_mov_reg <= '1';
			paddle_reg <= to_unsigned(200,11);
		elsif (clk'event and clk = '1') then
			ball_x_mov_reg <= ball_x_mov_next;
			ball_y_mov_reg <= ball_y_mov_next;
			paddle_reg <= paddle_next;
			ball_x_reg <= ball_x_next;
			ball_y_reg <= ball_y_next;
		end if;
	end process;

	paddle_next <= paddle_reg - to_unsigned(5,11) when (up = '1' and count_reg = 2000 and paddle_reg > 40) else
						paddle_reg + to_unsigned(5,11) when (down = '1' and count_reg = 2000 and paddle_reg < 440) else
						paddle_reg;	
	
-- count logic
	process(clk, reset, v_completed)
	begin
		if (reset = '1') then
			count_reg <= (others => '0');
		elsif (rising_edge(clk) and v_completed = '1') then
			count_reg <= count_next;
		end if;
	end process;	
	
	count_next <= 	(others => '0') when (state_reg /= state_next) else
						count_reg + 1;	
						
-- next state logic
	process(state_reg, count_reg, ball_x_mov_reg, ball_y_mov_reg)
	begin
		state_next <= state_reg;
		case state_reg is
			when idle =>
				if (Switch = '1') then
					if (count_reg = 1000 and ball_x_mov_reg = '0' and ball_y_mov_reg = '0')then
						state_next <= down_left;
					elsif (count_reg = 1000 and ball_x_mov_reg = '0' and ball_y_mov_reg = '1')then
						state_next <= up_left;
					elsif (count_reg = 1000 and ball_x_mov_reg = '1' and ball_y_mov_reg = '0')then
						state_next <= down_right;
					elsif (count_reg = 1000 and ball_x_mov_reg = '1' and ball_y_mov_reg = '1')then
						state_next <= up_right;	
					end if;
				else		
					if (count_reg = 2000 and ball_x_mov_reg = '0' and ball_y_mov_reg = '0')then
						state_next <= down_left;
					elsif (count_reg = 2000 and ball_x_mov_reg = '0' and ball_y_mov_reg = '1')then
						state_next <= up_left;
					elsif (count_reg = 2000 and ball_x_mov_reg = '1' and ball_y_mov_reg = '0')then
						state_next <= down_right;
					elsif (count_reg = 2000 and ball_x_mov_reg = '1' and ball_y_mov_reg = '1')then
						state_next <= up_right;	
					end if;
				end if;
			when down_left =>
				state_next <= idle;
			when down_right =>
				state_next <= idle;
			when up_left =>
				state_next <= idle;
			when up_right =>
				state_next <= idle;	
		end case;
	end process;						

--look ahead output logic
	process(state_next, ball_x_reg, ball_y_reg, ball_x_next, ball_y_next)
	begin
		ball_x_next <= ball_x_reg;
		ball_y_next <= ball_y_reg;
		ball_x_mov_next <= ball_x_mov_reg;		
		ball_y_mov_next <= ball_y_mov_reg;
		
		--default value
		case state_next is
			when idle =>
				ball_x_next <= ball_x_reg;
				ball_y_next <= ball_y_reg;
				ball_x_mov_next <= ball_x_mov_reg;
				ball_y_mov_next <= ball_y_mov_reg;
			when down_left =>
				ball_x_next <= ball_x_reg - to_unsigned(1,11);
				ball_y_next <= ball_y_reg - to_unsigned(1,11);
			when down_right =>
				ball_x_next <= ball_x_reg + to_unsigned(1,11);
				ball_y_next <= ball_y_reg - to_unsigned(1,11); 
			when up_left =>
				ball_x_next <= ball_x_reg - to_unsigned(1,11);
				ball_y_next <= ball_y_reg + to_unsigned(1,11); 
			when up_right =>
				ball_x_next <= ball_x_reg + to_unsigned(1,11);
				ball_y_next <= ball_y_reg + to_unsigned(1,11); 
		end case;
		
		if(ball_x_next > 630) then
			ball_x_next <= to_unsigned(620,11);
			ball_x_mov_next <= '0';
		end if;	
		
		if(ball_x_next < 10) then
			ball_x_next <= to_unsigned(20,11);
			ball_x_mov_next <= '1';
		end if;	
		
		if(ball_y_next > 470) then
			ball_y_next <= to_unsigned(460,11);
			ball_y_mov_next <= '0';
		end if;	
		
		if(ball_y_next < 10) then
			ball_y_next <= to_unsigned(20,11);
			ball_y_mov_next <= '1';
		end if;	
		
	end process;

--output 
	ball_x <= ball_x_reg;
	ball_y <= ball_y_reg;
	paddle_y <= paddle_reg;

end Behavioral;

