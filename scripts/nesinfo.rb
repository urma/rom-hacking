# NES parser and metadata information
# Based on http://fms.komkon.org/EMUL8/NES.html#LABM by Marat Fayzullin

# Byte     Contents
# ---------------------------------------------------------------------------
# 0-3      String "NES^Z" used to recognize .NES files.
# 4        Number of 16kB ROM banks.
# 5        Number of 8kB VROM banks.
# 6        bit 0     1 for vertical mirroring, 0 for horizontal mirroring.
#          bit 1     1 for battery-backed RAM at $6000-$7FFF.
#          bit 2     1 for a 512-byte trainer at $7000-$71FF.
#          bit 3     1 for a four-screen VRAM layout. 
#          bit 4-7   Four lower bits of ROM Mapper Type.
# 7        bit 0     1 for VS-System cartridges.
#          bit 1-3   Reserved, must be zeroes!
#          bit 4-7   Four higher bits of ROM Mapper Type.
# 8        Number of 8kB RAM banks. For compatibility with the previous
#          versions of the .NES format, assume 1x8kB RAM page when this
#          byte is zero.
# 9        bit 0     1 for PAL cartridges, otherwise assume NTSC.
#          bit 1-7   Reserved, must be zeroes!
# 10-15    Reserved, must be zeroes!
# 16-...   ROM banks, in ascending order. If a trainer is present, its
#          512 bytes precede the ROM bank contents.
# ...-EOF  VROM banks, in ascending order.
# ---------------------------------------------------------------------------

module ROMHacking
    class NESFile
    # Constants
    NES_HEADER_LENGTH = 0x10
    NES_MAGIC_OFFSET  = 0x00
    NES_ROM_OFFSET    = 0x04
    NES_VROM_OFFSET   = 0x05
    NES_FLAGS1_OFFSET = 0x06
    NES_FLAGS2_OFFSET = 0x07
    NES_RAM_OFFSET    = 0x08
    NES_VIDEO_OFFSET  = 0x09

    def initialize(filename = nil)
      @header = File.binread(filename, NESFile::NES_HEADER_LENGTH).unpack('C*')
      unless is_valid_header?(@header)
        throw ArgumentError.new("#{filename} is not a valid NES file")
      end
    end
    
    def is_valid_header?(header = nil)
      # Fist 4 bytes must match "NES^Z", bytes 10 to 15 are all 0
      header[0..3].pack('C4') == "NES\x1a" && header[10..15].all? { |b| b == 0 }
    end
    
    def rom_banks
      @header[NES_ROM_OFFSET]
    end
    
    def vrom_banks
      @header[NES_VROM_OFFSET]
    end
    
    def ram_banks
      @header[NES_RAM_OFFSET]
    end
    
    def is_vertical_mirror?
      (@header[NES_FLAGS1_OFFSET] & (0x01 << 0)) == 1
    end
    
    def is_horizontal_mirror?
      (@header[NES_FLAGS1_OFFSET] & (0x01 << 0)) == 0
    end
    
    def has_battery?
      (@header[NES_FLAGS1_OFFSET] & (0x01 << 1)) == 1
    end
    
    def has_trainer?
      (@header[NES_FLAGS1_OFFSET] & (0x01 << 2)) == 1
    end
    
    def is_four_screen_layout?
      (@header[NES_FLAGS1_OFFSET] & (0x01 << 3)) == 1
    end
    
    def mapper
      ((@header[NES_FLAGS1_OFFSET] & 0xf0) >> 4) + (@header[NES_FLAGS2_OFFSET] & 0xf0)
    end
    
    def is_vs?
      (@header[NES_FLAGS2_OFFSET] & (0x01 << 0)) == 1
    end
    
    def is_pal?
      (@header[NES_VIDEO_OFFSET] & (0x01 << 0)) == 1
    end
    
    def is_ntsc?
      (@header[NES_VIDEO_OFFSET] & (0x01 << 0)) == 0
    end
  end
end

if $0 == __FILE__
  parser = ROMHacking::NESFile.new(ARGV[0])
  
  def boolean_to_string(value)
    value ? "Yes" : "No"
  end
  
  $stdout.puts("-----------------")
  $stdout.puts("        Filename: #{ARGV[0]}")
  $stdout.puts("# 16kB ROM Banks: #{parser.rom_banks}")
  $stdout.puts("# 8kB VROM Banks: #{parser.vrom_banks}")
  $stdout.puts("       Mirroring: #{parser.is_vertical_mirror? ? 'Vertical' : 'Horizontal'}")
  $stdout.puts("  Battery Backup: #{boolean_to_string(parser.has_battery?)}")
  $stdout.puts("         Trainer: #{boolean_to_string(parser.has_trainer?)}")
  $stdout.puts(" 4 Screen Layout: #{boolean_to_string(parser.is_four_screen_layout?)}")
  $stdout.puts("     Mapper Type: #{parser.mapper}")
  $stdout.puts("    Color System: #{parser.is_pal? ? 'PAL' : 'NTSC'}")
  $stdout.puts("-----------------")
end
