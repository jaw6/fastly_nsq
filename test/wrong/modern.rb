require 'wrong'

### Wrong/Minitest adapter

require 'wrong/assert'
require 'wrong/helpers'

class Minitest::Test
  include Wrong::Assert
  include Wrong::Helpers

  def failure_class
    Minitest::Assertion
  end

  def aver(valence, explanation = nil, depth = 0)
    self.assertions += 1 # increment Minitest's assert count
    super(valence, explanation, depth + 1) # apparently this passes along the default block
  end
end
