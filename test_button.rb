require_relative 'lib/preline'
require_relative 'app/components/preline/core/button'

# Test with string type
button = Components::Preline::Button.new(
  text: "Submit",
  type: "submit",
  variant: "primary"
)

puts "Button created successfully with string 'submit' type\!"
