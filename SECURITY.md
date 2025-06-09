# Security Features

Phlex-Preline includes built-in security features to protect against XSS and injection attacks. By default, all HTML attributes, data attributes, and ARIA attributes are filtered through an allowlist system.

## Default Security Behavior

### Allowed HTML Attributes
The following standard HTML attributes are allowed by default:
- `id`, `class`, `title`, `lang`, `dir`, `tabindex`
- `placeholder`, `disabled`, `readonly`, `required`
- `rows`, `cols`, `maxlength`, `minlength`, `pattern`
- `min`, `max`, `step`, `size`, `multiple`, `checked`
- `autocomplete`, `autofocus`, `spellcheck`
- `rel`, `target`, `download`
- `alt`, `src`, `href`, `width`, `height`, `loading`
- `type`, `value`, `name`, `role`
- `colspan`, `rowspan`, `scope`
- `style`

### Allowed Data Attributes
Data attributes are allowed based on patterns:
- Specific attributes: `controller`, `action`, `target`, `method`, `track`, `confirm`, `remote`
- Turbo/Hotwire: Attributes starting with `turbo`
- Bootstrap: Attributes starting with `bs-`
- Preline/HyperScript: Attributes starting with `hs-`
- Stimulus: Attributes ending with `-target`, `-value`, `-class`, `-outlet`
- Common patterns: `test`, `testid`, `id`, `value`, `custom`, etc.

### Allowed ARIA Attributes
Common ARIA attributes for accessibility are allowed:
- `label`, `labelledby`, `describedby`, `controls`
- `expanded`, `hidden`, `disabled`, `checked`, `pressed`
- `current`, `level`, `valuemin`, `valuemax`, `valuenow`
- And many more...

## Bypassing Security Checks

In some cases, you may need to use custom attributes that aren't in the allowlist. You can temporarily or permanently bypass security checks.

### Method 1: Global Configuration

```ruby
# In an initializer or configuration file
Components::Preline.configure do |config|
  config.bypass_security_checks = true
end
```

### Method 2: Direct Setting

```ruby
# Enable bypass
Components::Preline.bypass_security_checks = true

# Your components will now accept any data attributes
button = Components::Preline::Button.new(
  text: "Save",
  data: { 
    "my-custom-attr": "value",
    "another-attr": "test"
  }
)

# Disable bypass (recommended after use)
Components::Preline.bypass_security_checks = false
```

### Method 3: Temporary Bypass

```ruby
# Temporarily bypass for specific operations
begin
  Components::Preline.bypass_security_checks = true
  
  # Create components with custom attributes
  button = Components::Preline::Button.new(
    text: "Special Button",
    data: { "custom-tracking-id": "12345" }
  )
  
ensure
  # Always re-enable security
  Components::Preline.bypass_security_checks = false
end
```

## Extending Allow Lists

Instead of bypassing security entirely, you can extend the allow lists to include your custom attributes. This is the recommended approach for production applications.

### Adding Allowed Attributes

```ruby
# Add HTML attributes
Components::Preline.allow_html_attributes(:contenteditable, :draggable, :hidden)

# Add data attributes (without data- prefix)
Components::Preline.allow_data_attributes('tooltip', 'popover-content', 'analytics-id')

# Add ARIA attributes (without aria- prefix)
Components::Preline.allow_aria_attributes('roledescription', 'keyshortcuts')

# Add patterns for data attributes
Components::Preline.allow_data_patterns(
  /^analytics-/,      # Allow any data-analytics-* attributes
  /^tracking-/,       # Allow any data-tracking-* attributes
  'custom-'           # Allow any data attribute containing 'custom-'
)
```

### Configuration in Initializer

```ruby
# config/initializers/phlex_preline.rb
Components::Preline.configure do |config|
  # Add custom attributes to allow lists
  config.allow_html_attributes(:x_data, :x_show, :x_on)  # Alpine.js
  config.allow_data_attributes('tippy-content', 'tippy-placement')  # Tippy.js
  config.allow_data_patterns(/^analytics-/, /^ga-/)  # Analytics
end
```

### Checking Current Allow Lists

```ruby
# View all current allow lists
allowed = Components::Preline.allowed_attributes
puts allowed[:html]          # => [:id, :class, :title, ...]
puts allowed[:data]          # => ["controller", "action", ...]
puts allowed[:aria]          # => ["label", "labelledby", ...]
puts allowed[:data_patterns] # => [/^analytics-/, ...]
```

### Resetting to Defaults

```ruby
# Reset all allow lists to their default values
Components::Preline.reset_allowed_attributes!
```

## Important Security Notes

1. **XSS Protection**: Even with security bypass enabled, attribute values are still sanitized to prevent XSS attacks. Script tags and `javascript:` URLs are removed.

2. **Production Use**: It's strongly recommended to keep security checks enabled in production. Only bypass when absolutely necessary.

3. **Specific Attributes**: Instead of bypassing all security, consider adding your custom attributes to the allowlist by modifying the `ALLOWED_DATA_ATTRIBUTES` constant or the `allowed_data_attribute?` method.

## Checking Security Status

```ruby
# Check if security is bypassed
if Components::Preline.bypass_security_checks?
  puts "Warning: Security checks are bypassed!"
end
```

## Best Practices

1. Always use the most restrictive security settings possible
2. If you need custom attributes regularly, consider contributing them to the allowlist
3. Document why security was bypassed when you do so
4. Use temporary bypasses with proper error handling
5. Test your components with security enabled before deploying