#!/usr/bin/env ruby

require 'fileutils'

# Generic class for code generators to inherit from
# Handles all non architecture-specific activities in code generation
class Codegen
  include FileUtils
  def initialize stack_size
    @as = "#{@prefix}as"
    @ld = "#{@prefix}ld"
    @label_number = 0
    @stack_size = stack_size
  end

  def compile_executable
    @asmout.close
    binfile = File.basename @asmsrc, '.*'
    objfile = "#{binfile}.o"
    `#{@as} #{@asmsrc} -o #{objfile}`
    `#{@ld} #{objfile} -o #{binfile}`
    rm @asmsrc
    rm objfile
  end

  def gen_code tokens
    @data_op = true
    @begin_label_stack = []
    @end_label_stack = []

    gen_preamble

    tokens.each do |tok|
      case tok
      when DataArithmetic then gen_data_op tok.value
      when PointerArithmetic then gen_pointer_op tok.value
      when :loopbegin then gen_loop_begin
      when :loopend then gen_loop_end
      when :putchar then gen_putchar
      when :getchar then gen_getchar
      end
    end

    gen_postamble
    compile_executable
  end

  def gen_preamble
    dirname = File.dirname __FILE__
    @asmout.write File.read("#{dirname}/../asm/#{@prefix}preamble.s")
  end

  def fresh_label
    @label_number += 1
    ".L#{@label_number}"
  end
end