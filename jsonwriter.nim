import stringbuilder, json

const defaultCapacity = 512

type
  JsonWriter = ref object
    depth: int
    first: bool
    array: bool
    writer: StringBuilder

# Starts a root object
# Should only be called once
proc rootObj*(w: JsonWriter, fn: proc()) =
  w.writer.append('{')
  fn()
  w.writer.append('}')

# Starts the writing process by creating an array.
# Should only be called once
proc rootArray*(w: JsonWriter, fn: proc()) =
  w.array = true
  w.writer.append('[')
  fn()
  w.writer.append(']')

proc separator*(w: JsonWriter) {.inline.} =
  if not w.first:
    w.writer.append(',')
  else:
    w.first = false

# writes a standalone and escaped string
proc write*(w: JsonWriter, value: string) {.inline.} =
  if (w.array): w.separator()
  w.writer.append(escapeJson(value))

# Writes a key. The key is placed within quotes and ends
# with a colon
proc key*(w: JsonWriter, k: string) {.inline.} =
  w.separator()
  w.write(k)
  w.writer.append(':')

# Writes a key: value wher value is a number
proc write*[T: Ordinal|uint|uint64|float|float64|float32](w: JsonWriter, k: string, value: T) {.inline.} =
  w.key(k)
  w.writer.append($value)

# Writes a key: value where value is char
proc write*(w: JsonWriter, k: string, value: char) {.inline.} =
  w.key(k)
  w.write($value)

# Writes a key: value where value is a string
proc write*(w: JsonWriter, k: string, value: string) {.inline.} =
  w.key(k)
  w.write(value)

# Writes a key: value where value is a string array
proc write*[T](w: JsonWriter, k: string, values: openArray[T]) {.inline.} =
  w.key(k)
  w.writer.append('[')
  if values.len == 0: w.writer.append(']'); return
  w.write(values[0])
  for i in 1..<values.len:
    w.writer.append(',')
    w.write(values[i])
  w.writer.append(']')

# Writes a value
proc write*[T: Ordinal|uint|uint64|float|float64|float32](w: JsonWriter, value: T) {.inline.} =
  if (w.array): w.separator()
  w.writer.append($value)

# Writes a value
proc write*(w: JsonWriter, value: char) {.inline.} =
  w.write($value)

proc obj*(w: JsonWriter, k: string, fn: proc()) =
  w.key(k)
  w.first = true
  w.writer.append('{')
  fn()
  w.first = false
  w.writer.append('}')

proc array*(w: JsonWriter, k: string, fn: proc()) =
  w.key(k)
  w.array = true
  w.first = true
  w.writer.append('[')
  fn()
  w.array = false
  w.first = false
  w.writer.append(']')


# Creates a new string, see destroy for an efficient alternative
proc `$`*(w: JsonWriter): string {.inline.} = $w.writer


# Efficiently converts the writer into a string.
# using any jsonwriter method after a call to destry (including additional
# calls to destroy) will have undefined behavior to both the jsonwriter and the
# returned string.
proc destroy*(w: JsonWriter): string {.inline.} = w.writer.destroy

# Create a new stringbuilder with the specified, or default, capacity
proc newJsonWriter*(cap: int = defaultCapacity): JsonWriter =
  new(result)
  result.first = true
  result.writer = newStringBuilder(cap, linear(cap))
