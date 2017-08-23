# hURL

It's a link shortener thing.

## Deployment

hURL supports deployment with `docker` and `docker-compose`.

It should be as simple as cloning this repo and running `docker-compose up -d`.

This will create containers of a compiled hURL image networked with a Redis instance.

By default, it listens on port 7777. See the `docker-compose.yml` for more information.

## API

### `POST /` - Create a redirect

Returns the created redirect object.

#### JSON Body

key    | type       | required
-------|------------|---------
target | URI string | yes
code   | string     | no
ttl    | integer    | no

- `target` must be HTTPS scheme and the host must respond to a `HEAD` request, replying with an `200 OK` status code.
- `code` must not already be taken. If omitted, one will be generated.
- `code` length must not be longer than the compiled `MAX_CODE_LENGTH`.
- `ttl` must be within the compiled `MIN_TTL` and `MAX_TTL`. If omitted, a default will be provided.

#### JSON Body Example

```json
{
  "target": "https://github.com/z64/hURL",
  "code": "hurl",
  "ttl": 120
}
```

The redirect will live at `localhost:7777/hurl` until it expires.

### `GET /{code}` - Query redirect

Executes a redirect stored at the given `code` to its `target`.

If you provide the header `Accept: application/json`, you will get the stored object instead of being redirected.

> Note: If using Redis, viewing the redirect object counts as a use.

## Contributors

- [z64](https://github.com/z64) Zac Nowicki - creator, maintainer
