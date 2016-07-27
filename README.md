# Ruby and Shell scripts to do docker things

## Clean Registry

### Ruby script to remove tags

- Require : curl

Ruby script to keep only a specified number of tags history of all images into a registry, the others are untagged (only for Registry V1)

### Shell script to clean files (from https://gist.github.com/kwk/c5443f2a1abcf0eb1eaa)

- Require : jq

Shell script to clean at an OS level, the images that are not anymore tagged by the registry (only for registry V1, who has not the delete image function from HTTP endpoint)

There is one variable to change, it correspond to the physical path on your server, where the registry store his images, as folder (on OS level). Inside this folder, you'll find two folders : images and repositories.

## Mirror Registry

- Require : docker-engine

Ruby script to move images from a registry, to another (only registry V1)
++ Now check the differences between the registries, before to launch the migration process

## Usage

### Clean

- Default use :
```bash
./clean-registry.rb -h example.com -n 5
```
- Dry-run use :
```bash
./clean-registry.rb -h example.com -n 5 --dry
```
- With https :
```bash
./clean-registry.rb -h example.com -n 5 --ssl
```
- With specific port (5000 by default, if not specified) :
```bash
./clean-registry.rb -h example.com -n 5 -p 5009
```

### Mirror

- Default use :
```bash
./mirror-registry.rb --sourcehost example.com --destinationhost example.com
```
- Dry-run use :
```bash
./mirror-registry.rb --sourcehost example.com --destinationhost example.com --dry
```
- With https :
```bash
./mirror-registry.rb --sourcehost example.com --destinationhost example.com --ssl
```
- With specific port (5000 by default, if not specified) :
```bash
./mirror-registry.rb --sourcehost example.com --sourceport 5009 --destinationhost example.com --destinationport 5005
```
