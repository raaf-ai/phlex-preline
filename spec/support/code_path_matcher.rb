# frozen_string_literal: true

# Custom RSpec matcher for checking if code contains a code_path comment
RSpec::Matchers.define :have_executed_code_path do |path_description|
  # Use a memoized instance variable to cache the rendered output
  define_method :get_rendered_output do |component|
    return component if component.is_a?(String)

    # Cache the rendered output in the component's instance
    # This prevents double rendering errors
    @rendered_output ||= render_phlex(component)
  end

  match do |component|
    output = get_rendered_output(component)
    
    # Check if the output contains the code path comment
    output.include?("<!-- Codepath: #{path_description} executed -->")
  end

  failure_message do |component|
    output = get_rendered_output(component)
    
    # Extract all code paths for better error messages
    executed_paths = output.scan(/<!-- Codepath: (.+?) executed -->/).flatten
    
    <<~MESSAGE
      Expected component to have executed code path:
        "#{path_description}"
      
      But the following code paths were executed:
      #{executed_paths.empty? ? '  (none)' : executed_paths.map { |path| "  - #{path}" }.join("\n")}
    MESSAGE
  end

  failure_message_when_negated do |component|
    "expected component not to have executed code path '#{path_description}' but it did"
  end

  description do
    "have executed code_path '#{path_description}'"
  end
end