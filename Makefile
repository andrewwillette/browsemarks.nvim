.PHONY: test
TEST_DIR = spec
test:
	nvim --headless -c 'PlenaryBustedDirectory spec'
