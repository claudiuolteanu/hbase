require 'stringio'
class MyIrb2

  def capture_stdout
      out = StringIO.new
      $stdout = out
      yield
      return out.string
    ensure
      $stdout = STDOUT
    end

  def eval(str)
    stdout = nil
	stdout = capture_stdout
    eval_result = Kernel.eval(str)
  end
  $caca = stdout;
end
$irb = MyIrb2.new
$var = $irb.eval("puts 1")
puts $var

