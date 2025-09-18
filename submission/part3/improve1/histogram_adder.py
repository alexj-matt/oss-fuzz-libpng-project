import struct
import zlib
import random

def insert_hist_chunk_auto(input_file, output_file, freq_source='random'):
    with open(input_file, 'rb') as f:
        data = f.read()

    # PNG signature
    signature = data[:8]
    assert signature == b'\x89PNG\r\n\x1a\n'

    # Parse chunks
    pos = 8
    output = bytearray(signature)
    inserted_hist = False

    while pos < len(data):
        length = struct.unpack(">I", data[pos:pos+4])[0]
        chunk_type = data[pos+4:pos+8]
        chunk_data = data[pos+8:pos+8+length]
        crc = data[pos+8+length:pos+12+length]

        output += data[pos:pos+12+length]
        pos += 12 + length

        # When we find PLTE, extract number of entries and insert hIST
        if chunk_type == b'PLTE' and not inserted_hist:
            num_colors = length // 3
            if freq_source == 'random':
                frequencies = [random.randint(1, 100) for _ in range(num_colors)]
            elif freq_source == 'uniform':
                frequencies = [1] * num_colors
            else:
                raise ValueError("freq_source must be 'random' or 'uniform'")

            hist_data = b''.join(struct.pack(">H", f) for f in frequencies)
            hist_crc = struct.pack(">I", zlib.crc32(b'hIST' + hist_data) & 0xffffffff)
            output += struct.pack(">I", len(hist_data))
            output += b'hIST'
            output += hist_data
            output += hist_crc
            inserted_hist = True

    with open(output_file, 'wb') as f:
        f.write(output)

    print(f"Inserted hIST chunk with {len(frequencies)} entries into '{output_file}'.")


def main():
    # Example: 2-color image, frequencies: red=10, blue=20
    # take the two main args
    import sys
    if len(sys.argv) != 3:
        print("Usage: python hist_adder.py <input_file> <output_file>")
        sys.exit(1)
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    insert_hist_chunk_auto(input_file, output_file, freq_source='random')


if __name__ == "__main__":
    main()
