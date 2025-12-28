
# Entity: BFP16_add 
- **File**: BFP16_add.sv

## Diagram
![Diagram](BFP16_add.svg "Diagram")
## Generics

| Generic name | Type | Value | Description |
| ------------ | ---- | ----- | ----------- |
| SIZE_DATA    |      | 32    |             |

## Ports

| Port name | Direction | Type            | Description |
| --------- | --------- | --------------- | ----------- |
| i_clk     | input     |                 |             |
| i_rst_n   | input     |                 |             |
| i_valid   | input     |                 |             |
| i_data_a  | input     | [SIZE_DATA-1:0] |             |
| i_data_b  | input     | [SIZE_DATA-1:0] |             |
| o_bfu_add | output    | [SIZE_DATA-1:0] |             |
| o_valid   | output    |                 |             |

## Signals

| Name                 | Type                  | Description |
| -------------------- | --------------------- | ----------- |
| w_data_a             | logic [SIZE_DATA-1:0] |             |
| w_data_b             | logic [SIZE_DATA-1:0] |             |
| w_sign_a             | logic                 |             |
| w_sign_b             | logic                 |             |
| w_exp_a              | logic [7:0]           |             |
| w_exp_b              | logic [7:0]           |             |
| w_man_a              | logic [7:0]           |             |
| w_man_b              | logic [7:0]           |             |
| is_b_zero            | logic                 |             |
| w_comp_exp_less      | logic                 |             |
| w_swap_exp_max       | logic [7:0]           |             |
| w_swap_exp_min       | logic [7:0]           |             |
| w_sub_exp_result     | logic [7:0]           |             |
| w_swap_man0_max      | logic [7:0]           |             |
| w_swap_man0_min      | logic [7:0]           |             |
| w_comp_man_less      | logic                 |             |
| w_swap_man1_max      | logic [7:0]           |             |
| w_swap_man1_min      | logic [7:0]           |             |
| w_shf_right_man1_min | logic [15:0]          |             |
| w_shf_right_over     | logic                 |             |
| w_alu_man_result     | logic [7:0]           |             |
| w_alu_man_overflow   | logic                 |             |
| w_lopd_one_pos       | logic [2:0]           |             |
| w_lopd_zero_flag     | logic                 |             |
| w_nor_man            | logic [7:0]           |             |
| w_exp_adjust         | logic [7:0]           |             |
| w_sel_exp            | logic                 |             |
| w_sel_man            | logic [1:0]           |             |
| w_sign_result        | logic                 |             |
| w_exp_result         | logic [7:0]           |             |
| w_man_result         | logic [7:0]           |             |
| w_man_b_zero         | logic [22:0]          |             |

## Processes
- proc_save_data_in: ( @( posedge i_clk or negedge i_rst_n ) )
  - **Type:** always_ff
- proc_save_valid_data: ( @( posedge i_clk or negedge i_rst_n ) )
  - **Type:** always_ff
- proc_save_out_data: ( @( posedge i_clk or negedge i_rst_n ) )
  - **Type:** always_ff

## Instantiations

- COMP_EXP_UNIT: COMP_8bit
- SWAP_EXP_UNIT: SWAP_unit
- SUB_EXP_UNIT: CLA_8bit
- SWAP_MAN0_UNIT: SWAP_unit
- SHF_RIGHT_MAN_UNIT: SHF_right
- COMP_MAN_UNIT: COMP_8bit
- SWAP_MAN1_UNIT: SWAP_unit
- MAN_ALU_UNIT: MAN_ALU
- LOPD_UNIT: LOPD_8bit
- NOR_UNIT: NOR_unit
- EXP_ADJUSTION_UNIT: EXP_adjust
- SIGN_UNIT: SIGN_unit
- PSC_UNIT: PSC_unit
