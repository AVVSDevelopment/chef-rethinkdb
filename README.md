rethinkdb Cookbook
==================
This cookbook provides you with the ability to install RethinkDB from package / source

Requirements
------------

* Tested on Ubuntu 12.04

#### packages
- `apt`

Attributes
----------

    default['rethinkdb']['install_method'] = 'package'
    default['rethinkdb']['version'] = '1.7.1'
    default['rethinkdb']['make_threads'] = node['cpu'] ? node['cpu']['total'].to_i : 1
    default['rethinkdb']['src_url'] = "http://download.rethinkdb.com/dist"
    default['rethinkdb']['dir'] = "/usr/local"
    
    default['rethinkdb']['instances'] = [  
        {      
          :name  => 'rethinkdb.yb.com',
          :user  => 'rethinkdb',
          :group => 'rethinkdb',
          :address => "all",
          :driverPort => 28015,
          :clusterPort => 29015,
          :portOffset => 0,
          :httpPort => 8080,
          :directory => "/opt/rethinkdb/rethinkdb.yb.com/data"
        }
    ]
            

Usage
-----
#### rethinkdb::default

```ruby
name 'rethinkdb'
description 'Rethinkdb - master'

default_attributes({
  
})

run_list(
  'recipe[rethinkdb]',
  'recipe[rethinkdb::start]'  
)
```

Contributing
------------


1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Authors: 

1. Vitaly Aminev (<v@aminev.me>) http://avvs.co
