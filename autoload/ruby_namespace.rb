#!/usr/bin/env ruby
require 'ripper/lexer'

class TokenProcessor
  def initialize(line)
    @line = line
  end

  def process(tokens)
    @end_stack = []
    @name_stack = []
    @next_push_name = nil
    tokens.each do |(line, col), type, token|
      if type != :on_sp
        pop_end_stack(type, token)
        if line >= @line
          return @name_stack
        end
        process_one(type, token)
        @prev_token_type = type
      end
    end
  end

  def pop_end_stack(type, token)
    if type == :on_kw && token == 'end'
      if @end_stack.empty?
        raise 'end keywords is found but @end_stack is empty'
      end
      popped_token = @end_stack.pop
      if NAMESPACE_TOKENS.include?(popped_token)
        name = @name_stack.pop
      end
    end
  end

  def process_one(type, token)
    keep_push_name = false
    if @prev_push_name
      if type == :on_op && token == '::'
        @name_stack[-1] += '::'
        keep_push_name = true
      elsif type == :on_const
        @name_stack[-1] += token
        keep_push_name = true
      end
    end

    if end_stack_keyword?(type, token)
      @end_stack.push(token)
    end
    push_namespace(type, token)

    if keep_push_name
      @prev_push_name = true
    end
  end

  NAMESPACE_TOKENS = %w[class module]

  def push_namespace(type, token)
    @prev_push_name = false
    if @next_push_name
      if token == '<<'
        @next_push_name += ' <<'
      else
        @name_stack.push("#{@next_push_name} #{token}")
        @next_push_name = nil
        @prev_push_name = true
      end
    elsif type == :on_kw && NAMESPACE_TOKENS.include?(token)
      @next_push_name = token
    else
      @next_push_name = nil
    end
  end

  END_KEYWORDS = %w[
    class
    module
    def
    loop
    do
    begin
  ]

  POST_END_KEYWORDS = %w[
    if
    unless
    while
    until
  ]
  NON_POST_PREV_TYPES = [:on_nl, :on_ignored_nl]

  def end_stack_keyword?(type, token)
    if type != :on_kw
      return false
    end
    if POST_END_KEYWORDS.include?(token)
      NON_POST_PREV_TYPES.include?(@prev_token_type)
    else
      END_KEYWORDS.include?(token)
    end
  end
end

path = ARGV[0]
line = ARGV[1]
if line.nil?
  puts "Usage: #{$0} /path/to/file lineno"
  exit 1
end
tokens = Ripper.lex(File.read(path), path)

name_stack = TokenProcessor.new(line.to_i).process(tokens)
if name_stack.empty?
  puts 'TOPLEVEL'
else
  puts name_stack.join('; ')
end
