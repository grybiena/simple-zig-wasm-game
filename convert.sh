# quick script to convert to u8 RGBA since that makes pixels easy to deal with in zig
# the png format is quite complicated and I just wanted to think about pixels
convert src/assets/basictiles.png -depth 8 RGBA:src/assets/basictiles.bin
convert src/assets/characters.png -depth 8 RGBA:src/assets/characters.bin
