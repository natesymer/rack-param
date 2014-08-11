# Rack::Param

Parameter checking and validation for `Rack::Request`. Originally designed to be used with [`Sansom`](http://github.com/fhsjaagshs/fhsjaagshs), but it also works with [`Rack`](http://github.com/rack/rack).

## Installation

Add this line to your application's Gemfile:

    gem 'rack-param'

And then execute:

    $ bundle

Or install it through `gem`:

    $ gem install rack-param

## Usage

    require "rack/param"
    
    r = Rack::Request env # pass your env
    r.param :param_name, Integer, :required => true ...
    
Now, `r.params` should contain a single entry:
    
    { :param_name => <some Integer> }
    
`Rack::Param` patches `Rack::Request#params` to contain only the validated parameters, in coerced form.

Here's a list of options:

`:required` => `true`/`false`<br />
`:blank` => `true`/`false`<br />
`:greater_than` => Any `Numeric`<br />
`:less_than` => Any `Numeric`<br />
`:min` => Any `Numeric`<br />
`:max` => Any `Numeric`<br />
`:length` => Any `Numeric`<br />
`:min_length` => Any `Numeric`<br />
`:max_length` => Any `Numeric`<br />
`:in` => Something that responds to `include?`<br />
`:regex` => A `Regexp`<br />
`:validator` => A block: `{ |param| true }`<br />

## Contributing

1. Fork it ( https://github.com/sansomrb/rack-param/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
