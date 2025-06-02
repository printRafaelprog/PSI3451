library IEEE;
use IEEE.std_logic_1164.all;
use work.wisdom_package.all;

entity row_ovf is 
	port(
		clk			   	: in  STD_LOGIC;											--from system
		res				: in  STD_LOGIC;										   	--from system
		disc_addr  : in  STD_LOGIC_VECTOR(7 downto 0);
		ctrl_flags		: out disc_dp_2_ctrl_flags							     	--to control unit
	);
end row_ovf;

architecture arch of row_ovf is
--***********************************
--*	INTERNAL SIGNAL DECLARATIONS	*
--***********************************
signal disc_addr_s		  : STD_LOGIC_VECTOR(7 downto 0);
signal ctrl_flags_s       : disc_dp_2_ctrl_flags;

begin
	--*******************************
	--*	SIGNAL ASSIGNMENTS			*
	--*******************************
	disc_addr_s <= disc_addr;

	ctrl_flags_s.end_of_guru <= '1' when disc_addr_s(7)='1' else '0';  -- Valor negativo
   	ctrl_flags <= ctrl_flags_s;
end arch;
