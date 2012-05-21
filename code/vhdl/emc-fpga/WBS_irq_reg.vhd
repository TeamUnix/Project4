--------------------------------------------------------------------------------
--! @file
--! @ingroup	RTL
--! @brief		WB output port
--! @details    General Purpose Wishbone output port. Width identical
--! 			to Wishbone datawidth, with granularity similar to width
--! @author		Morten Opprud Jakobsen \n
--!				AU-HIH \n                                            
--!				morten@hih.au.dk \n 
--! @version  	1.0
----------------------------------------------------------------------------------------------------------------------------------------------------------------
library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;
library work;
	use work.def_pkg.all;

entity WBS_irq_reg is
	port	(
			--! Wishbone Slave interface
			--Input
			clk_i					: in		std_logic;									--! Clock input from SYSCON
			rst_i					: in		std_logic;									--! Reset for Wishbone interface
			cyc_i					: in		std_logic;									--! cycle input, asserted when cycle is in progress
			stb_i					: in		std_logic;									--! Strobe input, similar to Chip Select
			we_i					: in		std_logic;									--! Write Enable: High=WR, Low=RD
--			dat_i					: in		wb_dat_typ;									--! data from host
			adr_i					: in		wb_lad_typ;									--! Low address input
			--Ouput
			ack_o					: out		std_logic;									--! Slave acknowledge output, asserted after sucessful cycle
			err_o					: out		std_logic;									--! Error output, abnormal cycle termination
			rty_o					: out		std_logic;									--! Retry output, slave not ready
			dat_o					: out		wb_dat_typ	:= (others => '0');									--! data to host
			--! Input port
			irq_i					: in		std_logic; --_vector (Num_irqs-1	downto 0);
			add_1					: in		std_logic_vector (AddrRange-1	downto 0);
--			add_2					: in		std_logic_vector (AddrRange-1	downto 0);
			--! Output port
			irq_o					:out		std_logic
			);
end WBS_irq_reg;

architecture RTL of WBS_irq_reg is

	--Types
--	type state_type is	(
--								IDLE,
--								DELAY
--								);

	--Signals
	signal	full		:	std_logic;
	signal	wr			:	std_logic;
	signal	rd			:	std_logic;
	signal	read_i	:	std_logic;
	signal	read_1	:	std_logic;
	signal	w_data	:	std_logic_vector (AddrRange-1	downto 0);
	signal	r_data	:	std_logic_vector (AddrRange-1	downto 0);
	signal	data_o	:	std_logic_vector (Datawidth-1 downto 0);
--	signal	q_reg		:	unsigned(1 downto 0);
--	signal	q_next	:	unsigned(1 downto 0);
--	signal state_reg	: state_type;
--	signal state_next	: state_type;

begin
-- =================================================
-- WishBone logic
-- =================================================
	--  Concurrent assignments
	--	Wishbone cycle acknowledge
	err_o <= '0';	--error signal
	rty_o <= '0';	--retry signal
	ack_o <= stb_i and cyc_i;  --! asynhronous cycle termination is OK here.
	read_i <= (cyc_i and stb_i and not we_i) or read_1;
	--Wishbone read
	data_output	:	process(clk_i)
	begin
		if(clk_i'event and clk_i = '1') then
			if(rst_i = '1') then
				read_1	<= '0';
				dat_o <= (others => '0');
--				state_reg <= IDLE;
--				q_reg <= (others => '0');
			else
--				q_reg <= q_next;
--				state_reg <= state_next;
				if((cyc_i and stb_i and not we_i) = '1') then
					case adr_i is
						when WBS_REG1 =>
							dat_o		<= data_o;
--							state_reg <= IDLE;
							read_1	<= '1';
						when others =>
					end case;
				else
--				state_reg <= state_next;
				--dat_o		<= (others => '0');
				read_1	<= '0';
				end if;
			end if;
		end if;			
	end process;
-- =================================================
-- Read input
-- =================================================
--read_input: process(state_reg)
--	begin
--		state_next		<= state_reg;
--		case state_reg is
--		-- Idle state -----------------------------------------------------
--			when IDLE =>
--				if((cyc_i and stb_i and not we_i) = '1') then
--					state_next <= DELAY;
--					q_next <= (others => '1');
--					read_i <= '1';
--				else
--					state_next		<= IDLE;
--					read_i <= '0';
--				end if;
--		-- Delay state ---------------------------------------------------
--			when DELAY =>
--				q_next <= q_reg-1;
--					if	(q_next = 0) then
--						state_next <= IDLE;
--					else
--						state_next <= DELAY;
--					end if;
--		end case;
--	end process;
-- =================================================
-- IRQ input
-- =================================================
	irq_input	:	entity	work.irq_input(RTL)
	Port map	(
				--Input
				Clk			=>		clk_i,
				Reset			=>		rst_i,
				full			=>		full,
				irq_i			=>		irq_i,
				add_1			=>		add_1,
--				add_2			=>		add_2,
				--Output
				wr				=>		wr,
				w_data		=>		w_data
				);
-- =================================================
-- IRQ FIFO
-- =================================================
	irq_fifo		:	entity	work.irq_fifo(RTL)
--	Generic map	(
--					W		=> 2
--					)
	Port map	(
				--Input
				Clk			=>		clk_i,
				Reset			=>		rst_i,
				rd				=>		rd,
				wr				=>		wr,
				w_data		=>		w_data,
				--Output
				empty			=>		irq_o,
				full			=>		full,
				r_data		=>		r_data
				);
-- =================================================
-- IRQ Output
-- =================================================
	irq_output		:	entity	work.irq_output(RTL)
	Port map	(
				--Input
				Clk			=>		clk_i,
				Reset			=>		rst_i,
				read_i		=>		read_i,
				r_data		=>		r_data,
				--Output
				rd				=>		rd,
				data_o		=>		data_o
				);
end RTL;