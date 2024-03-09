import csv
from itertools import product

def read_csv_data(file_path):
    with open(file_path, newline='') as csvfile:
        data_reader = csv.reader(csvfile)
        data = [row for row in data_reader]
    return data

def expand_x_combinations(values):
    replacements = [['0', '1'] if v.upper() == 'X' else [v] for v in values]
    return [''.join(product) for product in product(*replacements)]

def generate_verilog_code(data):
    verilog_code = "module control_store(\n"
    verilog_code += "    input [11:0] address,\n"
    verilog_code += "    output [18:0] control_signals\n);\n\n"
    verilog_code += "reg [18:0] rom[0:{}];\n\n".format(8000)
    verilog_code += "assign control_signals = rom[address];\n"
    verilog_code += "initial begin\n"

    for row in data[1:]:  
        instruction = row[0]
        opcode_binary = row[1]
        func3 = row[2]
        IR30 = row[3]
        IR25 = row[4]
        addr = opcode_binary + func3 + IR30 + IR25
        control_signals = row[5:]
        combinations = expand_x_combinations(control_signals)
        for comb in combinations:
            binary_representation = ''.join(comb)
            if instruction:  
                verilog_code += "    // {}\n".format(instruction)
            verilog_code += "    rom[12'b{}] = {}'b{};\n".format(addr, len(binary_representation), binary_representation)

    verilog_code += "end\nendmodule\n"
    return verilog_code

file_path = 'cst.csv'
data = read_csv_data(file_path)
verilog_code = generate_verilog_code(data)

output_file_path = 'control_store_verilog.v'
with open(output_file_path, 'w') as output_file:
    output_file.write(verilog_code)

print(f"Verilog code has been written to {output_file_path}.")
