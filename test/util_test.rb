require File.dirname(__FILE__) + '/test_helper'

module ChefVPCToolkit

class UtilTest < Test::Unit::TestCase

  def test_hostname

    assert_not_nil Util.hostname

  end

  def test_load_public_key

    key=Util.load_public_key
    assert_not_nil key

  end

end

end
