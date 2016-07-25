# Ruby and Shell scripts to do docker things

## Clean Registry

- Require : curl

Ruby script to keep only a specified number of tags history of all images into a registry, the others are untagged (only for Registry V1)

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
- With https :
```bash
./mirror-registry.rb --sourcehost example.com --destinationhost example.com --ssl
```
- With specific port (5000 by default, if not specified) :
```bash
./mirror-registry.rb --sourcehost example.com --sourceport 5009 --destinationhost example.com --destinationport 5005
```
