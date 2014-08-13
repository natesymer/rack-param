#Changelog

v 0.0.1

- Initial release

v 0.1.0

- Complete rewrite
   * Write tests
   * Make rules more readable in `param.rb`
   * `Rack::Request#params` now points to coerced and validated parameters
   
v 0.1.1

- Fix bug where invalid error message would be returned