require 'stringio'
require 'irb'
require 'hirb'

class Engine
  extend Shell
  def initialize()
    @binding = Kernel.binding
  end
  def run_code(code)
    # run something
    stdout_id = $stdout.to_i
    $stdout = StringIO.new
    cmd = <<-EOF
    $stdout = StringIO.new
    begin
      #{code}
    end
    EOF
    begin
      result = Thread.new { Kernel.eval(cmd, @binding) }.value
    rescue SecurityError
      return "illegal"
    rescue Exception => e
      return e
    ensure
      output = get_stdout
      $stdout = IO.new(stdout_id)
      return output
    end

    return output
  end

   private
   def get_stdout
     raise TypeError, "$stdout is a #{$stdout.class}" unless $stdout.is_a? StringIO
     $stdout.rewind
     $stdout.read
   end
   
end

module Kernel
  @shell = Shell::Shell.new(@hbase, @formatter)

  # Add commands to this namespace
  @shell.export_commands(self)
  @formatter = Shell::Formatter::Console.new

  # Setup the HBase module.  Create a configuration.
  @hbase = Hbase::Hbase.new

  # Setup console
  @shell = Shell::Shell.new(@hbase, @formatter)

  # Add commands to this namespace
  @shell.export_commands(self)

  # Add help command
  def help(command = nil)
    @shell.help(command)
  end

# Backwards compatibility method
  def tools
    @shell.help_group('tools')
  end
end

$myirb = Engine.new





