class Command
  attr_reader :opcode

  def initialize()
    @opcode = opcode
  end

  # Declares a symbolic variable consisting of a sequence of letters (e.g., sum).
  # The variable is stored at an available location in data memory.
  class DECCommand < Command
    def execute(ali, symbol)
      address = ali.memory[ALI::DATA_MEM_START..].index(0) + ALI::DATA_MEM_START
      ali.memory[address] = symbol
      ali.symbol_table[symbol] = { address: address, value: 0 }
    end
  end

  # Loads word at data memory address of symbol into the accumulator
  class LDACommand < Command
    def execute(ali, symbol)
      symbol_entry = ali.symbol_table[symbol]
      address = symbol_entry[:address]
      ali.accumulator = ali.memory[address]

      end
  end

  # Loads the integer value into the accumulator register. The value could be a negative number.
  class LDICommand < Command
    def execute(ali, value)
      ali.accumulator = value
    end
  end

  # Stores content of accumulator into data memory at address of symbol.
  class STRCommand < Command
    def execute(ali, symbol)
      symbol_entry = ali.symbol_table[symbol]
      address = symbol_entry[:address]
      ali.memory[address] = ali.accumulator
    end
  end

  # Exchanges the content registers A and B
  class XCHCommand < Command
    def execute(ali)
      temp = ali.accumulator
      ali.accumulator = ali.data_register
      ali.data_register = temp
    end
  end

  # Transfers control to instruction at address number in program memory
  class JMPCommand < Command
    def execute(ali, address)
      ali.program_counter = address -1
    end
  end

  # Transfers control to instruction at address number if the zero-result bit is set
  class JZSCommand < Command
    def execute(ali, address)
      ali.program_counter = address -1 if ali.zero_result_bit == 1
    end
  end

  # Adds the content of registers A and B. The sum is stored in A.
  # The overflow bit is set or cleared as needed.
  # However, if the sum out of range for 16-bit numbers, this operation has no effect.
  class ADDCommand < Command
    def execute(ali)
      result = ali.accumulator.to_i + ali.data_register.to_i
      if result.between?(-32768, 32767)
        ali.accumulator = result
        if result == 0
          ali.zero_result_bit = 1
        else
          ali.zero_result_bit = 0
        end
      end
    end
  end

  # The content of register B is subtracted from A.
  # The difference is stored in A.
  # The overflow bit is set or cleared as needed.
  # If the sum out of range for 16-bit numbers, this operation has no effect.
  class SUBCommand < Command
    def execute(ali)
      result = ali.accumulator - ali.data_register
      if result.between?(-32768, 32767)
        ali.accumulator = result
        if result == 0
          ali.zero_result_bit = 0
        else
          ali.zero_result_bit = 1
        end
      end
    end
  end

  # Terminates program execution
  class HLTCommand < Command
    def execute(ali)
      ali.program_counter = -1
    end
  end
end

# Define hardware components
class ALI
  MEMORY_SIZE = 256
  DATA_MEM_START = 128
  attr_accessor :memory, :accumulator, :data_register, :program_counter, :zero_result_bit, :symbol_table

  def initialize
    @memory = Array.new(MEMORY_SIZE, 0)     # Max size 128 for program & data memory each. Each index is 16 bits long
    @accumulator = 0                        # A 16-bit register. Register A
    @data_register = 0                      # A 16-bit register. Register B
    @program_counter = 0                    # An 8 bit program counter, Legal values are unsigned ints from 0 - 127
    @zero_result_bit = 0                    # Cleared if ADD or SUB instruction produces !0. Changed only after ADD or SUB
    @symbol_table = {}                      # hash table to store symbol-value pairs
    @command_map = {
      "DEC" => ::Command::DECCommand,
      "LDA" => ::Command::LDACommand,
      "LDI" => ::Command::LDICommand,
      "STR" => ::Command::STRCommand,
      "XCH" => ::Command::XCHCommand,
      "JMP" => ::Command::JMPCommand,
      "JZS" => ::Command::JZSCommand,
      "ADD" => ::Command::ADDCommand,
      "SUB" => ::Command::SUBCommand,
      "HLT" => ::Command::HLTCommand
    }
  end

  # Read a SAL program from the file. The program is stored in the memory starting at address 0
  def readfile(filename)
    File.foreach(filename).with_index do |line, index|
      break if index >= 128
      opcode, arg = line.split
      @memory[index] = [opcode, arg]
    end
  end

  # Execute a single line of code, starting from the instruction at memory address 0;
  # update the PC, the registers and memory according to the instruction;
  # print the value of the registers, the zero bit, and only the memory locations
  # that store source code or program data after the line is executed
  def execute_single_line
    opcode, arg = @memory[@program_counter]
    command = @command_map[opcode]
    if command.nil?
      @program_counter = -1
      return
    end

    concrete_command = command.new

    if arg
      if arg.start_with?(/\s*\d+/)
        concrete_command.execute(self, arg.to_i)
      else
        concrete_command.execute(self, arg)
      end

    else
      concrete_command.execute(self)
    end


    @program_counter += 1 if @program_counter != -1
  end

  # Execute all the instructions until a halt instruction is encountered or
  # there are no more instructions to be executed.
  # The program’s source code and data used by the program are printed.
  def execute_all_lines
    iterations = 0
    while @program_counter.between?(0, 127)
      execute_single_line
  
      # Handle infinite loop case
      if iterations == 2000
        temp_pc = @program_counter
        @program_counter = -1
        print "\n"
        print "Your program is running in an infinite loop. Continue? [Y/N]: "
        case gets.chomp.upcase
        when 'Y'
          iterations = 0
          @program_counter = temp_pc
        when 'N'
          break
        else
          print "\n"
          puts "Invalid command. Continue infinite loop? [Y/n]"
        end
      end
      iterations += 1
      # End handling infinite loop case
    end
  end

  def print_state
    puts "\n"
    puts "Accumulator: #{@accumulator}"
    puts "Data Register: #{@data_register}"
    puts "PC: #{@program_counter}"
    puts "Zero Bit: #{@zero_result_bit}"
    puts "Program Memory: #{@memory[0..127].map { |instr| instr || "empty" }}"
    puts "Data Memory: #{@memory[DATA_MEM_START..].map { |val| val.nil? ? 'empty' : val }}"
  end

  def command_loop
    loop do
      if @program_counter == -1
        puts "\nProgram has finished executing. Enter q to quit. "
        loop do
          input = gets.chomp
          break if input == 'q'
          puts "Invalid command. Please press q to quit."
        end
        break
      end
  
      print "\n"
      print "Enter command (s for step, a for all, q to quit): "
      case gets.chomp
      when 's'
        execute_single_line
        print_state
      when 'a'
        execute_all_lines
        print_state
      when 'q'
        break
      else
        puts "Invalid command."
      end
    end
  end

  # Program Start: Prompt user for input
  puts <<~MESSAGE
  \nWelcome to the Assembly Language Interpreter!
  After entering your filename, you can:
  - type 'a' + ENTER to execute all instructions
  - type 's' + ENTER to step through each instruction
  - or type 'q' to quit the program.\n
MESSAGE


  print "Enter the name of a file in the current directory: "
  filename = gets.chomp
  ALInterpreter = ALI.new
  ALInterpreter.readfile(filename)
  ALInterpreter.command_loop
  # ALInterpreter.print_state
end


