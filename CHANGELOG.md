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

v 0.1.2

- `:error_message` option

v 0.1.3

- Fixed show-stopping typo

v 0.1.4

- Fixed a typo that would prevent custom error messages from working.