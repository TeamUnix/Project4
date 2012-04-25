library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;
library work;
	use work.def_pkg.all;

entity irq_fifo is
	generic	(
			W		:	natural	:=	4 -- number of address bits
			);
	port	(
			--Input
			Clk			: in		std_logic;
			Reset		: in		std_logic;
			rd			: in		std_logic;
			wr			: in		std_logic;
			w_data		: in		std_logic_vector (AddrRange-1 downto 0);
			--Output
			empty		: out		std_logic;
			full		: out		std_logic;
			r_data		: out		std_logic_vector (AddrRange-1 downto 0)
			);
end irq_fifo;

architecture RTL of irq_fifo is
	--Types
	type		reg_file_type is array (2**W-1 downto 0) of std_logic_vector(AddrRange-1 downto 0);
	--Signals
	signal		array_reg		: reg_file_type;
	signal		w_ptr_reg		: std_logic_vector(W-1 downto 0);
	signal		w_ptr_next		: std_logic_vector(W-1 downto 0);
	signal		w_ptr_succ		: std_logic_vector(W-1 downto 0);
	signal		r_ptr_reg		: std_logic_vector(W-1 downto 0);
	signal		r_ptr_next		: std_logic_vector(W-1 downto 0);
	signal		r_ptr_succ		: std_logic_vector(W-1 downto 0);
	signal		full_reg		: std_logic;
	signal		empty_reg		: std_logic;
	signal		full_next		: std_logic;
	signal		empty_next		: std_logic;
	signal		wr_op			: std_logic_vector(1 downto 0);
	signal		wr_en			: std_logic;
begin
   --=================================================
   -- register file
   --=================================================
	fifo : process(Clk,Reset)
		begin
			if	(Reset='1') then
				array_reg	<= (others=>(others=>'0'));
			elsif	(Clk'event and Clk='1') then
					if	wr_en='1' then
						array_reg(to_integer(unsigned(w_ptr_reg)))	<= w_data;
				end if;
			end if;
	end process;
	-- read port
	r_data	<= array_reg(to_integer(unsigned(r_ptr_reg)));
	-- write enabled only when FIFO is not full
	wr_en	<= wr and (not full_reg);

   --=================================================
   -- fifo control logic
   --=================================================
   -- register for read and write pointers
	fifo_control : process(Clk,Reset)
		begin
			if		(Reset='1') then
					w_ptr_reg	<= (others=>'0');
					r_ptr_reg	<= (others=>'0');
					full_reg	<= '0';
					empty_reg	<= '1';
			elsif	(Clk'event and Clk='1') then
					w_ptr_reg	<= w_ptr_next;
					r_ptr_reg	<= r_ptr_next;
					full_reg	<= full_next;
					empty_reg	<= empty_next;
			end if;
	end process;

   -- successive pointer values
   w_ptr_succ	<= std_logic_vector(unsigned(w_ptr_reg)+1);
   r_ptr_succ	<= std_logic_vector(unsigned(r_ptr_reg)+1);

   -- next-state logic for read and write pointers
   wr_op	<= wr & rd;

	process(w_ptr_reg, w_ptr_succ, r_ptr_reg, r_ptr_succ, wr_op, empty_reg, full_reg)
		begin
			w_ptr_next	<= w_ptr_reg;
			r_ptr_next	<= r_ptr_reg;
			full_next	<= full_reg;
			empty_next	<= empty_reg;
			case wr_op is
				when "00" => -- no op
				when "01" => -- read
					if	(empty_reg /= '1') then -- not empty
						r_ptr_next	<= r_ptr_succ;
						full_next	<= '0';
						if	(r_ptr_succ=w_ptr_reg) then
							empty_next	<='1';
						end if;
					end if;
				when "10" => -- write
					if	(full_reg /= '1') then -- not full
						w_ptr_next	<= w_ptr_succ;
						empty_next	<= '0';
						if	(w_ptr_succ=r_ptr_reg) then
							full_next	<='1';
						end if;
					end if;
				when others => -- write/read;
					w_ptr_next	<= w_ptr_succ;
					r_ptr_next	<= r_ptr_succ;
			end case;
	end process;

	-- output
	full	<= full_reg;
	empty	<= empty_reg;
end RTL;