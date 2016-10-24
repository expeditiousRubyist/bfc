require_relative 'codegen.rb'

# Code generator for our currently only supported target, x86_64-linux-gnu
class GnuLinuxAmd64Codegen < Codegen
  def initialize stack_size
    @prefix = 'x86_64-linux-gnu-'
    @asmsrc = 'out.s' # TODO: make this settable via argument?
    @asmout = File.open(@asmsrc, 'w')
    super
  end
private
  def gen_preamble
    super
    @asmout.puts 'bfmain:'
    @asmout.puts "\tsubq\t$#{@stack_size}, %rsp"
    @asmout.puts "\tmovq\t%rsp, %rbx"
    @asmout.puts "\tinc %rbx"
  end

  def gen_postamble
    @asmout.puts "\taddq\t$#{@stack_size}, %rsp"
    @asmout.puts "\tret"
  end

  def gen_data_op amount
    return if amount.zero?
    restore_register_if_changed

    if amount < 0 then
      @asmout.puts "\tsubb\t$#{amount.abs}, %r12b"
    else
      @asmout.puts "\taddb\t$#{amount}, %r12b"
    end
  end

  def gen_pointer_op amount
    return if amount.zero?
    save_register_if_changed

    # TODO: Consider adding option of overflow checking?
    if amount < 0 then
      @asmout.puts "\tsubq\t$#{amount.abs}, %rbx"
    else
      @asmout.puts "\taddq\t$#{amount}, %rbx"
    end
  end

  def gen_loop_begin
    restore_register_if_changed

    begin_label = fresh_label
    @asmout.puts "#{begin_label}:"
    @begin_label_stack.push begin_label

    end_label = fresh_label
    @asmout.puts "\ttestb\t%r12b, %r12b"
    @asmout.puts "\tje\t#{end_label}"
    @end_label_stack.push end_label
  end

  def gen_loop_end
    restore_register_if_changed
    @asmout.puts "\tjmp\t#{@begin_label_stack.pop}"
    @asmout.puts "#{@end_label_stack.pop}:"
  end

  def gen_putchar
    save_register_if_changed
    @asmout.puts "\tcall\tbfputchar"
  end

  def gen_getchar
    @data_op = false # Note: no need to save_register_if_changed b/c overriding.
    @asmout.puts "\tcall\tbfgetchar"
  end

  def save_register_if_changed
    if @data_op then
      @asmout.puts "\tmovb\t%r12b, (%rbx)"
      @data_op = false
    end
  end

  def restore_register_if_changed
    unless @data_op
      @asmout.puts "\tmovb\t(%rbx), %r12b"
      @data_op = true
    end
  end
end