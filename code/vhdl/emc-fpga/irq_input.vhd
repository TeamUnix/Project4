library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;
library work;
	use work.def_pkg.ALL;

entity irq_input is
	
	port	(
			--Input
			Clk					: in		std_logic;
			Reset					: in		std_logic;
			full					: in		std_logic;
			irq_i					: in		std_logic_vector (1 downto 0);
			add_1					: in		std_logic_vector (6 downto 0);
			add_2					: in		std_logic_vector (6 downto 0);
			--Output
			wr						: out		std_logic;
			w_data				: out		std_logic_vector (6 downto 0) := (others => '0')
			);
end irq_input;

architecture RTL of irq_input is

	type state_type is	(
								IDLE,
								IRQ1,
								IRQ2
								);
	signal state_reg : state_type;
	signal state_next : state_type;
	signal irq_1 : std_logic;
	signal irq_2 : std_logic;

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
	process(state_reg, irq_i, add_1, add_2, full)
	begin
		state_next	<= state_reg;
		wr				<= '0';
		case state_reg is
			when IDLE =>
				--Idle state
				wr			<= '0';
				if(irq_i(0) = '1') then
					state_next <= IRQ1;
				elsif(irq_i(1) = '1') then
					irq_1			<= '0';
					state_next	<= IRQ2;
				else
					irq_1 <= '0';
					irq_2 <= '0';
				end if;
			when IRQ1 =>
				--IRQ1 state
				w_data		<= add_1;
				state_next	<= IDLE;
				if(full = '0' and irq_1 = '0') then
					wr		<= '1';
					irq_1	<= '1';
				end if;
			when IRQ2 =>
				--IRQ2 state
				w_data		<= add_2;
				state_next	<= IDLE;
				if(full = '0' and irq_2 = '0') then
					wr		<= '1';
					irq_2	<= '1';
				end if;
		end case;
	end process;

end RTL;