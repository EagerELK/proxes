require 'proxes/db'
require 'proxes/models/role'
require 'proxes/models/permission'

ProxES::Role.find_or_create(name: 'user')
sa = ProxES::Role.find_or_create(name: 'super_admin')
%w(GET POST PUT DELETE HEAD OPTIONS INDEX).each do |verb|
  ProxES::Permission.find_or_create(role: sa, verb: verb, pattern: '.*')
end
