library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;
library work;
	use work.def_pkg.ALL;

entity irq_input is
	
	port	(
			--Input
			clk						: in		std_logic;
			reset					: in		std_logic;
			fifo_full				: in		std_logic;
			irq_i					: in		std_logic_vector (Num_irqs-1 downto 0);
			add_i					: in		wb_irqs_dat_typ;
			--Output
			wr_o					: out		std_logic;
			w_data					: out		std_logic_vector (AddrRange-1 downto 0)
			);
end irq_input;

architecture RTL of irq_input is



begin

	process(clk, reset)
		begin
			if	(reset = '1') then
				w_data	<= (others=>'0');
				wr_o	<= '0';
			elsif	(clk'event and clk='1') then
				if	(fifo_full = '0') then
					if	(irq_i(0) = '1') then
						w_data	<= add_i(0);
						wr_o	<= '1';
					elsif	(irq_i(1) = '1') then
						w_data	<= add_i(1);
						wr_o	<= '1';
					end if;
				end if;
			end if;
	end process;

end RTL;