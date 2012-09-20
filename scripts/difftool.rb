require 'logger'
require 'pry'

module ROMHacking
  # Simple skeleton class
  DataFile = Struct.new(:filename, :data)
  
  class Diff
    # Attributes
    attr_reader :files
    
    def initialize(*files)
      load_files(files)
    end
    
    def compare(criteria = '!=')
      # Initially all the bytes in the file contents are interesting
      byte_range = (0..(@files.first[:data].length - 1)).to_a
      (0..(@files.size - 2)).each do |index|
        data_a = @files[index + 0].data
        data_b = @files[index + 1].data
        
        # We filter all offsets that do not match the comparison criteria
        next_range = byte_range.find_all do |offset|
          data_b[offset].send(criteria.to_sym, data_a[offset])
        end
        byte_range = next_range
      end
      byte_range
    end
    
    def display(*offsets)
      # Iterate over all files and display the byte value at given offsets
      @files.each_with_index do |file, index|
        values = offsets.map do |offset|
          sprintf('0x%04x: 0x%02x', offset, file.data[offset])
        end.join(', ')
        $stderr.puts("#{index}: filename: #{file.filename}, [ #{values} ]")
      end
      nil
    end
    
    protected
    def load_files(files)
      # All files must have the same size
      file_size = File.size(files.first)
      if files.any? { |filename| File.size(filename) != file_size }
        throw ArgumentError.new('File size differs between provided files')
      end
      
      # Load all file contents into a hash indexed by the filenames
      @files = Array.new
      files.each_with_index do |filename, index|
        $stderr.puts("Loading $diff.files[#{index}] => #{filename}")
        @files.push(DataFile.new(filename, File.binread(filename).unpack('C*')))
      end
    end
  end
end

if $0 == __FILE__
  $diff = ROMHacking::Diff.new(*ARGV)
  binding.pry(:quiet => true)
end
