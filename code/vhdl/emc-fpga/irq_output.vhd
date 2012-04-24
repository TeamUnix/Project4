----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:13:15 04/24/2012 
-- Design Name: 
-- Module Name:    irq_output - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity irq_output is
    Port ( r_data : in  STD_LOGIC_VECTOR (6 downto 0);
           read_i : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           data_o : out  STD_LOGIC_VECTOR (6 downto 0) := (others => '0');
           rd : out  STD_LOGIC);
end irq_output;

architecture RTL of irq_output is

	type state_type is	(
								IDLE,
								READ_O,
								RSET
								);
	signal state_reg : state_type;
	signal state_next : state_type;
	signal read_wb : std_logic;

begin

	-- state register
	process(Clk, Reset)
	begin
		if	(reset = '1') then
			state_reg <= IDLE;
		elsif (Clk'event and Clk='1') then
			state_reg <= state_next;
		end if;
	end process;

	-- next state/output logic
	process(state_reg, read_i, r_data, read_wb)
	begin
		state_next	<= state_reg;
		rd				<= '0';
		read_wb		<= read_wb;
		case state_reg is
			when IDLE =>
				--Idle state
				rd		<= '0';
				if	(read_i = '1') then
					if	(read_wb = '0') then
						state_next <= READ_O;
					else
						state_next <= IDLE;
					end if;
				else
					state_next	<= RSET;
				end if;
			when READ_O =>
				--READ_O state
				state_next	<= IDLE;
				data_o	<= r_data;
				read_wb	<= '1';
				rd			<= '1';
			when RSET =>
				--RSET state
				state_next	<= IDLE;
				read_wb <= '0';
		end case;
	end process;

end RTL;

