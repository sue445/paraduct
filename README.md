# Paraduct
[![Gem Version](https://badge.fury.io/rb/paraduct.svg)](http://badge.fury.io/rb/paraduct)
[![Build Status](https://travis-ci.org/sue445/paraduct.svg?branch=master)](https://travis-ci.org/sue445/paraduct)
[![Code Climate](https://codeclimate.com/github/sue445/paraduct/badges/gpa.svg)](https://codeclimate.com/github/sue445/paraduct)
[![Coverage Status](https://img.shields.io/coveralls/sue445/paraduct.svg)](https://coveralls.io/r/sue445/paraduct)
[![Dependency Status](https://gemnasium.com/sue445/paraduct.svg)](https://gemnasium.com/sue445/paraduct)

Paraduct (**parallel** + **parameterize** + **product**) is matrix test runner

[![Stories in Ready](https://badge.waffle.io/sue445/paraduct.svg?label=ready&title=Ready)](http://waffle.io/sue445/paraduct)

## Requirements
ruby 1.9+

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'paraduct'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install paraduct

## Usage
```bash
$ paraduct --help
Commands:
  paraduct generate        # generate .paraduct.yml
  paraduct help [COMMAND]  # Describe available commands or one specific command
  paraduct test            # run matrix test
```

### 1. Generate config file
```bash  
$ paraduct generate
      create  .paraduct.yml
```

### 2. Customize .paraduct.yml
```bash
$ vi .paraduct.yml
```

### 3. Run test
```bash
$ paraduct test
```

## Format
```yaml
script: |-
  echo "NAME1=${NAME1}, NAME2=${NAME2}"
work_dir: tmp/paraduct_workspace
variables:
  name1:
    - value1a
    - value1b
  name2:
    - value2a
    - value2b
max_threads: 4
```

### script
script to run

### work_dir
diretory to run

* own job is run under `work_dir/JOB_NAME`

### variables
Parameters to be combined

* key is capitalized (example. `name1` -> `NAME1`)
* JOB_NAME is generated with variables

name1   | name2   | JOB_NAME                      | current directory where the test is performed
------- | ------- | ----------------------------- | ---------------------------------------
value1a | value2a | NAME1_value1a_NAME2_value2a   | tmp/paraduct_workspace/NAME1_value1a_NAME2_value2a
value1a | value2b | NAME1_value1a_NAME2_value2b   | tmp/paraduct_workspace/NAME1_value1a_NAME2_value2b
value1b | value2a | NAME1_value1b_NAME2_value2a   | tmp/paraduct_workspace/NAME1_value1b_NAME2_value2a
value1b | value2b | NAME1_value1b_NAME2_value2b   | tmp/paraduct_workspace/NAME1_value1b_NAME2_value2b

### max_threads
maximum concurrent execution number of jobs

## Contributing

1. Fork it ( https://github.com/sue445/paraduct/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
