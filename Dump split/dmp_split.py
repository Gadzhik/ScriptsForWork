import sys

if len(sys.argv) != 3:
    print("Использование: python script.py <входной_файл> <выходной_файл>")
    sys.exit(1)

input_file = sys.argv[1]
output_file = sys.argv[2]

with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
    # Skip header
    next(infile)

    for line in infile:
        call_site = line.strip().split(':', 2)[2].strip()
        outfile.write(call_site + '\n')