require 'hirb'

class MyIrb
  # captures everything, stdout, stderr, returns, etc
  def initialize(java_callback_object)
  end
  

  def eval(str)
    eval_result = Kernel.eval(str)
    java_callback_object.results(str, eval_result)
  end
end

