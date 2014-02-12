----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:37:22 02/04/2014 
-- Design Name: 
-- Module Name:    pixel_gen - Behavioral 
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

entity pong_pixel_gen is
    Port ( row : in  unsigned (10 downto 0);
           column : in  unsigned (10 downto 0);
           blank : in  STD_LOGIC;
			  ball_x, ball_y, paddle_y : in unsigned (10 downto 0);
           r,g,b : out  STD_LOGIC_VECTOR (7 downto 0)
			 ); 
end pong_pixel_gen;

architecture Behavioral of pong_pixel_gen is

	type color_type is
					(black, blue, green, red, yellow);
	signal color: color_type;				

begin
	
	process(blank, column, row)
	begin
		if (blank = '1') then
			color <= black;
		
		elsif (column >= 213) and (column <= 240) and (row >= 160) and (row <= 320) then
			color <= blue;
		elsif (column >= 276) and (column <= 300) and (row >= 160) and (row <= 320) then
			color <= blue;
		elsif (column >= 240) and (column <= 276) and (row >= 160) and (row <= 180)then
			color <= blue;
		elsif (column >= 240) and (column <= 276) and (row >= 200) and (row <= 220)then
			color <= blue;
		elsif (column >= 320) and (column <= 360) and (row >= 160) and (row <= 320)then
			color <= blue;	
		elsif (column >= 360) and (column <= 426) and (row >= 160) and (row <= 180)then
			color <= blue;
		elsif (column >= 360) and (column <= 426) and (row >= 200) and (row <= 220)then
			color <= blue;	
		else 
			color <= black;
		
		end if;	
	end process;	
	
	process(color)
	begin
		r <= "00000000";
		g <= "00000000";
		b <= "00000000";
		case color is
			when black =>
				r <= "00000000";
				g <= "00000000";
				b <= "00000000";
			when blue =>
				r <= "00000000";
				g <= "00000000";
				b <= "11111111";
			when green =>
				r <= "00000000";
				g <= "11111111";
				b <= "00000000";
			when red=>
				r <= "11111111";
				g <= "00000000";
				b <= "00000000";
			when yellow =>
				r <= "11111111";
				g <= "11111111";
				b <= "00000000";	
			end case;	
		end process;
		
end Behavioral;

--architecture red of pixel_gen is
--begin
--	r <= (others => '1') when blank = '0' else
--			(others => '0');
--	g <= (others => '0');
--	b <= (others => '0');
--end red;