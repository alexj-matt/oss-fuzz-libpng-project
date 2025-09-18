import png
import random

def generate_10_seeds():
    for i in range(10):
        if i % 3 == 0:
            palette = [(x, x, x) for x in range(256)]
        elif i % 3 == 1:
            palette = [(x % 128, x % 128, x % 128) for x in range(256)]    
        else:
            palette = [(random.randint(0, 255), random.randint(0, 255), random.randint(0, 255)) for _ in range(256)]
        
        palette_size = random.randint(64, 256)
        palette = palette[:palette_size]

        width, height = random.randint(50, 200), random.randint(50, 200)
        image = [[random.randint(0, len(palette) - 1) for _ in range(width)] for _ in range(height)]

        filename = f"custom_seeds/generated_seed_{i + 1}.png"
        writer = png.Writer(width=width, height=height, palette=palette, bitdepth=8)
        with open(filename, 'wb') as f:
            writer.write(f, image)
        
        print(f"Generated Seed: {filename}")

generate_10_seeds()