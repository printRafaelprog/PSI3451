
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use work.wisdom_package.all;    -- adotar os mesmos tipos declarados no projeto do wisdom circuit   

ENTITY fsm_disc IS
	PORT ( 	
		rst					: IN STD_LOGIC;
		clk 				: IN STD_LOGIC;	
		fsm_sg_start 		: IN STD_LOGIC;
		cnt_disc_rdy 		: IN STD_LOGIC;
		guru_right_behind 	: IN STD_LOGIC;
		end_of_disc			: IN STD_LOGIC;
		duo_formed			: IN STD_LOGIC;
		flags_2_dp			: OUT disc_ctrl_2_dp_flags;
		flags_2_mem			: OUT disc_2_mem_flags;
	);
END fsm_disc;

ARCHITECTURE arch OF fsm_disc IS
	TYPE state_type IS (START_WALKING, RAND, WRITE_RAND, WAIT_COUNT_DISCIPLE, INCR, CHECK_LAST, CHECK_SAME_ADDR, WRITE_DISCIPLE, CLEAR_PREV, LAST_BLANK, LAST_GURU_BEHIND);  
	SIGNAL state, next_state : state_type;
	
BEGIN
	------------------------Lógica Sequencial-----------------------
	SEQ: PROCESS (rst, clk)
	BEGIN
		IF (rst='1') THEN
			state <= START_WALKING;
		ELSIF Rising_Edge(clk) THEN
			state <= next_state;
		END IF;
	END PROCESS SEQ;

	-----------------------Lógica Combinacional do estado siguinte--
	COMB: PROCESS (entrada0,..,entradaN, state)  // completar com sinais de entrada + state
	BEGIN
		CASE state IS
			WHEN START_WALKING =>
				IF (fsm_sg_start = '1') THEN
					next_state <= RAND;
				ELSE 
					next_state <= START_WALKING;
				END IF;
			WHEN RAND =>
				next_state <= WRITE_RAND;
			WHEN WRITE_RAND =>
				next_state <= WAIT_COUNT_DISCIPLE;
			WHEN WAIT_COUNT_DISCIPLE => 
				IF (cnt_disc_rdy = '1') THEN
					next_state <= INCR;
				ELSE
					next_state <= WAIT_COUNT_DISCIPLE;
				END IF;
			WHEN INCR =>
				next_state <= CHECK_LAST;
			WHEN CHECK_LAST => 
				IF (go_guru = '0') THEN
					next_state <= CHECK_LAST;
				ELSIF (end_of_disc = '1' AND guru_right_behind = '0') THEN
					next_state <= LAST_BLANK;
				ELSIF (end_of_disc = '1' AND guru_right_behind = '1') THEN
					next_state <= LAST_GURU_BEHIND;
				ELSE
					next_state <= CHECK_SAME_ADDR;
				END IF;
			WHEN CHECK_SAME =>
				IF (duo_formed = '0') THEN
					next_state <= WRITE_DISCIPLE;
				ELSE
					next_state <= CLEAR_PREV;
				END IF;
			WHEN WRITE_DISCIPLE => 
				next_state <= CLEAR_PREV;
			WHEN CLEAR_PREV =>
				IF (duo_formed = '1') THEN
					next_state <= START_WALKING;
				ELSE
					next_state <= WAIT_COUNT_DISCIPLE;
				END IF;
			WHEN LAST_BLANK =>
				next_state <= START_WALKING;
			WHEN LAST_GURU_BEHIND => 
				next_state <= START_WALKING;
		END CASE;
	END PROCESS COMB;

	-----------------------Lógica Combinacional saidas---------------------
	SAI: PROCESS (state)
	BEGIN
		CASE state IS
			WHEN START_WALKING =>
				flags_2_dp.ng_cte_decr		<= '0';
				flags_2_dp.rb_DISC_en 		<= '0';
				flags_2_dp.rb_PRE_DISC_en 	<= '0';
				flags_2_dp.rb_out_sel 		<= DISC_OUT;
				flags_2_dp.cg_sel 			<= BLANK;

				flags_2_mem.mem_wr_en 		<= '0';
				flags_2_mem.cg_sel 			<= BLANK;
			
			WHEN RAND =>
				flags_2_dp.ng_cte_decr		<= '0';
				flags_2_dp.rb_DISC_en 		<= '1';
				flags_2_dp.rb_PRE_DISC_en 	<= '1';
				flags_2_dp.rb_out_sel 		<= DISC_OUT;
				flags_2_dp.cg_sel 			<= DISC;

				flags_2_mem.mem_wr_en 		<= '0';
				flags_2_mem.cg_sel 			<= DISC;

			WHEN WRITE_RAND => 
				flags_2_dp.ng_cte_decr		<= '0';
				flags_2_dp.rb_DISC_en 		<= '0';
				flags_2_dp.rb_PRE_DISC_en 	<= '0';
				flags_2_dp.rb_out_sel 		<= DISC_OUT;
				flags_2_dp.cg_sel 			<= DISC;

				flags_2_mem.mem_wr_en 		<= '1';
				flags_2_mem.cg_sel 			<= DISC;

			WHEN WAIT_COUNT_DISCIPLE =>
				flags_2_dp.ng_cte_decr		<= '0';
				flags_2_dp.rb_DISC_en 		<= '0';
				flags_2_dp.rb_PRE_DISC_en 	<= '0';
				flags_2_dp.rb_out_sel 		<= DISC_OUT;
				flags_2_dp.cg_sel 			<= DISC;

				flags_2_mem.mem_wr_en 		<= '0';
				flags_2_mem.cg_sel 			<= DISC;

			WHEN INCR =>
				flags_2_dp.ng_cte_decr		<= '1';
				flags_2_dp.rb_DISC_en 		<= '1';
				flags_2_dp.rb_PRE_DISC_en 	<= '1';
				flags_2_dp.rb_out_sel 		<= DISC_OUT;
				flags_2_dp.cg_sel 			<= DISC;

				flags_2_mem.mem_wr_en 		<= '0';
				flags_2_mem.cg_sel 			<= DISC;

			WHEN CHECK_LAST =>
				flags_2_dp.ng_cte_decr		<= '1';
				flags_2_dp.rb_DISC_en 		<= '0';
				flags_2_dp.rb_PRE_DISC_en 	<= '0';
				flags_2_dp.rb_out_sel 		<= DISC_OUT;
				flags_2_dp.cg_sel 			<= DISC;

				flags_2_mem.mem_wr_en 		<= '0';
				flags_2_mem.cg_sel 			<= DISC;

			WHEN CHECK_SAME_ADDR =>
				flags_2_dp.ng_cte_decr		<= '1';
				flags_2_dp.rb_DISC_en 		<= '0';
				flags_2_dp.rb_PRE_DISC_en 	<= '0';
				flags_2_dp.rb_out_sel 		<= DISC_OUT;
				flags_2_dp.cg_sel 			<= DISC;

				flags_2_mem.mem_wr_en 		<= '0';
				flags_2_mem.cg_sel 			<= DISC;

			WHEN WRITE_DISCIPLE =>
				flags_2_dp.ng_cte_decr		<= '1';
				flags_2_dp.rb_DISC_en 		<= '0';
				flags_2_dp.rb_PRE_DISC_en 	<= '0';
				flags_2_dp.rb_out_sel 		<= DISC_OUT;
				flags_2_dp.cg_sel 			<= DISC;

				flags_2_mem.mem_wr_en 		<= '1';
				flags_2_mem.cg_sel 			<= DISC;

			WHEN CLEAR_PREV =>
				flags_2_dp.ng_cte_decr		<= '1';
				flags_2_dp.rb_DISC_en 		<= '0';
				flags_2_dp.rb_PRE_DISC_en 	<= '0';
				flags_2_dp.rb_out_sel 		<= DISC_PREV_OUT;
				flags_2_dp.cg_sel 			<= BLANK;

				flags_2_mem.mem_wr_en 		<= '0';
				flags_2_mem.cg_sel 			<= BLANK;

			WHEN LAST_BLANK =>
				flags_2_dp.ng_cte_decr		<= '1';
				flags_2_dp.rb_DISC_en 		<= '0';
				flags_2_dp.rb_PRE_DISC_en 	<= '0';
				flags_2_dp.rb_out_sel 		<= DISC_PREV_OUT;
				flags_2_dp.cg_sel 			<= BLANK;

				flags_2_mem.mem_wr_en 		<= '1';
				flags_2_mem.cg_sel 			<= BLANK;

			WHEN LAST_GURU_BEHIND =>
				flags_2_dp.ng_cte_decr		<= '1';
				flags_2_dp.rb_DISC_en 		<= '0';
				flags_2_dp.rb_PRE_DISC_en 	<= '0';
				flags_2_dp.rb_out_sel 		<= DISC_PREV_OUT;
				flags_2_dp.cg_sel 			<= BLANK;

				flags_2_mem.mem_wr_en 		<= '0';
				flags_2_mem.cg_sel 			<= BLANK;

			WHEN OTHERS => null
		END CASE;
	END PROCESS SAI;

END arch;