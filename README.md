# LocalizedSelect

Rails Gem to provide support for localized *<select>* menu with entries from your locale yaml-files.

Uses the Rails internationalization framework (I18n).

## Installation

Add this line to your application's Gemfile:

    gem 'localized_select'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install localized_select

## Usage


```ruby
	<%= localized_select(:address, :location_id, :locations) %>
```

with a locale file that contains:

```yaml
en:
  locations:
    1: "Home"
    2: "Away"
    3: "School"
```
becomes
```html
	<select id="address_location_id" name="address[location_id]">
		<option value="2">Away</option>
        <option value="1">Home</option>
		<option value="3">School</option>
	<select>
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
