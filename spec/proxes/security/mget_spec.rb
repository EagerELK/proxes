# frozen_string_literal: true

require 'spec_helper'
require 'support/multi_request_shared_examples'

describe ProxES::Request::Mget do
  it_behaves_like 'Multi Request', 'GET', '_mget'
end
