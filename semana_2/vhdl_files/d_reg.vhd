library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;


entity d_reg is 
	
	generic (t_ff: time := 2 ns);
   
	port
	(
	clk  : in  bit;
	load : in  BIT;			-- load may be fixed in '1' in most cases
	d    : in  BIT;
	q	 : out BIT
	);
end d_reg;

architecture arch_dreg of d_reg is

signal q_s	: BIT;

begin

   
-- Register with active-high clock
	process(clk)
	begin
		if clk'EVENT AND clk = '1' then
			if (load = '1') then
				q_s <= d;
			end if;
		end if;
	end process;
	q <= q_s after t_ff;
   
end arch_dreg;