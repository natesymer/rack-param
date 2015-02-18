# Rack::Param

Parameter checking and validation for `Rack::Request`. Originally designed to be used with [`Sansom`](http://github.com/fhsjaagshs/fhsjaagshs), but it also works with [`Rack`](http://github.com/rack/rack).

Installation
-

Add this line to your application's Gemfile:

    gem "rack-param"

And then execute:

    $ bundle

Or install it through `gem`:

    $ gem install rack-param

Usage
-

For example:

    require "rack/param"
    
    r = Rack::Request env # pass your env
    r.param :positive, Integer, :min => 0, :required => true
    
Now, `r.params` should contain a single entry, regardless of the original request's parameters.
    
    { "positive" => <some Integer> }
    
`Rack::Param` patches `Rack::Request#params` to contain only the validated parameters, in coerced form. If you want the original parameters hash, use the `Rack::Request#raw_params` method.

Rules
-

Rules are a way of making sure parameters are valid. Rather than type them yourself, use the rules below to 

<table border="0" style="width:100%">
  <tr>
    <td><b>Rule</b></td>
    <td><b>Argument</b></td>
    <td><b>Default</b></td>
    <td><b>Description</b></td>
  </tr>
  <tr>
    <td><code>:greater_than</code></td>
    <td><code>Numeric</code></td>
    <td>none</td>
    <td>Self explanatory.</td>
  </tr>
  <tr>
    <td><code>:less_than</code></td>
    <td><code>Numeric</code></td>
    <td>none</td>
    <td>Self explanatory.</td>	
  </tr>
  <tr>
    <td><code>:min</code></td>
    <td><code>Numeric</code></td>
    <td>none</td>
    <td>Greater than or equal to.</td>	
  </tr>
  <tr>
    <td><code>:max</code></td>
    <td><code>Numeric</code></td>
    <td>none</td>
    <td>Less than or equal to.</td>	
  </tr>
  <tr>
    <td><code>:length</code></td>
    <td><code>Numeric</code></td>
    <td>none</td>
    <td>Self explanatory.</td>	
  </tr>
  <tr>
    <td><code>:min_length</code></td>
    <td><code>Numeric</code></td>
    <td>none</td>
    <td>Greater than or equal to, using the parameter's length.</td>	
  </tr>
  <tr>
    <td><code>:max_length</code></td>
    <td><code>Numeric</code></td>
    <td>none</td>
    <td>Less than or equal to, using the parameter's length.</td>	
  </tr>
  <tr>
    <td><code>:in</code></td>
    <td>Responds to <code>include?</code></td>
    <td>none</td>
    <td>Less than or equal to, using the parameter's length.</td>	
  </tr>
  <tr>
    <!--TODO: This should be :matches-->
    <td><code>:regex</code></td>
    <td>Responds to <code>match</code></td>
    <td>none</td>
    <td>Self explanatory.</td>	
  </tr>
  <tr>
    <td><code>:validator</code></td>
    <td>Responds to <code>call</code> with a <i>single</i> argument. Returns <code>true</code> or <code>false</code<</td>
    <td>none</td>
    <td>If the argument returns something truthy or <code>true</code>, this rule is true.</td>
  </tr>
</table>

There are also a couple options used to control parameter checking.

<table border="0" style="width:100%">
  <tr>
    <td><b>Option</b></td>
    <td><b>Argument</b></td>
    <td><b>Default</b></td>
    <td><b>Description</b></td>
  </tr>
  <tr>
  	<td><code>:error_message</code></td>
    <td><code>String</code></td>
    <td>depends on rule</td>
    <td>The message to be used when a <code>Rack::ParameterError</code> is raised. It has a specific format: <code>$</code> is the parameter and <code>#</code> is the argument. (ex "Invalid token: $")</td>
   </tr>
   <tr>
    <td><code>:coerce</code></td>
    <td><code>true</code>/<code>false</code></td>
    <td><code>true</code></td>
    <td>Whether or not rack-param coerces the parameter.</td>	
  </tr>
  <tr>
    <td><code>:required</code></td>
    <td><code>true</code>/<code>false</code></td>
    <td><code>false</code></td>
    <td>Whether or not the parameter is required.</td>	
  </tr>
  <tr>
    <td><code>:default</code></td>
    <td><code>Object</code></td>
    <td><code>none</code></td>
    <td>If the parameter doesn't exist, this value takes its place. It should be a fully coerced value.</td>	
  </tr>
  <tr>
    <td><code>:transform</code></td>
    <td>Responds to <code>call</code> with a <i>single</i> argument. Returns a new value.</td>
    <td><code>none</code></td>
    <td>Called to transform a coerced value.</td>	
  </tr>
 </table>
 
Custom Types & Coercion
-

Have a custom type that you want to be able to coerce a value? Write a function whose name is the same as your class. It should take one argument, a `String`. In fact, most classes already have this (like `Integer()`)

    class Money
       ...
    end
    
    # somewhere in the global scope (or in `Kernel`)
    def Money str
      # turn str into a `Money` and return it
    end

Contributing
-

1. Fork it ( https://github.com/sansomrb/rack-param/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

Your changes must pass the rspec test suite.
