-- Zoran Salcic

library ieee;
use ieee.std_logic_1164.all;

use IEEE.numeric_std.all;

use work.recop_types.all;
use work.various_constants.all;

entity regfile is
	port (
		clk: in bit_1;
		init: in bit_1;
		-- control signal to allow data to write into Rz
		ld_r: in bit_1;
		-- Rz and Rx select signals
		sel_z: in integer range 0 to 15;
		sel_x: in integer range 0 to 15;
		-- register data outputs
		rx : out bit_16;
		rz: out bit_16;
		-- select signal for input data to be written into Rz
		rf_input_sel: in bit_4;
		-- input data
		ir_operand: in bit_16;
--		dm_out: in bit_16;
		aluout: in bit_16;
--		rz_max: in bit_16;
		sip_hold: in bit_16;
--		er_temp: in bit_1;
		-- R7 for writing to lower byte of dpcr
		r7 : out bit_16;
--		dprr_res : in bit_1;
--		dprr_res_reg : in bit_1;
--		dprr_wren : in bit_1;
		
		mem_data : in bit_16
				
		);
end regfile;

architecture beh of regfile is
	type reg_array is array (15 downto 0) of bit_16;
	signal regs: reg_array;
	signal data_input_z: bit_16;
	signal rz_recv_q : bit_1 := '0'; -- Declare rz_recv_q as a signal
begin
	r7 <=regs(7);

	-- mux selecting input data to be written to Rz
	input_select: process (rf_input_sel, ir_operand, aluout, sip_hold, sel_x, sel_z, clk)
    begin
		if rising_edge(clk) then
			  case rf_input_sel is
					when "0000" =>
						 data_input_z <= ir_operand; -- operand
					when "0001" =>
						 -- data_input_z <= X"000"&"000"&dprr_res_reg;
					when "0011" =>
						 data_input_z <= aluout; -- alu result
					when "0100" =>
						 --data_input_z <= rz_max; -- rz max
					when "0101" =>
						 data_input_z <= sip_hold;
					when "0110" =>
						 -- data_input_z <= X"000"&"000"&er_temp;
					when "0111" =>
						 -- data_input_z <= dm_out; 
					when "1000" =>
--						 data_input_z <= regs(sel_x); -- RZ <- m[Rx]
					when "1001" =>
						 data_input_z <= mem_data; -- load from memory
					when "1010" =>
						 data_input_z <= regs(sel_z); -- Rz <- Rz
					when others =>
						 data_input_z <= X"0000";
			  end case;
			  
		end if;
    end process input_select;
	
	process (clk, init)
	begin
		if init = '1' then
			-- reset regs
			regs<=((others => '0'),(others => '0'),(others => '0'),(others => '0'),(others => '0'),(others => '0'),(others => '0'),(others => '0'),(others => '0'),(others => '0'),(others => '0'),(others => '0'),(others => '0'),(others => '0'),(others => '0'),(others => '0'));
		elsif rising_edge(clk) then
				-- write data into Rz if ld signal is asserted
				if ld_r = '1' then
					regs(sel_z) <= data_input_z; -- load r enabled
				--elsif dprr_wren = '1' then
					-- regs(0) <= X"000"&"000"&dprr_res; -- fill with 0 & dprr_res
				else
					regs(sel_z) <= regs(sel_z);
				end if;
		end if;
	end process;
	

	rx <= regs(sel_x); -- send x to rx
	rz <= regs(sel_z); -- send z to rz
	
end beh;
