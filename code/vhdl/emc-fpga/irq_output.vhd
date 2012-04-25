library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
	use work.def_pkg.all;

entity irq_output is
	Port	(
			--Input
			Clk			: in		STD_LOGIC;
			Reset			: in		STD_LOGIC;
			read_i		: in		STD_LOGIC;
			r_data		: in		STD_LOGIC_VECTOR (AddrRange-1 downto 0);
			--Output
			rd				: out		STD_LOGIC;
			data_o		: out		STD_LOGIC_VECTOR (Datawidth-1 downto 0) := (others => '0')
			);
end irq_output;

architecture RTL of irq_output is

	--Types
	type state_type is	(
								IDLE,
								READ_O,
								RSET
								);
	--Signals
	signal state_reg		: state_type;
	signal state_next		: state_type;
	signal read_wb			: std_logic;

begin

	data_o(Datawidth-1 downto AddrRange)	<= (others => '0');
	data_o(AddrRange-1 downto 0)				<= r_data;

	-- state register
	process(Clk, Reset)
	begin
		if	(reset = '1') then
			state_reg		<= IDLE;
		elsif (Clk'event and Clk='1') then
			state_reg		<= state_next;
		end if;
	end process;

	-- next state/output logic
	process(state_reg, read_i, r_data, read_wb)
	begin
		state_next		<= state_reg;
		rd					<= '0';
		read_wb			<= read_wb;
		case state_reg is
		-- Idle state -----------------------------------------------------
			when IDLE =>
				rd		<= '0';
				if	(read_i = '1') then
					if	(read_wb = '0') then
						state_next		<= READ_O;
					else
						state_next		<= IDLE;
					end if;
				else
					state_next		<= RSET;
				end if;
		-- READ_O state ---------------------------------------------------
			when READ_O =>
				state_next										<= IDLE;
				read_wb											<= '1';
				rd													<= '1';
		-- RSET state -----------------------------------------------------
			when RSET =>
				state_next		<= IDLE;
				read_wb			<= '0';
		end case;
	end process;

end RTL;

