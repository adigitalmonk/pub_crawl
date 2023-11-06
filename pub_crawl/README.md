# Pub Crawl

Pub Crawl is a PubSub-supporting Key/Value store.

The server accepts four commands:

- `#peek <key>`
  - Look at the value of "key"
- `#pub <key> <data>`
  - Replace the value of "key" with the value of "data"
- `#sub <key>`
  - Subscribe to changes to "key"
- `#unsub <key>`
  - Unsubscribe to the changes for "key"


## Example

```
➜ telnet localhost 4040
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
#pub test some value
ok
#peek test
some value
#sub test some value
unknown_cmd
#sub test
ok
#pub test another value
ok
->updated test : some value -> another value
```

```
➜ telnet localhost 4040
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
#sub test
ok
->updated test : another value -> once more
```
