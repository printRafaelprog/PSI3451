library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity rand_num is
    GENERIC(
        WIDTH	   		: NATURAL  := 8
);

port(
        clk, reset     : IN  BIT; 
        rand_number  	   : OUT BIT_VECTOR(WIDTH-1 downto 0)  
     );			 
END  entity;

architecture arch_rand_num of rand_num is
    
    component d_reg is 
	
        generic (t_ff: time := 2 ns);
       
        port
        (
        clk  : in  BIT;
        load : in  BIT;			-- load may be fixed in '1' in most cases
        d    : in  BIT;
        q	 : out BIT
        );
    end component;
    
signal signal_seed : BIT_VECTOR(11 DOWNTO 0) := "111111111111"; -- seed do processo
signal q_sig : BIT_VECTOR(11 downto 0); -- sinal para as saidas do DFFs
signal d_sig : BIT_VECTOR(11 downto 0); -- sinal para as entradas do DFFs
signal xor_sig: BIT_VECTOR(7 downto 0); --- GUARDAR OS XORS 
signal clk_sig : BIT; -- clock



begin
    clk_sig <= clk;
    generate_rand_num: for i in 0 to 11 generate 
        gennerate_if_0: if i = 0 generate 
           d_sig(i) <= signal_seed(i) when (reset = '1') else -- logica reset = 1
                       q_sig(11);
           D_REG_0: d_reg port map (clk => clk_sig, load => '1', d =>d_sig(i), q => q_sig(i)); -- logica reset = 0
        end generate gennerate_if_0; 
        gennerate_if_XOR: if ((i = 1) OR (i = 2) OR (i = 4) OR (i = 5) OR (i = 7) OR (i = 8))  generate  -- posicoes com xor
          d_sig(i) <= signal_seed(i) when reset = '1' else
                       xor_sig(i-1) ;
          xor_sig(i-1) <= (q_sig(i-1) xor q_sig(11));
          D_REG_XOR: d_reg port map (clk => clk_sig, load => '1', d => d_sig(i), q => q_sig(i));
        end generate gennerate_if_XOR;
        generate_resto: if ((i /= 0) and (i /= 1) and (i /= 2) and (i /= 4) and (i /= 5) and (i /= 7) and (i /= 8))  generate  -- posicoes sem xor
        d_sig(i) <= signal_seed(i) when reset = '1' else
                    q_sig(i-1) ;
        D_REG_RESTO: d_reg port map (clk => clk_sig, load => '1', d =>d_sig(i), q => q_sig(i));
        end generate generate_resto;
    end generate generate_rand_num;



    rand_number <= "000000" & q_sig(1 downto 0); -- conexao LFSR com rand_num

end arch_rand_num;   