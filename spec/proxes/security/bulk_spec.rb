# frozen_string_literal: true

require 'spec_helper'
require 'proxes/middleware/security'
require 'proxes/forwarder'
require 'proxes/models/permission'
require 'elasticsearch'
require 'support/multi_request_shared_examples'

describe ProxES::Request::Bulk do
  it_behaves_like 'Multi Request', 'POST', '_bulk'
end
