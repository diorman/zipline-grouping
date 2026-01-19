.PHONY: install
install:
	@bundle

.PHONY: lint
lint:
	@bundle exec rubocop

.PHONY: test
test:
	@bundle exec ruby -e 'Dir["test/**/*_test.rb"].sort.each { |f| require_relative f }'
