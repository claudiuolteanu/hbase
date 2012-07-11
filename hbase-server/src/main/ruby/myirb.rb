
class MyIrb
  # captures everything, stdout, stderr, returns, etc
  
  def eval(str)
    $eval_result = Kernel.eval(str)
    puts $eval_result
  end
end
$ob = MyIrb.new
$ob.eval('puts "test"')




