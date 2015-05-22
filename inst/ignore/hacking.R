# put them together
# '.[] | {message: .message, name: .name}'
# '{"adf": 5}'
x <- '[{"message": "hello", "name": "jenn"}, {"message": "world", "name": "beth"}]'

x %>%
  index() %>%
  select(message = .message, name = .name)

x %>% index() %>% dotstr("name") %>% peek
x %>% index() %>% dotstr("name") %>% jq
x %>% indexif() %>% jq
x %>% index() %>% length() %>% jq
x %>% index() %>% dotstr("name") %>% length() %>% jq
x %>% index() %>% select(name = .name) %>% jq
x %>% index() %>% del(.name) %>% jq
'[{"foo": 5, "bar": 7}, {"foo": [4,5]}]' %>% index %>% del(.bar) %>% jq
'[1,2,3,4]' %>% reverse %>% jq
'[a,b,c,d]' %>% reverse %>% jq
x %>% keys %>% jq
'{"abc": 1, "abcd": 2, "Foo": 3}' %>% keys %>% jq
'[42,3,35]' %>% keys %>% jq
'[[],{},1,"foo",null,true,false]' %>% index() %>% types(numbers) %>% jq
'[[],{},1,"foo",null,true,false]' %>% index() %>% types(numbers, strings, booleans) %>% jq


library("httr")
library("jsonlite")
out <- minify(content(GET('https://api.github.com/repos/stedolan/jq/commits?per_page=5'), "text"))

# jq '.'
out %>% dot() %>% jq
# out %>% jq(dot())
# jq '.[]'
out %>% index() %>% jq
# jq '.[0]'
out %>% index(0) %>% jq
# jq '.[1]'
out %>% index(1) %>% jq
# jq '.[0] | {message: .commit.message, name: .commit.committer.name}'
out %>% index(0) %>% select(message = .commit.message, name = .commit.committer.name) %>% jq
# jq '.[] | {message: .commit.message, name: .commit.committer.name}'
out %>% index() %>% select(message = .commit.message, name = .commit.committer.name) %>% jq
# jq '[.[] | {message: .commit.message, name: .commit.committer.name}]'
# not done yet, make fxn array()



