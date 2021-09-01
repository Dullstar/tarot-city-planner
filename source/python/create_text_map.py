# Creates a text map for easy external text editing.
import sys

def main():
    if len(sys.argv) == 1:
        print("Outfile parameter required.")
        print("Usage: python create_text_map.py [outfilename] [optional: size x, default 100], [optional: size y, default 100]")
        exit()

    size_x = 100
    size_y = 100
    outfilename = sys.argv[1]
    if len(sys.argv) > 2:
        size_x = int(sys.argv[2])
    if len(sys.argv) > 3:
        size_y = int(sys.argv[3])

    with open(outfilename, "w") as file:
        for y in range(size_y):
            for x in range(size_x):
                file.write("0")
                file.write(" ")
            file.write("\n")

if __name__ == "__main__":
    main()
