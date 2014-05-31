vim-ruby_namespace
==================

Show current namespace in Ruby file.

## Usage
Execute `:RubyNamespace` command to see namespace of the current line.

## Example

```ruby
class C1
  def initialize
    # namespace = C1
  end
  # namespace = C1

  module M1
    class C2
      # namespace = class C1; module M1; class C2

      class << self
        # namespace = class C1; module M1; class C2; class << self
      end
    end
  end

  class M1::C2
    # namespace = class C1; class M1::C2
  end
end

# namespace = TOPLEVEL
```
