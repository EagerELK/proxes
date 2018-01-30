guard :rspec, cmd: 'rspec' do
  # watch /lib/ files
  watch(/^lib\/(.+).rb$/) do |m|
    "spec/#{m[1]}_spec.rb"
  end

  # watch /spec/ files
  watch(/^spec\/(.+).rb$/) do |m|
    "spec/#{m[1]}.rb"
  end
end
