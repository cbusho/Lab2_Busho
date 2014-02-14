----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:07:25 02/04/2014 
-- Design Name: 
-- Module Name:    atlys_lab_video - Behavioral 
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
library UNISIM;
use UNISIM.VComponents.all;

entity atlys_lab_video is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  SW6: in STD_LOGIC;
			  SW7: in STD_LOGIC;
			  BTNU: in STD_LOGIC;
			  BTND: in STD_LOGIC;	
           tmds : out  STD_LOGIC_VECTOR (3 downto 0);
           tmdsb : out  STD_LOGIC_VECTOR (3 downto 0));
end atlys_lab_video;

architecture Behavioral of atlys_lab_video is

COMPONENT vga_sync
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;          
		h_sync : OUT std_logic;
		v_sync : OUT std_logic;
		v_completed : OUT std_logic;
		blank : OUT std_logic;
		row : OUT unsigned(10 downto 0);
		column : OUT unsigned(10 downto 0)
		);
	END COMPONENT;
	
COMPONENT pong_pixel_gen
	PORT(
			  row : in  unsigned (10 downto 0);
           column : in  unsigned (10 downto 0);
           blank : in  STD_LOGIC;
			  ball_x, ball_y, paddle_y : in unsigned (10 downto 0);
           r,g,b : out  STD_LOGIC_VECTOR (7 downto 0)
		);
	END COMPONENT;	
	
COMPONENT pong_control
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		Switch : IN std_logic;
		up : IN std_logic;
		down : IN std_logic;
		v_completed : IN std_logic;          
		ball_x : OUT unsigned(10 downto 0);
		ball_y : OUT unsigned(10 downto 0);
		paddle_y : OUT unsigned(10 downto 0)
		);
	END COMPONENT;	

signal top_blank: std_logic;
signal top_row, top_column, ball_x_s, ball_y_s, paddle_y_s: unsigned(10 downto 0);
signal red, green, blue: std_logic_vector(7 downto 0);
signal v_sync_sig, h_sync_sig, pixel_clk, serialize_clk, serialize_clk_n,
		 red_s, green_s, blue_s, clock_s, v_comp: std_logic;

begin

    -- Clock divider - creates pixel clock from 100MHz clock
    inst_DCM_pixel: DCM
    generic map(
                   CLKFX_MULTIPLY => 2,
                   CLKFX_DIVIDE   => 8,
                   CLK_FEEDBACK   => "1X"
               )
    port map(
                clkin => clk,
                rst   => reset,
                clkfx => pixel_clk
            );

    -- Clock divider - creates HDMI serial output clock
    inst_DCM_serialize: DCM
    generic map(
                   CLKFX_MULTIPLY => 10, -- 5x speed of pixel clock
                   CLKFX_DIVIDE   => 8,
                   CLK_FEEDBACK   => "1X"
               )
    port map(
                clkin => clk,
                rst   => reset,
                clkfx => serialize_clk,
                clkfx180 => serialize_clk_n
            );

    -- TODO: VGA component instantiation
	 Inst_vga_sync: vga_sync PORT MAP(
		clk => pixel_clk,
		reset => reset,
		h_sync => h_sync_sig,
		v_sync => v_sync_sig,
		v_completed => v_comp,
		blank => top_blank,
		row => top_row,
		column => top_column
	);
	 
    -- TODO: Pixel generator component instantiation
	 Inst_pixel_gen: pong_pixel_gen PORT MAP(
		row => top_row,
		column => top_column,
		blank => top_blank,
		ball_x => ball_x_s,
		ball_y => ball_y_s,
		paddle_y => paddle_y_s,
		r => red,
		g => green,
		b => blue
	);
	
	Inst_pong_control: pong_control PORT MAP(
		clk => pixel_clk,
		reset => reset,
		Switch => SW7,
		up => BTNU,
		down => BTND,
		v_completed => v_comp,
		ball_x => ball_x_s,
		ball_y => ball_y_s,
		paddle_y => paddle_y_s
	);

    -- Convert VGA signals to HDMI (actually, DVID ... but close enough)
    inst_dvid: entity work.dvid
    port map(
                clk       => serialize_clk,
                clk_n     => serialize_clk_n, 
                clk_pixel => pixel_clk,
                red_p     => red,
                green_p   => green,
                blue_p    => blue,
                blank     => top_blank,
                hsync     => h_sync_sig,
                vsync     => v_sync_sig,
                -- outputs to TMDS drivers
                red_s     => red_s,
                green_s   => green_s,
                blue_s    => blue_s,
                clock_s   => clock_s
            );

    -- Output the HDMI data on differential signalling pins
    OBUFDS_blue  : OBUFDS port map
        ( O  => TMDS(0), OB => TMDSB(0), I  => blue_s  );
    OBUFDS_red   : OBUFDS port map
        ( O  => TMDS(1), OB => TMDSB(1), I  => green_s );
    OBUFDS_green : OBUFDS port map
        ( O  => TMDS(2), OB => TMDSB(2), I  => red_s   );
    OBUFDS_clock : OBUFDS port map
        ( O  => TMDS(3), OB => TMDSB(3), I  => clock_s );
		  
end Behavioral;