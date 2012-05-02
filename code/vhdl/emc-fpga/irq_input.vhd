library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;
library work;
	use work.def_pkg.ALL;

entity irq_input is
	port	(
			--Input
			Clk				: in		std_logic;
			Reset			: in		std_logic;
			full			: in		std_logic;
			irq_i			: in		std_logic; --_vector (Num_irqs-1	downto 0);
			add_1			: in		std_logic_vector (AddrRange-1	downto 0);
--			add_2			: in		std_logic_vector (AddrRange-1	downto 0);
			--Output
			wr				: out		std_logic	:= '0';
			w_data			: out		std_logic_vector (AddrRange-1	downto 0) := (others => '0')
			);
end irq_input;

architecture RTL of irq_input is

	--Types
	type state_type is	(
								IDLE,
								IRQ1,
								IRQ1_W
--								IRQ2,
--								IRQ2_W
								);
	--Signals
	signal state_reg		: state_type;
	signal state_next		: state_type;
	signal irq_1			: std_logic		:=	'0';
--	signal irq_2			: std_logic		:=	'0';

begin

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
	process(state_reg, irq_i, add_1, full, irq_1)
	begin
		state_next		<= state_reg;
		--wr					<= '0';
		case state_reg is
		-- Idle state -------------------------------------------
			when IDLE =>
				wr		<= '0';
				if(irq_i = '1') then
					state_next		<= IRQ1;
--				elsif(irq_i(1) = '1') then
--					irq_1				<= '0';
--					state_next		<= IRQ2;
				else
					irq_1		<= '0';
--					irq_2		<= '0';
				end if;
		-- IRQ1 state -------------------------------------------
			when IRQ1 =>
				w_data			<= add_1;
				state_next		<= IRQ1_W;
			when IRQ1_W =>
				state_next		<= IDLE;
				if(((not full) and (not irq_1)) = '1') then
					wr			<= '1';
					irq_1		<= '1';
				end if;
		-- IRQ2 state -------------------------------------------
-- 			when IRQ2 =>
-- 				w_data			<= add_2;
-- 				state_next		<= IRQ2_W;
-- 			when IRQ2_W =>
-- 				state_next		<= IDLE;
-- 				if((not full and not irq_2) = '1') then
-- 					wr			<= '1';
-- 					irq_2		<= '1';
-- 				end if;
		end case;
	end process;

end RTL;
