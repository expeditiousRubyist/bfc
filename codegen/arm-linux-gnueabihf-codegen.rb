require_relative 'codegen.rb'

# Code generator for ARM Hard Float on Linux
class GnuLinuxArmHfCodegen < Codegen
  def initialize stack_size
    @prefix = 'arm-linux-gnueabihf-'
    @asmsrc = 'out.s' # TODO: make this settable via argument?
    @asmout = File.open(@asmsrc, 'w')
    super
  end
private
  def gen_preamble
    super
    @asmout.puts 'bfmain:'
    @asmout.puts "\tpush\t{lr}"
    @asmout.puts "\tsub\tsp, \##{@stack_size}"
    @asmout.puts "\tmov\tr4, sp"
  end

  def gen_postamble
    @asmout.puts "\tadd\tsp, \##{@stack_size}"
    @asmout.puts "\tpop\t{lr}"
    @asmout.puts "\tbx\tlr"
  end

  def gen_data_op amount
    return if amount.zero?
    restore_register_if_changed

    if amount < 0 then
      @asmout.puts "\tsub\tr5, \##{amount.abs}"
    else
      @asmout.puts "\tadd\tr5, \##{amount}"
    end
  end

  def gen_pointer_op amount
    return if amount.zero?
    save_register_if_changed

    # TODO: Consider adding option of overflow checking?
    if amount < 0 then
      @asmout.puts "\tsub\tr4, \##{amount.abs}"
    else
      @asmout.puts "\tadd\tr4, \##{amount}"
    end
  end

  def gen_loop_begin
    restore_register_if_changed

    begin_label = fresh_label
    @asmout.puts "#{begin_label}:"
    @begin_label_stack.push begin_label

    end_label = fresh_label
    @asmout.puts "\tand\tr5, \#255"
    @asmout.puts "\tcmp\tr5, \#0"
    @asmout.puts "\tbeq #{end_label}"
    @end_label_stack.push end_label
  end

  def gen_loop_end
    restore_register_if_changed
    @asmout.puts "\tb\t#{@begin_label_stack.pop}"
    @asmout.puts "#{@end_label_stack.pop}:"
  end

  def gen_putchar
    save_register_if_changed
    @asmout.puts "\tbl\tbfputchar"
  end

  def gen_getchar
    @data_op = false # Note: no need to save_register_if_changed b/c overriding.
    @asmout.puts "\tbl\tbfgetchar"
  end

  def save_register_if_changed
    if @data_op then
      @asmout.puts "\tstrb\tr5, [r4]"
      @data_op = false
    end
  end

  def restore_register_if_changed
    unless @data_op
      @asmout.puts "\tldrb\tr5, [r4]"
      @data_op = true
    end
  end
end