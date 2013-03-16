guard 'rspec' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^models/(.+)\.rb$}) {|m| "spec/#{m[1]}_spec.rb"}
end